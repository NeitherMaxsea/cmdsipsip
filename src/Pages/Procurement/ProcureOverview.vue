<template>
  <section class="space-y-6">
    <div class="rounded-2xl bg-gradient-to-r from-cyan-600 to-teal-600 text-white p-6 shadow-lg">
      <p class="text-xs uppercase tracking-[0.14em] text-white/80">Procurement</p>
      <h2 class="text-2xl font-bold mt-1">Inventory And Material Readiness</h2>
      <p class="text-sm text-white/90 mt-1">Track Operations requests awaiting materials, inventory health, and incoming deliveries.</p>
    </div>

    <div v-if="loading" class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
      <div v-for="idx in 4" :key="`overview-skeleton-${idx}`" class="h-24 animate-pulse rounded-2xl border border-slate-200 bg-white shadow-sm"></div>
    </div>

    <div v-else class="space-y-6">
      <div v-if="refreshing" class="rounded-xl border border-slate-200 bg-white/80 px-4 py-3 text-xs font-semibold text-slate-500">
        Refreshing latest dashboard data...
      </div>
      <article v-if="alerts.length" class="rounded-2xl border border-amber-200 bg-amber-50 p-4 text-amber-900">
        <p class="text-sm font-bold mb-2">Alerts</p>
        <ul class="space-y-1 text-sm">
          <li v-for="(alert, idx) in alerts" :key="`alert-${idx}`">{{ alert }}</li>
        </ul>
      </article>

      <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
        <article class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <p class="text-xs uppercase tracking-wide text-slate-400">Operations Requests Awaiting Materials</p>
          <p class="text-2xl font-bold text-slate-900 mt-1">{{ metrics.awaitingRequests }}</p>
        </article>
        <article class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <p class="text-xs uppercase tracking-wide text-slate-400">Low Stock Items</p>
          <p class="text-2xl font-bold text-rose-600 mt-1">{{ metrics.lowStockItems }}</p>
        </article>
        <article class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <p class="text-xs uppercase tracking-wide text-slate-400">Open Purchase Orders</p>
          <p class="text-2xl font-bold text-amber-600 mt-1">{{ metrics.incomingOrders }}</p>
        </article>
        <article class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <p class="text-xs uppercase tracking-wide text-slate-400">Overdue/Delayed</p>
          <p class="text-2xl font-bold text-slate-900 mt-1">{{ metrics.overdueOrders }}</p>
        </article>
      </div>

      <div class="grid grid-cols-1 xl:grid-cols-2 gap-4">
        <article class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <div class="flex items-center justify-between mb-3">
          <p class="text-sm font-bold text-slate-900">Priority Operations Requests</p>
            <Link href="/Procurement/ProcurementDashboard?section=requests" preserve-scroll class="text-xs font-semibold text-teal-700 hover:underline">View All</Link>
          </div>
          <div v-if="priorityRequests.length" class="space-y-2">
            <div
              v-for="req in priorityRequests"
              :key="req.id"
              class="flex items-center justify-between rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm"
            >
              <div>
                <p class="font-semibold text-slate-900">{{ req.customer }}</p>
                <p class="text-xs text-slate-500">{{ req.service || 'N/A' }}</p>
                <p class="mt-1 text-[11px] text-slate-400">{{ req.summary }}</p>
              </div>
              <span class="text-xs font-semibold text-slate-600">{{ req.dateLabel }}</span>
            </div>
          </div>
          <p v-else class="text-sm text-slate-500">No awaiting requests.</p>
        </article>

        <article class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <div class="flex items-center justify-between mb-3">
            <p class="text-sm font-bold text-slate-900">Low Stock List</p>
            <Link href="/Procurement/ProcurementDashboard?section=supply-chain" preserve-scroll class="text-xs font-semibold text-teal-700 hover:underline">Supply Chain</Link>
          </div>
          <div v-if="lowStockList.length" class="space-y-2">
            <div
              v-for="item in lowStockList"
              :key="item.key"
              class="flex items-center justify-between rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm"
            >
              <div>
                <p class="font-semibold text-slate-900">{{ item.name }}</p>
                <p class="text-xs text-slate-500">{{ item.unit }}</p>
              </div>
              <span class="text-xs font-semibold text-rose-600">{{ item.available }} pcs</span>
            </div>
          </div>
          <p v-else class="text-sm text-slate-500">No low stock items.</p>
        </article>
      </div>

      <div class="grid grid-cols-1 xl:grid-cols-2 gap-4">
        <article class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <div class="flex items-center justify-between mb-3">
          <p class="text-sm font-bold text-slate-900">Recent Purchase Orders</p>
            <Link href="/Procurement/ProcurementDashboard?section=stocks" preserve-scroll class="text-xs font-semibold text-teal-700 hover:underline">View All</Link>
          </div>
          <div v-if="recentOrders.length" class="space-y-2">
            <div
              v-for="order in recentOrders"
              :key="order.id"
              class="flex items-center justify-between rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm"
            >
              <div>
                <p class="font-semibold text-slate-900">{{ order.material }}</p>
                <p class="text-xs text-slate-500">{{ order.statusLabel }}</p>
              </div>
              <span class="text-xs font-semibold text-slate-600">{{ order.dateLabel }}</span>
            </div>
          </div>
          <p v-else class="text-sm text-slate-500">No stock orders yet.</p>
        </article>

        <article class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <div class="flex items-center justify-between mb-3">
            <p class="text-sm font-bold text-slate-900">Incoming Deliveries (7 days)</p>
            <Link href="/Procurement/ProcurementDashboard?section=stocks" preserve-scroll class="text-xs font-semibold text-teal-700 hover:underline">Track Orders</Link>
          </div>
          <div v-if="incomingDeliveries.length" class="space-y-2">
            <div
              v-for="item in incomingDeliveries"
              :key="item.key"
              class="flex items-center justify-between rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm"
            >
              <div>
                <p class="font-semibold text-slate-900">{{ item.material }}</p>
                <p class="text-xs text-slate-500">{{ item.dateLabel }}</p>
              </div>
              <span class="text-xs font-semibold text-amber-700">{{ item.qtyLabel }}</span>
            </div>
          </div>
          <p v-else class="text-sm text-slate-500">No incoming deliveries this week.</p>
        </article>
      </div>

    </div>
  </section>
</template>

<script setup>
import { Link } from '@inertiajs/vue3'
import { computed, onMounted, ref } from 'vue'
import axios from 'axios'
import { readCachedViewState, writeCachedViewState } from '@/lib/view-state-cache'

const OVERVIEW_CACHE_KEY = 'procurement-overview'
const cachedOverviewState = readCachedViewState(OVERVIEW_CACHE_KEY, null)
const hasCachedOverviewState = Boolean(cachedOverviewState)
const loading = ref(!hasCachedOverviewState)
const refreshing = ref(false)
const requests = ref(Array.isArray(cachedOverviewState?.requests) ? cachedOverviewState.requests : [])
const inventory = ref(Array.isArray(cachedOverviewState?.inventory) ? cachedOverviewState.inventory : [])
const orders = ref(Array.isArray(cachedOverviewState?.orders) ? cachedOverviewState.orders : [])

const lowStockThreshold = 5

const toDate = (value) => {
  if (!value) return null
  const d = new Date(value)
  return Number.isNaN(d.getTime()) ? null : d
}

const formatDate = (value) => {
  const d = toDate(value)
  return d ? d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' }) : 'N/A'
}

const prettyValue = (value, fallback = 'N/A') => {
  const normalized = String(value || '').trim().toLowerCase()
  return normalized
    ? normalized.replace(/_/g, ' ').replace(/\b\w/g, (m) => m.toUpperCase())
    : fallback
}

const customerTypeLabel = (value) => {
  const normalized = String(value || '').trim().toLowerCase()
  if (normalized === 'non_contract') return 'Non-Contract'
  if (normalized === 'contracted') return 'Contracted'
  return prettyValue(value)
}

const paymentTermsLabel = (value) => {
  const normalized = String(value || '').trim().toLowerCase()
  if (normalized === 'full_before_service') return 'Full Before Service'
  if (normalized === '30_percent_down_30_days') return '30% Down / 30 Days'
  return prettyValue(value, 'Payment Terms Pending')
}

const today = () => {
  const now = new Date()
  return new Date(now.getFullYear(), now.getMonth(), now.getDate())
}

const addDays = (date, days) => new Date(date.getTime() + days * 24 * 60 * 60 * 1000)

const metrics = computed(() => {
  const awaitingRequests = requests.value.filter((r) => String(r.status).toLowerCase() === 'awaiting_material').length
  const lowStockItems = inventory.value.filter((i) => Number(i.available) <= lowStockThreshold).length
  const incomingOrders = orders.value.filter((o) => String(o.status).toLowerCase() !== 'received').length
  const overdueOrders = orders.value.filter((o) => {
    if (String(o.status).toLowerCase() === 'received') return false
    const expected = toDate(o.expected_date)
    return expected && expected < today()
  }).length

  return { awaitingRequests, lowStockItems, incomingOrders, overdueOrders }
})

const priorityRequests = computed(() => {
  const awaiting = requests.value.filter((r) => String(r.status).toLowerCase() === 'awaiting_material')
  const sorted = awaiting.sort((a, b) => {
    const da = toDate(a.preferred_date || a.created_at)
    const db = toDate(b.preferred_date || b.created_at)
    if (!da && !db) return 0
    if (!da) return 1
    if (!db) return -1
    return da - db
  })
  return sorted.slice(0, 5).map((r) => ({
    id: r.id,
    customer: `${r.first_name || ''} ${r.last_name || ''}`.trim() || 'Unknown',
    service: r.service_type,
    dateLabel: formatDate(r.preferred_date || r.created_at),
    summary: `${customerTypeLabel(r.customer_type)} • ${prettyValue(r.property_type, 'Residential')} • ${paymentTermsLabel(r.payment_terms)}`,
  }))
})

const lowStockList = computed(() => {
  return inventory.value
    .filter((i) => Number(i.available) <= lowStockThreshold)
    .slice(0, 5)
    .map((i) => ({
      key: `${i.material_name}-${i.unit}`,
      name: i.material_name || 'Unknown',
      unit: i.unit || 'pcs',
      available: Number(i.available) || 0,
    }))
})

const recentOrders = computed(() => {
  const sorted = [...orders.value].sort((a, b) => {
    const da = toDate(a.created_at || a.expected_date)
    const db = toDate(b.created_at || b.expected_date)
    if (!da && !db) return 0
    if (!da) return 1
    if (!db) return -1
    return db - da
  })
  return sorted.slice(0, 5).map((o) => ({
    id: o.id,
    material: o.material_name || 'Unknown',
    statusLabel: String(o.status || 'ordered'),
    dateLabel: formatDate(o.created_at || o.expected_date),
  }))
})

const incomingDeliveries = computed(() => {
  const start = today()
  const end = addDays(start, 7)
  return orders.value
    .filter((o) => {
      if (String(o.status).toLowerCase() === 'received') return false
      const d = toDate(o.expected_date || o.arrival_date)
      return d && d >= start && d <= end
    })
    .slice(0, 5)
    .map((o) => ({
      key: `incoming-${o.id}`,
      material: o.material_name || 'Unknown',
      dateLabel: formatDate(o.expected_date || o.arrival_date),
      qtyLabel: `${o.quantity || 0} ${o.unit || 'pcs'}`,
    }))
})

const alerts = computed(() => {
  const list = []
  const zeroStock = inventory.value.filter((i) => Number(i.available) <= 0).length
  if (zeroStock) list.push(`${zeroStock} item(s) have zero stock. Please place orders.`)
  if (metrics.value.overdueOrders) list.push(`${metrics.value.overdueOrders} order(s) are overdue.`)
  const stuck = requests.value.filter((r) => {
    if (String(r.status).toLowerCase() !== 'awaiting_material') return false
    const created = toDate(r.created_at)
    return created && created < addDays(today(), -7)
  }).length
  if (stuck) list.push(`${stuck} request(s) are awaiting materials for more than 7 days.`)
  return list
})

const fetchData = async ({ background = false } = {}) => {
  if (background) refreshing.value = true
  else loading.value = true
  try {
    const [reqRes, invRes, ordRes] = await Promise.all([
      axios.get('/procurement/requests-awaiting-material'),
      axios.get('/procurement/inventory-summary'),
      axios.get('/procurement/stock-orders'),
    ])
    requests.value = Array.isArray(reqRes.data) ? reqRes.data : []
    inventory.value = Array.isArray(invRes.data) ? invRes.data : []
    orders.value = Array.isArray(ordRes.data) ? ordRes.data : []
    writeCachedViewState(OVERVIEW_CACHE_KEY, {
      requests: requests.value,
      inventory: inventory.value,
      orders: orders.value,
    })
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

onMounted(() => {
  fetchData({ background: hasCachedOverviewState })
})
</script>
