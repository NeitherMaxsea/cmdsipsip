<template>
  <div class="flex min-h-screen bg-slate-100">
    <HrSidebarNav :active-menu="activeMenu" @navigate="navigateTo" />

    <div class="flex flex-1 flex-col bg-slate-100">
      <HrTopbar @logout="logout" />

      <div class="hr-content flex flex-col gap-5 p-6 max-md:p-4">
        <section class="rounded-[18px] border border-slate-200 bg-[linear-gradient(145deg,_#ffffff_0%,_#f4f8ff_65%,_#ecfdf5_100%)] p-[22px] shadow-[0_10px_28px_rgba(15,23,42,0.06)]">
          <div class="flex flex-col items-start justify-between gap-4 md:flex-row">
            <div>
              <p class="m-0 text-[11px] font-extrabold uppercase tracking-[0.12em] text-teal-700">HR Workspace</p>
              <h1 class="mt-2 text-[34px] font-extrabold leading-[1.05] tracking-[-0.02em] text-slate-900 max-md:text-[28px]">
                {{ isTeamAssignmentMode ? 'Team Assignment Workspace' : 'Approval Queue Workspace' }}
              </h1>
              <p class="mt-2 max-w-[780px] text-sm text-slate-600">
                {{
                  isTeamAssignmentMode
                    ? 'Assign or reassign approved employees to teams and monitor acceptance status.'
                    : 'Review employee and provider records that require HR approval before workforce assignment.'
                }}
              </p>
            </div>

            <button type="button" class="min-w-[116px] rounded-[10px] border border-slate-300 bg-white px-3.5 py-2.5 text-[13px] font-bold text-slate-900 shadow-sm disabled:cursor-not-allowed disabled:opacity-60 hover:bg-slate-50" :disabled="loading" @click="loadAll">
              {{ loading ? 'Refreshing...' : 'Refresh Data' }}
            </button>
          </div>

          <div class="mt-4 grid gap-3 max-sm:grid-cols-1 sm:grid-cols-2 xl:grid-cols-2 2xl:grid-cols-4">
            <article class="rounded-xl border border-slate-200 bg-white p-3.5 shadow-sm">
              <p class="m-0 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-500">Pending Approval</p>
              <p class="mt-2 text-[30px] font-extrabold leading-none text-slate-900">{{ pendingCount }}</p>
              <p class="mt-2 text-xs text-slate-500">Waiting for HR manager review before Operations can see the record.</p>
            </article>

            <article class="rounded-xl border border-emerald-200 bg-emerald-50/80 p-3.5 shadow-sm">
              <p class="m-0 text-[11px] font-bold uppercase tracking-[0.08em] text-emerald-700">Approved Employees</p>
              <p class="mt-2 text-[30px] font-extrabold leading-none text-slate-900">{{ approvedCount }}</p>
              <p class="mt-2 text-xs text-emerald-800">Already released to Operations for team assignment and dispatch planning.</p>
            </article>

            <article class="rounded-xl border border-sky-200 bg-sky-50/80 p-3.5 shadow-sm">
              <p class="m-0 text-[11px] font-bold uppercase tracking-[0.08em] text-sky-700">Assigned to Team</p>
              <p class="mt-2 text-[30px] font-extrabold leading-none text-slate-900">{{ assignedApprovedCount }}</p>
              <p class="mt-2 text-xs text-sky-800">Approved employees already grouped for the next Operations step.</p>
            </article>

            <article class="rounded-xl border border-amber-200 bg-amber-50/80 p-3.5 shadow-sm">
              <p class="m-0 text-[11px] font-bold uppercase tracking-[0.08em] text-amber-700">Awaiting Team</p>
              <p class="mt-2 text-[30px] font-extrabold leading-none text-slate-900">{{ unassignedApprovedCount }}</p>
              <p class="mt-2 text-xs text-amber-800">Approved na pero wala pang team assignment sa Operations.</p>
            </article>
          </div>
        </section>

        <section v-if="isApprovalMode" class="rounded-[18px] border border-slate-200 bg-white p-[22px] shadow-[0_8px_24px_rgba(15,23,42,0.05)]">
          <header class="flex flex-col items-start justify-between gap-3 md:flex-row">
            <div>
              <p class="m-0 text-[11px] font-extrabold uppercase tracking-[0.12em] text-teal-700">Approval Queue</p>
              <h2 class="mt-2 text-[34px] font-extrabold leading-[1.08] tracking-[-0.02em] text-slate-900 max-md:text-[28px]">Employees Waiting for Approval</h2>
              <p class="mt-2 text-sm text-slate-500">Review each employee record, then decide if it can be released to Operations or blocked with a rejection note.</p>
            </div>

            <span class="inline-flex items-center rounded-full bg-indigo-50 px-3 py-2 text-xs font-bold text-indigo-700">{{ pendingCount }} pending</span>
          </header>

          <div class="mt-4 grid gap-3 lg:grid-cols-3">
            <article class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
              <p class="text-[11px] font-extrabold uppercase tracking-[0.12em] text-slate-500">Step 1</p>
              <p class="mt-2 text-sm font-bold text-slate-900">Check employee identity and role.</p>
              <p class="mt-1 text-xs leading-5 text-slate-500">Confirm the employee record, email, and service role match the company service setup.</p>
            </article>
            <article class="rounded-2xl border border-emerald-200 bg-emerald-50/80 p-4">
              <p class="text-[11px] font-extrabold uppercase tracking-[0.12em] text-emerald-700">Approve</p>
              <p class="mt-2 text-sm font-bold text-slate-900">Release to Operations</p>
              <p class="mt-1 text-xs leading-5 text-emerald-800">Approved employees become visible in the Operations workspace for team assignment and dispatch planning.</p>
            </article>
            <article class="rounded-2xl border border-rose-200 bg-rose-50/80 p-4">
              <p class="text-[11px] font-extrabold uppercase tracking-[0.12em] text-rose-700">Reject</p>
              <p class="mt-2 text-sm font-bold text-slate-900">Block from Operations</p>
              <p class="mt-1 text-xs leading-5 text-rose-800">Rejected records stay out of Operations until the employee details are corrected and resubmitted.</p>
            </article>
          </div>

          <div class="mt-4">
            <p v-if="loading" class="m-0 text-[13px] text-slate-500">Loading pending approvals...</p>

            <div v-else-if="pendingEmployees.length === 0" class="rounded-[14px] border border-dashed border-slate-300 bg-slate-50 p-6">
              <p class="m-0 text-[15px] font-bold text-slate-900">No pending employees</p>
              <p class="mt-1.5 text-xs text-slate-500">New employees created by HR Staff will appear here for approval.</p>
            </div>

            <div v-else class="overflow-hidden rounded-[18px] border border-slate-200 bg-white shadow-sm">
              <div class="overflow-x-auto">
                <table class="min-w-full text-left">
                  <thead class="bg-[linear-gradient(180deg,_#f8fbff_0%,_#f1f5f9_100%)]">
                    <tr class="text-[11px] font-extrabold uppercase tracking-[0.12em] text-slate-500">
                      <th class="px-6 py-4">Full Name</th>
                      <th class="px-6 py-4">Email</th>
                      <th class="px-6 py-4">Role</th>
                      <th class="px-6 py-4">Release Setup</th>
                      <th class="px-6 py-4">Status</th>
                      <th class="px-6 py-4 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-slate-200 bg-white">
                    <tr
                      v-for="employee in pendingEmployees"
                      :key="employee.id"
                      class="transition hover:bg-slate-50/70"
                    >
                      <td class="px-6 py-5 align-top">
                        <div class="max-w-[320px]">
                          <p class="m-0 text-[15px] font-semibold leading-7 text-slate-900">{{ employee.name }}</p>
                          <div class="mt-2 flex flex-wrap gap-2">
                            <span class="inline-flex items-center rounded-full bg-indigo-50 px-3 py-1 text-[11px] font-bold text-indigo-700">
                              Pending HR Review
                            </span>
                          </div>
                          <p v-if="!canApproveEmployee(employee)" class="mt-2 text-[11px] font-semibold text-amber-700">
                            {{ approvalLockedReason(employee) }}
                          </p>
                        </div>
                      </td>
                      <td class="px-6 py-5 align-top text-sm text-slate-600">
                        {{ employee.email || 'No email on file' }}
                      </td>
                      <td class="px-6 py-5 align-top">
                        <div class="space-y-2">
                          <p class="text-sm font-semibold text-slate-900">{{ employee.role || 'Role pending' }}</p>
                          <span class="inline-flex items-center rounded-full bg-cyan-50 px-3 py-1 text-xs font-semibold text-cyan-700">
                            {{ pendingEmployeeServiceLabel(employee) }}
                          </span>
                        </div>
                      </td>
                      <td class="px-6 py-5 align-top">
                        <div class="max-w-[240px] space-y-1.5">
                          <p class="text-sm font-semibold text-slate-900">{{ pendingEmployeeReleaseTitle(employee) }}</p>
                          <p class="text-sm leading-6 text-slate-600">{{ pendingEmployeeReleaseSummary(employee) }}</p>
                        </div>
                      </td>
                      <td class="px-6 py-5 align-top">
                        <div class="flex flex-col items-start gap-2">
                          <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-bold" :class="requestedStatusClass(employee)">
                            {{ employee.requested_status || 'Active' }}
                          </span>
                          <span class="inline-flex items-center rounded-full border border-slate-200 bg-white px-3 py-1 text-[11px] font-semibold text-slate-600">
                            For HR release
                          </span>
                        </div>
                      </td>
                      <td class="px-6 py-5 align-top">
                        <div class="flex flex-wrap justify-end gap-2">
                          <button
                            type="button"
                            class="inline-flex items-center justify-center rounded-full bg-emerald-500 px-3.5 py-1.5 text-xs font-bold text-white transition hover:bg-emerald-600 disabled:cursor-not-allowed disabled:opacity-55"
                            :disabled="processingId === employee.id || !canApproveEmployee(employee)"
                            :title="canApproveEmployee(employee) ? '' : approvalLockedReason(employee)"
                            @click="approveEmployee(employee)"
                          >
                            {{ processingId === employee.id ? 'Processing...' : 'Approve' }}
                          </button>
                          <button
                            type="button"
                            class="inline-flex items-center justify-center rounded-full border border-rose-200 bg-white px-3.5 py-1.5 text-xs font-bold text-rose-600 transition hover:bg-rose-50 disabled:cursor-not-allowed disabled:opacity-55"
                            :disabled="processingId === employee.id || !canApproveEmployee(employee)"
                            :title="canApproveEmployee(employee) ? '' : approvalLockedReason(employee)"
                            @click="rejectEmployee(employee)"
                          >
                            Reject
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </section>

        <section v-if="isTeamAssignmentMode" class="rounded-[18px] border border-slate-200 bg-white p-[22px] shadow-[0_8px_24px_rgba(15,23,42,0.05)]">
          <header class="flex flex-col items-start justify-between gap-3 md:flex-row">
            <div>
              <p class="m-0 text-[11px] font-extrabold uppercase tracking-[0.12em] text-teal-700">Team Assignment</p>
              <h2 class="mt-2 text-[34px] font-extrabold leading-[1.08] tracking-[-0.02em] text-slate-900 max-md:text-[28px]">Approved Employees Team Assignment</h2>
              <p class="mt-2 text-sm text-slate-500">
                Only approved employees can be assigned or reassigned. Employee account must accept assignment. Team capacity is limited to 3 members.
              </p>
            </div>
            <div class="flex flex-wrap items-center gap-2">
              <span class="inline-flex items-center rounded-full bg-emerald-50 px-3 py-2 text-xs font-bold text-emerald-700">{{ approvedCount }} approved</span>
              <span class="inline-flex items-center rounded-full bg-cyan-50 px-3 py-2 text-xs font-bold text-cyan-700">{{ confirmedTeamAssignmentsCount }} team-confirmed</span>
              <span class="inline-flex items-center rounded-full bg-amber-50 px-3 py-2 text-xs font-bold text-amber-700">{{ unassignedApprovedEmployees.length }} unassigned</span>
            </div>
          </header>

          <div class="mt-3.5 flex flex-wrap gap-2">
            <button
              v-for="filter in TEAM_FILTER_OPTIONS"
              :key="`team-filter-${filter.key}`"
              type="button"
              class="rounded-full border border-slate-300 bg-white px-3 py-2 text-xs font-bold text-slate-700 transition hover:border-slate-400 hover:bg-slate-50 [&.active]:border-sky-500 [&.active]:bg-sky-100 [&.active]:text-sky-800"
              :class="{ active: teamTableFilter === filter.key }"
              @click="teamTableFilter = filter.key"
            >
              {{ filter.label }}
            </button>
          </div>

          <div class="mt-4">
            <div v-if="!loading && approvedEmployees.length === 0" class="rounded-[14px] border border-dashed border-slate-300 bg-slate-50 p-6">
              <p class="m-0 text-[15px] font-bold text-slate-900">No approved employees yet</p>
              <p class="mt-1.5 text-xs text-slate-500">Approve employees first, then assignment options will appear here.</p>
            </div>

            <div v-else-if="!loading" class="flex flex-col gap-3.5">
              <article class="rounded-[14px] border border-slate-200 bg-slate-50 p-3.5">
                <header class="mb-2.5 flex flex-col items-start justify-between gap-3 md:flex-row">
                  <div>
                    <h3 class="m-0 text-[19px] font-extrabold leading-tight text-slate-900">Unassigned Queue</h3>
                    <p class="mt-1 text-xs text-slate-500">Approved employees without team assignment.</p>
                  </div>
                  <span class="inline-flex items-center rounded-full bg-indigo-50 px-3 py-2 text-xs font-bold text-indigo-700">{{ unassignedApprovedEmployees.length }} waiting</span>
                </header>

                <div v-if="unassignedApprovedEmployees.length === 0" class="rounded-[14px] border border-dashed border-slate-300 bg-slate-50 p-4">
                  <p class="m-0 text-[15px] font-bold text-slate-900">No unassigned employees</p>
                  <p class="mt-1.5 text-xs text-slate-500">All approved employees already belong to a team.</p>
                </div>

                <div v-else class="overflow-auto rounded-[14px] border border-slate-200">
                  <table class="w-full min-w-[860px] border-collapse">
                    <thead>
                      <tr>
                        <th class="border-b border-slate-200 bg-slate-50 px-4 py-3 text-left text-xs font-extrabold uppercase tracking-[0.08em] text-slate-500">Employee</th>
                        <th class="border-b border-slate-200 bg-slate-50 px-4 py-3 text-left text-xs font-extrabold uppercase tracking-[0.08em] text-slate-500">Role</th>
                        <th class="border-b border-slate-200 bg-slate-50 px-4 py-3 text-left text-xs font-extrabold uppercase tracking-[0.08em] text-slate-500">Assign Team</th>
                        <th class="border-b border-slate-200 bg-slate-50 px-4 py-3 text-right text-xs font-extrabold uppercase tracking-[0.08em] text-slate-500">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="employee in unassignedApprovedEmployees" :key="`unassigned-approved-${employee.id}`">
                        <td class="border-b border-slate-100 px-4 py-4 align-middle text-sm text-slate-700">
                          <p class="m-0 text-[17px] font-bold leading-tight text-slate-900">{{ employee.name }}</p>
                          <p class="mt-1 text-[13px] text-slate-500">{{ employee.email || 'No email' }}</p>
                        </td>
                        <td class="border-b border-slate-100 px-4 py-4 align-middle text-sm text-slate-700">
                          <span class="inline-flex items-center rounded-full border border-slate-200 bg-white px-2.5 py-1.5 text-xs font-bold text-slate-700">{{ employee.role || 'N/A' }}</span>
                        </td>
                        <td class="border-b border-slate-100 px-4 py-4 align-middle text-sm text-slate-700">
                          <select
                            v-model="selectedApprovedTeams[employee.id]"
                            class="w-full max-w-[210px] rounded-[10px] border border-slate-300 bg-white px-3 py-2.5 text-[13px] text-slate-900 outline-none focus:border-sky-500 focus:ring-4 focus:ring-sky-500/15 disabled:cursor-not-allowed disabled:opacity-60"
                            :disabled="assigningApprovedTeamId === employee.id"
                          >
                            <option value="">Select team</option>
                            <option
                              v-for="team in teamOptions"
                              :key="`unassigned-team-${employee.id}-${team}`"
                              :value="team"
                            >
                              {{ team }}
                            </option>
                          </select>
                        </td>
                        <td class="border-b border-slate-100 px-4 py-4 align-middle text-sm text-slate-700">
                          <div class="flex justify-end gap-2.5 max-md:justify-start">
                            <button
                              type="button"
                              class="min-w-[132px] rounded-[10px] border border-blue-700 bg-gradient-to-br from-blue-500 to-blue-700 px-3.5 py-2.5 text-xs font-bold text-white disabled:cursor-not-allowed disabled:opacity-55"
                              :disabled="!canAssignApprovedTeam(employee) || assigningApprovedTeamId === employee.id"
                              @click="assignApprovedEmployeeTeam(employee)"
                            >
                              {{ assigningApprovedTeamId === employee.id ? 'Saving...' : 'Assign Team' }}
                            </button>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </article>

              <div
                v-if="approvedEmployeesByTeam.length > 0 && filteredApprovedEmployeesByTeam.length === 0"
                class="rounded-[14px] border border-dashed border-slate-300 bg-slate-50 p-4"
              >
                <p class="m-0 text-[15px] font-bold text-slate-900">No teams match this filter</p>
                <p class="mt-1.5 text-xs text-slate-500">Try another filter to view team groups.</p>
              </div>

              <article
                v-for="group in filteredApprovedEmployeesByTeam"
                :key="`approved-team-group-${group.team}`"
                class="rounded-[14px] border border-slate-200 bg-slate-50 p-3.5"
              >
                <header class="mb-2.5 flex flex-col items-start justify-between gap-3 md:flex-row">
                  <div>
                    <h3 class="m-0 text-[19px] font-extrabold leading-tight text-slate-900">{{ group.team }}</h3>
                    <p class="mt-1 text-xs text-slate-500">
                      Capacity {{ group.capacity_used }}/{{ group.capacity_limit }}
                      ({{ group.capacity_remaining }} slots left)
                    </p>
                  </div>
                  <div class="flex flex-wrap items-center gap-2">
                    <span class="inline-flex items-center rounded-full bg-emerald-50 px-3 py-2 text-xs font-bold text-emerald-700">{{ group.accepted_count }} accepted</span>
                    <span class="inline-flex items-center rounded-full bg-amber-50 px-3 py-2 text-xs font-bold text-amber-700">{{ group.pending_count }} pending</span>
                    <span class="inline-flex items-center rounded-full bg-rose-50 px-3 py-2 text-xs font-bold text-rose-700">{{ group.rejected_count }} rejected</span>
                  </div>
                </header>

                <div class="overflow-auto rounded-[14px] border border-slate-200">
                  <table class="w-full min-w-[860px] border-collapse">
                    <thead>
                      <tr>
                        <th class="border-b border-slate-200 bg-slate-50 px-4 py-3 text-left text-xs font-extrabold uppercase tracking-[0.08em] text-slate-500">Employee</th>
                        <th class="border-b border-slate-200 bg-slate-50 px-4 py-3 text-left text-xs font-extrabold uppercase tracking-[0.08em] text-slate-500">Role</th>
                        <th class="border-b border-slate-200 bg-slate-50 px-4 py-3 text-left text-xs font-extrabold uppercase tracking-[0.08em] text-slate-500">Employee Confirmation</th>
                        <th class="border-b border-slate-200 bg-slate-50 px-4 py-3 text-left text-xs font-extrabold uppercase tracking-[0.08em] text-slate-500">Reassign Team</th>
                        <th class="border-b border-slate-200 bg-slate-50 px-4 py-3 text-right text-xs font-extrabold uppercase tracking-[0.08em] text-slate-500">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="employee in group.members" :key="`approved-${group.team}-${employee.id}`">
                        <td class="border-b border-slate-100 px-4 py-4 align-middle text-sm text-slate-700">
                          <p class="m-0 text-[17px] font-bold leading-tight text-slate-900">{{ employee.name }}</p>
                          <p class="mt-1 text-[13px] text-slate-500">{{ employee.email || 'No email' }}</p>
                        </td>
                        <td class="border-b border-slate-100 px-4 py-4 align-middle text-sm text-slate-700">
                          <span class="inline-flex items-center rounded-full border border-slate-200 bg-white px-2.5 py-1.5 text-xs font-bold text-slate-700">{{ employee.role || 'N/A' }}</span>
                        </td>
                        <td class="border-b border-slate-100 px-4 py-4 align-middle text-sm text-slate-700">
                          <span class="inline-flex items-center rounded-full px-2.5 py-1.5 text-xs font-bold" :class="teamAssignmentStatusClass(employee)">
                            {{ teamAssignmentStatusLabel(employee) }}
                          </span>
                        </td>
                        <td class="border-b border-slate-100 px-4 py-4 align-middle text-sm text-slate-700">
                          <select
                            v-model="selectedApprovedTeams[employee.id]"
                            class="w-full max-w-[210px] rounded-[10px] border border-slate-300 bg-white px-3 py-2.5 text-[13px] text-slate-900 outline-none focus:border-sky-500 focus:ring-4 focus:ring-sky-500/15 disabled:cursor-not-allowed disabled:opacity-60"
                            :disabled="assigningApprovedTeamId === employee.id"
                          >
                            <option value="">Select team</option>
                            <option
                              v-for="team in teamOptions"
                              :key="`approved-team-${employee.id}-${team}`"
                              :value="team"
                            >
                              {{ team }}
                            </option>
                          </select>
                        </td>
                        <td class="border-b border-slate-100 px-4 py-4 align-middle text-sm text-slate-700">
                          <div class="flex justify-end gap-2.5 max-md:justify-start">
                            <button
                              type="button"
                              class="min-w-[132px] rounded-[10px] border border-amber-700 bg-gradient-to-br from-amber-500 to-amber-700 px-3.5 py-2.5 text-xs font-bold text-white disabled:cursor-not-allowed disabled:opacity-55"
                              :disabled="!canAssignApprovedTeam(employee) || assigningApprovedTeamId === employee.id"
                              @click="assignApprovedEmployeeTeam(employee)"
                            >
                              {{ assigningApprovedTeamId === employee.id ? 'Saving...' : approvedTeamActionLabel(employee) }}
                            </button>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </article>
            </div>
          </div>
        </section>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { router } from '@inertiajs/vue3'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import HrSidebarNav from '@/Components/HrSidebarNav.vue'
import HrTopbar from '@/Components/HrTopbar.vue'
import { confirmAndLogout } from '@/lib/auth-flow'

const props = defineProps({
  mode: {
    type: String,
    default: 'approval',
  },
})

const isTeamAssignmentMode = computed(() => props.mode === 'team-assignment')
const isApprovalMode = computed(() => !isTeamAssignmentMode.value)
const activeMenu = ref(isTeamAssignmentMode.value ? 'Team Assignment' : 'Approval Queue')
const loading = ref(false)
const processingId = ref(null)
const assigningApprovedTeamId = ref(null)
const pendingEmployees = ref([])
const approvedEmployees = ref([])
const selectedApprovedTeams = reactive({})
const teamTableFilter = ref('all')
const TEAM_MEMBER_LIMIT = 3
const TEAM_FILTER_OPTIONS = [
  { key: 'all', label: 'All Teams' },
  { key: 'full', label: 'Full' },
  { key: 'pending', label: 'Has Pending' },
  { key: 'rejected', label: 'Has Rejected' },
]

const baseTeamOptions = Array.from({ length: 26 }, (_, index) => `Team ${String.fromCharCode(65 + index)}`)

const normalizeValue = (value) => String(value || '').trim()
const normalizeRoleKey = (value) => normalizeValue(value).toLowerCase().replace(/[\s-]+/g, '_')
const officeDepartmentRoles = new Set(['operational', 'operational_management', 'finance', 'csr', 'procurement', 'hr'])

const teamOptions = computed(() => [...baseTeamOptions])

const pendingCount = computed(() => pendingEmployees.value.length)
const approvedCount = computed(() => approvedEmployees.value.length)
const assignedApprovedCount = computed(() =>
  approvedEmployees.value.filter((employee) => normalizeValue(employee?.team) !== '').length
)
const unassignedApprovedCount = computed(() =>
  Math.max(approvedCount.value - assignedApprovedCount.value, 0)
)
const normalizeTeamAssignmentStatus = (employee) => {
  const status = String(employee?.team_assignment_status || '').trim().toLowerCase()
  if (status === 'accepted' || status === 'pending' || status === 'rejected') return status
  return normalizeValue(employee?.team) !== '' ? 'accepted' : 'unassigned'
}
const teamAssignmentStatusLabel = (employee) => {
  const status = normalizeTeamAssignmentStatus(employee)
  if (status === 'accepted') return 'Accepted'
  if (status === 'pending') return 'Pending Employee Approval'
  if (status === 'rejected') return 'Rejected by Employee'
  return 'Unassigned'
}
const teamAssignmentStatusClass = (employee) => {
  const status = normalizeTeamAssignmentStatus(employee)
  if (status === 'accepted') return 'bg-emerald-50 text-emerald-700'
  if (status === 'pending') return 'bg-amber-50 text-amber-700'
  if (status === 'rejected') return 'bg-rose-50 text-rose-700'
  return 'bg-slate-100 text-slate-600'
}
const confirmedTeamAssignmentsCount = computed(() =>
  approvedEmployees.value.filter((employee) => normalizeTeamAssignmentStatus(employee) === 'accepted').length
)
const unassignedApprovedEmployees = computed(() =>
  approvedEmployees.value.filter((employee) => normalizeValue(employee?.team) === '')
)
const approvedEmployeesByTeam = computed(() => {
  const grouped = new Map()

  for (const employee of approvedEmployees.value) {
    const team = normalizeValue(employee?.team)
    if (!team) continue
    if (!grouped.has(team)) grouped.set(team, [])
    grouped.get(team).push(employee)
  }

  return Array.from(grouped.entries())
    .map(([team, members]) => {
      const rows = [...members].sort((a, b) =>
        normalizeValue(a?.name).localeCompare(normalizeValue(b?.name))
      )
      const acceptedCount = rows.filter((row) => normalizeTeamAssignmentStatus(row) === 'accepted').length
      const pendingCount = rows.filter((row) => normalizeTeamAssignmentStatus(row) === 'pending').length
      const rejectedCount = rows.filter((row) => normalizeTeamAssignmentStatus(row) === 'rejected').length
      const capacityUsed = acceptedCount + pendingCount

      return {
        team,
        members: rows,
        accepted_count: acceptedCount,
        pending_count: pendingCount,
        rejected_count: rejectedCount,
        capacity_limit: TEAM_MEMBER_LIMIT,
        capacity_used: capacityUsed,
        capacity_remaining: Math.max(TEAM_MEMBER_LIMIT - capacityUsed, 0),
      }
    })
    .sort((a, b) => a.team.localeCompare(b.team))
})
const filteredApprovedEmployeesByTeam = computed(() => {
  if (teamTableFilter.value === 'all') return approvedEmployeesByTeam.value
  if (teamTableFilter.value === 'full') {
    return approvedEmployeesByTeam.value.filter((group) => group.capacity_used >= group.capacity_limit)
  }
  if (teamTableFilter.value === 'pending') {
    return approvedEmployeesByTeam.value.filter((group) => group.pending_count > 0)
  }
  if (teamTableFilter.value === 'rejected') {
    return approvedEmployeesByTeam.value.filter((group) => group.rejected_count > 0)
  }
  return approvedEmployeesByTeam.value
})

const serviceProviderLabel = (employee) => normalizeValue(employee?.service_provider_name) || 'Unlinked'
const serviceProviderBadgeClass = (employee) =>
  normalizeValue(employee?.service_provider_id) ? 'bg-emerald-50 text-emerald-700' : 'bg-amber-50 text-amber-700'

const employeeInitials = (employee) => {
  const name = normalizeValue(employee?.name)
  if (!name) return 'EM'
  return name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part.charAt(0).toUpperCase())
    .join('')
}

const pendingEmployeeServiceLabel = (employee) => {
  const directTrack = String(
    employee?.service_track || employee?.serviceTrack || employee?.workspace_category || employee?.category || ''
  ).trim().toLowerCase()
  if (directTrack === 'plumbing') return 'Plumbing'
  if (directTrack === 'siphoning') return 'Siphoning'

  const normalizedRole = String(employee?.role || '').toLowerCase()

  if (normalizedRole.includes('siphon') && normalizedRole.includes('plumb')) {
    return 'Siphoning / Plumbing'
  }
  if (normalizedRole.includes('plumb')) {
    return 'Plumbing'
  }
  if (normalizedRole.includes('siphon')) {
    return 'Siphoning'
  }

  return 'Company-based'
}

const pendingEmployeeReleaseTitle = (employee) => {
  const requestedStatus = normalizeValue(employee?.requested_status) || 'Active'
  return `Release as ${requestedStatus}`
}

const pendingEmployeeReleaseSummary = (employee) => {
  const role = normalizeValue(employee?.role) || 'Employee record'
  return `${role} becomes visible to Operations for team assignment.`
}

const pendingEmployeeFlowText = (employee) => {
  const role = normalizeValue(employee?.role) || 'selected role'
  const requestedStatus = normalizeValue(employee?.requested_status) || 'Active'
  return `${role} will be activated with status ${requestedStatus} and will become available in Operations for team assignment and dispatch planning.`
}

const requestedStatusClass = (employee) => {
  const status = String(employee?.requested_status || 'Active').trim().toLowerCase()
  if (status === 'active') return 'bg-emerald-50 text-emerald-700'
  if (status === 'on leave') return 'bg-rose-50 text-rose-700'
  if (status === 'inactive') return 'bg-indigo-50 text-indigo-700'
  return 'bg-slate-100 text-slate-600'
}
const canApproveEmployee = (employee) => employee?.can_approve_action !== false
const approvalLockedReason = (employee) =>
  String(employee?.approve_block_reason || 'Approval is not allowed for this record.')

const normalizeStatus = (employee) => String(employee?.status || '').trim().toLowerCase()
const normalizeApproval = (employee) => String(employee?.approval_status || '').trim().toLowerCase()
const normalizeApprovalState = (employee) => {
  const approval = normalizeApproval(employee)
  if (approval === 'approved' || approval === 'pending' || approval === 'rejected') return approval

  const status = normalizeStatus(employee)
  if (status === 'approved' || status === 'pending' || status === 'rejected') return status
  if (status === 'pending approval') return 'pending'
  if (status === 'active') return employee?.is_approved === false ? 'pending' : 'approved'
  if (typeof employee?.is_approved === 'boolean') return employee.is_approved ? 'approved' : 'pending'
  if (typeof employee?.is_user_approved === 'boolean') return employee.is_user_approved ? 'approved' : 'pending'
  return 'pending'
}
const isOfficeDepartmentAccount = (employee) => {
  const roleKey = normalizeRoleKey(employee?.role)
  if (!roleKey) return false
  return officeDepartmentRoles.has(roleKey)
}

const isWorkforceEmployeeRecord = (employee) => {
  if (!employee || isOfficeDepartmentAccount(employee)) return false
  const accountSource = normalizeRoleKey(employee?.account_source)
  const createdByRole = normalizeRoleKey(employee?.created_by_role)
  const serviceTrack = normalizeRoleKey(
    employee?.service_track || employee?.serviceTrack || employee?.workspace_category || employee?.category
  )

  if (serviceTrack === 'plumbing' || serviceTrack === 'siphoning') return true
  if (createdByRole === 'hr') return true
  if (accountSource === 'hr_created') return true
  return !officeDepartmentRoles.has(normalizeRoleKey(employee?.requested_status))
}

const isEmployeeApprovedRecord = (employee) => {
  if (!isWorkforceEmployeeRecord(employee)) return false
  return normalizeApprovalState(employee) === 'approved'
}

const approvedTeamActionLabel = (employee) =>
  normalizeValue(employee?.team) ? 'Reassign Team' : 'Assign Team'

const canAssignApprovedTeam = (employee) => {
  const selectedTeam = normalizeValue(selectedApprovedTeams[employee.id])
  const currentTeam = normalizeValue(employee?.team)
  return selectedTeam !== '' && selectedTeam.toLowerCase() !== currentTeam.toLowerCase()
}

const navigateTo = (menu, url) => {
  activeMenu.value = menu
  router.visit(url)
}

watch(
  () => props.mode,
  (value) => {
    activeMenu.value = value === 'team-assignment' ? 'Team Assignment' : 'Approval Queue'
  }
)

const loadPending = async () => {
  const res = await axios.get('/hr/employees/pending-approvals')
  const rows = Array.isArray(res.data) ? res.data : []
  pendingEmployees.value = rows.filter((employee) => {
    if (!isWorkforceEmployeeRecord(employee)) return false
    return normalizeApprovalState(employee) === 'pending'
  })
}

const loadApproved = async () => {
  const res = await axios.get('/hr/employees')
  const rows = Array.isArray(res.data) ? res.data : []
  approvedEmployees.value = rows.filter((employee) => isEmployeeApprovedRecord(employee))

  for (const employee of approvedEmployees.value) {
    if (typeof selectedApprovedTeams[employee.id] === 'undefined') {
      selectedApprovedTeams[employee.id] = normalizeValue(employee?.team)
    }
  }
}

const loadAll = async () => {
  loading.value = true
  try {
    await Promise.all([loadPending(), loadApproved()])
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to load HR approval data.', 'error')
  } finally {
    loading.value = false
  }
}

const approveEmployee = async (employee) => {
  if (!canApproveEmployee(employee)) {
    Swal.fire('Not allowed', approvalLockedReason(employee), 'info')
    return
  }

  const preferredStatus = employee.requested_status || 'Active'
  const confirm = await Swal.fire({
    title: 'Approve and release to Operations?',
    text: `${employee.name} will be activated with status "${preferredStatus}" and will appear in Operations for team assignment.`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Approve And Release',
  })
  if (!confirm.isConfirmed) return

  processingId.value = employee.id
  try {
    const res = await axios.post(`/hr/employees/${employee.id}/approve`, {
      status: preferredStatus,
    }, { skipGlobalLoading: true })
    pendingEmployees.value = pendingEmployees.value.filter((row) => row.id !== employee.id)
    approvedEmployees.value = [
      {
        ...employee,
        status: 'approved',
        approval_status: 'approved',
        is_approved: true,
        requested_status: preferredStatus,
      },
      ...approvedEmployees.value.filter((row) => row.id !== employee.id),
    ]
    Swal.fire('Success', res.data?.message || 'Employee approved.', 'success')
    loadAll().catch(() => {})
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to approve employee.', 'error')
  } finally {
    processingId.value = null
  }
}

const rejectEmployee = async (employee) => {
  if (!canApproveEmployee(employee)) {
    Swal.fire('Not allowed', approvalLockedReason(employee), 'info')
    return
  }

  const result = await Swal.fire({
    title: 'Reject employee record?',
    text: `This will keep ${employee.name} out of Operations until the details are corrected.`,
    input: 'text',
    inputLabel: 'Reason (optional)',
    inputPlaceholder: 'Reason for rejection',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Reject Record',
  })
  if (!result.isConfirmed) return

  processingId.value = employee.id
  try {
    const res = await axios.post(`/hr/employees/${employee.id}/reject`, {
      reason: result.value || null,
    }, { skipGlobalLoading: true })
    pendingEmployees.value = pendingEmployees.value.filter((row) => row.id !== employee.id)
    Swal.fire('Success', res.data?.message || 'Employee rejected.', 'success')
    loadAll().catch(() => {})
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to reject employee.', 'error')
  } finally {
    processingId.value = null
  }
}

const assignApprovedEmployeeTeam = async (employee) => {
  const selectedTeam = normalizeValue(selectedApprovedTeams[employee.id])
  const currentTeam = normalizeValue(employee?.team)
  if (!selectedTeam) {
    Swal.fire('Warning', 'Please select a team.', 'warning')
    return
  }
  if (selectedTeam.toLowerCase() === currentTeam.toLowerCase()) {
    Swal.fire('Info', `${employee.name} is already assigned to ${selectedTeam}.`, 'info')
    return
  }

  const isReassign = currentTeam !== ''
  const confirm = await Swal.fire({
    title: isReassign ? 'Reassign team?' : 'Assign team?',
    text: isReassign
      ? `${employee.name} will be moved from ${currentTeam} to ${selectedTeam}.`
      : `${employee.name} will be assigned to ${selectedTeam}.`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: isReassign ? 'Reassign' : 'Assign',
  })
  if (!confirm.isConfirmed) return

  assigningApprovedTeamId.value = employee.id
  try {
    const res = await axios.patch(`/hr/employees/${employee.id}`, { team: selectedTeam }, { skipGlobalLoading: true })
    approvedEmployees.value = approvedEmployees.value.map((row) => (
      row.id === employee.id ? { ...row, team: selectedTeam } : row
    ))
    Swal.fire('Success', res.data?.message || 'Employee team updated.', 'success')
    loadAll().catch(() => {})
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to update team.', 'error')
  } finally {
    assigningApprovedTeamId.value = null
  }
}

const logout = async () => {
  await confirmAndLogout()
}

onMounted(loadAll)
</script>
