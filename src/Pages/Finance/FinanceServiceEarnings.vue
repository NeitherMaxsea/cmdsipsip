<template>
  <FinanceShell
    title="Service Earnings"
    subtitle="View earnings by service category."
    active-path="/finance/service-earnings"
  >
    <div class="panel">
      <h3>Service Income Breakdown</h3>
      <table>
        <thead>
          <tr>
            <th>Service</th>
            <th>Completed Jobs</th>
            <th>Gross Earnings</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.service">
            <td>{{ row.service }}</td>
            <td>{{ row.jobs }}</td>
            <td>{{ money(row.earnings) }}</td>
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
