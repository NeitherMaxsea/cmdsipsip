<template>
  <div class="p-6 space-y-4">
    <div class="rounded-2xl bg-gradient-to-r from-teal-600 via-emerald-600 to-cyan-600 p-5 text-white shadow-lg">
      <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <h2 class="text-2xl font-bold">Service Requests</h2>
          <p class="text-sm text-white/85">Review, archive, and manage customer requests.</p>
        </div>
        <button
          type="button"
          class="self-start rounded-lg bg-white/20 px-4 py-2 text-sm font-semibold hover:bg-white/30"
          @click="emit('refresh')"
        >
          Refresh
        </button>
      </div>
    </div>

    <div class="rounded-2xl border border-gray-100 bg-white p-3 shadow-sm">
      <div class="flex flex-col gap-3 lg:flex-row lg:items-center">
        <div class="flex flex-wrap gap-2">
          <button
            v-for="opt in statusFilters"
            :key="opt.value"
            type="button"
            class="rounded-full border px-3 py-1.5 text-xs font-semibold transition"
            :class="statusFilter === opt.value ? 'border-teal-600 bg-teal-600 text-white' : 'border-gray-300 bg-white text-gray-600 hover:bg-gray-50'"
            @click="statusFilter = opt.value"
          >
            {{ opt.label }}
          </button>
        </div>
        <input
          v-model.trim="searchText"
          type="text"
          placeholder="Search customer or service..."
          class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-teal-500 focus:ring-2 focus:ring-teal-100 lg:ml-auto lg:w-80"
        />
        <label class="inline-flex items-center gap-2 text-sm text-gray-700">
          <input v-model="showArchived" type="checkbox" class="h-4 w-4 rounded border-gray-300 text-teal-600 focus:ring-teal-500" />
          Show archived
        </label>
      </div>
      <div class="mt-3 flex flex-wrap gap-2">
        <button type="button" class="rounded-lg border border-gray-300 bg-white px-3 py-1.5 text-xs font-semibold text-gray-700 hover:bg-gray-50" @click="selectAll">
          Select all
        </button>
        <button type="button" class="rounded-lg border border-gray-300 bg-white px-3 py-1.5 text-xs font-semibold text-gray-700 hover:bg-gray-50" @click="clearSelection">
          Clear selection
        </button>
        <button
          type="button"
          class="rounded-lg px-3 py-1.5 text-xs font-semibold text-white"
          :class="selectedIds.length ? 'bg-rose-600 hover:bg-rose-700' : 'bg-gray-300 cursor-not-allowed'"
          :disabled="!selectedIds.length"
          @click="archiveSelected"
        >
          Archive selected ({{ selectedIds.length }})
        </button>
      </div>
    </div>

    <div v-if="loading" class="rounded-2xl border border-gray-100 bg-white p-6 text-gray-500 shadow-sm">
      Loading requests...
    </div>

    <div v-else-if="filteredRequests.length === 0" class="rounded-2xl border border-dashed border-gray-300 bg-white p-8 text-center text-gray-500 shadow-sm">
      No service requests matched your filters.
    </div>

    <div v-else class="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
      <table class="min-w-full text-sm">
        <thead class="border-b bg-gray-50 text-xs uppercase text-gray-500">
          <tr>
            <th class="px-4 py-3 text-left">
              <input
                type="checkbox"
                class="h-4 w-4 rounded border-gray-300 text-teal-600 focus:ring-teal-500"
                :checked="allVisibleSelected"
                @change="toggleSelectAllVisible"
              />
            </th>
            <th class="px-4 py-3 text-left">User</th>
            <th class="px-4 py-3 text-left">Service</th>
            <th class="px-4 py-3 text-left">Status</th>
            <th class="px-4 py-3 text-right">Action</th>
          </tr>
        </thead>
        <tbody class="divide-y">
          <tr v-for="req in filteredRequests" :key="req.id" class="transition hover:bg-gray-50/60">
            <td class="px-4 py-3">
              <input
                v-if="canArchive(req)"
                type="checkbox"
                class="h-4 w-4 rounded border-gray-300 text-teal-600 focus:ring-teal-500"
                :checked="selectedIds.includes(req.id)"
                @change="toggleSelect(req.id)"
              />
            </td>
            <td class="px-4 py-3 font-medium text-gray-800">
              <div class="flex items-center gap-3">
                <div class="flex h-9 w-9 items-center justify-center rounded-full bg-sky-50 font-semibold text-sky-700">
                  {{ (req.user_name || '?').slice(0, 1).toUpperCase() }}
                </div>
                <div>
                  <div class="font-semibold text-gray-800">{{ req.user_name }}</div>
                  <div class="text-xs text-gray-400">Customer</div>
                </div>
              </div>
            </td>
            <td class="px-4 py-3 text-gray-600">
              <div class="font-medium text-gray-700">{{ req.service_name }}</div>
              <div class="text-xs text-gray-500 mt-0.5">Payment: {{ paymentMethodLabel(req.payment_method) }}</div>
            </td>
            <td class="px-4 py-3">
              <div class="flex items-center gap-2">
                <span class="rounded-full px-2.5 py-1 text-xs font-semibold capitalize" :class="statusClass(req.status)">
                  {{ req.status }}
                </span>
                <span v-if="req.archived_at" class="rounded-full bg-rose-100 px-2 py-0.5 text-[11px] font-semibold text-rose-700">
                  Archived
                </span>
              </div>
            </td>
            <td class="px-4 py-3 text-right">
              <div class="flex items-center justify-end gap-2">
                <button
                  type="button"
                  class="rounded-lg bg-sky-50 px-3 py-1.5 text-xs font-semibold text-sky-700 transition hover:bg-sky-100"
                  @click="openView(req)"
                >
                  View
                </button>
                <button
                  v-if="canArchive(req) && !req.archived_at"
                  type="button"
                  class="rounded-lg bg-rose-50 px-3 py-1.5 text-xs font-semibold text-rose-700 transition hover:bg-rose-100"
                  @click="archiveOne(req)"
                >
                  Archive
                </button>
                <button
                  v-if="req.archived_at"
                  type="button"
                  class="rounded-lg bg-emerald-50 px-3 py-1.5 text-xs font-semibold text-emerald-700 transition hover:bg-emerald-100"
                  @click="restoreOne(req)"
                >
                  Restore
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4 py-6">
      <div class="relative w-full max-w-3xl max-h-[88vh] overflow-y-auto rounded-2xl bg-white p-6 shadow-lg">
        <button class="absolute right-4 top-3 text-xl text-gray-400 hover:text-gray-700" @click="closeModal">
          &times;
        </button>

        <h3 class="mb-4 text-xl font-bold text-gray-800">Service Request Details</h3>

        <div class="grid grid-cols-1 gap-4 text-gray-700 sm:grid-cols-2">
          <div class="rounded-lg border bg-gray-50 p-3">
            <p class="mb-1 text-xs text-gray-500">User</p>
            <p class="font-semibold">{{ selected.user_name }}</p>
          </div>
          <div class="rounded-lg border bg-gray-50 p-3">
            <p class="mb-1 text-xs text-gray-500">Service</p>
            <p class="font-semibold">{{ selected.service_name }}</p>
          </div>
          <div class="rounded-lg border bg-gray-50 p-3">
            <p class="mb-1 text-xs text-gray-500">Contact Number</p>
            <p class="font-semibold">{{ displayContactNumber(selected.contact_number) }}</p>
          </div>
          <div class="rounded-lg border bg-gray-50 p-3">
            <p class="mb-1 text-xs text-gray-500">Address</p>
            <p class="font-semibold">{{ selected.address_text || '-' }}</p>
          </div>
          <div class="rounded-lg border bg-gray-50 p-3">
            <p class="mb-1 text-xs text-gray-500">Status</p>
            <p class="font-semibold capitalize">{{ selected.status }}</p>
          </div>
          <div class="rounded-lg border bg-gray-50 p-3">
            <p class="mb-1 text-xs text-gray-500">Preferred Date</p>
            <p class="font-semibold">{{ selected.preferred_date || '-' }}</p>
          </div>
          <div class="rounded-lg border bg-gray-50 p-3">
            <p class="mb-1 text-xs text-gray-500">Service Time</p>
            <p class="font-semibold">{{ serviceTimeLabel(selected) }}</p>
          </div>
          <div v-if="selected.latest_invoice" class="rounded-lg border bg-sky-50 p-3 sm:col-span-2">
            <p class="mb-2 text-xs text-gray-500">Latest Invoice</p>
            <div class="grid grid-cols-1 gap-2 sm:grid-cols-2">
              <p><strong>Ref:</strong> {{ selected.latest_invoice.reference || '-' }}</p>
              <p><strong>Phase:</strong> {{ normalizeValue(selected.latest_invoice.phase) }}</p>
              <p><strong>Status:</strong> <span class="capitalize">{{ normalizeValue(selected.latest_invoice.status) }}</span></p>
              <p><strong>Amount:</strong> {{ invoiceAmountLabel(selected) }}</p>
              <p><strong>Due:</strong> {{ formatDate(selected.latest_invoice.due_at) }}</p>
              <p><strong>Paid:</strong> {{ formatDate(selected.latest_invoice.paid_at) }}</p>
            </div>
            <div v-if="selected.latest_invoice.invoice_url && canShowInvoiceAmount(selected)" class="mt-3">
              <a
                :href="selected.latest_invoice.invoice_url"
                target="_blank"
                rel="noopener"
                class="inline-flex rounded-md bg-sky-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-sky-700"
              >
                Open Invoice Link
              </a>
            </div>
          </div>
          <div v-if="selected.details" class="rounded-lg border bg-slate-50 p-3 sm:col-span-2">
            <p class="mb-1 text-xs text-gray-500">Details</p>
            <div class="space-y-2">
              <div v-if="extractDetailFields(selected.details).length" class="grid grid-cols-1 gap-2 sm:grid-cols-2">
                <div
                  v-for="item in extractDetailFields(selected.details)"
                  :key="item.key"
                  class="rounded-lg border bg-white p-2.5"
                >
                  <p class="mb-1 text-[11px] uppercase tracking-wide text-gray-500">{{ item.label }}</p>
                  <p class="text-sm font-semibold text-gray-800">{{ item.value }}</p>
                </div>
              </div>
              <div class="rounded-lg border bg-white p-2.5">
                <p class="mb-1 text-[11px] uppercase tracking-wide text-gray-500">Customer Note</p>
                <div class="max-h-28 overflow-y-auto rounded-md border border-slate-200 bg-slate-50 px-2.5 py-2">
                  <p class="text-sm font-semibold leading-relaxed text-gray-800 whitespace-pre-wrap break-words">
                    {{ extractDetailNote(selected.details) }}
                  </p>
                </div>
              </div>
            </div>
          </div>
          <div class="rounded-lg border border-cyan-200 bg-cyan-50 p-3 sm:col-span-2">
            <div class="mb-1 flex items-center justify-between gap-3">
              <p class="text-xs font-semibold uppercase tracking-wide text-cyan-700">Geo Map Route</p>
              <a
                v-if="detailOpenRouteUrl"
                :href="detailOpenRouteUrl"
                target="_blank"
                rel="noopener"
                class="text-xs font-semibold text-teal-700 hover:underline"
              >
                Open Route
              </a>
            </div>
            <p class="text-[11px] text-slate-600">{{ detailMapStatus }}</p>
            <div v-if="hasDetailMapRoute(selected)" class="mt-2 h-[190px] overflow-hidden rounded-lg border border-cyan-200">
              <div id="business-service-request-map" class="h-full w-full"></div>
            </div>
            <p v-else class="mt-2 text-xs text-slate-500">Map route unavailable because coordinates are missing.</p>
          </div>
        </div>

        <div v-if="normalizeStatus(selected.status) === 'pending'" class="mt-6 flex justify-end gap-3">
          <button
            @click="handleApprove"
            class="inline-flex items-center rounded-lg bg-gradient-to-r from-emerald-600 to-teal-600 px-5 py-2 text-sm font-bold text-white shadow-md transition hover:-translate-y-0.5 hover:from-emerald-700 hover:to-teal-700"
          >
            Approve
          </button>
          <button
            @click="handleReject"
            class="inline-flex items-center rounded-lg bg-gradient-to-r from-rose-600 to-pink-600 px-5 py-2 text-sm font-bold text-white shadow-md transition hover:-translate-y-0.5 hover:from-rose-700 hover:to-pink-700"
          >
            Reject
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, nextTick, onBeforeUnmount } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import L from 'leaflet'

const props = defineProps({
  requests: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
})

const emit = defineEmits(['refresh'])

const showModal = ref(false)
const selected = ref({})
const detailMapStatus = ref('')
const detailOpenRouteUrl = ref('')
const selectedIds = ref([])
const showArchived = ref(false)
const statusFilter = ref('all')
const searchText = ref('')
let detailMap = null

const statusFilters = [
  { value: 'all', label: 'All' },
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
  { value: 'completed', label: 'Completed' },
]

const normalizeStatus = (value) => String(value || '').trim().toLowerCase()

const statusClass = (status) => {
  const s = normalizeStatus(status)
  if (s === 'pending') return 'bg-amber-50 text-amber-700'
  if (s === 'approved' || s === 'accepted') return 'bg-emerald-50 text-emerald-700'
  if (s === 'assigned' || s === 'in_progress') return 'bg-sky-50 text-sky-700'
  if (s === 'completed') return 'bg-teal-50 text-teal-700'
  if (s === 'rejected') return 'bg-rose-50 text-rose-700'
  if (s === 'cancelled') return 'bg-slate-100 text-slate-700'
  return 'bg-gray-100 text-gray-700'
}

const requestList = computed(() =>
  (props.requests || []).map((r) => ({
    ...r,
    user_name: r.user_name || `${r.user?.first_name || ''} ${r.user?.middle_initial ? `${r.user.middle_initial}. ` : ''}${r.user?.last_name || ''}`.trim(),
    service_name: r.service_name || r.service_type || r.category || 'N/A',
    details: r.details || r.notes || '',
    contact_number: r.contact_number || r.user?.contact_number || '',
    address_text: r.address_text || r.address || '',
    preferred_date: r.preferred_date || '',
    service_time: r.service_time || '',
    payment_method: r.payment_method || '',
    payment_channel: r.payment_channel || r.latest_invoice?.payment_channel || '',
    payment_status: r.payment_status || '',
    total_amount: Number(r.total_amount || 0),
    downpayment_amount: Number(r.downpayment_amount || 0),
    final_amount: Number(r.final_amount || 0),
    latitude: r.latitude ?? r.user_latitude ?? null,
    longitude: r.longitude ?? r.user_longitude ?? null,
    business_latitude: r.business_latitude ?? r.business?.latitude ?? r.business?.business_latitude ?? null,
    business_longitude: r.business_longitude ?? r.business?.longitude ?? r.business?.business_longitude ?? null,
    latest_invoice: r.latest_invoice || null,
    invoices: Array.isArray(r.invoices) ? r.invoices : [],
  }))
)

const paymentMethodLabel = (method) => {
  const m = String(method || '').toLowerCase().trim()
  if (m === 'downpayment') return 'Downpayment'
  if (m === 'full' || m === 'personal') return 'Full Payment'
  return 'N/A'
}

const visibleRequests = computed(() =>
  requestList.value.filter((r) => (showArchived.value ? !!r.archived_at : !r.archived_at))
)

const filteredRequests = computed(() => {
  const keyword = searchText.value.toLowerCase()
  return visibleRequests.value.filter((r) => {
    const s = normalizeStatus(r.status)
    if (statusFilter.value !== 'all' && s !== statusFilter.value) return false
    if (!keyword) return true
    return (
      String(r.user_name || '').toLowerCase().includes(keyword) ||
      String(r.service_name || '').toLowerCase().includes(keyword)
    )
  })
})

const canArchive = (r) => {
  const s = normalizeStatus(r?.status)
  return ['rejected', 'completed', 'cancelled'].includes(s)
}

const allVisibleSelected = computed(() => {
  const ids = filteredRequests.value.filter((r) => canArchive(r) && !r.archived_at).map((r) => r.id)
  if (!ids.length) return false
  return ids.every((id) => selectedIds.value.includes(id))
})

const toggleSelect = (id) => {
  if (selectedIds.value.includes(id)) {
    selectedIds.value = selectedIds.value.filter((x) => x !== id)
    return
  }
  selectedIds.value = [...selectedIds.value, id]
}

const toggleSelectAllVisible = () => {
  const ids = filteredRequests.value.filter((r) => canArchive(r) && !r.archived_at).map((r) => r.id)
  if (!ids.length) return
  if (allVisibleSelected.value) {
    selectedIds.value = selectedIds.value.filter((id) => !ids.includes(id))
    return
  }
  selectedIds.value = [...new Set([...selectedIds.value, ...ids])]
}

const selectAll = () => {
  const ids = requestList.value.filter((r) => canArchive(r) && !r.archived_at).map((r) => r.id)
  selectedIds.value = [...new Set([...selectedIds.value, ...ids])]
}

const clearSelection = () => {
  selectedIds.value = []
}

const archiveOne = async (req) => {
  const confirm = await Swal.fire({
    title: 'Archive this request?',
    text: 'Archived requests can be restored later.',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Archive',
  })
  if (!confirm.isConfirmed) return

  try {
    await axios.post(`/business/service-requests/${req.id}/archive`)
    emit('refresh')
    Swal.fire('Archived', 'Request archived.', 'success')
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to archive request.', 'error')
  }
}

const archiveSelected = async () => {
  const ids = [...new Set(selectedIds.value)]
  if (!ids.length) return
  const confirm = await Swal.fire({
    title: `Archive ${ids.length} request(s)?`,
    text: 'Archived requests can be restored later.',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Archive selected',
  })
  if (!confirm.isConfirmed) return

  try {
    await Promise.all(ids.map((id) => axios.post(`/business/service-requests/${id}/archive`)))
    selectedIds.value = []
    emit('refresh')
    Swal.fire('Archived', `${ids.length} request(s) archived.`, 'success')
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to archive selected requests.', 'error')
  }
}

const restoreOne = async (req) => {
  try {
    await axios.post(`/business/service-requests/${req.id}/restore`)
    emit('refresh')
    Swal.fire('Restored', 'Request restored.', 'success')
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to restore request.', 'error')
  }
}

const openView = (req) => {
  selected.value = { ...req }
  showModal.value = true
  renderDetailMap()
}

const closeModal = () => {
  destroyDetailMap()
  detailMapStatus.value = ''
  detailOpenRouteUrl.value = ''
  showModal.value = false
  selected.value = {}
}

onBeforeUnmount(() => {
  destroyDetailMap()
})

const normalizeValue = (value) => {
  if (value === null || value === undefined || value === '') return '-'
  return String(value).replaceAll('_', ' ')
}

const extractTaggedTime = (details) => {
  const text = String(details || '')
  const match = text.match(/\[TIME:\s*([^\]]+)\]/i)
  return match?.[1]?.trim() || ''
}

const formatTimeValue = (value) => {
  const raw = String(value || '').trim()
  if (!raw) return ''
  const compact = raw.toUpperCase()
  const hhmm = compact.match(/^(\d{1,2}):(\d{2})$/)
  if (hhmm) {
    const hours = Number(hhmm[1])
    const minutes = Number(hhmm[2])
    if (hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59) {
      const suffix = hours >= 12 ? 'PM' : 'AM'
      const h12 = hours % 12 || 12
      return `${h12}:${String(minutes).padStart(2, '0')} ${suffix}`
    }
  }
  return raw
}

const serviceTimeLabel = (req) => {
  const raw = req?.service_time || extractTaggedTime(req?.details)
  const formatted = formatTimeValue(raw)
  return formatted || '-'
}

const displayContactNumber = (value) => {
  const raw = String(value ?? '').trim()
  if (!raw) return '-'
  const digits = raw.replace(/\D/g, '')
  if (!digits) return raw
  if (digits.startsWith('63') && digits.length >= 11) return `0${digits.slice(2)}`
  if (digits.startsWith('9') && digits.length === 10) return `0${digits}`
  if (digits.startsWith('0')) return digits
  return raw
}

const toFiniteNumber = (value) => {
  if (value === null || value === undefined) return null
  const raw = String(value).trim()
  if (!raw) return null
  const n = Number(raw)
  return Number.isFinite(n) ? n : null
}

const detailRouteCoords = (req) => {
  const fromLat = toFiniteNumber(req?.latitude)
  const fromLng = toFiniteNumber(req?.longitude)
  const toLat = toFiniteNumber(req?.business_latitude)
  const toLng = toFiniteNumber(req?.business_longitude)
  return { fromLat, fromLng, toLat, toLng, canRoute: fromLat !== null && fromLng !== null && toLat !== null && toLng !== null }
}

const hasDetailMapRoute = (req) => detailRouteCoords(req).canRoute

const distanceBetweenKm = (lat1, lng1, lat2, lng2) => {
  const toRadians = (value) => (value * Math.PI) / 180
  const earthRadiusKm = 6371
  const deltaLat = toRadians(lat2 - lat1)
  const deltaLng = toRadians(lng2 - lng1)
  const originLat = toRadians(lat1)
  const destinationLat = toRadians(lat2)
  const haversine = (Math.sin(deltaLat / 2) ** 2)
    + (Math.cos(originLat) * Math.cos(destinationLat) * (Math.sin(deltaLng / 2) ** 2))
  const centralAngle = 2 * Math.atan2(Math.sqrt(haversine), Math.sqrt(1 - haversine))
  return Math.max(0, earthRadiusKm * centralAngle)
}

const destroyDetailMap = () => {
  if (detailMap) {
    detailMap.remove()
    detailMap = null
  }
}

const renderDetailMap = async () => {
  await nextTick()
  destroyDetailMap()

  const coords = detailRouteCoords(selected.value)
  if (!coords.canRoute) {
    detailOpenRouteUrl.value = ''
    detailMapStatus.value = 'Coordinates missing for this request route.'
    return
  }

  detailOpenRouteUrl.value = `https://www.google.com/maps/dir/?api=1&origin=${encodeURIComponent(`${coords.fromLat},${coords.fromLng}`)}&destination=${encodeURIComponent(`${coords.toLat},${coords.toLng}`)}&travelmode=driving`
  detailMapStatus.value = `Approx. ${distanceBetweenKm(coords.fromLat, coords.fromLng, coords.toLat, coords.toLng).toFixed(2)} km from customer to business.`

  const host = document.getElementById('business-service-request-map')
  if (!host) return

  detailMap = L.map(host, { zoomControl: true, attributionControl: false })
  L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
    maxZoom: 19,
    subdomains: 'abcd',
  }).addTo(detailMap)

  try {
    const response = await axios.get('/user/route-preview', {
      params: {
        from_lat: coords.fromLat,
        from_lng: coords.fromLng,
        to_lat: coords.toLat,
        to_lng: coords.toLng,
      },
      timeout: 9000,
    })

    const latLngs = Array.isArray(response?.data?.points)
      ? response.data.points
        .map((point) => [Number(point?.[0]), Number(point?.[1])])
        .filter((point) => Number.isFinite(point[0]) && Number.isFinite(point[1]))
      : []

    if (!latLngs.length) throw new Error('Invalid route response')

    const routeLine = L.polyline(latLngs, {
      color: '#2563eb',
      weight: 5,
      opacity: 0.95,
      lineCap: 'round',
      lineJoin: 'round',
    }).addTo(detailMap)
    detailMap.fitBounds(routeLine.getBounds(), { padding: [24, 24] })

    const routeDistanceKm = Number(response?.data?.distance_km)
    if (Number.isFinite(routeDistanceKm) && routeDistanceKm > 0) {
      detailMapStatus.value = `Approx. ${routeDistanceKm.toFixed(2)} km from customer to business.`
    }
  } catch {
    detailMap.setView([coords.fromLat, coords.fromLng], 14)
    detailMapStatus.value = 'Road route unavailable right now. Please use Open Route for navigation.'
  }

  setTimeout(() => detailMap?.invalidateSize?.(), 40)
}

const money = (value, currency = 'PHP') => {
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: currency || 'PHP' }).format(Number(value || 0))
}

const requestServiceTrack = (req) => {
  const raw = String(req?.service_track || req?.service_type || req?.service_name || '').trim().toLowerCase()
  if (/(siphon|septic|desludg|vacuum|jetter)/.test(raw)) return 'siphoning'
  return raw
}

const inspectionBillingNotice = 'Inspection required before final billing'

const hasCompletedInspection = (req) => {
  const result = String(req?.inspection_result || '').trim().toLowerCase()
  if (['minor', 'major'].includes(result)) return true
  const status = String(req?.status || '').trim().toLowerCase()
  return ['completed', 'warranty_pending', 'warranty_rework'].includes(status)
}

const isInspectionBillingRequired = (req) => requestServiceTrack(req) === 'siphoning'

const canShowInvoiceAmount = (req) => {
  if (!isInspectionBillingRequired(req)) return true
  if (hasCompletedInspection(req)) return true
  const phase = String(req?.latest_invoice?.phase || '').trim().toLowerCase()
  const paymentMethod = String(req?.payment_method || '').trim().toLowerCase()
  return phase === 'downpayment' || paymentMethod === 'downpayment'
}

const invoiceAmountLabel = (req) => {
  if (!canShowInvoiceAmount(req)) return inspectionBillingNotice
  const amount = Number(req?.latest_invoice?.amount)
  if (Number.isFinite(amount) && amount > 0) return money(amount, req?.latest_invoice?.currency)
  const fallback = Number(req?.final_amount || req?.total_amount || 0)
  if (Number.isFinite(fallback) && fallback > 0) return money(fallback, req?.latest_invoice?.currency)
  return 'N/A'
}

const formatDate = (value) => {
  if (!value) return '-'
  const dt = new Date(value)
  if (Number.isNaN(dt.getTime())) return '-'
  return dt.toLocaleString('en-PH', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  })
}

const paymentStatusLabel = (req) => {
  const method = normalizeStatus(req?.payment_method)
  const reqStatus = normalizeStatus(req?.payment_status)
  const invStatus = normalizeStatus(req?.latest_invoice?.status)
  const invoices = Array.isArray(req?.invoices) ? req.invoices : []
  const hasFinalPaid = invoices.some((inv) => normalizeStatus(inv.phase) === 'final' && normalizeStatus(inv.status) === 'paid')
  const hasDownpaymentPaid = invoices.some((inv) => normalizeStatus(inv.phase) === 'downpayment' && normalizeStatus(inv.status) === 'paid')
  const hasAnyPaid = invoices.some((inv) => normalizeStatus(inv.status) === 'paid')

  if (method === 'downpayment') {
    if (hasFinalPaid) return 'Fully Paid'
    if (reqStatus === 'partial_paid' || hasDownpaymentPaid || (hasAnyPaid && !hasFinalPaid)) return 'Downpayment Paid (Partial)'
    if (invStatus === 'pending' || reqStatus === 'unpaid' || !reqStatus) return 'Downpayment Pending'
    if (invStatus === 'expired') return 'Downpayment Expired'
    if (invStatus === 'failed') return 'Downpayment Failed'
    return 'Downpayment Pending'
  }

  if (reqStatus === 'paid') return 'Paid'
  if (reqStatus === 'unpaid') return 'Unpaid'
  if (reqStatus) return normalizeValue(reqStatus)
  return 'Pending'
}

const extractDetailFields = (details) => {
  const text = String(details || '')
  const map = [
    { key: 'payment_type', label: 'Payment Type', regex: /Payment Type:\s*([^]+?)(?=Payment Channel:|Downpayment Terms:|$)/i },
    { key: 'payment_channel', label: 'Payment Channel', regex: /Payment Channel:\s*([^]+?)(?=Payment Type:|Downpayment Terms:|$)/i },
    { key: 'downpayment_terms', label: 'Downpayment Terms', regex: /Downpayment Terms:\s*([^]+?)(?=Payment Type:|Payment Channel:|$)/i },
  ]

  return map
    .map((item) => {
      const match = text.match(item.regex)
      return {
        key: item.key,
        label: item.label,
        value: match ? normalizeValue(match[1].trim()) : '',
      }
    })
    .filter((item) => item.value && item.value !== '-')
}

const extractDetailNote = (details) => {
  const text = String(details || '').trim()
  if (!text) return '-'

  let cleaned = text
    .replace(/\[TEAM-REQUEST\]/ig, '')
    .replace(/\[TEAM:[^\]]+\]/ig, '')
    .replace(/\[DATE:[^\]]+\]/ig, '')
    .replace(/\[TIME:[^\]]+\]/ig, '')
    .replace(/\[ROUTED_TO:[^\]]+\]/ig, '')
    .replace(/\[TEAM_TYPE:[^\]]+\]/ig, '')
    .replace(/\[(?:PAYMENT|ESTIMATE|DISTANCE_KM|URGENCY|COMPLEXITY|PRICING_SERVICE|PRICING_DISTANCE_KM|PRICING_COMPLEXITY|PRICING_URGENCY|PRICING_TOTAL):[^\]]+\]/ig, '')
    .replace(/\[[A-Z0-9_ -]+:[^\]]+\]/ig, '')
    .replace(/Payment Type:\s*([^]+?)(?=Payment Channel:|Downpayment Terms:|$)/gi, '')
    .replace(/Payment Channel:\s*([^]+?)(?=Payment Type:|Downpayment Terms:|$)/gi, '')
    .replace(/Downpayment Terms:\s*([^]+?)(?=Payment Type:|Payment Channel:|$)/gi, '')
    .replace(/\s+/g, ' ')
    .trim()

  if (!cleaned) {
    cleaned = 'No additional customer note.'
  }

  return cleaned
}

const reviewRequest = async ({ id, action, reason = null, showSuccess = true }) => {
  try {
    const payload = { action }
    if (action === 'reject') payload.reason = reason
    await axios.post(`/business/service-requests/${id}/review`, payload)
    if (showSuccess) Swal.fire('Success', 'Request updated', 'success')
    emit('refresh')
  } catch (err) {
    if (err.response?.status === 404) {
      emit('refresh')
      return
    }
    Swal.fire('Error', err.response?.data?.message || 'Validation error', 'error')
  }
}

const handleApprove = async () => {
  const confirm = await Swal.fire({
    title: 'Approve this request?',
    text: 'The request will be marked as approved.',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Yes, approve',
  })
  if (!confirm.isConfirmed) return

  await reviewRequest({ id: selected.value.id, action: 'approve' })
  closeModal()
}

const handleReject = async () => {
  const { value: reason } = await Swal.fire({
    title: 'Reject request',
    input: 'textarea',
    inputLabel: 'Reason for rejection',
    inputPlaceholder: 'Type reason here...',
    showCancelButton: true,
    inputValidator: (val) => (!val?.trim() ? 'Reason is required' : null),
  })
  if (!reason) return

  const confirm = await Swal.fire({
    title: 'Are you sure?',
    text: 'This will reject the request and notify the user.',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Yes, reject',
  })
  if (!confirm.isConfirmed) return

  await reviewRequest({ id: selected.value.id, action: 'reject', reason: reason.trim() })
  closeModal()
}
</script>

