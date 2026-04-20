<template>
  <div class="min-h-screen flex flex-col bg-gray-100">
    <nav class="bg-white/90 backdrop-blur border-b border-gray-100 px-6 py-4 flex justify-between items-center sticky top-0 z-40">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-2xl bg-gradient-to-br from-teal-400 to-emerald-500 text-white flex items-center justify-center font-bold shadow-sm">
          I
        </div>
        <div>
          <h1 class="text-xl font-bold text-gray-800 tracking-tight">Individual Business</h1>
          <p class="text-xs text-gray-500">Owner-managed operations (no HR)</p>
        </div>
      </div>
      <div class="flex items-center gap-3">
        <WorkspaceNotificationBell />
        <div class="relative business-profile-wrap">
          <button
            type="button"
            class="flex h-[38px] min-w-[38px] items-center gap-2 rounded-full border border-slate-200 bg-white px-2.5 text-slate-700 transition-all hover:bg-slate-50 hover:text-slate-900"
            aria-label="Profile menu"
            @click="toggleProfileMenu"
          >
            <span class="inline-flex h-7 w-7 items-center justify-center rounded-full bg-teal-600 text-[11px] font-bold text-white">
              {{ profileInitials }}
            </span>
            <span class="hidden text-xs font-semibold sm:inline">Profile</span>
          </button>
          <div
            v-if="showProfileMenu"
            class="absolute right-0 z-40 mt-2 w-44 rounded-xl border border-slate-200 bg-white py-1 shadow-[0_12px_30px_rgba(15,23,42,0.14)]"
          >
            <button
              type="button"
              class="w-full px-4 py-2 text-left text-sm text-slate-700 hover:bg-slate-50"
              @click="openProfile"
            >
              Profile
            </button>
            <button
              type="button"
              class="w-full px-4 py-2 text-left text-sm text-rose-600 hover:bg-rose-50"
              @click="confirmLogout"
            >
              Logout
            </button>
          </div>
        </div>
      </div>
    </nav>

    <div class="flex flex-1">
      <aside class="w-64 bg-white p-6 border-r border-gray-100">
        <p class="text-xs uppercase tracking-wide text-gray-400 mb-4">Individual Mode</p>
        <ul class="space-y-2">
          <li v-for="item in navItems" :key="item.key">
            <Link
              :href="item.href"
              class="px-3 py-2 rounded-xl flex items-center gap-3"
              :class="activeSection===item.key ? 'font-bold text-teal-700 bg-teal-50' : 'text-gray-600 hover:text-teal-700 hover:bg-teal-50'"
            >
              <span class="w-8 h-8 rounded-lg bg-teal-50 text-teal-700 inline-flex items-center justify-center text-xs font-bold">{{ item.icon }}</span>
              <span>{{ item.label }}</span>
            </Link>
          </li>
        </ul>
      </aside>

      <main class="flex-1 p-6">
        <div v-if="!isIndividualBusiness" class="bg-white rounded-2xl p-6 shadow text-gray-700">
          This account is not `Individual` type. Redirecting to Business Dashboard...
        </div>

        <section v-else-if="activeSection==='overview'" class="space-y-4">
          <div class="rounded-2xl bg-gradient-to-r from-teal-600 via-emerald-600 to-cyan-600 p-5 text-white shadow-lg">
            <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <h2 class="text-2xl font-bold">Individual Overview</h2>
                <p class="text-sm text-white/85">Key owner metrics and assignment health.</p>
                <p class="text-xs text-white/75 mt-1">Last Updated: {{ lastUpdatedLabel }}</p>
              </div>
              <button
                type="button"
                class="self-start rounded-lg bg-white/20 px-4 py-2 text-sm font-semibold hover:bg-white/30 disabled:cursor-not-allowed disabled:opacity-60"
                :disabled="exportingKpi"
                @click="exportKpiCsv"
              >
                {{ exportingKpi ? 'Exporting...' : 'Export KPI CSV' }}
              </button>
            </div>
          </div>
          <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
            <MetricCard title="Avg Assign Time" :value="`${individualKpis.avg_assign_minutes} mins`" />
            <MetricCard title="Completion Rate" :value="`${individualKpis.completion_rate}%`" />
            <MetricCard title="Waiting Queue" :value="individualKpis.waiting_for_assignment" />
            <MetricCard title="Needs Attention" :value="individualKpis.sla_breaches" />
          </div>
          <div v-if="individualKpis.sla_breaches > 0" class="rounded-xl border border-amber-300 bg-amber-50 p-3 text-sm text-amber-800">
            {{ individualKpis.sla_breaches }} request(s) exceeded SLA threshold of {{ businessContext.sla_threshold_minutes }} minutes.
          </div>
          <div class="rounded-2xl bg-white p-5 shadow-sm">
            <div class="mb-3 flex items-center justify-between">
              <h3 class="text-lg font-semibold text-gray-800">Recent Assignment Activity</h3>
              <button type="button" class="rounded-lg bg-teal-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-teal-700" @click="fetchAssignmentAuditLogs">
                Refresh Logs
              </button>
            </div>
            <div v-if="loadingAuditLogs" class="text-sm text-gray-500">Loading assignment logs...</div>
            <div v-else-if="!assignmentAuditLogs.length" class="text-sm text-gray-500">No assignment activity yet.</div>
            <div v-else class="space-y-2">
              <div
                v-for="log in assignmentAuditLogs"
                :key="log.id"
                class="rounded-lg border border-gray-200 bg-gray-50 px-3 py-2"
              >
                <p class="text-sm font-semibold text-gray-800">
                  Request #{{ log.service_request_id }} - {{ log.provider_name || ('Provider #' + (log.service_provider_id || 'N/A')) }}
                </p>
                <p class="text-xs text-gray-600">
                  {{ log.assignment_mode === 'auto' ? 'Auto' : 'Manual' }} via {{ log.assignment_source }} by {{ log.assigned_by_name || 'System' }}
                  <span class="text-gray-500">on {{ formatDateTime(log.created_at) }}</span>
                </p>
              </div>
            </div>
          </div>
        </section>

        <section v-else-if="activeSection==='requests'" class="space-y-4">
          <div class="rounded-2xl border border-teal-100 bg-white p-5 shadow-sm">
            <div class="mb-3 flex items-center justify-between gap-3">
              <div>
                <h3 class="text-lg font-semibold text-gray-800">Quick Assign</h3>
                <p class="text-xs text-gray-500">Assign approved requests directly to available providers.</p>
              </div>
              <button type="button" class="rounded-lg bg-teal-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-teal-700" @click="fetchProviders">
                Refresh Providers
              </button>
            </div>

            <div v-if="loadingProviders" class="rounded-xl border border-gray-100 bg-gray-50 p-4 text-sm text-gray-500">Loading provider pool...</div>
            <div v-else-if="!individualAssignableRequests.length" class="rounded-xl border border-dashed border-gray-300 bg-gray-50 p-4 text-sm text-gray-500">
              No approved/accepted requests waiting for assignment.
            </div>
            <div v-else-if="!availableProviders.length" class="rounded-xl border border-dashed border-amber-300 bg-amber-50 p-4 text-sm text-amber-700">
              No available providers yet.
            </div>
            <div v-else class="space-y-2">
              <div v-for="req in individualAssignableRequests" :key="req.id" class="grid grid-cols-1 gap-2 rounded-xl border border-gray-100 bg-gray-50 p-3 lg:grid-cols-12 lg:items-center">
                <div class="lg:col-span-5">
                  <p class="text-sm font-semibold text-gray-800">{{ req.user_name || 'Customer' }} - {{ req.service_name || req.service_type }}</p>
                  <p class="text-xs text-gray-500">Request #{{ req.id }} - Status: {{ req.status }}</p>
                </div>
                <div class="lg:col-span-4">
                  <select v-model="selectedProviderByRequest[req.id]" class="w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm">
                    <option value="">Select provider</option>
                    <option v-for="provider in availableProviders" :key="provider.id" :value="provider.id">{{ provider.display_name }}</option>
                  </select>
                </div>
                <div class="lg:col-span-3">
                  <button
                    type="button"
                    class="w-full rounded-lg bg-emerald-600 px-3 py-2 text-sm font-semibold text-white hover:bg-emerald-700 disabled:cursor-not-allowed disabled:bg-gray-300"
                    :disabled="!selectedProviderByRequest[req.id] || assigningRequestId===req.id"
                    @click="quickAssignProvider(req.id)"
                  >
                    {{ assigningRequestId===req.id ? 'Assigning...' : 'Assign Provider' }}
                  </button>
                </div>
              </div>
            </div>
          </div>

          <ServiceRequests :requests="requests" :loading="loadingRequests" @refresh="fetchRequests" />
        </section>

        <section v-else-if="activeSection==='providers'" class="space-y-4">
          <div class="rounded-2xl bg-white p-5 shadow-sm">
            <div class="flex items-center justify-between mb-3">
              <h3 class="text-lg font-semibold text-gray-800">Provider Pool</h3>
              <button type="button" class="rounded-lg bg-teal-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-teal-700" @click="fetchProviders">Refresh</button>
            </div>
            <div v-if="loadingProviders" class="text-sm text-gray-500">Loading...</div>
            <div v-else-if="!availableProviders.length" class="text-sm text-gray-500">No available providers.</div>
            <div v-else class="space-y-2">
              <div v-for="p in availableProviders" :key="p.id" class="rounded-lg border border-gray-200 p-3 bg-gray-50">
                <p class="font-semibold text-gray-800">{{ p.display_name }}</p>
                <p class="text-xs text-gray-500">Category: {{ p.category || 'N/A' }}</p>
              </div>
            </div>
          </div>
        </section>

        <section v-else-if="activeSection==='settings'" class="space-y-4">
          <div class="rounded-2xl bg-white p-5 shadow-sm">
            <h3 class="text-lg font-semibold text-gray-800 mb-2">Individual Settings</h3>
            <p class="text-sm text-gray-500 mb-4">Control assignment behavior for this individual business.</p>
            <div class="flex flex-col gap-3 sm:flex-row sm:items-center">
              <button
                type="button"
                class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-60"
                :disabled="updatingAutoAssign"
                @click="toggleAutoAssign"
              >
                {{ updatingAutoAssign ? 'Updating...' : (businessContext.auto_assign_enabled ? 'Auto-Assign: ON' : 'Auto-Assign: OFF') }}
              </button>

              <div class="flex items-center gap-2">
                <label class="text-sm text-gray-600">SLA (minutes)</label>
                <input
                  v-model.number="slaInputMinutes"
                  type="number"
                  min="15"
                  max="720"
                  class="w-28 rounded-lg border border-gray-300 px-3 py-2 text-sm"
                />
                <button
                  type="button"
                  class="rounded-lg bg-teal-600 px-3 py-2 text-sm font-semibold text-white hover:bg-teal-700 disabled:cursor-not-allowed disabled:opacity-60"
                  :disabled="updatingSla"
                  @click="saveSlaThreshold"
                >
                  {{ updatingSla ? 'Saving...' : 'Save SLA' }}
                </button>
              </div>
            </div>

            <div class="mt-5 rounded-xl border border-gray-200 bg-gray-50 p-4">
              <p class="text-xs uppercase tracking-wide text-gray-500">Management Flow</p>
              <p class="mt-1 text-sm font-semibold text-gray-800">Current: {{ currentManagementModeLabel }}</p>
              <p class="mt-1 text-xs text-gray-500">
                Individual and small business flow stays in Business-Managed mode (no HR workspace).
              </p>
              <p class="mt-2 rounded-lg border border-teal-100 bg-teal-50 px-3 py-2 text-xs font-medium text-teal-800">
                For HR-managed operations, business type must be Company and workspace should use HR routes.
              </p>
            </div>
          </div>
        </section>
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { Link, router, usePage } from '@inertiajs/vue3'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import ServiceRequests from '@/Pages/Business/ServiceRequests.vue'
import { confirmAndLogout } from '@/lib/auth-flow'
import { getDashboardPathForRole } from '@/lib/firebase-auth'
import WorkspaceNotificationBell from '@/Components/WorkspaceNotificationBell.vue'

const MetricCard = {
  props: ['title', 'value'],
  template: `
    <div class="rounded-xl border border-gray-100 bg-white p-4 shadow-sm">
      <p class="text-xs uppercase tracking-wide text-gray-500">{{ title }}</p>
      <p class="mt-1 text-2xl font-bold text-gray-800">{{ value }}</p>
    </div>
  `,
}

const props = defineProps({
  section: { type: String, default: 'overview' },
})
const page = usePage()

const activeSection = computed(() => {
  const allowed = ['overview', 'requests', 'providers', 'settings']
  const querySection = typeof window !== 'undefined'
    ? new URLSearchParams(window.location.search).get('section')
    : ''
  if (allowed.includes(props.section)) return props.section
  if (allowed.includes(querySection)) return querySection
  return 'overview'
})

const navItems = [
  { key: 'overview', label: 'Overview', icon: 'OV', href: '/IndividualBusiness/Shell?section=overview' },
  { key: 'requests', label: 'Requests', icon: 'RQ', href: '/IndividualBusiness/Shell?section=requests' },
  { key: 'providers', label: 'Providers', icon: 'PR', href: '/IndividualBusiness/Shell?section=providers' },
  { key: 'settings', label: 'Settings', icon: 'ST', href: '/IndividualBusiness/Shell?section=settings' },
]
const showProfileMenu = ref(false)
const profileInitials = computed(() => {
  const user = page.props?.auth?.user || {}
  const first = String(user.first_name || '').trim()
  const last = String(user.last_name || '').trim()
  const initials = `${first.charAt(0)}${last.charAt(0)}`.toUpperCase().trim()
  if (initials) return initials
  const businessName = String(
    user.business_name
      || user.business_name_1
      || user.company_name
      || businessContext.business_name
      || ''
  ).trim()
  if (businessName) {
    return businessName
      .split(/\s+/)
      .slice(0, 2)
      .map((part) => part.charAt(0))
      .join('')
      .toUpperCase()
  }
  const email = String(user.email || '').trim()
  return email ? email.charAt(0).toUpperCase() : 'PR'
})

const businessContext = reactive({
  business_type: '',
  is_individual: false,
  management_mode: '',
  auto_assign_enabled: false,
  sla_threshold_minutes: 120,
  metrics: {
    completion_rate: 0,
    avg_assign_minutes: 0,
    waiting_for_assignment: 0,
    sla_breaches: 0,
  },
})
const isIndividualBusiness = computed(() => !!businessContext.is_individual)
const preferredBusinessRoute = computed(() => getDashboardPathForRole({
  role: 'business',
  business_type: businessContext.business_type || '',
  management_mode: businessContext.management_mode || '',
  is_approved: true,
  status: 'approved',
  approval_status: 'approved',
}))

const requests = ref([])
const availableProviders = ref([])
const loadingRequests = ref(false)
const loadingProviders = ref(false)
const selectedProviderByRequest = reactive({})
const assigningRequestId = ref(null)
const updatingAutoAssign = ref(false)
const updatingSla = ref(false)
const updatingManagementMode = ref(false)
const slaInputMinutes = ref(120)
const selectedManagementMode = ref('')
const exportingKpi = ref(false)
const lastUpdatedLabel = ref('N/A')
const assignmentAuditLogs = ref([])
const loadingAuditLogs = ref(false)
const managementModeLabel = (mode) => {
  const value = String(mode || '').trim().toLowerCase()
  if (value === 'hr') return 'HR-Managed'
  if (value === 'business') return 'Business-Managed'
  return 'Not set'
}
const currentManagementModeLabel = computed(() => managementModeLabel(businessContext.management_mode))

const normalizeStatus = (value) => String(value || '').trim().toLowerCase()

const toggleProfileMenu = () => {
  showProfileMenu.value = !showProfileMenu.value
}

const openProfile = () => {
  showProfileMenu.value = false
  router.visit('/Profile/Profile')
}

const handleProfileMenuClick = (event) => {
  const target = event?.target
  if (!(target instanceof HTMLElement)) return
  if (!target.closest('.business-profile-wrap')) {
    showProfileMenu.value = false
  }
}

const individualAssignableRequests = computed(() =>
  requests.value.filter((r) => {
    const status = normalizeStatus(r.status)
    return ['approved', 'accepted'].includes(status) && !r.service_provider_id
  })
)

const individualKpis = computed(() => {
  if (businessContext.metrics) {
    return {
      completion_rate: Number(businessContext.metrics.completion_rate || 0),
      avg_assign_minutes: Number(businessContext.metrics.avg_assign_minutes || 0),
      waiting_for_assignment: Number(businessContext.metrics.waiting_for_assignment || 0),
      sla_breaches: Number(businessContext.metrics.sla_breaches || 0),
    }
  }

  const rows = requests.value || []
  const total = rows.length
  const completed = rows.filter((r) => normalizeStatus(r.status) === 'completed').length
  const waiting = rows.filter((r) => ['approved', 'accepted'].includes(normalizeStatus(r.status)) && !r.service_provider_id)
  const breaches = waiting.filter((r) => {
    const created = r?.created_at ? new Date(r.created_at) : null
    if (!created || Number.isNaN(created.getTime())) return false
    return Math.max(0, (Date.now() - created.getTime()) / 60000) > Number(businessContext.sla_threshold_minutes || 120)
  }).length

  const durations = rows
    .filter((r) => r?.assigned_at && r?.created_at)
    .map((r) => {
      const created = new Date(r.created_at)
      const assigned = new Date(r.assigned_at)
      if (Number.isNaN(created.getTime()) || Number.isNaN(assigned.getTime())) return null
      return Math.max(0, (assigned.getTime() - created.getTime()) / 60000)
    })
    .filter((v) => v !== null)

  const avgAssign = durations.length ? Math.round((durations.reduce((sum, v) => sum + v, 0) / durations.length) * 100) / 100 : 0

  return {
    completion_rate: total ? Math.round((completed / total) * 10000) / 100 : 0,
    avg_assign_minutes: avgAssign,
    waiting_for_assignment: waiting.length,
    sla_breaches: breaches,
  }
})

const fetchBusinessContext = async () => {
  try {
    const res = await axios.get('/business/context')
    businessContext.business_type = res.data?.business_type || ''
    businessContext.is_individual = !!res.data?.is_individual
    businessContext.management_mode = String(res.data?.management_mode || '').trim().toLowerCase()
    businessContext.auto_assign_enabled = !!res.data?.auto_assign_enabled
    businessContext.sla_threshold_minutes = Number(res.data?.sla_threshold_minutes || 120)
    businessContext.metrics = res.data?.metrics || businessContext.metrics
    selectedManagementMode.value = businessContext.management_mode || selectedManagementMode.value || 'business'
    const generatedAt = res.data?.generated_at
    lastUpdatedLabel.value = generatedAt ? new Date(generatedAt).toLocaleString() : new Date().toLocaleString()
    slaInputMinutes.value = businessContext.sla_threshold_minutes
    if (!businessContext.is_individual) {
      router.replace(preferredBusinessRoute.value || '/Business/BusinessDashboard')
      return
    }
    if (preferredBusinessRoute.value && preferredBusinessRoute.value !== '/IndividualBusiness/Shell') {
      router.replace(preferredBusinessRoute.value)
    }
  } catch {
    businessContext.business_type = ''
    businessContext.is_individual = false
    businessContext.management_mode = ''
  }
}

const exportKpiCsv = async () => {
  if (exportingKpi.value) return
  exportingKpi.value = true
  try {
    const res = await axios.get('/business/reports/individual-kpi-csv', {
      responseType: 'blob',
    })
    const blob = new Blob([res.data], { type: 'text/csv;charset=utf-8;' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `individual_kpi_report_${Date.now()}.csv`
    document.body.appendChild(a)
    a.click()
    a.remove()
    window.URL.revokeObjectURL(url)
  } catch (error) {
    Swal.fire('Error', error?.response?.data?.message || 'Failed to export KPI CSV.', 'error')
  } finally {
    exportingKpi.value = false
  }
}

const fetchRequests = async () => {
  loadingRequests.value = true
  try {
    const res = await axios.get('/business/service-requests')
    requests.value = (res.data || []).map((r) => ({
      ...r,
      user_name: r.user_name || `${r.user?.first_name || ''} ${r.user?.middle_initial ? r.user.middle_initial + '. ' : ''}${r.user?.last_name || ''}`.trim(),
      service_name: r.service_name || r.service_type || (r.category || 'N/A'),
      details: r.details || r.notes || '',
      contact_number: r.contact_number || r.user?.contact_number || '',
      address_text: r.address_text || r.address || '',
      preferred_date: r.preferred_date || '',
      payment_method: r.payment_method || '',
    }))
  } finally {
    loadingRequests.value = false
  }
}

const fetchProviders = async () => {
  if (!isIndividualBusiness.value) return
  loadingProviders.value = true
  try {
    const res = await axios.get('/business/service-providers')
    availableProviders.value = (res.data || [])
      .filter((p) => Number(p?.is_available) === 1)
      .map((p) => ({
        ...p,
        display_name: `${p?.user?.first_name || ''} ${p?.user?.middle_initial ? `${p.user.middle_initial}. ` : ''}${p?.user?.last_name || ''}`.trim() || `Provider #${p.id}`,
      }))
  } finally {
    loadingProviders.value = false
  }
}

const quickAssignProvider = async (requestId) => {
  const providerId = selectedProviderByRequest[requestId]
  if (!providerId) return
  assigningRequestId.value = requestId
  try {
    const res = await axios.post(`/business/service-requests/${requestId}/assign`, {
      service_provider_id: providerId,
    })
    Swal.fire('Assigned', res.data?.message || 'Provider assigned successfully.', 'success')
    selectedProviderByRequest[requestId] = ''
    await fetchRequests()
    await fetchProviders()
    await fetchBusinessContext()
  } catch (error) {
    Swal.fire('Error', error?.response?.data?.message || 'Failed to assign provider.', 'error')
  } finally {
    assigningRequestId.value = null
  }
}

const toggleAutoAssign = async () => {
  if (!isIndividualBusiness.value || updatingAutoAssign.value) return
  updatingAutoAssign.value = true
  const nextEnabled = !businessContext.auto_assign_enabled
  try {
    const res = await axios.post('/business/settings/auto-assign', { enabled: nextEnabled })
    businessContext.auto_assign_enabled = !!res.data?.auto_assign_enabled
    Swal.fire('Updated', res.data?.message || 'Auto-assign setting updated.', 'success')
  } catch (error) {
    Swal.fire('Error', error?.response?.data?.message || 'Failed to update auto-assign setting.', 'error')
  } finally {
    updatingAutoAssign.value = false
  }
}

const saveSlaThreshold = async () => {
  if (!isIndividualBusiness.value || updatingSla.value) return
  updatingSla.value = true
  const payload = {
    sla_threshold_minutes: Number(slaInputMinutes.value || 120),
  }
  try {
    const res = await axios.post('/business/settings/sla-threshold', payload)
    businessContext.sla_threshold_minutes = Number(res.data?.sla_threshold_minutes || payload.sla_threshold_minutes)
    await fetchBusinessContext()
    Swal.fire('Updated', res.data?.message || 'SLA threshold updated.', 'success')
  } catch (error) {
    Swal.fire('Error', error?.response?.data?.message || 'Failed to update SLA threshold.', 'error')
  } finally {
    updatingSla.value = false
  }
}

const saveManagementMode = async () => {
  const mode = String(selectedManagementMode.value || '').trim().toLowerCase()
  if (!mode || !['hr', 'business'].includes(mode) || updatingManagementMode.value) return

  const current = String(businessContext.management_mode || '').trim().toLowerCase()
  if (mode === current) {
    Swal.fire('No changes', 'Management mode is already set to this option.', 'info')
    return
  }

  const confirm = await Swal.fire({
    title: 'Switch management mode?',
    text: mode === 'hr'
      ? 'You will be routed to HR workspace.'
      : 'You will be routed to the shared business-managed workspace.',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Yes, switch',
    confirmButtonColor: '#0f766e',
  })
  if (!confirm.isConfirmed) return

  updatingManagementMode.value = true
  try {
    const res = await axios.post('/business/setup/management', {
      management_mode: mode,
    })

    businessContext.management_mode = String(res.data?.management_mode || mode).trim().toLowerCase()
    const redirectTo = res.data?.redirect_to || (mode === 'hr' ? '/HR/HrBusinessShell' : '/Business/BusinessDashboard')
    router.visit(redirectTo)
  } catch (error) {
    Swal.fire('Error', error?.response?.data?.message || 'Failed to update management mode.', 'error')
  } finally {
    updatingManagementMode.value = false
  }
}

const fetchAssignmentAuditLogs = async () => {
  if (!isIndividualBusiness.value) return
  loadingAuditLogs.value = true
  try {
    const res = await axios.get('/business/reports/assignment-audit')
    assignmentAuditLogs.value = res.data || []
  } finally {
    loadingAuditLogs.value = false
  }
}

const formatDateTime = (value) => {
  if (!value) return 'N/A'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return value
  return d.toLocaleString()
}

const confirmLogout = async () => {
  showProfileMenu.value = false
  await confirmAndLogout({
    confirmTitle: 'Log out?',
    confirmText: 'You will be signed out of your account.',
  })
}

watch(
  () => activeSection.value,
  async (section) => {
    if (section === 'requests' || section === 'overview') await fetchRequests()
    if (section === 'overview' || section === 'settings') await fetchBusinessContext()
    if (section === 'overview') await fetchAssignmentAuditLogs()
    if (section === 'requests' || section === 'providers') await fetchProviders()
  },
  { immediate: false }
)

onMounted(async () => {
  document.addEventListener('click', handleProfileMenuClick)
  await fetchBusinessContext()
  await fetchRequests()
  await fetchProviders()
  await fetchAssignmentAuditLogs()
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleProfileMenuClick)
})
</script>

