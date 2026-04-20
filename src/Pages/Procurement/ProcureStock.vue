<template>
  <section class="space-y-5">
    <div class="rounded-2xl bg-gradient-to-r from-sky-600 to-blue-700 text-white p-6 shadow-lg">
      <p class="text-xs uppercase tracking-[0.14em] text-white/85">Supply Tracking</p>
      <h2 class="text-2xl font-bold mt-1">Stock and Deliveries</h2>
      <p class="text-sm text-white/90 mt-1">Track ordered and received deliveries. Receiving action is handled in Supply Chain Management.</p>
    </div>

    <div v-if="loading" class="grid gap-4 md:grid-cols-2">
      <div v-for="idx in 4" :key="`stock-skeleton-${idx}`" class="h-36 animate-pulse rounded-2xl border border-slate-200 bg-white shadow-sm"></div>
    </div>

    <div v-else class="space-y-4">
      <div v-if="refreshing" class="rounded-xl border border-slate-200 bg-white/80 px-4 py-3 text-xs font-semibold text-slate-500">
        Refreshing latest stock orders...
      </div>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="tab in tabs"
          :key="tab.value"
          @click="activeTab = tab.value"
          class="px-4 py-2 rounded-lg text-sm font-semibold border transition"
          :class="activeTab === tab.value ? 'bg-slate-900 text-white border-slate-900' : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-50'"
        >
          {{ tab.label }}
        </button>
      </div>

      <div v-if="groupedOrders.length" class="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
          <table class="min-w-full text-sm">
            <thead class="bg-slate-50 text-slate-500">
              <tr>
                <th class="px-4 py-3 text-left font-semibold uppercase tracking-wide text-[11px]">Material</th>
                <th class="px-4 py-3 text-left font-semibold uppercase tracking-wide text-[11px]">Status</th>
                <th class="px-4 py-3 text-left font-semibold uppercase tracking-wide text-[11px]">Quantity</th>
                <th class="px-4 py-3 text-left font-semibold uppercase tracking-wide text-[11px]">Expected Date</th>
                <th class="px-4 py-3 text-left font-semibold uppercase tracking-wide text-[11px]">Arrival Date</th>
                <th class="px-4 py-3 text-left font-semibold uppercase tracking-wide text-[11px]">Source</th>
                <th class="px-4 py-3 text-left font-semibold uppercase tracking-wide text-[11px]">Purchase Link</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-200">
              <tr v-for="order in pagedOrders" :key="order.key" class="hover:bg-slate-50">
                <td class="px-4 py-3 font-semibold text-slate-900">
                  {{ order.material_name }}
                </td>
                <td class="px-4 py-3">
                  <span class="px-3 py-1 rounded-full text-xs font-semibold capitalize" :class="statusClass(order.status_key)">
                    {{ order.status_label }}
                  </span>
                </td>
                <td class="px-4 py-3 text-slate-700">
                  <span>{{ order.quantity_label }}</span>
                  <span v-if="order.is_low_stock" class="ml-2 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-rose-100 text-rose-700">
                    LOW STOCK
                  </span>
                </td>
                <td class="px-4 py-3 text-slate-700">
                  {{ order.expected_date_label }}
                </td>
                <td class="px-4 py-3 text-slate-700">
                  {{ order.arrival_date_label }}
                </td>
                <td class="px-4 py-3 text-slate-700">
                  {{ order.source_label }}
                </td>
                <td class="px-4 py-3">
                  <a
                    v-if="order.purchase_links.length === 1"
                    :href="order.purchase_links[0]"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="text-blue-600 hover:underline break-all"
                  >
                    View Link
                  </a>
                  <button
                    v-else-if="order.purchase_links.length > 1"
                    type="button"
                    class="text-blue-600 hover:underline"
                    @click="openLinksModal(order)"
                  >
                    View Links ({{ order.purchase_links.length }})
                  </button>
                  <span v-else class="text-slate-400">No link</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <p class="px-4 py-3 text-xs text-slate-500 border-t border-slate-200 bg-white">
          Receiving action moved to <span class="font-semibold">Supply Chain Management</span>.
        </p>
        <div v-if="totalPages > 1" class="flex items-center justify-between border-t border-slate-200 bg-white px-4 py-3 text-sm">
          <p class="text-slate-500">Page {{ currentPage }} of {{ totalPages }}</p>
          <div class="flex items-center gap-2">
            <button
              type="button"
              class="px-3 py-1.5 rounded-lg border border-slate-300 text-slate-700 disabled:opacity-50"
              :disabled="currentPage === 1"
              @click="currentPage--"
            >
              Prev
            </button>
            <button
              type="button"
              class="px-3 py-1.5 rounded-lg border border-slate-300 text-slate-700 disabled:opacity-50"
              :disabled="currentPage === totalPages"
              @click="currentPage++"
            >
              Next
            </button>
          </div>
        </div>
      </div>

      <div v-else class="rounded-2xl border border-dashed border-slate-300 bg-white p-10 text-center text-slate-500">
        {{ emptyText }}
      </div>
    </div>

    <div v-if="showLinksModal" class="fixed inset-0 z-50 flex items-center justify-center">
      <div class="absolute inset-0 bg-slate-900/40" @click="closeLinksModal"></div>
      <div class="relative w-full max-w-lg mx-4 bg-white rounded-2xl shadow-xl border border-slate-200">
        <div class="px-5 py-4 border-b border-slate-200 flex items-center justify-between">
          <div>
            <p class="text-xs uppercase tracking-[0.12em] text-slate-400">Purchase Links</p>
            <h3 class="text-lg font-semibold text-slate-900">{{ modalTitle }}</h3>
          </div>
          <button type="button" class="text-slate-500 hover:text-slate-700" @click="closeLinksModal">
            Close
          </button>
        </div>
        <div class="px-5 py-4 max-h-80 overflow-y-auto">
          <ul class="space-y-2">
            <li v-for="(link, idx) in modalLinks" :key="`${link}-${idx}`">
              <a
                :href="link"
                target="_blank"
                rel="noopener noreferrer"
                class="text-blue-600 hover:underline break-all"
              >
                {{ link }}
              </a>
            </li>
          </ul>
        </div>
        <div class="px-5 py-4 border-t border-slate-200 text-right">
          <button type="button" class="px-4 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-50" @click="closeLinksModal">
            Close
          </button>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import { readCachedViewState, writeCachedViewState } from '@/lib/view-state-cache'

const props = defineProps({
  embedded: {
    type: Boolean,
    default: false,
  },
})

const STOCK_CACHE_KEY = 'procurement-stock-orders'
const cachedStockState = readCachedViewState(STOCK_CACHE_KEY, null)
const hasCachedStockState = Boolean(cachedStockState)
const orders = ref(Array.isArray(cachedStockState?.orders) ? cachedStockState.orders : [])
const loading = ref(!hasCachedStockState)
const refreshing = ref(false)
const activeTab = ref('received')
const currentPage = ref(1)
const pageSize = 10
const tabs = [
  { label: 'Received Deliveries', value: 'received' },
  { label: 'All Orders', value: 'all' },
]

const filteredOrders = computed(() => {
  const list = orders.value || []
  if (activeTab.value === 'received') return list.filter((o) => String(o.status).toLowerCase() === 'received')
  return list
})

const groupedOrders = computed(() => {
  const groups = new Map()
  for (const order of filteredOrders.value) {
    const key = order.material_name || 'Unknown'
    if (!groups.has(key)) {
      groups.set(key, {
        key,
        material_name: key,
        quantity: 0,
        units: new Set(),
        statuses: new Set(),
        expected_dates: new Set(),
        arrival_dates: new Set(),
        sources: new Set(),
        purchase_links: new Set(),
      })
    }
    const group = groups.get(key)
    const qty = Number(order.quantity)
    group.quantity += Number.isFinite(qty) ? qty : 0
    if (order.unit) group.units.add(order.unit)
    if (order.status) group.statuses.add(String(order.status).toLowerCase())
    if (order.expected_date) group.expected_dates.add(order.expected_date)
    if (order.arrival_date) group.arrival_dates.add(order.arrival_date)
    if (order.business_name) group.sources.add(order.business_name)
    if (order.purchase_link) group.purchase_links.add(order.purchase_link)
  }

  return Array.from(groups.values()).map((group) => {
    const units = Array.from(group.units)
    const statuses = Array.from(group.statuses)
    const expectedDates = Array.from(group.expected_dates)
    const arrivalDates = Array.from(group.arrival_dates)
    const sources = Array.from(group.sources)
    const purchaseLinks = Array.from(group.purchase_links)

    let statusKey = 'ordered'
    let statusLabel = 'ordered'
    if (statuses.length === 1) {
      statusKey = statuses[0]
      statusLabel = statuses[0]
    } else if (statuses.length > 1) {
      statusKey = 'partial'
      statusLabel = 'partial'
    }

    const quantityUnit = units.length === 1 ? units[0] : units.length === 0 ? 'pcs' : 'mixed units'
    const expectedLabel = expectedDates.length === 1 ? formatDate(expectedDates[0]) : expectedDates.length === 0 ? 'N/A' : 'Multiple'
    const arrivalLabel = arrivalDates.length === 1 ? formatDate(arrivalDates[0]) : arrivalDates.length === 0 ? 'N/A' : 'Multiple'
    const sourceLabel = sources.length === 1 ? sources[0] : sources.length === 0 ? 'General Stock' : 'Multiple'

    const isLowStock = group.quantity <= 5
    return {
      key: group.key,
      material_name: group.material_name,
      quantity_label: `${group.quantity} ${quantityUnit}`,
      is_low_stock: isLowStock,
      status_key: statusKey,
      status_label: statusLabel,
      expected_date_label: expectedLabel,
      arrival_date_label: arrivalLabel,
      source_label: sourceLabel,
      purchase_links: purchaseLinks,
    }
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(groupedOrders.value.length / pageSize)))

const pagedOrders = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return groupedOrders.value.slice(start, start + pageSize)
})

const lowStockItems = computed(() => groupedOrders.value.filter((o) => o.is_low_stock))

const emptyText = computed(() => {
  if (activeTab.value === 'received') return 'No received stock orders.'
  if (activeTab.value === 'all') return 'No stock orders yet.'
  return 'No pending stock orders.'
})

watch(activeTab, () => {
  currentPage.value = 1
})

watch(groupedOrders, () => {
  if (currentPage.value > totalPages.value) currentPage.value = totalPages.value
})

const fetchOrders = async ({ background = false } = {}) => {
  if (background) refreshing.value = true
  else loading.value = true
  try {
    const res = await axios.get('/procurement/stock-orders')
    orders.value = res.data || []
    writeCachedViewState(STOCK_CACHE_KEY, {
      orders: orders.value,
    })
  } catch {
    if (!background) {
      Swal.fire('Error', 'Failed to load stock orders', 'error')
    }
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

const statusClass = (status) => {
  if (status === 'ordered') return 'bg-amber-100 text-amber-700'
  if (status === 'received') return 'bg-emerald-100 text-emerald-700'
  if (status === 'partial') return 'bg-sky-100 text-sky-700'
  return 'bg-slate-100 text-slate-700'
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  const parsed = new Date(date)
  if (Number.isNaN(parsed.getTime())) return date
  return parsed.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
}

const showLinksModal = ref(false)
const modalLinks = ref([])
const modalTitle = ref('')

const openLinksModal = (order) => {
  modalTitle.value = order.material_name
  modalLinks.value = order.purchase_links || []
  showLinksModal.value = true
}

const closeLinksModal = () => {
  showLinksModal.value = false
  modalLinks.value = []
  modalTitle.value = ''
}

onMounted(() => {
  if (!props.embedded && typeof window !== 'undefined') {
    window.location.replace('/Procurement/ProcurementDashboard?section=stocks')
    return
  }
  fetchOrders({ background: hasCachedStockState })
})
</script>

