<template>
  <FinanceShell
    title="Payment Processing"
    subtitle="Review captured payment transactions and methods."
    active-path="/finance/payment-process"
  >
    <div class="panel">
      <h3>Payment Records</h3>
      <table>
        <thead>
          <tr>
            <th>Ref No</th>
            <th>Invoice</th>
            <th>Method</th>
            <th>Amount</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.id">
            <td>{{ row.ref }}</td>
            <td>{{ row.invoice }}</td>
            <td>{{ row.method }}</td>
            <td>{{ money(row.amount) }}</td>
            <td><span class="badge" :class="row.status">{{ row.status }}</span></td>
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
  rows: {
    type: Array,
    default: () => [],
  },
})

const rows = computed(() => props.rows)

function money(value) {
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP' }).format(value || 0)
}
</script>
