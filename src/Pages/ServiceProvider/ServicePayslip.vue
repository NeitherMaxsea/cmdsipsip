<template>
  <section class="space-y-5">
    <section class="flex flex-wrap items-start justify-between gap-3 rounded-[18px] border border-slate-200 bg-white p-5 shadow-[0_8px_18px_rgba(15,23,42,0.06)]">
      <div>
        <p class="m-0 text-[11px] font-bold uppercase tracking-[0.12em] text-green-600">Service Provider Operations</p>
        <h2 class="mt-1.5 text-[30px] font-extrabold leading-[1.1] text-slate-900">Service Payslip</h2>
        <p class="mt-2 text-sm text-slate-600">Review your earnings based on attendance and completed jobs.</p>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <input v-model="selectedMonth" type="month" class="rounded-[10px] border border-slate-300 bg-white px-2.5 py-2 text-[13px] text-slate-700" @change="fetchPayslip" />
        <button class="rounded-full border border-slate-300 bg-white px-3.5 py-2 text-xs font-bold text-slate-600 disabled:cursor-not-allowed disabled:opacity-50" :disabled="loading" @click="fetchPayslip">Refresh</button>
      </div>
    </section>

    <section class="grid grid-cols-1 gap-3 md:grid-cols-4">
      <div class="rounded-[14px] border border-slate-200 bg-white p-3.5 shadow-[0_8px_18px_rgba(15,23,42,0.05)]">
        <p class="m-0 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-500">Daily Rate</p>
        <p class="mt-1.5 text-[24px] font-extrabold leading-[1.2] text-slate-900">PHP {{ formatMoney(data.daily_rate) }}</p>
      </div>
      <div class="rounded-[14px] border border-slate-200 bg-white p-3.5 shadow-[0_8px_18px_rgba(15,23,42,0.05)]">
        <p class="m-0 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-500">Gross Pay</p>
        <p class="mt-1.5 text-[24px] font-extrabold leading-[1.2] text-slate-900">PHP {{ formatMoney(data.gross_pay) }}</p>
      </div>
      <div class="rounded-[14px] border border-slate-200 bg-white p-3.5 shadow-[0_8px_18px_rgba(15,23,42,0.05)]">
        <p class="m-0 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-500">Deductions</p>
        <p class="mt-1.5 text-[24px] font-extrabold leading-[1.2] text-slate-900">PHP {{ formatMoney(data.deductions?.total) }}</p>
      </div>
      <div class="rounded-[14px] border border-green-200 bg-green-50 p-3.5 shadow-[0_8px_18px_rgba(15,23,42,0.05)]">
        <p class="m-0 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-500">Net Pay</p>
        <p class="mt-1.5 text-[24px] font-extrabold leading-[1.2] text-slate-900">PHP {{ formatMoney(data.net_pay) }}</p>
      </div>
    </section>

    <section class="rounded-[18px] border border-slate-200 bg-white p-3.5 shadow-[0_8px_18px_rgba(15,23,42,0.06)]">
      <div class="mb-2.5 flex items-center justify-between">
        <h3>Payslip Breakdown ({{ data.period_label || '-' }})</h3>
      </div>

      <div v-if="loading" class="p-2 text-sm text-slate-500">Loading payslip...</div>
      <div v-else class="space-y-4">
        <div class="grid grid-cols-1 gap-3 md:grid-cols-3">
          <div class="rounded-xl border border-slate-200 bg-white p-3">
            <p class="m-0 text-[11px] uppercase tracking-[0.08em] text-slate-500">Provider</p>
            <p class="mt-1.5 text-base font-semibold text-slate-900">{{ data.provider_name || 'N/A' }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-white p-3">
            <p class="m-0 text-[11px] uppercase tracking-[0.08em] text-slate-500">Present Days</p>
            <p class="mt-1.5 text-base font-semibold text-slate-900">{{ data.days_present ?? 0 }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-white p-3">
            <p class="m-0 text-[11px] uppercase tracking-[0.08em] text-slate-500">Completed Jobs</p>
            <p class="mt-1.5 text-base font-semibold text-slate-900">{{ data.completed_jobs ?? 0 }}</p>
          </div>
        </div>

        <div class="rounded-xl border border-slate-200 bg-slate-50 p-4">
          <p class="text-xs uppercase tracking-wide text-slate-500">Deduction Details</p>
          <div class="mt-2 grid grid-cols-1 gap-2 sm:grid-cols-3 text-sm text-slate-700">
            <p>Late: <span class="font-semibold">PHP {{ formatMoney(data.deductions?.late) }}</span></p>
            <p>Absence: <span class="font-semibold">PHP {{ formatMoney(data.deductions?.absence) }}</span></p>
            <p>Platform Fee: <span class="font-semibold">PHP {{ formatMoney(data.deductions?.platform_fee) }}</span></p>
          </div>
        </div>

        <div class="overflow-x-auto">
          <table class="w-full min-w-[680px] text-sm [&_th]:border-b [&_th]:border-slate-200 [&_th]:px-3 [&_th]:py-2.5 [&_th]:text-left [&_th]:text-[11px] [&_th]:uppercase [&_th]:tracking-wide [&_th]:text-slate-500 [&_td]:border-b [&_td]:border-slate-100 [&_td]:px-3 [&_td]:py-2.5 [&_td]:text-slate-700">
            <thead>
              <tr>
                <th>Date</th>
                <th>Clock In</th>
                <th>Clock Out</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in data.attendance || []" :key="`${row.attendance_date}-${idx}`">
                <td>{{ formatDate(row.attendance_date) }}</td>
                <td>{{ row.clock_in_at || '-' }}</td>
                <td>{{ row.clock_out_at || '-' }}</td>
                <td>
                  <span class="rounded-full px-2 py-1 text-[11px] font-bold uppercase tracking-wide" :class="statusClass(row.status)">{{ row.status }}</span>
                </td>
              </tr>
              <tr v-if="!(data.attendance || []).length">
                <td colspan="4" class="p-2 text-sm text-slate-500">No attendance rows for this month.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>
  </section>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'

const loading = ref(false)
const selectedMonth = ref(new Date().toISOString().slice(0, 7))
const data = ref({
  period_label: '',
  provider_name: '',
  daily_rate: 0,
  days_present: 0,
  completed_jobs: 0,
  gross_pay: 0,
  net_pay: 0,
  deductions: { late: 0, absence: 0, platform_fee: 0, total: 0 },
  attendance: [],
})

const formatMoney = (value) => {
  const amount = Number(value || 0)
  return amount.toLocaleString(undefined, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
}

const formatDate = (value) => {
  if (!value) return '-'
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return value
  return parsed.toLocaleDateString()
}

const statusClass = (status) => {
  const normalized = String(status || '').toLowerCase()
  if (normalized === 'late') return 'bg-amber-100 text-amber-700'
  if (normalized === 'absent') return 'bg-rose-100 text-rose-700'
  return 'bg-emerald-100 text-emerald-700'
}

const fetchPayslip = async () => {
  loading.value = true
  try {
    const res = await axios.get('/service-provider/payslip-data', {
      params: { month: selectedMonth.value },
    })
    data.value = { ...data.value, ...res.data }
  } catch (error) {
    Swal.fire('Error', error.response?.data?.message || 'Failed to load payslip data.', 'error')
  } finally {
    loading.value = false
  }
}

onMounted(fetchPayslip)
</script>




