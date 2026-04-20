<template>
  <div class="h-screen overflow-hidden bg-slate-100">
    <div class="flex h-full min-h-0 max-lg:flex-col">
    <OperationsSidebar active="flow" />

    <div class="flex min-h-0 flex-1 flex-col bg-slate-50">
      <OperationalTopbar @refresh="fetchDashboard" @logout="logout" />

      <main class="flex-1 overflow-y-auto p-4 sm:p-6">
      <div class="mx-auto max-w-7xl space-y-6">
        <section class="overflow-hidden rounded-2xl border-t-4 border-t-teal-600 bg-gradient-to-b from-white to-slate-50 p-6 shadow-sm ring-1 ring-slate-200">
          <div>
            <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-teal-700">Operational Management</p>
            <h1 class="mt-1 text-4xl font-extrabold leading-none tracking-tight text-slate-900">Request Workflow Tracker</h1>
            <p class="mt-2 text-sm text-slate-600">View each request from CSR intake, through Operations review, approved employee or team assignment, conditional Procurement and Finance checks, up to dispatch and closure.</p>
          </div>
        </section>

        <section class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <h3 class="text-sm font-semibold text-slate-800">Interview-Based Workflow Alignment</h3>
          <div class="mt-3 grid grid-cols-1 gap-2 md:grid-cols-2 xl:grid-cols-4">
            <div v-for="step in flowSteps" :key="step.id" class="rounded-lg border border-slate-200 bg-slate-50 px-3 py-2">
              <p class="text-[11px] font-bold uppercase tracking-wide text-slate-500">Step {{ step.id }}</p>
              <p class="mt-1 text-sm font-semibold text-slate-800">{{ step.title }}</p>
              <p class="mt-1 text-xs text-slate-500">{{ step.summary }}</p>
            </div>
          </div>
        </section>

        <section class="rounded-2xl border border-slate-200 bg-white shadow-sm">
          <div class="border-b border-slate-200 px-4 py-3">
            <h2 class="text-base font-semibold text-slate-900">Flow Stage by Request</h2>
          </div>
          <div v-if="loading" class="p-4 text-sm text-slate-500">Loading flow data...</div>
          <div v-else-if="!queue.length" class="p-4 text-sm text-slate-500">No requests available.</div>
          <div v-else class="overflow-x-auto">
            <table class="min-w-full text-sm">
              <thead class="bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
                <tr>
                  <th class="px-4 py-3">Request</th>
                  <th class="px-4 py-3">Service</th>
                  <th class="px-4 py-3">Status</th>
                  <th class="px-4 py-3">Flow Stage</th>
                  <th class="px-4 py-3">Company Terms</th>
                  <th class="px-4 py-3">Next Action</th>
                  <th class="px-4 py-3">PR</th>
                  <th class="px-4 py-3">Updated</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-200">
                <tr v-for="item in queue" :key="item.id">
                  <td class="px-4 py-3 font-semibold text-slate-900">
                    <p>#{{ item.id }}</p>
                    <p class="mt-1 text-xs font-medium text-slate-500">{{ item.customer_name || 'N/A' }}</p>
                  </td>
                  <td class="px-4 py-3 text-slate-700">
                    <p class="font-semibold text-slate-900">{{ item.service_type || 'N/A' }}</p>
                    <div class="mt-2 flex flex-wrap gap-1">
                      <span
                        v-for="chip in requestMetaChips(item)"
                        :key="`${item.id}-${chip}`"
                        class="rounded-full bg-slate-100 px-2 py-0.5 text-[11px] font-semibold text-slate-600"
                      >
                        {{ chip }}
                      </span>
                    </div>
                  </td>
                  <td class="px-4 py-3">
                    <span class="rounded-full px-2.5 py-1 text-xs font-semibold" :class="statusClass(item.status)">
                      {{ prettyStatus(item.status) }}
                    </span>
                  </td>
                  <td class="px-4 py-3 text-xs text-slate-700">
                    <p class="font-semibold text-slate-800">{{ flowStage(item) }}</p>
                      <p class="mt-1 text-[11px] text-slate-500">
                        {{ item.workflow_stage ? `CSR: ${prettyStatus(item.workflow_stage)}` : 'CSR: Waiting on intake stage' }}
                      </p>
                      <p class="text-[11px] text-slate-500">
                        {{ item.procurement_stage ? `Procurement: ${prettyStatus(item.procurement_stage)}` : `Stock: ${prettyStatus(item.stock_status)}` }}
                      </p>
                      <p class="text-[11px] text-slate-500">
                        {{ item.pricing_stage ? `Pricing: ${prettyStatus(item.pricing_stage)}` : 'Pricing: Awaiting review' }}
                      </p>
                  </td>
                  <td class="px-4 py-3 text-xs text-slate-600">
                    <p class="font-semibold text-slate-800">{{ paymentTermsLabel(item.payment_terms) }}</p>
                    <p class="mt-1">{{ item.payment_channel ? paymentChannelLabel(item.payment_channel) : 'No channel tagged yet' }}</p>
                    <p v-if="item.payment_due_days" class="mt-1 text-[11px] text-slate-500">Balance due in {{ item.payment_due_days }} day(s)</p>
                  </td>
                  <td class="px-4 py-3 text-xs text-slate-600">{{ nextFlowAction(item) }}</td>
                  <td class="px-4 py-3">
                    <div class="flex flex-wrap gap-1">
                      <span
                        v-for="pr in item.pr_statuses || []"
                        :key="`${item.id}-${pr}`"
                        class="rounded-full px-2 py-0.5 text-[11px] font-semibold"
                        :class="prStatusClass(pr)"
                      >
                        {{ prettyPrStatus(pr) }}
                      </span>
                      <span v-if="!(item.pr_statuses || []).length" class="text-xs text-slate-500">-</span>
                    </div>
                  </td>
                  <td class="px-4 py-3 text-slate-600">{{ item.updated_at || 'N/A' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>
      </main>
    </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import OperationsSidebar from './Partials/OperationsSidebar.vue'
import OperationalTopbar from './Partials/OperationalTopbar.vue'
import { useOperationalData } from './useOperationalData'

const {
  loading,
  queue,
  flowSteps,
  prettyStatus,
  statusClass,
  prettyPrStatus,
  prStatusClass,
  flowStage,
  nextFlowAction,
  paymentTermsLabel,
  paymentChannelLabel,
  requestMetaChips,
  fetchDashboard,
  logout,
} = useOperationalData()

onMounted(fetchDashboard)
</script>
