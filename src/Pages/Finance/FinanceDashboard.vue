<template>
  <FinanceShell
    title="Finance Dashboard"
    subtitle="Monitor payment checks, procurement budget reviews, payouts, and finance reporting."
    active-path="/finance"
  >
    <div class="stats-grid">
      <div class="stat-card" v-for="card in cards" :key="card.label">
        <p class="label">{{ card.label }}</p>
        <h3>{{ card.value }}</h3>
      </div>
    </div>

    <div class="panel">
      <h3>Recent Invoices</h3>
      <table>
        <thead>
          <tr>
            <th>Invoice No</th>
            <th>Client</th>
            <th>Status</th>
            <th>Amount</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="inv in recentInvoices" :key="inv.id">
            <td>{{ inv.invoice_no }}</td>
            <td>{{ inv.client }}</td>
            <td>
              <span class="badge" :class="inv.status">{{ inv.status }}</span>
            </td>
            <td>{{ money(inv.amount) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </FinanceShell>
</template>

<script setup>
import { computed } from 'vue'
import FinanceShell from './FinanceShell.vue'

const props = defineProps({
  recentInvoices: {
    type: Array,
    default: () => [],
  },
  cards: {
    type: Array,
    default: () => [],
  },
})

const recentInvoices = computed(() => props.recentInvoices)
const cards = computed(() =>
  props.cards.map((card) => ({
    ...card,
    value: typeof card.value === 'number' && !String(card.label).toLowerCase().includes('invoice')
      ? money(card.value)
      : String(card.value),
  })),
)

function money(value) {
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP' }).format(value || 0)
}
</script>
