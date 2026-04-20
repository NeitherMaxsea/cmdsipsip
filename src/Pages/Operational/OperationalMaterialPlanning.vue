<template>
  <div class="h-screen overflow-hidden bg-slate-100">
    <div class="flex h-full min-h-0 max-lg:flex-col">
    <OperationsSidebar active="materials" />

    <div class="flex min-h-0 flex-1 flex-col bg-slate-50">
      <OperationalTopbar @refresh="fetchDashboard" @logout="logout" />

      <main class="flex-1 overflow-y-auto p-4 sm:p-6">
      <div class="mx-auto max-w-7xl space-y-6">
        <section class="overflow-hidden rounded-2xl border-t-4 border-t-teal-600 bg-gradient-to-b from-white to-slate-50 p-6 shadow-sm ring-1 ring-slate-200">
          <div>
            <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-teal-700">Operational Management</p>
            <h1 class="mt-1 text-4xl font-extrabold leading-none tracking-tight text-slate-900">Materials Coordination</h1>
            <p class="mt-2 text-sm text-slate-600">Track PR statuses and submit material planning after Operations confirms team assignment, inspection needs, or service release requirements.</p>
          </div>
        </section>

        <section class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <h3 class="text-sm font-semibold text-slate-800">Purchase Requisition Status</h3>
          <div class="mt-3 grid grid-cols-2 gap-2 md:grid-cols-4 xl:grid-cols-7">
            <div class="rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 text-xs">
              <p class="text-slate-500">Pending</p>
              <p class="mt-1 text-lg font-bold text-slate-800">{{ prSummary.pending }}</p>
            </div>
            <div class="rounded-lg border border-amber-200 bg-amber-50 px-3 py-2 text-xs">
              <p class="text-amber-700">Pending Finance</p>
              <p class="mt-1 text-lg font-bold text-amber-800">{{ prSummary.pending_finance_approval }}</p>
            </div>
            <div class="rounded-lg border border-emerald-200 bg-emerald-50 px-3 py-2 text-xs">
              <p class="text-emerald-700">Approved</p>
              <p class="mt-1 text-lg font-bold text-emerald-800">{{ prSummary.approved }}</p>
            </div>
            <div class="rounded-lg border border-rose-200 bg-rose-50 px-3 py-2 text-xs">
              <p class="text-rose-700">Rejected</p>
              <p class="mt-1 text-lg font-bold text-rose-800">{{ prSummary.rejected }}</p>
            </div>
            <div class="rounded-lg border border-cyan-200 bg-cyan-50 px-3 py-2 text-xs">
              <p class="text-cyan-700">In Transit</p>
              <p class="mt-1 text-lg font-bold text-cyan-800">{{ prSummary.in_transit }}</p>
            </div>
            <div class="rounded-lg border border-indigo-200 bg-indigo-50 px-3 py-2 text-xs">
              <p class="text-indigo-700">Delivered</p>
              <p class="mt-1 text-lg font-bold text-indigo-800">{{ prSummary.delivered }}</p>
            </div>
            <div class="rounded-lg border border-teal-200 bg-teal-50 px-3 py-2 text-xs">
              <p class="text-teal-700">Completed</p>
              <p class="mt-1 text-lg font-bold text-teal-800">{{ prSummary.completed }}</p>
            </div>
          </div>
        </section>

        <section class="rounded-2xl border border-slate-200 bg-white shadow-sm">
          <div class="border-b border-slate-200 px-4 py-3">
            <h2 class="text-base font-semibold text-slate-900">Requests for Material Coordination</h2>
          </div>
          <div v-if="loading" class="p-4 text-sm text-slate-500">Loading requests...</div>
          <div v-else-if="!planningRows.length" class="p-4 text-sm text-slate-500">No requests pending material planning.</div>
          <div v-else class="overflow-x-auto">
            <table class="min-w-full text-sm">
              <thead class="bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
                <tr>
                  <th class="px-4 py-3">Request</th>
                  <th class="px-4 py-3">Service</th>
                  <th class="px-4 py-3">Selected Team</th>
                  <th class="px-4 py-3">Status</th>
                  <th class="px-4 py-3">PR</th>
                  <th class="px-4 py-3">Updated</th>
                  <th class="px-4 py-3 text-right">Action</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-200">
                <tr v-for="item in planningRows" :key="item.id">
                  <td class="px-4 py-3 font-semibold text-slate-900">#{{ item.id }}</td>
                  <td class="px-4 py-3 text-slate-700">{{ item.service_type || 'N/A' }}</td>
                  <td class="px-4 py-3 text-slate-700">{{ item.selected_team || 'N/A' }}</td>
                  <td class="px-4 py-3">
                    <span class="rounded-full px-2.5 py-1 text-xs font-semibold" :class="statusClass(item.status)">
                      {{ prettyStatus(item.status) }}
                    </span>
                  </td>
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
                  <td class="px-4 py-3 text-right">
                    <button
                      type="button"
                      class="rounded-md bg-amber-600 px-2.5 py-1 text-xs font-semibold text-white hover:bg-amber-700 disabled:opacity-50"
                      :disabled="workingRequestId === item.id"
                      @click="planMaterials(item)"
                    >
                      Plan Materials
                    </button>
                  </td>
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
import { computed, onMounted } from 'vue'
import OperationsSidebar from './Partials/OperationsSidebar.vue'
import OperationalTopbar from './Partials/OperationalTopbar.vue'
import { useOperationalData } from './useOperationalData'

const {
  loading,
  workingRequestId,
  queue,
  prSummary,
  prettyStatus,
  statusClass,
  prettyPrStatus,
  prStatusClass,
  fetchDashboard,
  planMaterials,
  logout,
} = useOperationalData()

const planningRows = computed(() =>
  queue.value.filter((item) => item.can_plan_materials)
)

onMounted(fetchDashboard)
</script>
