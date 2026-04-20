<template>
  <FinanceShell
    title="Field Team Earnings"
    subtitle="Track workforce and partner earnings for payroll and payout review."
    active-path="/finance/technician-earnings"
  >
    <div class="panel">
      <h3>Field Team Earnings Summary</h3>
      <table>
        <thead>
          <tr>
            <th>Technician</th>
            <th>Completed Jobs</th>
            <th>Earnings</th>
            <th>Payout Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="tech in technicians" :key="tech.id">
            <td>{{ tech.name }}</td>
            <td>{{ tech.jobs }}</td>
            <td>{{ money(tech.earnings) }}</td>
            <td><span class="badge" :class="tech.status">{{ tech.status }}</span></td>
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
  technicians: {
    type: Array,
    default: () => [],
  },
})

const technicians = computed(() => props.technicians)

function money(value) {
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP' }).format(value || 0)
}
</script>
