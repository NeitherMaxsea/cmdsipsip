<template>
  <div class="space-y-6">
    <section class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <p class="text-xs font-semibold uppercase tracking-[0.14em] text-cyan-700">Governance</p>
      <h2 class="mt-2 text-2xl font-black text-slate-900">RBAC Overview</h2>
      <p class="mt-2 text-sm text-slate-600">
        Detect whether a registered record should use the company office model or the business-owner workspace model.
      </p>

      <div class="mt-5 grid gap-4 lg:grid-cols-[minmax(0,360px)_minmax(0,1fr)]">
        <div>
          <label class="mb-2 block text-xs font-semibold uppercase tracking-[0.14em] text-slate-500">
            Registered Record
          </label>
          <select
            v-model="selectedBusinessId"
            class="w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 text-sm text-slate-700 focus:border-cyan-500 focus:ring-2 focus:ring-cyan-100"
          >
            <option value="">Select company or business...</option>
            <option v-for="option in businessOptions" :key="option.id" :value="String(option.id)">
              {{ option.business_name }} - {{ option.type_label }}
            </option>
          </select>
          <p class="mt-2 text-xs text-slate-500">
            {{ businessContextLoading ? 'Loading registered business records...' : `${companyCount} companies and ${smallBusinessCount} small businesses detected.` }}
          </p>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-slate-50 p-5">
          <p class="text-xs font-semibold uppercase tracking-[0.14em] text-slate-500">RBAC Result</p>

          <div v-if="selectedBusinessContext" class="mt-3 space-y-4">
            <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <h3 class="text-xl font-black text-slate-900">{{ selectedBusinessContext.businessName }}</h3>
                <p class="mt-1 text-sm text-slate-600">{{ selectedBusinessContext.rbacRule }}</p>
              </div>
              <span
                class="inline-flex w-fit rounded-full border px-3 py-1 text-xs font-semibold"
                :class="selectedBusinessContext.isCompany
                  ? 'border-cyan-200 bg-cyan-50 text-cyan-800'
                  : 'border-amber-200 bg-amber-50 text-amber-800'"
              >
                {{ selectedBusinessContext.typeLabel }}
              </span>
            </div>

            <div class="grid gap-3 sm:grid-cols-2">
              <div class="rounded-xl border border-white bg-white px-4 py-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-400">Workspace Mode</p>
                <p class="mt-1 text-sm font-semibold text-slate-900">{{ selectedBusinessContext.workspaceLabel }}</p>
              </div>
              <div class="rounded-xl border border-white bg-white px-4 py-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-400">Management Mode</p>
                <p class="mt-1 text-sm font-semibold text-slate-900">{{ selectedBusinessContext.managementModeLabel }}</p>
              </div>
            </div>

            <div>
              <p class="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-400">Applicable Roles</p>
              <div class="mt-2 flex flex-wrap gap-2">
                <span
                  v-for="role in selectedBusinessContext.applicableRoles"
                  :key="role"
                  class="inline-flex rounded-full border border-slate-200 bg-white px-3 py-1 text-xs font-semibold text-slate-700"
                >
                  {{ role }}
                </span>
              </div>
            </div>
          </div>

          <div v-else class="mt-3 rounded-2xl border border-dashed border-slate-300 bg-white px-4 py-8 text-center text-sm text-slate-500">
            Select a record to view the detected RBAC model.
          </div>
        </div>
      </div>
    </section>

    <section class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <h3 class="text-lg font-black text-slate-900">RBAC Models</h3>
      <div class="mt-4 grid gap-4 md:grid-cols-2">
        <article class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
          <p class="text-sm font-bold text-slate-900">Company</p>
          <p class="mt-1 text-sm text-slate-600">Uses office-based roles assigned by the administrator.</p>
          <div class="mt-3 flex flex-wrap gap-2">
            <span
              v-for="role in companyRoles"
              :key="role"
              class="inline-flex rounded-full border border-slate-200 bg-white px-3 py-1 text-xs font-semibold text-slate-700"
            >
              {{ role }}
            </span>
          </div>
        </article>

        <article class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
          <p class="text-sm font-bold text-slate-900">Business</p>
          <p class="mt-1 text-sm text-slate-600">Uses the business-owner workspace instead of office departments.</p>
          <div class="mt-3 flex flex-wrap gap-2">
            <span
              v-for="role in businessRoles"
              :key="role"
              class="inline-flex rounded-full border border-slate-200 bg-white px-3 py-1 text-xs font-semibold text-slate-700"
            >
              {{ role }}
            </span>
          </div>
        </article>
      </div>
    </section>
  </div>
</template>

<script setup>
import axios from 'axios'
import { computed, onMounted, ref } from 'vue'

const businessOptions = ref([])
const selectedBusinessId = ref('')
const businessContextLoading = ref(false)

const companyRoles = ['HR', 'CSR', 'Finance', 'Procurement', 'Operational Management']
const businessRoles = ['Business Owner']

const normalizeBusinessType = (value) => {
  const raw = String(value || '').trim().toLowerCase().replace(/[_/-]+/g, ' ')
  if (['company', 'corporation', 'corporate'].includes(raw)) return 'company'
  if (['individual', 'small business', 'individual small business', 'sole proprietor', 'sole proprietorship'].includes(raw)) {
    return 'individual_small_business'
  }
  return ''
}

const managementModeForBusinessType = (businessType) => {
  if (businessType === 'company') return 'hr'
  if (businessType === 'individual_small_business') return 'business'
  return ''
}

const businessTypeLabel = (businessType) => {
  if (businessType === 'company') return 'Company'
  if (businessType === 'individual_small_business') return 'Individual/Small Business'
  return 'Unclassified'
}

const managementModeLabel = (mode) => {
  if (mode === 'hr') return 'HR-Managed'
  if (mode === 'business') return 'Business-Managed'
  return 'Not Set'
}

const fetchBusinesses = async () => {
  businessContextLoading.value = true
  try {
    const res = await axios.get('/admin/businesses')
    businessOptions.value = (res.data || []).map((item) => {
      const normalizedType = normalizeBusinessType(item.business_type)
      const derivedMode = String(item.management_mode || '').trim().toLowerCase() || managementModeForBusinessType(normalizedType)
      return {
        ...item,
        id: item.id,
        business_name: item.business_name || item.company_name || item.user?.business_name || `Business #${item.id}`,
        normalized_type: normalizedType,
        type_label: businessTypeLabel(normalizedType),
        derived_mode: derivedMode,
        assignment_email: item.company_email || item.assignment_email || item.user?.email || item.email || 'No email found',
        approved: Boolean(item.is_approved ?? item.approved ?? false),
      }
    })
  } catch (error) {
    console.error('Failed to fetch RBAC business context:', error)
    businessOptions.value = []
  } finally {
    businessContextLoading.value = false
  }
}

onMounted(() => {
  fetchBusinesses()
})

const companyCount = computed(() => businessOptions.value.filter((item) => item.normalized_type === 'company').length)
const smallBusinessCount = computed(() => businessOptions.value.filter((item) => item.normalized_type === 'individual_small_business').length)

const selectedBusinessContext = computed(() => {
  const selected = businessOptions.value.find((item) => String(item.id) === String(selectedBusinessId.value))
  if (!selected) return null

  const isCompany = selected.normalized_type === 'company'
  const workspaceLabel = isCompany ? 'Company With Department Offices' : 'Business Owner Workspace'
  const ownerWorkspaceLabel = isCompany ? 'HR-managed company routing is expected.' : 'Business owner handles the main workspace directly.'
  const applicableRoles = isCompany ? companyRoles : businessRoles
  const moduleFamilies = isCompany
    ? ['hr.*', 'csr.*', 'finance.*', 'procurement.*', 'operations.*']
    : ['business.*']

  return {
    businessName: selected.business_name,
    isCompany,
    typeLabel: selected.type_label,
    workspaceLabel,
    managementModeLabel: managementModeLabel(selected.derived_mode),
    applicableRoles,
    rbacRule: isCompany
      ? 'RBAC should detect this record as a company, enabling HR-managed routing plus company-scoped CSR, Finance, Procurement, and Operational roles.'
      : 'RBAC should detect this record as an individual or small business, keeping access in the business workspace instead of the company office workflow.',
  }
})
</script>
