<template>
  <section class="space-y-5">
    <div class="rounded-2xl bg-gradient-to-r from-sky-600 to-blue-700 text-white p-6 shadow-lg">
      <p class="text-xs uppercase tracking-[0.14em] text-white/85">Inventory</p>
      <h2 class="text-2xl font-bold mt-1">Stock Orders</h2>
      <p class="text-sm text-white/90 mt-1">Track incoming materials and mark deliveries as received.</p>
    </div>

    <div v-if="loading" class="text-slate-500">Loading stock orders...</div>

    <div v-else-if="orders.length" class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      <article v-for="order in orders" :key="order.id" class="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm">
        <div class="flex items-start justify-between gap-3">
          <div>
            <p class="text-xs uppercase tracking-wide text-slate-400">Material</p>
            <h3 class="text-xl font-bold text-slate-900">{{ order.material_name }}</h3>
          </div>
          <span class="px-3 py-1 rounded-full text-xs font-semibold capitalize" :class="statusClass(order.status)">
            {{ order.status }}
          </span>
        </div>

        <div class="mt-4 grid grid-cols-2 gap-3 text-sm">
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-3">
            <p class="text-[11px] uppercase tracking-wide text-slate-400">Quantity</p>
            <p class="font-semibold text-slate-800 mt-1">{{ order.quantity }} {{ order.unit || 'pcs' }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-3">
            <p class="text-[11px] uppercase tracking-wide text-slate-400">Expected Date</p>
            <p class="font-semibold text-slate-800 mt-1">{{ formatDate(order.expected_date) }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-3">
            <p class="text-[11px] uppercase tracking-wide text-slate-400">Arrival Date</p>
            <p class="font-semibold text-slate-800 mt-1">{{ formatDate(order.arrival_date) }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-3">
            <p class="text-[11px] uppercase tracking-wide text-slate-400">Business</p>
            <p class="font-semibold text-slate-800 mt-1">{{ order.business_name || 'N/A' }}</p>
          </div>
        </div>

        <div class="mt-4">
          <button
            v-if="order.status !== 'received'"
            @click="markReceived(order)"
            class="bg-emerald-500 hover:bg-emerald-600 text-white px-4 py-2 rounded-lg text-sm font-semibold"
          >
            Mark as Received
          </button>
          <p v-else class="text-sm font-semibold text-emerald-600">Received and recorded.</p>
        </div>
      </article>
    </div>

    <div v-else class="rounded-2xl border border-dashed border-slate-300 bg-white p-10 text-center text-slate-500">
      No stock orders yet.
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'

const orders = ref([])
const loading = ref(true)

const fetchOrders = async () => {
  loading.value = true
  try {
    const res = await axios.get('/procurement/stock-orders')
    orders.value = res.data || []
  } catch {
    Swal.fire('Error', 'Failed to load stock orders', 'error')
  } finally {
    loading.value = false
  }
}

const markReceived = async (order) => {
  try {
    await axios.post(`/procurement/mark-received/${order.id}`)
    Swal.fire('Success', 'Stock marked as received', 'success')
    fetchOrders()
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to update stock', 'error')
  }
}

const statusClass = (status) => {
  if (status === 'ordered') return 'bg-amber-100 text-amber-700'
  if (status === 'received') return 'bg-emerald-100 text-emerald-700'
  return 'bg-slate-100 text-slate-700'
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  const parsed = new Date(date)
  if (Number.isNaN(parsed.getTime())) return date
  return parsed.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
}

onMounted(fetchOrders)
</script>

