<template>
  <div class="h-screen overflow-hidden bg-slate-100">
    <div class="flex h-full min-h-0 max-lg:flex-col">
    <OperationsSidebar active="dashboard" />

    <div class="flex min-h-0 flex-1 flex-col bg-slate-50">
      <OperationalTopbar @refresh="fetchDashboard" @logout="logout" />

      <main class="flex-1 overflow-y-auto p-4 sm:p-6">
      <div class="mx-auto max-w-7xl space-y-6">
        <section class="overflow-hidden rounded-2xl border-t-4 border-t-teal-600 bg-gradient-to-b from-white to-slate-50 p-6 shadow-sm ring-1 ring-slate-200">
          <div>
            <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-teal-700">Operational Management</p>
            <h1 class="mt-1 text-4xl font-extrabold leading-none tracking-tight text-slate-900">Operational Management Workspace</h1>
            <p class="mt-2 text-sm text-slate-600">Receive CSR-endorsed requests, assign approved employees or teams, decide if inspection is needed, coordinate materials, and confirm dispatch readiness.</p>
          </div>
        </section>

        <section class="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
          <article class="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
            <p class="text-xs uppercase tracking-wide text-slate-500">Total Work Orders</p>
            <p class="mt-1 text-3xl font-extrabold text-slate-900">{{ stats.total_requests }}</p>
          </article>
          <article class="rounded-xl border border-amber-200 bg-amber-50 p-4 shadow-sm">
            <p class="text-xs uppercase tracking-wide text-amber-700">Awaiting Operations Review</p>
            <p class="mt-1 text-3xl font-extrabold text-amber-800">{{ stats.pending_review }}</p>
          </article>
          <article class="rounded-xl border border-orange-200 bg-orange-50 p-4 shadow-sm">
            <p class="text-xs uppercase tracking-wide text-orange-700">Awaiting Materials</p>
            <p class="mt-1 text-3xl font-extrabold text-orange-800">{{ stats.awaiting_materials }}</p>
          </article>
          <article class="rounded-xl border border-cyan-200 bg-cyan-50 p-4 shadow-sm">
            <p class="text-xs uppercase tracking-wide text-cyan-700">Dispatch Ready</p>
            <p class="mt-1 text-3xl font-extrabold text-cyan-800">{{ stats.job_ready }}</p>
          </article>
          <article class="rounded-xl border border-indigo-200 bg-indigo-50 p-4 shadow-sm">
            <p class="text-xs uppercase tracking-wide text-indigo-700">Ongoing</p>
            <p class="mt-1 text-3xl font-extrabold text-indigo-800">{{ stats.ongoing }}</p>
          </article>
          <article class="rounded-xl border border-emerald-200 bg-emerald-50 p-4 shadow-sm">
            <p class="text-xs uppercase tracking-wide text-emerald-700">Completed Today</p>
            <p class="mt-1 text-3xl font-extrabold text-emerald-800">{{ stats.completed_today }}</p>
          </article>
        </section>

        <section class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <h3 class="text-sm font-semibold text-slate-800">Material And Finance Gate Status</h3>
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
  stats,
  prSummary,
  fetchDashboard,
  logout,
} = useOperationalData()

onMounted(fetchDashboard)
</script>
