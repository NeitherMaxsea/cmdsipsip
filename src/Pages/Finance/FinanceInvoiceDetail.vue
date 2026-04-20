<template>
  <FinanceShell
    title="Invoice Detail"
    subtitle="Inspect invoice, customer, and payment details."
    active-path="/finance/invoice"
  >
    <div>
      <section class="no-print mb-3.5 flex flex-wrap gap-2.5 print:hidden">
        <a class="cursor-pointer rounded-[10px] bg-slate-700 px-3.5 py-2.5 text-sm font-bold text-white no-underline" href="/finance/invoice">Back to Invoices</a>
        <button class="cursor-pointer rounded-[10px] bg-[linear-gradient(135deg,#0f766e,#14b8a6)] px-3.5 py-2.5 text-sm font-bold text-white" type="button" @click="printInvoice">Print / Save PDF</button>
        <button class="cursor-pointer rounded-[10px] bg-slate-800 px-3.5 py-2.5 text-sm font-bold text-white" type="button" @click="copySummary">Copy Details</button>
        <a
          v-if="invoice.invoice_url"
          class="cursor-pointer rounded-[10px] bg-[linear-gradient(135deg,#059669,#10b981)] px-3.5 py-2.5 text-sm font-bold text-white no-underline"
          :href="invoice.invoice_url"
          target="_blank"
          rel="noopener"
        >
          Open Payment Link
        </a>
      </section>

      <article
        id="invoice-card"
        class="rounded-[18px] border border-[#dbe4ee] bg-[radial-gradient(1200px_500px_at_110%_-20%,rgba(20,184,166,0.16),transparent_45%),radial-gradient(800px_360px_at_-10%_120%,rgba(14,116,144,0.14),transparent_46%),#fff] p-[22px] text-slate-900 print:border-0 print:bg-white print:p-0 print:shadow-none"
      >
        <header class="mb-4 flex items-start justify-between gap-3">
          <div>
            <p class="mb-1.5 text-[11px] font-medium uppercase tracking-[0.12em] text-teal-700">Service Billing</p>
            <h1 class="m-0 text-[clamp(22px,3.2vw,32px)] font-bold">Invoice {{ displayInvoiceNo }}</h1>
            <p class="mt-1.5 text-slate-600">Created {{ formatDate(invoice.created_at) }}</p>
          </div>
          <div
            class="rounded-full bg-slate-100 px-3 py-2 text-xs font-bold text-slate-900"
            :class="{
              'bg-emerald-100 text-emerald-800': (invoice.status || '').toLowerCase() === 'paid',
              'bg-amber-100 text-amber-800': (invoice.status || '').toLowerCase() === 'pending',
              'bg-red-100 text-red-800': ['failed', 'expired'].includes((invoice.status || '').toLowerCase()),
            }"
          >
            {{ String(invoice.status || 'pending').toUpperCase() }}
          </div>
        </header>

        <section class="mb-3 grid grid-cols-1 gap-3 min-[900px]:grid-cols-2">
          <div class="rounded-xl border border-slate-200 bg-white p-3.5">
            <p class="mb-2 text-[11px] uppercase tracking-[0.08em] text-slate-500">Billed To</p>
            <h3>{{ invoice.customer_name || '-' }}</h3>
            <p>{{ invoice.customer_email || '-' }}</p>
            <p>{{ invoice.customer_contact || '-' }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-white p-3.5">
            <p class="mb-2 text-[11px] uppercase tracking-[0.08em] text-slate-500">Business</p>
            <h3>{{ invoice.business_name || '-' }}</h3>
            <p>{{ invoice.address_text || '-' }}</p>
          </div>
        </section>

        <section class="mb-3 grid grid-cols-1 gap-3 min-[900px]:grid-cols-2">
          <div class="rounded-xl border border-slate-200 bg-white p-3.5">
            <p class="mb-2 text-[11px] uppercase tracking-[0.08em] text-slate-500">Invoice Details</p>
            <p><strong>Phase:</strong> {{ normalizeText(invoice.phase) }}</p>
            <p><strong>Service Type:</strong> {{ normalizeText(invoice.service_type) }}</p>
            <p><strong>Payment Method:</strong> {{ normalizeText(invoice.payment_method) }}</p>
            <p><strong>Payment Channel:</strong> {{ normalizeText(invoice.payment_channel) }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-white p-3.5">
            <p class="mb-2 text-[11px] uppercase tracking-[0.08em] text-slate-500">References</p>
            <p><strong>Internal Ref:</strong> {{ invoice.external_id || '-' }}</p>
            <p><strong>Gateway Transaction ID:</strong> {{ invoice.gateway_transaction_id || '-' }}</p>
            <p><strong>Due Date:</strong> {{ formatDate(invoice.due_at) }}</p>
            <p><strong>Paid At:</strong> {{ formatDate(invoice.paid_at) }}</p>
          </div>
        </section>

        <section class="mt-3.5 flex items-center justify-between gap-4 rounded-[14px] border border-slate-300 bg-[linear-gradient(135deg,#0b4f6c,#0f766e)] p-4 text-white">
          <div>
            <p class="mb-1.5 opacity-90">Total Amount</p>
            <h2 class="m-0 text-[clamp(22px,4vw,34px)] font-bold">{{ money(invoice.amount, invoice.currency) }}</h2>
          </div>
          <div>
            <p>Service Request #{{ invoice.service_request_id }}</p>
            <p>Payment Status: {{ normalizeText(invoice.payment_status) }}</p>
          </div>
        </section>

        <section v-if="invoice.notes" class="mt-3.5 rounded-xl border border-dashed border-slate-400 bg-slate-50 p-3.5">
          <p class="mb-2 text-[11px] uppercase tracking-[0.08em] text-slate-500">Notes</p>
          <p>{{ invoice.notes }}</p>
        </section>
      </article>
    </div>
  </FinanceShell>
</template>

<script setup>
import FinanceShell from './FinanceShell.vue'
import Swal from '@/lib/sweetalert-toast-shim'

const props = defineProps({
  invoice: {
    type: Object,
    required: true,
  },
})

const invoice = props.invoice
const displayInvoiceNo = invoice.gateway_transaction_id || invoice.external_id || `INV-${invoice.id}`

function money(value, currency = 'PHP') {
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: currency || 'PHP' }).format(value || 0)
}

function formatDate(value) {
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

function normalizeText(value) {
  if (!value) return '-'
  return String(value).replaceAll('_', ' ')
}

function printInvoice() {
  window.print()
}

async function copySummary() {
  const lines = [
    `Invoice: ${displayInvoiceNo}`,
    `Customer: ${invoice.customer_name || '-'}`,
    `Business: ${invoice.business_name || '-'}`,
    `Amount: ${money(invoice.amount, invoice.currency)}`,
    `Status: ${normalizeText(invoice.status)}`,
    `Due: ${formatDate(invoice.due_at)}`,
    `Payment Link: ${invoice.invoice_url || '-'}`,
  ]

  try {
    await navigator.clipboard.writeText(lines.join('\n'))
    await Swal.fire('Copied', 'Invoice details copied.', 'success')
  } catch (_e) {
    await Swal.fire('Copy Failed', 'Unable to copy automatically. Please copy manually.', 'error')
  }
}
</script>

