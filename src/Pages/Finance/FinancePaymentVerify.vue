<template>
  <FinanceShell
    title="Payment Verification"
    subtitle="Validate expected versus received payment amounts."
    active-path="/finance/payment-verify"
  >
    <div class="panel">
      <h3>Verification Queue</h3>
      <table>
        <thead>
          <tr>
            <th>Payment Ref</th>
            <th>Invoice</th>
            <th>Expected</th>
            <th>Received</th>
            <th>Result</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in queue" :key="item.id">
            <td>{{ item.ref }}</td>
            <td>{{ item.invoice }}</td>
            <td>{{ money(item.expected) }}</td>
            <td>{{ money(item.received) }}</td>
            <td>
              <span class="badge" :class="item.expected === item.received ? 'ok' : 'review'">
                {{ item.expected === item.received ? 'Match' : 'Needs Review' }}
              </span>
            </td>
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
  queue: {
    type: Array,
    default: () => [],
  },
})

const queue = computed(() => props.queue)

function money(value) {
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP' }).format(value || 0)
}
</script>
