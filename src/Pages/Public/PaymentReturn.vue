<template>
  <div class="min-h-screen bg-gradient-to-br from-teal-50 via-cyan-50 to-slate-100 flex items-center justify-center p-4">
    <div class="w-full max-w-2xl rounded-3xl bg-white/95 shadow-xl border border-slate-200 p-6 sm:p-7">
      <div class="flex items-start justify-between gap-3">
        <div>
          <h1 class="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">Payment Summary</h1>
          <p class="mt-1 text-sm text-slate-600">{{ statusLabel }}</p>
        </div>
        <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-bold capitalize" :class="statusBadgeClass">
          {{ normalize(resolvedStatus) }}
        </span>
      </div>

      <div class="mt-5 rounded-2xl border border-slate-200 p-4 bg-slate-50/90">
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-slate-800">
          <p><strong>Reference:</strong> {{ resolvedInvoice?.reference || '-' }}</p>
          <p><strong>Amount:</strong> {{ amountLabel }}</p>
          <p><strong>Phase:</strong> <span class="capitalize">{{ normalize(resolvedInvoice?.phase) }}</span></p>
          <p><strong>Channel:</strong> <span class="capitalize">{{ normalize(resolvedInvoice?.payment_channel) }}</span></p>
        </div>
      </div>

      <div class="mt-4">
        <div class="h-2 w-full rounded-full bg-slate-200 overflow-hidden">
          <div class="h-full bg-gradient-to-r from-teal-500 to-cyan-500 transition-all duration-300" :style="{ width: `${progressPercent}%` }"></div>
        </div>
        <p class="mt-2 text-sm text-slate-500">Redirecting to dashboard in {{ secondsLeft }}s...</p>
      </div>

      <div class="mt-5 flex flex-wrap gap-3">
        <a :href="dashboardUrl" class="inline-flex items-center rounded-lg bg-teal-600 px-4 py-2 text-white font-semibold hover:bg-teal-700">
          Go to Dashboard
        </a>
        <a v-if="showInvoiceLink" :href="resolvedInvoice.invoice_url" target="_blank" rel="noopener" class="inline-flex items-center rounded-lg border border-slate-300 px-4 py-2 text-slate-700 font-semibold hover:bg-slate-100">
          Open Payment Page
        </a>
      </div>
    </div>
  </div>
</template>

<script setup>
import axios from 'axios'
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

const props = defineProps({
  status: { type: String, default: 'pending' },
  invoice: { type: Object, default: null },
  dashboard_url: { type: String, default: '/dashboard' },
})

const REDIRECT_SECONDS = 5
const getQueryParam = (key) => {
  if (typeof window === 'undefined') return ''
  return String(new URLSearchParams(window.location.search).get(key) || '').trim()
}

const requestRecord = ref(null)
const loading = ref(false)
const requestId = ref(getQueryParam('request_id'))
const queryStatus = ref(getQueryParam('status'))
const queryDashboardUrl = ref(getQueryParam('dashboard_url'))

const prettifyValue = (value) => {
  const text = String(value || '').trim().replace(/[_-]+/g, ' ')
  return text ? text.replace(/\b\w/g, (letter) => letter.toUpperCase()) : '-'
}
const normalize = (value) => prettifyValue(value)
const buildFallbackInvoice = (request) => {
  if (!request || typeof request !== 'object') return null

  const paymentMethod = String(request.payment_method || '').trim().toLowerCase()
  const downpaymentAmount = Number(request.downpayment_amount || 0)
  const totalAmount = Number(request.total_amount || 0)
  const derivedAmount = paymentMethod === 'downpayment' && Number.isFinite(downpaymentAmount) && downpaymentAmount > 0
    ? downpaymentAmount
    : Number.isFinite(totalAmount) && totalAmount > 0
      ? totalAmount
      : null
  const derivedPhase = paymentMethod === 'downpayment'
    ? 'downpayment'
    : paymentMethod === 'personal'
      ? 'on_site'
      : paymentMethod === 'full'
        ? 'full'
        : 'request'

  return {
    id: request.id,
    reference: `INV-${request.id}`,
    amount: derivedAmount,
    currency: request.currency || 'PHP',
    phase: derivedPhase,
    status: String(request.payment_status || queryStatus.value || props.status || 'pending').trim().toLowerCase() || 'pending',
    payment_channel: request.payment_channel || (paymentMethod === 'personal' ? 'on_site' : ''),
    invoice_url: '',
  }
}

const requestServiceTrack = (request) => {
  const raw = String(
    request?.service_track
    || request?.service_type
    || request?.category
    || request?.category_label
    || ''
  ).trim().toLowerCase()
  if (/(siphon|septic|desludg|vacuum|jetter)/.test(raw)) return 'siphoning'
  return raw
}

const inspectionBillingNotice = 'Inspection required before final billing'

const hasCompletedInspection = (request) => {
  const result = String(request?.inspection_result || '').trim().toLowerCase()
  if (['minor', 'major'].includes(result)) return true
  const status = String(request?.status || '').trim().toLowerCase()
  return ['completed', 'warranty_pending', 'warranty_rework'].includes(status)
}

const isInspectionBillingRequired = (request) => requestServiceTrack(request) === 'siphoning'

const canShowInvoiceAmount = (request, invoice) => {
  if (!isInspectionBillingRequired(request)) return true
  if (hasCompletedInspection(request)) return true
  const phase = String(invoice?.phase || '').trim().toLowerCase()
  const paymentMethod = String(request?.payment_method || '').trim().toLowerCase()
  return phase === 'downpayment' || paymentMethod === 'downpayment'
}

const resolvedInvoice = computed(() => props.invoice || requestRecord.value?.latest_invoice || buildFallbackInvoice(requestRecord.value))
const resolvedStatus = computed(() => {
  return String(resolvedInvoice.value?.status || queryStatus.value || props.status || 'pending').trim().toLowerCase() || 'pending'
})
const dashboardUrl = computed(() => props.dashboard_url || queryDashboardUrl.value || '/dashboard')
const currentPageUrl = computed(() => {
  if (typeof window === 'undefined') return ''
  return `${window.location.pathname}${window.location.search}`
})
const showInvoiceLink = computed(() => {
  if (loading.value) return false
  const target = String(resolvedInvoice.value?.invoice_url || '').trim()
  return Boolean(target) && target !== currentPageUrl.value && canShowInvoiceAmount(requestRecord.value, resolvedInvoice.value)
})
const amountLabel = computed(() => {
  if (loading.value && requestId.value && !requestRecord.value) return 'Loading payment details.'
  if (!canShowInvoiceAmount(requestRecord.value, resolvedInvoice.value)) return inspectionBillingNotice
  if (!resolvedInvoice.value || resolvedInvoice.value.amount == null) return '-'
  const amount = Number(resolvedInvoice.value.amount)
  if (!Number.isFinite(amount)) return '-'
  const currency = String(resolvedInvoice.value.currency || 'PHP').toUpperCase()
  return `${currency} ${amount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
})

const statusBadgeClass = computed(() => {
  const s = resolvedStatus.value
  if (s === 'paid' || s === 'success') return 'bg-emerald-100 text-emerald-700'
  if (s === 'failed' || s === 'error') return 'bg-rose-100 text-rose-700'
  if (s === 'cancelled') return 'bg-slate-200 text-slate-700'
  return 'bg-amber-100 text-amber-700'
})

const statusLabel = computed(() => {
  const s = resolvedStatus.value
  if (s === 'cancelled') return 'Payment was cancelled. You can try again anytime.'
  if (s === 'failed') return 'Payment failed. Please try again.'
  if (s === 'paid' || s === 'success') return 'Payment flow completed. Your invoice status will update after confirmation.'
  if (!canShowInvoiceAmount(requestRecord.value, resolvedInvoice.value)) return 'Inspection required before final billing. The amount will update after site assessment.'
  if (loading.value) return 'Loading payment details.'
  return 'Request saved. Payment details will update once the invoice is confirmed.'
})

const secondsLeft = ref(REDIRECT_SECONDS)
const progressPercent = computed(() => {
  const done = REDIRECT_SECONDS - Number(secondsLeft.value || 0)
  return Math.max(0, Math.min(100, Math.round((done / REDIRECT_SECONDS) * 100)))
})
let timer = null
const fetchRequestSummary = async () => {
  if (props.invoice || !requestId.value) return

  try {
    loading.value = true
    const response = await axios.get(`/user/service-requests/${encodeURIComponent(requestId.value)}`, {
      skipGlobalLoading: true,
    })
    requestRecord.value = response?.data || null
  } catch {
    requestRecord.value = null
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchRequestSummary()
  timer = setInterval(() => {
    if (secondsLeft.value <= 1) {
      clearInterval(timer)
      window.location.assign(dashboardUrl.value)
      return
    }
    secondsLeft.value -= 1
  }, 1000)
})

onBeforeUnmount(() => {
  if (timer) clearInterval(timer)
})
</script>
