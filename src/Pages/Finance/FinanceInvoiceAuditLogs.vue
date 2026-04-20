<template>
  <FinanceShell
    title="Invoice Audit Logs"
    subtitle="Review invoice activity history and traceability."
    active-path="/finance/invoice-audit-logs"
  >
    <div class="panel">
      <h3>Audit Trail</h3>
      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Invoice</th>
            <th>Action</th>
            <th>Updated By</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="log in logs" :key="log.id">
            <td>{{ log.date }}</td>
            <td>{{ log.invoice }}</td>
            <td>{{ log.action }}</td>
            <td>{{ log.user }}</td>
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
  logs: {
    type: Array,
    default: () => [],
  },
})

const logs = computed(() => props.logs)
</script>
