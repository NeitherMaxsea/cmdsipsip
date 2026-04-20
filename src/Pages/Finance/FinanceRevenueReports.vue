<template>
  <FinanceShell
    title="Revenue Reports"
    subtitle="Analyze revenue performance by reporting period."
    active-path="/finance/revenue-reports"
  >
    <div class="tools">
      <label>
        Report Period
        <select v-model="period">
          <option value="daily">Daily</option>
          <option value="weekly">Weekly</option>
          <option value="monthly">Monthly</option>
        </select>
      </label>
    </div>

    <div class="stats-grid">
      <div class="stat-card">
        <p>Total Revenue</p>
        <h3>{{ money(current.total) }}</h3>
      </div>
      <div class="stat-card">
        <p>Paid Revenue</p>
        <h3>{{ money(current.paid) }}</h3>
      </div>
      <div class="stat-card">
        <p>Pending Revenue</p>
        <h3>{{ money(current.pending) }}</h3>
      </div>
    </div>
  </FinanceShell>
</template>

<script setup>
import { computed, ref } from 'vue'
import FinanceShell from './FinanceShell.vue'

const props = defineProps({
  reportByPeriod: {
    type: Object,
    default: () => ({
      daily: { total: 0, paid: 0, pending: 0 },
      weekly: { total: 0, paid: 0, pending: 0 },
      monthly: { total: 0, paid: 0, pending: 0 },
    }),
  },
})

const period = ref('daily')

const current = computed(() => props.reportByPeriod[period.value] || { total: 0, paid: 0, pending: 0 })

function money(value) {
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP' }).format(value || 0)
}
</script>
