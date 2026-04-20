<template>
  <div class="flex min-h-screen bg-slate-50">
    <HrSidebarNav :active-menu="activeMenuLabel" @navigate="navigateTo" />

    <main class="flex min-w-0 flex-1 flex-col overflow-y-auto bg-slate-50">
      <HrTopbar @logout="logout" />

      <div class="hr-content space-y-5 p-6">
        <section class="relative isolate flex items-start justify-between gap-3 overflow-hidden rounded-[18px] border border-blue-100 border-t-4 border-t-emerald-600 bg-gradient-to-b from-white to-slate-50 p-5 shadow-[0_8px_20px_rgba(15,23,42,0.05)]">
          <div>
            <p class="m-0 text-[11px] uppercase tracking-[0.12em] text-emerald-700">HR Workspace</p>
            <h1 class="mt-1.5 text-[34px] font-extrabold leading-[1.1] text-slate-900">
              {{ stageTitle }}
            </h1>
            <p class="mt-2 text-sm text-slate-600">
              {{ stageDescription }}
            </p>
          </div>
          <button class="rounded-full border border-slate-900 bg-gradient-to-br from-slate-900 to-slate-800 px-4 py-2 text-xs font-bold text-white shadow-lg shadow-slate-900/20 transition hover:-translate-y-0.5 hover:brightness-105" @click="loadAll">Refresh</button>
        </section>

        <section class="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div class="rounded-xl border border-slate-200 bg-white p-3.5 shadow-sm">
            <p class="text-xs uppercase tracking-wide text-slate-500">Total Queue</p>
            <p class="mt-1 text-3xl font-extrabold leading-tight text-slate-900">{{ stats.total }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-white p-3.5 shadow-sm">
            <p class="text-xs uppercase tracking-wide text-slate-500">Needs Assignment</p>
            <p class="mt-1 text-3xl font-extrabold leading-tight text-slate-900">{{ stats.needs }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-white p-3.5 shadow-sm">
            <p class="text-xs uppercase tracking-wide text-slate-500">Already Assigned</p>
            <p class="mt-1 text-3xl font-extrabold leading-tight text-slate-900">{{ stats.assigned }}</p>
          </div>
        </section>

        <section class="flex flex-wrap items-center gap-2.5 rounded-xl border border-slate-200 bg-white p-3">
          <div class="flex flex-wrap gap-2">
            <button
              v-for="opt in filters"
              :key="opt.value"
              @click="statusFilter = opt.value"
              class="px-3 py-1.5 rounded-full text-xs font-semibold border transition"
              :class="statusFilter === opt.value ? 'bg-white text-emerald-700 border-emerald-300' : 'bg-white text-slate-600 border-slate-300 hover:border-slate-400 hover:text-slate-800'"
            >
              {{ opt.label }}
            </button>
          </div>
          <input
            v-model.trim="search"
            type="text"
            placeholder="Search business, customer, or assignee..."
            class="ml-auto w-full max-w-xs rounded-[10px] border border-slate-300 bg-white px-3 py-2 text-[13px] text-slate-700 placeholder:text-slate-400 focus:border-slate-500 focus:outline-none"
          />
        </section>

        <section v-if="showEmployeeTeamSection" class="rounded-xl border border-slate-200 bg-white p-3.5 shadow-sm">
          <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p class="text-xs uppercase tracking-wide text-slate-500">Employee Team Assignment</p>
              <h2 class="text-lg font-semibold text-slate-900">Employees for Team Assignment</h2>
              <p class="text-sm text-slate-500">Employees created from Employee Management appear here for initial assignment or reassignment.</p>
            </div>
            <div class="flex items-center gap-2">
              <span class="rounded-full bg-amber-50 px-3 py-1 text-xs font-medium text-amber-700">
                {{ waitingEmployeesCount }} waiting
              </span>
              <span class="rounded-full bg-emerald-50 px-3 py-1 text-xs font-medium text-emerald-700">
                {{ assignedEmployeesCount }} assigned
              </span>
            </div>
          </div>

          <p v-if="!isHrManager" class="mt-3 text-xs text-rose-600">
            Only the HR approver can assign or reassign teams for approved employees.
          </p>

          <div v-if="assignableEmployees.length" class="mt-4 overflow-x-auto rounded-xl border border-slate-200">
            <table class="w-full text-sm">
              <thead class="bg-white text-left text-xs uppercase tracking-wide text-slate-500">
                <tr>
                  <th class="px-4 py-3">Employee</th>
                  <th class="px-4 py-3">Role</th>
                  <th class="px-4 py-3">Status</th>
                  <th class="px-4 py-3">Team</th>
                  <th class="px-4 py-3">Assignment</th>
                  <th class="px-4 py-3">Assign Team</th>
                  <th class="px-4 py-3 text-right">Action</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-200">
                <tr v-for="employee in assignableEmployees" :key="employee.id" class="bg-white">
                  <td class="px-4 py-3">
                    <p class="font-semibold text-slate-900">{{ employee.name || `Employee #${employee.id}` }}</p>
                    <p class="text-xs text-slate-500">{{ employee.email || 'No email' }}</p>
                  </td>
                  <td class="px-4 py-3 text-slate-600">{{ employee.role || 'N/A' }}</td>
                  <td class="px-4 py-3 text-slate-600">{{ employee.status || 'N/A' }}</td>
                  <td class="px-4 py-3 text-slate-600">{{ employee.team || 'Unassigned' }}</td>
                  <td class="px-4 py-3">
                    <span
                      class="rounded-full px-3 py-1 text-xs font-semibold"
                      :class="employeeAssignmentBadgeClass(employee)"
                    >
                      {{ employeeAssignmentBadgeText(employee) }}
                    </span>
                  </td>
                  <td class="px-4 py-3">
                    <select
                      v-model="selectedEmployeeTeams[employee.id]"
                      class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:ring-2 focus:ring-slate-200 focus:border-slate-500"
                      :disabled="!canAssignEmployeeTeam(employee) || assigningEmployeeTeamId === employee.id"
                    >
                      <option value="">Select team</option>
                      <option v-for="team in employeeTeamOptions" :key="team" :value="team">{{ team }}</option>
                    </select>
                  </td>
                  <td class="px-4 py-3">
                    <div class="flex justify-end">
                      <button
                        type="button"
                        class="min-w-[130px] rounded-lg border px-3 py-2 text-xs font-bold text-white transition disabled:cursor-not-allowed disabled:opacity-55"
                        :class="employeeActionClass(employee)"
                        :disabled="!canAssignEmployeeTeam(employee) || !selectedEmployeeTeams[employee.id] || assigningEmployeeTeamId === employee.id"
                        @click="assignEmployeeTeam(employee)"
                      >
                        {{ assigningEmployeeTeamId === employee.id ? 'Saving...' : employeeActionLabel(employee) }}
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-else class="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-4 text-sm text-slate-500">
            No employee records found for team assignment.
          </div>
        </section>

        <section v-if="loading" class="p-2.5 text-sm text-slate-500">Loading coordination queue...</section>

        <section v-else-if="visibleRequests.length" class="grid grid-cols-1 xl:grid-cols-2 gap-5">
          <article
            v-for="req in visibleRequests"
            :key="req.id"
            class="rounded-[18px] border border-slate-200 border-l-4 bg-white p-5 shadow-[0_8px_20px_rgba(15,23,42,0.05)]"
            :class="isAssigned(req) ? 'border-l-emerald-500' : 'border-l-amber-500'"
          >
            <div class="flex items-start justify-between gap-3">
              <div>
                <p class="text-xs uppercase tracking-wide text-slate-400">Request #{{ req.id }}</p>
                <h3 class="text-lg font-semibold text-slate-900">{{ req.business?.business_name || 'N/A Business' }}</h3>
                <p class="text-sm text-slate-500 mt-0.5">Customer: {{ fullName(req.user) }}</p>
              </div>
              <span
                class="px-2.5 py-1 rounded-full text-xs font-semibold capitalize"
                :class="isAssigned(req) ? 'bg-emerald-50 text-emerald-700' : 'bg-amber-50 text-amber-700'"
              >
                {{ req.status }}
              </span>
            </div>

            <div class="mt-4 grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Service Type</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">Service: {{ req.service_type || 'N/A' }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Assigned Team</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">{{ requestSelectedTeam(req) }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Management Flow</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">{{ managementFlowLabel(req) }}</p>
                <p class="text-xs font-semibold text-teal-700 mt-1">Fixed Price: {{ formatCurrency(serviceFeeAmount(req)) }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Preferred Date</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">Date: {{ requestSelectedDate(req) }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Team Schedule</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">{{ requestTeamSchedule(req) }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Service Time</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">{{ requestSelectedTime(req) }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Payment Method</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">{{ paymentMethodLabel(req.payment_method) }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Payment Channel</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">{{ paymentChannelLabel(req.payment_channel) }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Service Fee</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">{{ formatCurrency(serviceFeeAmount(req)) }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Requested At</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">{{ formatDateTime(req.created_at) }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Address</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">{{ req.address_text || 'N/A' }}</p>
              </div>
              <div class="rounded-lg border border-slate-200 bg-white p-3">
                <p class="text-[11px] uppercase tracking-wide text-slate-400">Contact Number</p>
                <p class="text-sm font-semibold text-slate-800 mt-1">{{ req.contact_number || 'N/A' }}</p>
              </div>
            </div>

            <div v-if="cleanRequestNotes(req)" class="mt-3 rounded-lg border border-slate-200 bg-white p-3">
              <p class="text-[11px] uppercase tracking-wide text-slate-400">Notes</p>
              <p class="text-sm font-semibold text-slate-800 mt-1">{{ cleanRequestNotes(req) }}</p>
            </div>

            <div class="mt-3 rounded-xl border border-slate-200 bg-white p-3">
              <p class="text-xs text-slate-600">
                <template v-if="requestNeedsCsrValidation(req)">
                  HR clearance for company-managed requests sends this request to <span class="font-semibold">CSR Intake Review</span> first before Operations can see Stage 2.
                </template>
                <template v-else>
                  HR clearance now sends this request to <span class="font-semibold">Operational Review</span> before any materials or procurement step begins.
                </template>
              </p>
              <div class="mt-3 flex justify-end">
                <button
                  type="button"
                  class="rounded-full border border-slate-900 bg-gradient-to-br from-slate-900 to-slate-800 px-3.5 py-2 text-xs font-bold text-white shadow-md shadow-slate-900/20 transition hover:-translate-y-0.5 disabled:cursor-not-allowed disabled:opacity-50 disabled:shadow-none disabled:hover:translate-y-0"
                  :disabled="!canApproveForProcurement(req) || approvingRequestId === req.id"
                  @click="approveForProcurement(req)"
                >
                  {{ approvingRequestId === req.id ? 'Routing...' : requestNeedsCsrValidation(req) ? 'Send to CSR' : 'Send to Operations' }}
                </button>
              </div>
            </div>
          </article>
        </section>

        <section v-else class="rounded-xl border border-dashed border-slate-300 bg-white p-7 text-center">
          <p class="text-slate-700 font-semibold">No coordination items matched your filter.</p>
          <p class="text-sm text-slate-500 mt-1">Try switching filters or refreshing the queue.</p>
        </section>
      </div>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import HrSidebarNav from '@/Components/HrSidebarNav.vue'
import HrTopbar from '@/Components/HrTopbar.vue'
import { confirmAndLogout } from '@/lib/auth-flow'

const loading = ref(false)
const approvingRequestId = ref(null)
const assigningEmployeeTeamId = ref(null)
const requests = ref([])
const availableProviders = ref([])
const availableEmployees = ref([])
const employeePool = ref([])
const statusFilter = ref('all')
const search = ref('')
const selectedEmployeeTeams = reactive({})
const page = usePage()
const isHrManager = computed(() => Boolean(page.props?.auth?.flags?.is_hr_manager))
const stage = computed(() => {
  const url = String(page.url || '')
  const parts = url.split('?')
  if (parts.length < 2) return ''
  const params = new URLSearchParams(parts[1] || '')
  return String(params.get('stage') || '').trim().toLowerCase()
})
const isReadyStage = computed(() => stage.value === 'ready')
const isAwaitingStage = computed(() => stage.value === 'awaiting-material')
const stageTitle = computed(() => {
  if (isReadyStage.value) return 'Ready For Dispatch'
  if (isAwaitingStage.value) return 'Awaiting Materials'
  return 'Request Coordination Queue'
})
const stageDescription = computed(() => {
  if (isReadyStage.value) return 'Showing requests that already cleared materials and payment gates and are ready for dispatch.'
  if (isAwaitingStage.value) return 'Showing requests that are already in materials planning or procurement follow-up.'
  return 'Review staffing details, then send qualified requests into Operations for the next workflow step.'
})
const activeMenuLabel = computed(() => {
  if (isReadyStage.value) return 'Ready For Dispatch'
  if (isAwaitingStage.value) return 'Awaiting Materials'
  return 'Request Coordination'
})
const showEmployeeTeamSection = computed(() => false)
const employeeTeamOptions = Array.from({ length: 26 }, (_, index) => `Team ${String.fromCharCode(65 + index)}`)

const filters = [
  { value: 'all', label: 'All' },
  { value: 'for_assignment', label: 'Needs HR Approval' },
  { value: 'assigned', label: 'Approved / Routed' },
]

const navigateTo = (_menu, url) => router.visit(url)

const fullName = (u) => {
  if (!u) return 'N/A'
  const mi = u.middle_initial ? `${u.middle_initial}. ` : ''
  return `${u.first_name || ''} ${mi}${u.last_name || ''}`.replace(/\s+/g, ' ').trim() || 'N/A'
}

const readMetaTag = (text, key) => {
  const source = String(text || '')
  const pattern = new RegExp(`\\[${key}:\\s*([^\\]]+)\\]`, 'i')
  const match = source.match(pattern)
  return match?.[1]?.trim() || ''
}

const requestSelectedTeam = (req) => {
  const fromNotes = readMetaTag(req?.notes, 'TEAM')
  if (fromNotes) return fromNotes
  if (req?.employee?.team) return req.employee.team
  return 'Not specified'
}

const requestSelectedDate = (req) => {
  const fromNotes = readMetaTag(req?.notes, 'DATE')
  if (fromNotes) return fromNotes
  return formatDate(req?.preferred_date)
}

const requestSelectedTime = (req) => {
  const fromNotes = readMetaTag(req?.notes, 'TIME')
  if (fromNotes) return fromNotes
  return 'Not specified'
}

const requestTeamSchedule = (req) => {
  const date = requestSelectedDate(req)
  const time = requestSelectedTime(req)
  if (!date || date === 'N/A') return time
  if (!time || time === 'Not specified') return date
  return `${date} | ${time}`
}

const cleanRequestNotes = (req) => {
  const text = String(req?.notes || '')
  return text
    .replace(/\[(TEAM|DATE|TIME)\s*:[^\]]+\]/gi, '')
    .trim()
}

const managementFlowLabel = (req) => {
  const mode = String(req?.business?.management_mode || '').trim().toLowerCase()
  if (mode === 'hr') return 'HR-Managed'
  if (mode === 'business') return 'Business-Managed'
  return 'N/A'
}

const serviceFeeAmount = (req) => {
  const amount = Number(req?.total_amount || 0)
  if (Number.isFinite(amount) && amount > 0) return amount
  const mode = String(req?.business?.management_mode || '').trim().toLowerCase()
  if (mode === 'hr') return 3500
  if (mode === 'business') return 3000
  return 0
}

const formatCurrency = (value) => {
  const amount = Number(value || 0)
  if (!Number.isFinite(amount)) return 'PHP 0.00'
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP' }).format(amount)
}

const paymentMethodLabel = (method) => {
  const normalized = String(method || '').trim().toLowerCase()
  if (normalized === 'full') return 'Full Payment'
  if (normalized === 'downpayment') return 'Downpayment'
  if (normalized === 'personal') return 'Cash'
  return normalized ? normalized.charAt(0).toUpperCase() + normalized.slice(1) : 'N/A'
}

const paymentChannelLabel = (channel) => {
  const normalized = String(channel || '').trim().toLowerCase()
  if (!normalized) return 'Cash'
  if (normalized === 'gcash') return 'GCash'
  if (normalized === 'paypal') return 'PayPal'
  if (normalized === 'paymaya' || normalized === 'sm_bills' || normalized === 'lazada_shopeepay') return 'PayPal'
  if (normalized === 'bank_transfer') return 'Bank Transfer'
  return normalized.charAt(0).toUpperCase() + normalized.slice(1)
}

const assignableEmployees = computed(() => {
  return (employeePool.value || []).filter((employee) => {
    const approvalStatus = String(employee?.approval_status || '').toLowerCase()
    const status = String(employee?.status || '').toLowerCase()
    const isApprovalAllowed = approvalStatus === 'approved' || (approvalStatus === '' && employee?.is_user_approved === true)
    const isRejected = approvalStatus === 'rejected' || status === 'rejected' || status === 'pending approval'

    return isApprovalAllowed && !isRejected
  })
})

const normalizedValue = (value) => String(value || '').trim()
const employeeApprovalStatus = (employee) => String(employee?.approval_status || '').toLowerCase()
const employeeStatus = (employee) => String(employee?.status || '').toLowerCase()
const currentEmployeeTeam = (employee) => normalizedValue(employee?.team)
const selectedEmployeeTeam = (employee) => normalizedValue(selectedEmployeeTeams[employee.id])
const isEmployeeAssigned = (employee) => currentEmployeeTeam(employee) !== ''
const isEmployeeApproved = (employee) => {
  const approval = employeeApprovalStatus(employee)
  if (approval) return approval === 'approved'
  const status = employeeStatus(employee)
  if (status === 'pending approval' || status === 'rejected') return false
  if (typeof employee?.is_user_approved === 'boolean') return employee.is_user_approved
  return status !== ''
}
const isEmployeePendingApproval = (employee) =>
  employeeApprovalStatus(employee) === 'pending' ||
  employeeStatus(employee) === 'pending approval' ||
  employee?.is_user_approved === false
const isEmployeeTeamReassignment = (employee) =>
  currentEmployeeTeam(employee) !== '' &&
  selectedEmployeeTeam(employee) !== '' &&
  selectedEmployeeTeam(employee) !== currentEmployeeTeam(employee)
const isEmployeeTeamFreshAssignment = (employee) =>
  currentEmployeeTeam(employee) === '' && selectedEmployeeTeam(employee) !== ''
const waitingEmployeesCount = computed(() =>
  assignableEmployees.value.filter((employee) => !isEmployeeAssigned(employee)).length
)
const assignedEmployeesCount = computed(() =>
  assignableEmployees.value.filter((employee) => isEmployeeAssigned(employee)).length
)
const employeeAssignmentBadgeClass = (employee) => {
  if (!isEmployeeAssigned(employee)) return 'bg-amber-50 text-amber-700'
  if (isEmployeePendingApproval(employee) || !isEmployeeApproved(employee)) return 'bg-sky-50 text-sky-700'
  return 'bg-emerald-50 text-emerald-700'
}
const employeeAssignmentBadgeText = (employee) => {
  if (!isEmployeeAssigned(employee)) return 'Unassigned'
  if (isEmployeePendingApproval(employee) || !isEmployeeApproved(employee)) return 'Assigned - Pending'
  return 'Assigned'
}
const canAssignEmployeeTeam = (employee) => isHrManager.value && isEmployeeApproved(employee)
const employeeActionClass = (employee) => {
  return isEmployeeAssigned(employee)
    ? 'border-amber-600 bg-gradient-to-br from-amber-500 to-amber-700 shadow-lg shadow-amber-700/20 hover:-translate-y-0.5'
    : 'border-blue-700 bg-gradient-to-br from-blue-500 to-blue-700 shadow-lg shadow-blue-700/20 hover:-translate-y-0.5'
}
const employeeActionLabel = (employee) => {
  return isEmployeeAssigned(employee) ? 'Reassign Team' : 'Assign Team'
}

const formatDate = (value) => {
  if (!value) return 'N/A'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return value
  return d.toLocaleDateString()
}

const formatDateTime = (value) => {
  if (!value) return 'N/A'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return value
  return d.toLocaleString()
}

const isAssigned = (req) => Boolean(req?.service_provider_id) || Boolean(req?.employee_id)

const initRequestSelections = (req) => {
  return req
}

const loadRequests = async () => {
  const res = await axios.get('/hr/service-requests', { timeout: 15000 })
  requests.value = res.data || []
  for (const req of requests.value) {
    initRequestSelections(req)
  }
}

const loadProviders = async () => {
  const res = await axios.get('/hr/available-providers', { timeout: 15000 })
  availableProviders.value = res.data || []
}

const loadEmployees = async () => {
  const res = await axios.get('/hr/available-employees', { timeout: 15000 })
  availableEmployees.value = res.data || []
}

const loadEmployeePool = async () => {
  const res = await axios.get('/hr/employees')
  employeePool.value = Array.isArray(res.data) ? res.data : []
  for (const employee of employeePool.value) {
    selectedEmployeeTeams[employee.id] = String(employee?.team || '').trim()
  }
}

const loadAll = async () => {
  loading.value = true
  try {
    await loadRequests()

    const [providersResult, employeesResult] = await Promise.allSettled([
      loadProviders(),
      loadEmployees(),
    ])

    const hasProviderError = providersResult.status === 'rejected'
    const hasEmployeeError = employeesResult.status === 'rejected'
    if (hasProviderError || hasEmployeeError) {
      const details = [
        hasProviderError ? 'providers' : null,
        hasEmployeeError ? 'employees' : null,
      ].filter(Boolean).join(' and ')
      Swal.fire('Partial Load', `Requests loaded, but failed to load ${details}. You can still review queue items.`, 'warning')
    }
  } catch {
    Swal.fire('Error', 'Failed to load request coordination queue.', 'error')
  } finally {
    loading.value = false
  }
}

const canApproveForProcurement = (req) => {
  if (!isHrManager.value) return false
  const status = String(req?.status || '').toLowerCase()
  return ['pending', 'approved', 'accepted'].includes(status)
}

const requestNeedsCsrValidation = (req) => {
  const managementMode = String(req?.management_mode || req?.business?.management_mode || req?.assigned_business?.management_mode || '').trim().toLowerCase()
  const businessType = String(req?.business_type || req?.business?.business_type || req?.assigned_business?.business_type || '').trim().toLowerCase()
  const workflowStage = String(req?.workflow_stage || '').trim().toLowerCase()
  const operationsStage = String(req?.operations_stage || '').trim().toLowerCase()
  const csrStatus = String(req?.csr_status || '').trim().toLowerCase()

  if (!(managementMode === 'hr' || businessType === 'company')) return false
  if (csrStatus === 'validated') return false
  if (workflowStage === 'csr_forwarded' || operationsStage === 'awaiting_operational_review') return false
  return true
}

const approveForProcurement = async (req) => {
  if (!isHrManager.value) {
    Swal.fire('Unauthorized', 'Only the HR approver can clear requests for procurement handoff.', 'error')
    return
  }

  const goesToCsr = requestNeedsCsrValidation(req)
  const confirm = await Swal.fire({
    title: goesToCsr ? 'Send request to CSR?' : 'Send request to Operations?',
    text: goesToCsr
      ? 'Company-managed requests must be validated by CSR first before they can move into Operational review.'
      : 'This will send the request into Operational review before materials planning.',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Confirm'
  })
  if (!confirm.isConfirmed) return

  approvingRequestId.value = req.id
  try {
    const res = await axios.post(`/hr/service-requests/${req.id}/approve-procurement`, {}, { skipGlobalLoading: true })
    Swal.fire('Success', res.data?.message || (goesToCsr ? 'Request sent to CSR intake review first.' : 'Request sent to Operations review.'), 'success')
    requests.value = requests.value.filter((row) => row.id !== req.id)
    loadAll().catch(() => {})
  } catch (err) {
    const backendMessage = err.response?.data?.message
    const backendError = err.response?.data?.error
    Swal.fire('Error', backendMessage || backendError || 'Failed to approve request.', 'error')
  } finally {
    approvingRequestId.value = null
  }
}

const assignEmployeeTeam = async (employee) => {
  if (!canAssignEmployeeTeam(employee)) {
    Swal.fire('Unauthorized', 'Only the HR approver can assign teams for approved employees.', 'error')
    return
  }

  const team = String(selectedEmployeeTeams[employee.id] || '').trim()
  if (!team) {
    Swal.fire('Warning', 'Please select a team.', 'warning')
    return
  }

  const previousTeam = currentEmployeeTeam(employee)
  if (previousTeam !== '' && previousTeam.toLowerCase() === team.toLowerCase()) {
    Swal.fire('Info', `${employee.name || `Employee #${employee.id}`} is already assigned to ${team}.`, 'info')
    return
  }
  const reassignment = previousTeam !== '' && previousTeam !== team
  const assignmentText = reassignment
    ? `${employee.name || `Employee #${employee.id}`} will be reassigned from ${previousTeam} to ${team}.`
    : `${employee.name || `Employee #${employee.id}`} will be assigned to ${team}.`

  const confirm = await Swal.fire({
    title: reassignment ? 'Reassign employee team?' : 'Assign employee team?',
    text: assignmentText,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Confirm',
  })
  if (!confirm.isConfirmed) return

  assigningEmployeeTeamId.value = employee.id
  try {
    const res = await axios.patch(`/hr/employees/${employee.id}`, { team }, { skipGlobalLoading: true })
    employeePool.value = employeePool.value.map((row) => (
      row.id === employee.id ? { ...row, team } : row
    ))
    Swal.fire('Success', res.data?.message || 'Employee team assigned successfully.', 'success')
    Promise.all([loadEmployeePool(), loadEmployees()]).catch(() => {})
  } catch (err) {
    const backendMessage = err.response?.data?.message || err.response?.data?.error || 'Failed to assign employee team.'
    Swal.fire('Error', backendMessage, 'error')
  } finally {
    assigningEmployeeTeamId.value = null
  }
}

const visibleRequests = computed(() => {
  const q = search.value.toLowerCase()
  return (requests.value || []).filter((req) => {
    const requestStatus = String(req?.status || '').toLowerCase()
    if (isReadyStage.value && requestStatus !== 'job_ready') return false
    if (isAwaitingStage.value && requestStatus !== 'awaiting_material') return false

    const assigned = isAssigned(req)
    if (statusFilter.value === 'for_assignment' && assigned) return false
    if (statusFilter.value === 'assigned' && !assigned) return false

    if (!q) return true
    const businessName = String(req.business?.business_name || '').toLowerCase()
    const customer = fullName(req.user).toLowerCase()
    const assignee = `${requestSelectedTeam(req)} ${requestSelectedTime(req)}`.toLowerCase()
    return businessName.includes(q) || customer.includes(q) || assignee.includes(q)
  })
})

const stats = computed(() => {
  const stageScopedRequests = (requests.value || []).filter((req) => {
    const requestStatus = String(req?.status || '').toLowerCase()
    if (isReadyStage.value) return requestStatus === 'job_ready'
    if (isAwaitingStage.value) return requestStatus === 'awaiting_material'
    return true
  })
  const total = stageScopedRequests.length
  const assigned = stageScopedRequests.filter((req) => isAssigned(req)).length
  const needs = total - assigned
  return { total, needs, assigned }
})

const logout = async () => {
  await confirmAndLogout()
}

onMounted(loadAll)
</script>



