<template>
  <FinanceShell
    title="Finance Invoices"
    subtitle="Track invoice lifecycle and payment status."
    active-path="/finance/invoice"
  >
    <div class="tools">
      <input v-model="search" type="text" placeholder="Search invoice or client..." />
      <select v-model="statusFilter">
        <option value="all">All Statuses</option>
        <option value="paid">Paid</option>
        <option value="pending">Pending</option>
        <option value="overdue">Overdue</option>
      </select>
    </div>

    <div class="panel">
      <table>
        <thead>
          <tr>
            <th>Invoice No</th>
            <th>Client</th>
            <th>Status</th>
            <th>Amount</th>
            <th>Due Date</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="inv in filteredInvoices" :key="inv.id">
            <td>{{ inv.invoice_no }}</td>
            <td>{{ inv.client }}</td>
            <td><span class="badge" :class="inv.status">{{ inv.status }}</span></td>
            <td>{{ money(inv.amount) }}</td>
            <td>{{ inv.due_date }}</td>
            <td>
              <a
                :href="inv.view_url"
                class="inline-flex min-w-[72px] items-center justify-center rounded-lg bg-[linear-gradient(135deg,#0f766e,#0ea5a4)] px-[10px] py-1.5 text-xs font-semibold text-white no-underline hover:brightness-105"
              >
                View
              </a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </FinanceShell>
</template>

<script setup>
import { computed, ref } from 'vue'
import FinanceShell from './FinanceShell.vue'

const props = defineProps({
  invoices: {
    type: Array,
    default: () => [],
  },
})

const search = ref('')
const statusFilter = ref('all')

const sourceInvoices = computed(() => props.invoices)

const filteredInvoices = computed(() => {
  const term = search.value.trim().toLowerCase()
  return sourceInvoices.value.filter((inv) => {
    const normalizedStatus = (inv.status || '').toLowerCase()
    const matchStatus = statusFilter.value === 'all' || normalizedStatus === statusFilter.value
    const matchTerm = !term || inv.invoice_no.toLowerCase().includes(term) || inv.client.toLowerCase().includes(term)
    return matchStatus && matchTerm
  })
})

function money(value) {
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP' }).format(value || 0)
}
</script>
