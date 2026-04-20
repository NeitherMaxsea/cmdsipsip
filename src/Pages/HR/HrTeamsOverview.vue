<template>
  <div class="flex min-h-screen bg-slate-100">
    <HrSidebarNav :active-menu="activeMenu" @navigate="navigateTo" />

    <div class="flex flex-1 flex-col bg-slate-100">
      <HrTopbar @logout="logout" />

      <div class="hr-content flex flex-col gap-5 p-6 max-md:p-4">
        <section class="rounded-[18px] border border-slate-200 bg-[linear-gradient(145deg,_#ffffff_0%,_#f4f8ff_65%,_#ecfdf5_100%)] p-[22px] shadow-[0_10px_28px_rgba(15,23,42,0.06)]">
          <div class="flex flex-col items-start justify-between gap-3 md:flex-row">
            <div>
              <p class="m-0 text-[11px] font-extrabold uppercase tracking-[0.12em] text-teal-700">HR Workspace</p>
              <h1 class="mt-2 text-[34px] font-extrabold leading-[1.05] tracking-[-0.02em] text-slate-900 max-md:text-[28px]">Team Overview</h1>
              <p class="mt-2.5 max-w-[780px] text-sm text-slate-600">
                View formed teams and track who accepted, is pending, or rejected team assignment.
              </p>
            </div>
            <button type="button" class="min-w-[108px] rounded-[10px] border border-slate-300 bg-white px-3.5 py-2.5 text-[13px] font-bold text-slate-900 disabled:cursor-not-allowed disabled:opacity-60" :disabled="loading" @click="loadOverview">
              {{ loading ? 'Refreshing...' : 'Refresh' }}
            </button>
          </div>

          <div class="mt-4 grid gap-3 max-sm:grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 2xl:grid-cols-6">
            <article class="rounded-xl border border-slate-200 bg-white p-3.5">
              <p class="m-0 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-500">Teams</p>
              <p class="mt-2 text-[28px] font-extrabold leading-none text-slate-900">{{ summary.team_count }}</p>
            </article>
            <article class="rounded-xl border border-slate-200 bg-white p-3.5">
              <p class="m-0 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-500">Approved Employees</p>
              <p class="mt-2 text-[28px] font-extrabold leading-none text-slate-900">{{ summary.approved_employee_count }}</p>
            </article>
            <article class="rounded-xl border border-slate-200 bg-white p-3.5">
              <p class="m-0 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-500">Accepted</p>
              <p class="mt-2 text-[28px] font-extrabold leading-none text-emerald-700">{{ summary.accepted_count }}</p>
            </article>
            <article class="rounded-xl border border-slate-200 bg-white p-3.5">
              <p class="m-0 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-500">Pending</p>
              <p class="mt-2 text-[28px] font-extrabold leading-none text-amber-700">{{ summary.pending_count }}</p>
            </article>
            <article class="rounded-xl border border-slate-200 bg-white p-3.5">
              <p class="m-0 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-500">Rejected</p>
              <p class="mt-2 text-[28px] font-extrabold leading-none text-rose-700">{{ summary.rejected_count }}</p>
            </article>
            <article class="rounded-xl border border-slate-200 bg-white p-3.5">
              <p class="m-0 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-500">Unassigned</p>
              <p class="mt-2 text-[28px] font-extrabold leading-none text-slate-900">{{ summary.unassigned_count }}</p>
            </article>
          </div>
        </section>

        <section class="rounded-[18px] border border-slate-200 bg-white p-[22px] shadow-[0_8px_24px_rgba(15,23,42,0.05)]">
          <div class="flex items-start justify-between gap-3">
            <div>
              <p class="m-0 text-[11px] font-extrabold uppercase tracking-[0.12em] text-teal-700">Coordination Queue</p>
              <h2 class="mt-2 text-[26px] font-extrabold leading-[1.1] tracking-[-0.02em] text-slate-900 max-md:text-[22px]">Requests Awaiting HR Coordination</h2>
              <p class="mt-1.5 text-xs text-slate-500">Review incoming requests that still need staffing or HR clearance before procurement handoff.</p>
            </div>
            <button
              type="button"
              class="rounded-[10px] border border-slate-300 bg-white px-3 py-2 text-xs font-bold text-slate-900 disabled:cursor-not-allowed disabled:opacity-60"
              :disabled="loadingIncomingRequests"
              @click="loadIncomingRequests"
            >
              {{ loadingIncomingRequests ? 'Refreshing...' : 'Refresh' }}
            </button>
          </div>

          <div v-if="loadingIncomingRequests" class="mt-3 rounded-[14px] border border-dashed border-slate-300 bg-slate-50 p-4">
            <p class="m-0 text-sm text-slate-600">Loading coordination queue...</p>
          </div>

          <div v-else-if="incomingRequests.length === 0" class="mt-3 rounded-[14px] border border-dashed border-slate-300 bg-slate-50 p-4">
            <p class="m-0 text-sm font-semibold text-slate-800">No request coordination items right now.</p>
          </div>

          <div v-else class="mt-3 overflow-auto rounded-xl border border-slate-200 bg-white">
            <table class="w-full min-w-[720px] border-collapse">
              <thead>
                <tr>
                  <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Request</th>
                  <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Customer</th>
                  <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Business</th>
                  <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Service</th>
                  <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="request in incomingRequests" :key="`incoming-${request.id}`">
                  <td class="border-b border-slate-100 px-3 py-2.5 text-[13px] text-slate-700 last:border-b-0">#{{ request.id }}</td>
                  <td class="border-b border-slate-100 px-3 py-2.5 text-[13px] text-slate-700 last:border-b-0">{{ fullName(request.user) }}</td>
                  <td class="border-b border-slate-100 px-3 py-2.5 text-[13px] text-slate-700 last:border-b-0">{{ request.business?.business_name || 'N/A' }}</td>
                  <td class="border-b border-slate-100 px-3 py-2.5 text-[13px] text-slate-700 last:border-b-0">{{ request.service_type || 'N/A' }}</td>
                  <td class="border-b border-slate-100 px-3 py-2.5 text-[13px] text-slate-700 last:border-b-0">
                    <span class="inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-bold capitalize" :class="requestStatusPillClass(request.status)">
                      {{ request.status || 'pending' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="mt-3">
            <button
              type="button"
              class="rounded-[10px] border border-slate-900 bg-slate-900 px-3.5 py-2 text-xs font-bold text-white"
              @click="router.visit(`${hrBasePath}/assigned-requests`)"
            >
              Open Coordination Queue
            </button>
          </div>
        </section>

        <section class="rounded-[18px] border border-slate-200 bg-white p-[22px] shadow-[0_8px_24px_rgba(15,23,42,0.05)]">
          <div class="flex flex-col items-start justify-between gap-3 lg:flex-row">
            <div>
              <p class="m-0 text-[11px] font-extrabold uppercase tracking-[0.12em] text-teal-700">Team Directory</p>
              <h2 class="mt-2 text-[26px] font-extrabold leading-[1.1] tracking-[-0.02em] text-slate-900 max-md:text-[22px]">Formed Teams</h2>
            </div>
            <div class="flex flex-wrap gap-2.5">
              <input
                v-model.trim="search"
                type="text"
                class="min-w-[260px] rounded-[10px] border border-slate-300 bg-white px-3 py-2.5 text-[13px] text-slate-900 outline-none ring-0 focus:border-sky-500 focus:ring-4 focus:ring-sky-500/15 max-md:min-w-0 max-md:w-full"
                placeholder="Search team/member/email..."
              />
              <select v-model="statusFilter" class="min-w-[150px] rounded-[10px] border border-slate-300 bg-white px-3 py-2.5 text-[13px] text-slate-900 outline-none ring-0 focus:border-sky-500 focus:ring-4 focus:ring-sky-500/15">
                <option value="all">All Status</option>
                <option value="accepted">Accepted</option>
                <option value="pending">Pending</option>
                <option value="rejected">Rejected</option>
              </select>
            </div>
          </div>

          <div v-if="loading" class="rounded-[14px] border border-dashed border-slate-300 bg-slate-50 p-5">
            <p class="m-0 text-[15px] font-bold text-slate-900">Loading team overview...</p>
          </div>

          <div v-else-if="filteredTeams.length === 0" class="rounded-[14px] border border-dashed border-slate-300 bg-slate-50 p-5">
            <p class="m-0 text-[15px] font-bold text-slate-900">No teams found</p>
            <p class="mt-1.5 text-xs text-slate-500">Try another filter or assign employees to teams first.</p>
          </div>

          <div v-else class="mt-4 flex flex-col gap-4">
            <div
              v-for="group in categorizedFilteredTeams"
              :key="group.key"
              class="rounded-[14px] border border-slate-200 bg-slate-50/40 p-3"
            >
              <div class="mb-2.5 flex items-center justify-between">
                <p class="m-0 text-[12px] font-extrabold uppercase tracking-[0.08em] text-slate-700">{{ group.label }}</p>
                <span class="rounded-full bg-white px-2.5 py-1 text-[11px] font-bold text-slate-700">{{ group.teams.length }} team(s)</span>
              </div>
              <div class="grid gap-3.5 xl:grid-cols-2">
            <article v-for="team in group.teams" :key="team.team" class="rounded-[14px] border border-slate-200 bg-slate-50 p-3.5">
              <div class="flex items-start justify-between gap-2.5">
                <div>
                  <h3 class="m-0 text-lg font-extrabold text-slate-900">{{ team.team }}</h3>
                  <p class="mt-1 text-[11px] font-bold uppercase tracking-[0.08em] text-teal-700">{{ inferTeamCategory(team) }}</p>
                  <p class="mt-1.5 text-xs text-slate-600">
                    Capacity: {{ team.capacity_used }}/{{ team.capacity_limit }}
                    <span :class="team.is_full ? 'ml-2 font-bold text-rose-700' : 'ml-2 font-bold text-emerald-700'">
                      {{ team.is_full ? 'Full' : `${team.capacity_remaining} slot left` }}
                    </span>
                  </p>
                </div>
                <span class="inline-flex items-center rounded-full bg-indigo-50 px-2.5 py-1.5 text-[11px] font-bold text-indigo-700">{{ team.total_members }} members</span>
              </div>

              <div class="mt-2.5 flex flex-wrap gap-2">
                <span class="rounded-full bg-emerald-50 px-2.5 py-1 text-[11px] font-bold text-emerald-700">{{ team.accepted_count }} accepted</span>
                <span class="rounded-full bg-amber-50 px-2.5 py-1 text-[11px] font-bold text-amber-700">{{ team.pending_count }} pending</span>
                <span class="rounded-full bg-rose-50 px-2.5 py-1 text-[11px] font-bold text-rose-700">{{ team.rejected_count }} rejected</span>
                <span class="rounded-full bg-sky-50 px-2.5 py-1 text-[11px] font-bold text-sky-700">
                  Leader: {{ teamLeaderName(team) }}
                </span>
              </div>

              <div class="mt-2.5 rounded-xl border border-slate-200 bg-white p-3">
                <div class="flex flex-col gap-2.5">
                  <div>
                    <p class="m-0 text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Group Schedule</p>
                    <p class="mt-1 text-xs text-slate-600">Set schedule before team assignment appears on workforce and partner rosters.</p>
                    <p v-if="team.team_schedule_date && team.team_schedule_time_from && team.team_schedule_time_to" class="mt-1 text-xs font-semibold text-teal-700">
                      Current: {{ formatSchedule(team.team_schedule_date, team.team_schedule_time_from, team.team_schedule_time_to) }}
                    </p>
                  </div>
                  <div class="grid gap-2 sm:grid-cols-[1fr_1fr_1fr_auto]">
                    <input
                      v-model="scheduleDrafts[team.team].date"
                      :min="todayDate"
                      type="date"
                      class="rounded-[10px] border border-slate-300 bg-white px-3 py-2 text-[13px] text-slate-900 outline-none focus:border-sky-500 focus:ring-4 focus:ring-sky-500/15"
                    />
                    <select
                      v-model="scheduleDrafts[team.team].time_from"
                      class="rounded-[10px] border border-slate-300 bg-white px-3 py-2 text-[13px] text-slate-900 outline-none focus:border-sky-500 focus:ring-4 focus:ring-sky-500/15"
                    >
                      <option value="">From</option>
                      <option v-for="slot in teamScheduleTimeOptions" :key="`from-${team.team}-${slot.value}`" :value="slot.value">
                        {{ slot.label }}
                      </option>
                    </select>
                    <select
                      v-model="scheduleDrafts[team.team].time_to"
                      class="rounded-[10px] border border-slate-300 bg-white px-3 py-2 text-[13px] text-slate-900 outline-none focus:border-sky-500 focus:ring-4 focus:ring-sky-500/15"
                    >
                      <option value="">To</option>
                      <option v-for="slot in teamScheduleTimeOptions" :key="`to-${team.team}-${slot.value}`" :value="slot.value">
                        {{ slot.label }}
                      </option>
                    </select>
                    <button
                      type="button"
                      class="rounded-[10px] border border-slate-300 bg-slate-900 px-3 py-2 text-[12px] font-bold text-white disabled:cursor-not-allowed disabled:opacity-60"
                      :disabled="savingTeamName === team.team"
                      @click="saveTeamSchedule(team)"
                    >
                      {{ savingTeamName === team.team ? 'Saving...' : 'Save Schedule' }}
                    </button>
                  </div>
                </div>
              </div>

              <div class="mt-2.5 overflow-auto rounded-xl border border-slate-200 bg-white">
                <table class="w-full min-w-[520px] border-collapse">
                  <thead>
                    <tr>
                      <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Member</th>
                      <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Role</th>
                      <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="member in team.members" :key="`member-${team.team}-${member.id}`">
                      <td class="border-b border-slate-100 px-3 py-2.5 align-top text-[13px] text-slate-700 last:border-b-0">
                        <p class="m-0 inline-flex items-center gap-2 font-bold text-slate-900">
                          <span class="h-2.5 w-2.5 rounded-full ring-2" :class="memberAcceptDotClass(member.team_assignment_status)"></span>
                          {{ member.name }}
                          <span
                            v-if="isTeamLeader(member, team)"
                            class="inline-flex items-center rounded-full bg-sky-50 px-2 py-0.5 text-[10px] font-extrabold uppercase tracking-wide text-sky-700"
                          >
                            Leader
                          </span>
                        </p>
                        <p class="mt-1 text-xs text-slate-500">{{ member.email || 'No email' }}</p>
                      </td>
                      <td class="border-b border-slate-100 px-3 py-2.5 align-top text-[13px] text-slate-700 last:border-b-0">{{ member.role || 'N/A' }}</td>
                      <td class="border-b border-slate-100 px-3 py-2.5 align-top text-[13px] text-slate-700 last:border-b-0">
                        <span class="inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-bold" :class="statusPillClass(member.team_assignment_status)">
                          {{ statusLabel(member.team_assignment_status) }}
                        </span>
                        <p v-if="member.team_assignment_response_note" class="mt-1 text-[11px] text-slate-500 max-w-[280px]">
                          {{ member.team_assignment_response_note }}
                        </p>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </article>
              </div>
            </div>
          </div>
        </section>

        <section class="rounded-[18px] border border-slate-200 bg-white p-[22px] shadow-[0_8px_24px_rgba(15,23,42,0.05)]">
          <p class="m-0 text-[11px] font-extrabold uppercase tracking-[0.12em] text-teal-700">Unassigned</p>
          <h2 class="mt-2 text-[26px] font-extrabold leading-[1.1] tracking-[-0.02em] text-slate-900 max-md:text-[22px]">Approved Employees Without Team</h2>

          <div v-if="unassigned.length === 0" class="mt-3 rounded-[14px] border border-dashed border-slate-300 bg-slate-50 p-5">
            <p class="m-0 text-[15px] font-bold text-slate-900">No unassigned employees</p>
          </div>

          <div v-else class="mt-3 overflow-auto rounded-xl border border-slate-200 bg-white">
            <table class="w-full min-w-[520px] border-collapse">
              <thead>
                <tr>
                  <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Employee</th>
                  <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Role</th>
                  <th class="border-b border-slate-200 bg-slate-50 px-3 py-2.5 text-left text-[11px] font-extrabold uppercase tracking-[0.08em] text-slate-500">Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="employee in unassigned" :key="`unassigned-${employee.id}`">
                  <td class="border-b border-slate-100 px-3 py-2.5 align-top text-[13px] text-slate-700 last:border-b-0">
                    <p class="m-0 inline-flex items-center gap-2 font-bold text-slate-900">
                      <span class="h-2.5 w-2.5 rounded-full ring-2" :class="memberAcceptDotClass(employee.team_assignment_status)"></span>
                      {{ employee.name }}
                    </p>
                    <p class="mt-1 text-xs text-slate-500">{{ employee.email || 'No email' }}</p>
                  </td>
                  <td class="border-b border-slate-100 px-3 py-2.5 align-top text-[13px] text-slate-700 last:border-b-0">{{ employee.role || 'N/A' }}</td>
                  <td class="border-b border-slate-100 px-3 py-2.5 align-top text-[13px] text-slate-700 last:border-b-0">
                    <span class="inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-bold" :class="statusPillClass(employee.team_assignment_status)">
                      {{ statusLabel(employee.team_assignment_status) }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import HrSidebarNav from '@/Components/HrSidebarNav.vue'
import HrTopbar from '@/Components/HrTopbar.vue'
import { confirmAndLogout } from '@/lib/auth-flow'

const activeMenu = ref('Team Overview')
const page = usePage()
const hrBasePath = computed(() =>
  String(page.props?.auth?.user?.role || '').trim().toLowerCase() === 'employee'
    ? '/employee/hr'
    : '/hr'
)
const loading = ref(false)
const search = ref('')
const statusFilter = ref('all')
const teams = ref([])
const unassigned = ref([])
const incomingRequests = ref([])
const loadingIncomingRequests = ref(false)
const scheduleDrafts = ref({})
const savingTeamName = ref('')
const todayDate = new Date().toISOString().slice(0, 10)
const teamScheduleTimeOptions = Array.from({ length: 13 }, (_, index) => {
  const hour = index + 6
  const suffix = hour >= 12 ? 'PM' : 'AM'
  const displayHour = hour > 12 ? hour - 12 : hour
  const value = `${String(hour).padStart(2, '0')}:00`
  return {
    value,
    label: `${String(displayHour).padStart(2, '0')}:00 ${suffix}`,
  }
})
const allowedScheduleTimeSet = new Set(teamScheduleTimeOptions.map((slot) => slot.value))
const summary = ref({
  team_count: 0,
  approved_employee_count: 0,
  accepted_count: 0,
  pending_count: 0,
  rejected_count: 0,
  unassigned_count: 0,
})

const normalizeText = (value) => String(value || '').trim().toLowerCase()
const fullName = (u) => {
  if (!u) return 'N/A'
  const mi = u.middle_initial ? `${u.middle_initial}. ` : ''
  return `${u.first_name || ''} ${mi}${u.last_name || ''}`.replace(/\s+/g, ' ').trim() || 'N/A'
}
const normalizeTeamStatus = (value) => {
  const status = normalizeText(value)
  if (status === 'accepted' || status === 'pending' || status === 'rejected') return status
  return 'unassigned'
}
const inferWorkCategoryFromText = (value) => {
  const text = normalizeText(value)
  if (!text) return ''
  if (text.includes('siphon') || text.includes('septic') || text.includes('desludg') || text.includes('sewer') || text.includes('jetter') || text.includes('drain')) {
    return 'Siphoning'
  }
  if (text.includes('plumb') || text.includes('pipe') || text.includes('leak') || text.includes('waterline') || text.includes('sanitary')) {
    return 'Plumbing'
  }
  return ''
}
const inferTeamCategory = (team) => {
  const byTeamName = inferWorkCategoryFromText(team?.team)
  if (byTeamName) return byTeamName

  const members = Array.isArray(team?.members) ? team.members : []
  let siphoningCount = 0
  let plumbingCount = 0
  members.forEach((member) => {
    const hit = inferWorkCategoryFromText(member?.role)
    if (hit === 'Siphoning') siphoningCount += 1
    if (hit === 'Plumbing') plumbingCount += 1
  })
  if (siphoningCount > plumbingCount) return 'Siphoning'
  if (plumbingCount > siphoningCount) return 'Plumbing'
  return 'General'
}
const statusLabel = (value) => {
  const status = normalizeTeamStatus(value)
  if (status === 'accepted') return 'Accepted'
  if (status === 'pending') return 'Pending'
  if (status === 'rejected') return 'Rejected'
  return 'Unassigned'
}
const statusPillClass = (value) => {
  const status = normalizeTeamStatus(value)
  if (status === 'accepted') return 'bg-emerald-50 text-emerald-700'
  if (status === 'pending') return 'bg-amber-50 text-amber-700'
  if (status === 'rejected') return 'bg-rose-50 text-rose-700'
  return 'bg-slate-100 text-slate-600'
}
const memberAcceptDotClass = (value) => {
  const status = normalizeTeamStatus(value)
  if (status === 'accepted') return 'bg-emerald-500 ring-emerald-100'
  return 'bg-rose-500 ring-rose-100'
}
const requestStatusPillClass = (value) => {
  const status = normalizeText(value)
  if (status === 'pending') return 'bg-amber-50 text-amber-700'
  if (status === 'approved' || status === 'accepted') return 'bg-sky-50 text-sky-700'
  if (status === 'awaiting_material') return 'bg-violet-50 text-violet-700'
  if (status === 'job_ready') return 'bg-emerald-50 text-emerald-700'
  return 'bg-slate-100 text-slate-700'
}

const isTeamLeader = (member, team) => {
  const memberId = Number(member?.id || 0)
  if (!memberId) return false

  const explicitLeaderId = Number(team?.leader_member_id || 0)
  if (explicitLeaderId > 0) {
    return memberId === explicitLeaderId
  }

  return Boolean(member?.is_team_leader)
}

const teamLeaderName = (team) => {
  const members = Array.isArray(team?.members) ? team.members : []
  const explicitLeaderId = Number(team?.leader_member_id || 0)
  if (explicitLeaderId > 0) {
    const explicitLeader = members.find((member) => Number(member?.id || 0) === explicitLeaderId)
    if (explicitLeader?.name) return explicitLeader.name
  }
  const fallback = members.find((member) => Boolean(member?.is_team_leader))
  return fallback?.name || 'Not set'
}

const normalizeTime = (value) => String(value || '').trim().slice(0, 5)

const formatSchedule = (dateValue, timeFromValue, timeToValue) => {
  const date = String(dateValue || '').trim()
  const timeFrom = normalizeTime(timeFromValue)
  const timeTo = normalizeTime(timeToValue)
  if (!date && !timeFrom && !timeTo) return 'Not set'
  if (!date) return `${timeFrom}${timeTo ? ` - ${timeTo}` : ''}`.trim()
  if (!timeFrom && !timeTo) return date
  if (!timeTo) return `${date} ${timeFrom}`
  return `${date} ${timeFrom} - ${timeTo}`
}

const hydrateScheduleDrafts = (teamRows) => {
  const draft = {}
  for (const team of teamRows || []) {
    const teamName = String(team?.team || '')
    if (!teamName) continue
    draft[teamName] = {
      date: String(team?.team_schedule_date || ''),
      time_from: normalizeTime(team?.team_schedule_time_from),
      time_to: normalizeTime(team?.team_schedule_time_to),
    }
  }
  scheduleDrafts.value = draft
}

const filteredTeams = computed(() => {
  const keyword = normalizeText(search.value)
  const targetStatus = normalizeText(statusFilter.value)

  return (teams.value || [])
    .map((team) => {
      let members = Array.isArray(team?.members) ? [...team.members] : []

      if (targetStatus !== '' && targetStatus !== 'all') {
        members = members.filter((member) => normalizeTeamStatus(member?.team_assignment_status) === targetStatus)
      }

      if (keyword !== '') {
        members = members.filter((member) => {
          const haystack = [
            team?.team,
            member?.name,
            member?.email,
            member?.role,
            member?.team_assignment_status,
          ]
            .map((entry) => String(entry || ''))
            .join(' ')
            .toLowerCase()
          return haystack.includes(keyword)
        })
      }

      if (!members.length) return null

      const acceptedCount = members.filter((member) => normalizeTeamStatus(member?.team_assignment_status) === 'accepted').length
      const pendingCount = members.filter((member) => normalizeTeamStatus(member?.team_assignment_status) === 'pending').length
      const rejectedCount = members.filter((member) => normalizeTeamStatus(member?.team_assignment_status) === 'rejected').length
      const used = acceptedCount + pendingCount

      return {
        ...team,
        members,
        total_members: members.length,
        accepted_count: acceptedCount,
        pending_count: pendingCount,
        rejected_count: rejectedCount,
        capacity_used: used,
        capacity_remaining: Math.max(Number(team?.capacity_limit || 3) - used, 0),
        is_full: used >= Number(team?.capacity_limit || 3),
      }
    })
    .filter(Boolean)
})

const categorizedFilteredTeams = computed(() => {
  const groups = [
    { key: 'siphoning', label: 'Siphoning Teams', teams: [] },
    { key: 'plumbing', label: 'Plumbing Teams', teams: [] },
    { key: 'general', label: 'General Teams', teams: [] },
  ]

  filteredTeams.value.forEach((team) => {
    const category = inferTeamCategory(team)
    if (category === 'Siphoning') {
      groups[0].teams.push(team)
      return
    }
    if (category === 'Plumbing') {
      groups[1].teams.push(team)
      return
    }
    groups[2].teams.push(team)
  })

  return groups.filter((group) => group.teams.length > 0)
})

const navigateTo = (menu, url) => {
  activeMenu.value = menu
  router.visit(url)
}

const loadOverview = async () => {
  loading.value = true
  try {
    const res = await axios.get('/hr/employees/team-overview')
    const rows = Array.isArray(res.data?.teams) ? res.data.teams : []
    teams.value = rows
    hydrateScheduleDrafts(rows)
    unassigned.value = Array.isArray(res.data?.unassigned) ? res.data.unassigned : []
    summary.value = {
      team_count: Number(res.data?.summary?.team_count || 0),
      approved_employee_count: Number(res.data?.summary?.approved_employee_count || 0),
      accepted_count: Number(res.data?.summary?.accepted_count || 0),
      pending_count: Number(res.data?.summary?.pending_count || 0),
      rejected_count: Number(res.data?.summary?.rejected_count || 0),
      unassigned_count: Number(res.data?.summary?.unassigned_count || 0),
    }
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to load team overview.', 'error')
  } finally {
    loading.value = false
  }
}

const loadIncomingRequests = async () => {
  loadingIncomingRequests.value = true
  try {
    const res = await axios.get('/hr/service-requests')
    const rows = Array.isArray(res.data) ? res.data : []
    incomingRequests.value = rows.filter((request) => {
      const status = normalizeText(request?.status)
      return ['pending', 'approved', 'accepted'].includes(status)
    })
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to load request coordination queue.', 'error')
  } finally {
    loadingIncomingRequests.value = false
  }
}

const saveTeamSchedule = async (team) => {
  const teamName = String(team?.team || '').trim()
  if (!teamName) return

  const draft = scheduleDrafts.value[teamName] || { date: '', time_from: '', time_to: '' }
  const payload = {
    team: teamName,
    schedule_date: String(draft.date || ''),
    schedule_time_from: normalizeTime(draft.time_from),
    schedule_time_to: normalizeTime(draft.time_to),
  }

  if (!payload.schedule_date || !payload.schedule_time_from || !payload.schedule_time_to) {
    Swal.fire('Missing Data', 'Please select date, time from, and time to.', 'warning')
    return
  }
  if (!allowedScheduleTimeSet.has(payload.schedule_time_from) || !allowedScheduleTimeSet.has(payload.schedule_time_to)) {
    Swal.fire('Invalid Time', 'Use hourly slots from 6:00 AM to 6:00 PM only.', 'warning')
    return
  }

  if (payload.schedule_time_to <= payload.schedule_time_from) {
    Swal.fire('Invalid Time Range', 'End time must be later than start time.', 'warning')
    return
  }

  savingTeamName.value = teamName
  try {
    const res = await axios.post('/hr/employees/team-schedule', payload)
    Swal.fire('Success', res.data?.message || 'Team schedule saved.', 'success')
    await loadOverview()
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to save team schedule.', 'error')
  } finally {
    savingTeamName.value = ''
  }
}

const logout = async () => {
  await confirmAndLogout()
}

onMounted(async () => {
  await Promise.all([loadOverview(), loadIncomingRequests()])
})
</script>