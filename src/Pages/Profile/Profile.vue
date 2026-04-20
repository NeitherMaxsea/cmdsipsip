<template>
  <div :class="useHrShell ? 'flex min-h-screen bg-slate-50' : ''">
    <HrSidebarNav
      v-if="useHrShell"
      :active-menu="activeMenu"
      :locked="isWorkspaceLocked"
      @navigate="navigateTo"
    />
    <div :class="useHrShell ? 'flex flex-1 flex-col bg-slate-50' : ''">
      <HrTopbar v-if="useHrShell" @logout="logout" />
      <div :class="useHrShell ? 'p-6 max-md:p-4' : ''">
        <div class="mx-auto w-full max-w-5xl px-6 py-8">
    <div class="relative overflow-hidden rounded-[28px] bg-gradient-to-r from-teal-600 via-emerald-500 to-cyan-500 p-6 shadow-[0_24px_60px_-28px_rgba(13,148,136,0.45)]">
      <div class="absolute -top-6 -right-10 h-32 w-32 rounded-full bg-white/20"></div>
      <div class="absolute -bottom-8 -left-8 h-28 w-28 rounded-full bg-white/15"></div>
      <div class="relative flex flex-col gap-6 text-white md:flex-row md:items-center md:justify-between">
        <div>
          <div class="inline-flex items-center gap-2 rounded-full border border-white/25 bg-white/10 px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.16em] text-white/90">
            Profile
          </div>
          <h2 class="mt-3 text-2xl font-bold tracking-tight">Account Overview</h2>
          <p class="mt-1 max-w-2xl text-sm text-white/85">Review your registration details and uploaded requirements.</p>
        </div>
        <div class="flex flex-wrap gap-2">
          <span class="rounded-full bg-white/20 px-3 py-1 text-xs font-semibold">
            {{ statusLabel || 'Pending Review' }}
          </span>
        </div>
      </div>
    </div>

    <div v-if="loading" class="mt-6 rounded-2xl border border-slate-200 bg-white p-6 text-sm text-slate-500">
      Loading profile details...
    </div>
    <div v-else-if="errorMessage" class="mt-6 rounded-2xl border border-rose-200 bg-rose-50 p-6 text-sm text-rose-700">
      {{ errorMessage }}
    </div>
    <div v-else class="mt-6 space-y-6">
      <section class="rounded-[24px] border border-slate-200 bg-white p-6 shadow-[0_24px_60px_-34px_rgba(15,23,42,0.18)]">
        <h3 class="text-lg font-semibold text-slate-900">Account Details</h3>
        <div class="mt-4 grid grid-cols-1 gap-4 md:grid-cols-2">
          <article class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Name</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ displayName }}</p>
          </article>
          <article class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Role</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ roleLabel }}</p>
          </article>
          <article class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Email</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ profile.email || 'N/A' }}</p>
          </article>
          <article class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Contact Number</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ profile.contact_number || 'N/A' }}</p>
          </article>
        </div>

        <div v-if="profile.rejection_reason || reviewMessage" class="mt-6 rounded-2xl border px-4 py-3 text-sm" :class="reviewNoteClass">
          <p class="font-semibold">Account Review Note</p>
          <p class="mt-1">{{ profile.rejection_reason || reviewMessage }}</p>
        </div>
      </section>

      <section v-if="isBusinessAccount" class="rounded-[24px] border border-slate-200 bg-white p-6 shadow-[0_24px_60px_-34px_rgba(15,23,42,0.18)]">
        <div class="flex flex-wrap items-start justify-between gap-3">
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Account Review</p>
            <h3 class="mt-1 text-lg font-semibold text-slate-900">Company Verification Status</h3>
            <p class="mt-1 text-sm text-slate-600">{{ statusSummaryCopy }}</p>
          </div>
          <span
            v-if="statusLabel"
            class="inline-flex rounded-full px-3 py-1 text-xs font-semibold"
            :class="statusBadgeClass"
          >
            {{ statusLabel }}
          </span>
        </div>

        <div v-if="approvalState === 'rejected'" class="mt-4 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
          Upload the corrected documents below, then resubmit for admin review.
        </div>
        <div v-if="approvalState === 'rejected' && rejectionChecklistDetails.length" class="mt-4 rounded-xl border border-rose-200 bg-white px-4 py-3 text-sm text-slate-700">
          <p class="font-semibold text-rose-700">Required updates</p>
          <div class="mt-2 space-y-2">
            <div v-for="item in rejectionChecklistDetails" :key="item.key" class="rounded-lg border border-rose-100 bg-rose-50/60 px-3 py-2">
              <p class="text-sm font-semibold text-rose-800">{{ item.label }}</p>
              <p class="text-xs text-rose-700">{{ item.description }}</p>
            </div>
          </div>
        </div>
        <div v-else-if="approvalState === 'pending'" class="mt-4 rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-700">
          Your updated files are under review. Please wait for admin approval.
        </div>
        <div v-else-if="approvalState === 'approved'" class="mt-4 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Approved. Your company can now access the workspace tabs.
        </div>
      </section>

      <section v-if="isBusinessAccount" class="rounded-[24px] border border-slate-200 bg-white p-6 shadow-[0_24px_60px_-34px_rgba(15,23,42,0.18)]">
        <h3 class="text-lg font-semibold text-slate-900">Company Profile</h3>
        <p class="mt-1 text-sm text-slate-600">Details were auto-filled from your registration form.</p>
        <div class="mt-4 grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Business Name</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ businessName || 'N/A' }}</p>
          </div>
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Business Type</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ businessTypeLabel }}</p>
          </div>
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Business Ownership</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ profile.business_ownership || 'N/A' }}</p>
          </div>
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Years in Operation</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ yearsInOperationLabel }}</p>
          </div>
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Owner / Representative</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ businessOwner || 'N/A' }}</p>
          </div>
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Company Email</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ profile.company_email || profile.email || 'N/A' }}</p>
          </div>
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Category</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ profile.category || 'N/A' }}</p>
          </div>
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Operating Hours</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ profile.operating_hours || 'N/A' }}</p>
          </div>
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Business Address</p>
            <p class="mt-1 text-sm font-semibold text-slate-800">{{ businessAddress || 'N/A' }}</p>
          </div>
        </div>
      </section>

      <section v-if="isBusinessAccount" class="rounded-[24px] border border-slate-200 bg-white p-6 shadow-[0_24px_60px_-34px_rgba(15,23,42,0.18)]">
        <div class="flex items-center justify-between gap-3">
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Existing Documents</p>
            <h3 class="mt-1 text-lg font-semibold text-slate-900">Saved Requirements</h3>
          </div>
          <span class="rounded-full bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600">
            {{ storedDocuments.length }} files
          </span>
        </div>
        <div v-if="storedDocuments.length" class="mt-4 grid grid-cols-1 gap-3 md:grid-cols-2">
          <article
            v-for="doc in storedDocuments"
            :key="doc.key"
            class="rounded-2xl border border-slate-200 bg-slate-50 p-3"
          >
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-400">{{ doc.label }}</p>
            <p class="mt-2 break-all text-sm font-semibold text-slate-800">{{ doc.name }}</p>
            <button
              v-if="doc.previewable"
              type="button"
              class="mt-2 inline-flex items-center text-sm font-semibold text-teal-700 hover:underline"
              @click="openStoredDocument(doc.url)"
            >
              {{ doc.isImage ? 'Preview document' : 'Open document' }}
            </button>
            <p v-else class="mt-2 text-sm text-slate-400">No preview available for this file.</p>
          </article>
        </div>
        <p v-else class="mt-4 text-sm text-slate-500">No saved documents found on this account yet.</p>
      </section>

      <section v-if="isHrManagedBusiness" class="rounded-[24px] border border-slate-200 bg-white p-6 shadow-[0_24px_60px_-34px_rgba(15,23,42,0.18)]">
        <div class="flex flex-wrap items-start justify-between gap-3">
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Department Access</p>
            <h3 class="mt-1 text-lg font-semibold text-slate-900">HR-Managed Company Roles</h3>
            <p class="mt-1 text-sm text-slate-600">
              Department accounts (CSR, Procurement, Operations, Finance, HR) are created by the Admin under User Management and linked to your company.
            </p>
          </div>
        </div>
        <div class="mt-4 flex flex-wrap gap-2">
          <span class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-700">CSR</span>
          <span class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-700">Procurement</span>
          <span class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-700">Operational Management</span>
          <span class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-700">Finance</span>
          <span class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-700">HR</span>
        </div>
      </section>

      <section v-if="isBusinessAccount && canResubmitDocuments" class="rounded-[24px] border border-slate-200 bg-white p-6 shadow-[0_24px_60px_-34px_rgba(15,23,42,0.18)]">
        <div class="flex items-center justify-between gap-3">
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">New Documents</p>
            <h3 class="mt-1 text-lg font-semibold text-slate-900">Files Ready For Resubmission</h3>
            <p class="mt-1 text-sm text-slate-600">Upload replacements if admin asked for revisions.</p>
            <p v-if="requiredDocumentLabels.length" class="mt-2 text-xs font-semibold text-slate-500">
              Required documents: {{ requiredDocumentLabels.join(', ') }}
            </p>
          </div>
          <span class="rounded-full bg-teal-50 px-2.5 py-1 text-xs font-semibold text-teal-700">
            {{ selectedDocuments.length }} selected
          </span>
        </div>
        <div class="mt-4 grid grid-cols-1 gap-3 md:grid-cols-2">
          <label
            v-for="field in resubmissionFields"
            :key="field.key"
            class="rounded-2xl border border-slate-200 bg-slate-50 p-3"
          >
            <span class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-400">{{ field.label }}</span>
            <input
              type="file"
              accept=".jpg,.jpeg,.png,.webp,.pdf,image/*,application/pdf"
              class="mt-3 block w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700"
              @change="handleDocumentSelection(field.key, $event)"
            />
            <p class="mt-2 break-all text-sm font-semibold text-slate-800">
              {{ selectedDocumentMap[field.key]?.name || 'No new file selected' }}
            </p>
          </label>
        </div>
        <div class="mt-5 flex flex-col gap-2 sm:flex-row">
          <button
            type="button"
            class="inline-flex items-center justify-center rounded-2xl bg-teal-600 px-4 py-2.5 font-semibold text-white shadow-lg shadow-teal-600/20 transition hover:bg-teal-700 disabled:cursor-not-allowed disabled:opacity-60"
            :disabled="!selectedDocuments.length || uploadingDocuments"
            @click="submitDocuments"
          >
            {{ uploadingDocuments ? 'Uploading...' : 'Upload New Documents' }}
          </button>
          <button
            v-if="selectedDocuments.length"
            type="button"
            class="inline-flex items-center justify-center rounded-2xl border border-slate-200 bg-white px-4 py-2.5 font-semibold text-slate-700 transition hover:bg-slate-50"
            @click="clearAllSelectedDocuments"
          >
            Clear Selected Files
          </button>
        </div>
      </section>
    </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import { buildTemporaryFilePath, resolveStoredFileUrl, stripFileQuery } from '@/lib/file-url'
import { hasLocalResubmission, markProfileResubmitted } from '@/lib/profile-resubmission'
import { confirmAndLogout } from '@/lib/auth-flow'
import HrSidebarNav from '@/Components/HrSidebarNav.vue'
import HrTopbar from '@/Components/HrTopbar.vue'

const page = usePage()
const profile = reactive({})
const loading = ref(true)
const errorMessage = ref('')
const uploadingDocuments = ref(false)
const activeMenu = ref('')

const trimString = (value) => String(value ?? '').trim()

const documentFields = [
  { key: 'government_id', label: 'Government ID' },
  { key: 'bir_registration', label: 'BIR Registration' },
  { key: 'dti_registration', label: 'DTI Registration' },
  { key: 'mayor_permit', label: 'Mayor Permit' },
  { key: 'business_permit', label: 'Business Permit' },
  { key: 'sanitary_permit', label: 'Sanitary Permit' },
]

const selectedDocumentMap = reactive({
  government_id: null,
  bir_registration: null,
  dti_registration: null,
  mayor_permit: null,
  business_permit: null,
  sanitary_permit: null,
})
const selectedDocumentPreviewUrls = reactive({
  government_id: '',
  bir_registration: '',
  dti_registration: '',
  mayor_permit: '',
  business_permit: '',
  sanitary_permit: '',
})

const normalizedRole = computed(() => trimString(profile.role || page.props?.auth?.user?.role).toLowerCase())
const normalizedBusinessType = computed(() => trimString(profile.business_type || page.props?.auth?.user?.business_type).toLowerCase())
const normalizedWorkspaceType = computed(() => trimString(profile.workspace_type || page.props?.auth?.user?.workspace_type).toLowerCase())
const normalizedManagementMode = computed(() => trimString(profile.management_mode || page.props?.auth?.user?.management_mode).toLowerCase())
const isBusinessAccount = computed(() => normalizedRole.value === 'business' || Boolean(profile.business_type))
const isHrManagedBusiness = computed(() => (
  normalizedRole.value === 'business'
  && (
    normalizedBusinessType.value === 'company'
    || normalizedManagementMode.value === 'hr'
    || normalizedWorkspaceType.value === 'hr_managed_company'
  )
))
const useHrShell = computed(() => isHrManagedBusiness.value)

const roleLabel = computed(() => {
  if (normalizedRole.value === 'business') {
    return normalizedBusinessType.value === 'company' ? 'Company' : 'Business'
  }
  return normalizedRole.value ? normalizedRole.value.replace(/_/g, ' ').replace(/\b\w/g, (m) => m.toUpperCase()) : 'User'
})

const displayName = computed(() => {
  const first = String(profile.first_name || '').trim()
  const last = String(profile.last_name || '').trim()
  const full = `${first} ${last}`.trim()
  return full || profile.business_owner || profile.email || 'N/A'
})

const businessName = computed(() =>
  profile.business_name || profile.business_name_1 || profile.company_name || ''
)

const businessOwner = computed(() => {
  if (profile.business_owner) return profile.business_owner
  const first = String(profile.business_owner_first || profile.first_name || '').trim()
  const middle = String(profile.business_owner_middle || profile.middle_initial || '').trim()
  const last = String(profile.business_owner_last || profile.last_name || '').trim()
  return [first, middle, last].filter(Boolean).join(' ').trim()
})

const businessTypeLabel = computed(() => {
  if (!normalizedBusinessType.value) return 'N/A'
  return normalizedBusinessType.value === 'company' ? 'Company' : 'Individual'
})

const yearsInOperationLabel = computed(() => {
  const raw = String(profile.years_in_operation || '').trim()
  if (!raw) return 'N/A'
  if (/^\d+$/.test(raw)) {
    return `${raw} year${raw === '1' ? '' : 's'}`
  }
  return raw
})

const businessAddress = computed(() => {
  const segments = [
    profile.address_unit,
    profile.address_street,
    profile.address_barangay ? `Brgy. ${profile.address_barangay}` : '',
    profile.address_city,
    profile.address_province,
    profile.address_postal,
  ]
  const combined = segments.filter(Boolean).join(', ')
  return combined || profile.address || ''
})

const hasResubmittedDocuments = computed(() => {
  const reviewKind = trimString(profile.latest_account_review_kind).toLowerCase()
  const reviewTitle = trimString(profile.latest_account_review_title).toLowerCase()
  const reviewMessageText = trimString(profile.latest_account_review_message).toLowerCase()
  const reviewAt = trimString(profile.latest_account_review_at)
  const resubmittedAt = trimString(profile.document_resubmitted_at)
  const hasStoredResubmissionFile = Boolean(
    trimString(profile.government_id_resubmission || profile.government_id_resubmission_url)
  )
  const resubmittedTime = resubmittedAt ? new Date(resubmittedAt).getTime() : 0
  const reviewTime = reviewAt ? new Date(reviewAt).getTime() : 0
  const resubmittedAfterReview = Boolean(resubmittedAt) && (
    !reviewAt
    || Number.isNaN(resubmittedTime)
    || Number.isNaN(reviewTime)
    || resubmittedTime >= reviewTime
  )
  return Boolean(
    reviewKind === 'resubmitted'
    || reviewTitle.includes('resubmitted')
    || reviewMessageText.includes('resubmitted')
    || reviewMessageText.includes('updated documents were submitted')
    || resubmittedAfterReview
    || hasStoredResubmissionFile
    || hasLocalResubmission(profile, reviewAt)
  )
})

const approvalState = computed(() => {
  const status = trimString(profile.status || profile.approval_status).toLowerCase()
  if (status === 'approved' || profile.is_approved) return 'approved'
  if (status === 'rejected') return hasResubmittedDocuments.value ? 'pending' : 'rejected'
  if (['pending', 'pending_approval'].includes(status)) return 'pending'
  if (profile.is_approved === false) return 'pending'
  return profile.is_approved ? 'approved' : 'pending'
})

const statusLabel = computed(() => {
  if (approvalState.value === 'approved') return 'Approved'
  if (approvalState.value === 'rejected') return 'Rejected'
  if (approvalState.value) return 'Pending Review'
  return ''
})

const statusBadgeClass = computed(() => {
  if (approvalState.value === 'approved') return 'bg-emerald-100 text-emerald-700'
  if (approvalState.value === 'rejected') return 'bg-rose-100 text-rose-700'
  return 'bg-amber-100 text-amber-700'
})

const reviewNoteClass = computed(() => {
  if (approvalState.value === 'approved') return 'border-emerald-200 bg-emerald-50 text-emerald-700'
  if (approvalState.value === 'rejected') return 'border-rose-200 bg-rose-50 text-rose-700'
  return 'border-amber-200 bg-amber-50 text-amber-700'
})

const reviewMessage = computed(() => String(profile.latest_account_review_message || '').trim())
const rejectionChecklist = computed(() => (
  Array.isArray(profile.rejection_checklist) ? profile.rejection_checklist.filter(Boolean) : []
))
const rejectionChecklistMap = {
  invalid_government_id: {
    label: 'Government ID issue',
    description: 'Re-upload a clear Government ID image.',
    docs: ['government_id'],
  },
  business_documents_incomplete: {
    label: 'Business documents incomplete',
    description: 'Complete the missing business permits and registrations.',
    docs: ['bir_registration', 'dti_registration', 'mayor_permit', 'business_permit', 'sanitary_permit'],
  },
  business_information_mismatch: {
    label: 'Business info mismatch',
    description: 'Update business details or upload matching documents.',
    docs: ['bir_registration', 'dti_registration', 'mayor_permit', 'business_permit', 'sanitary_permit'],
  },
  location_information_missing: {
    label: 'Location details issue',
    description: 'Update your company address/location information.',
    docs: [],
  },
  duplicate_registration: {
    label: 'Possible duplicate registration',
    description: 'Please coordinate with the admin to verify the duplicate record.',
    docs: [],
  },
  other_validation_issue: {
    label: 'Other validation issue',
    description: 'Follow the admin note and update the required details.',
    docs: [],
  },
}
const rejectionChecklistDetails = computed(() => (
  rejectionChecklist.value
    .map((key) => {
      const normalized = String(key || '').trim()
      const mapped = rejectionChecklistMap[normalized]
      if (mapped) return { key: normalized, ...mapped }
      return {
        key: normalized,
        label: normalized.replace(/_/g, ' '),
        description: 'Please review the admin note and update the required information.',
        docs: [],
      }
    })
))
const requiredDocumentKeys = computed(() => {
  const keys = new Set()
  rejectionChecklistDetails.value.forEach((item) => {
    (item.docs || []).forEach((docKey) => keys.add(docKey))
  })
  return [...keys]
})
const requiredDocumentLabels = computed(() => (
  requiredDocumentKeys.value
    .map((key) => documentFields.find((field) => field.key === key)?.label)
    .filter(Boolean)
))
const resubmissionFields = computed(() => {
  if (!requiredDocumentKeys.value.length) return documentFields
  return documentFields.filter((field) => requiredDocumentKeys.value.includes(field.key))
})
const isApproved = computed(() => {
  if (loading.value) return false
  const status = trimString(profile.status || profile.approval_status).toLowerCase()
  if (['pending', 'rejected', 'archived'].includes(status)) return false
  return profile.is_approved !== false
})
const isWorkspaceLocked = computed(() => (useHrShell.value ? !isApproved.value : false))
const canResubmitDocuments = computed(() => approvalState.value === 'rejected')
const statusSummaryCopy = computed(() => {
  if (approvalState.value === 'rejected') {
    return 'Admin rejected the submission. Please re-upload the required documents.'
  }
  if (approvalState.value === 'approved') {
    return 'Approved. You can now access HR workspace modules.'
  }
  if (hasResubmittedDocuments.value) {
    return 'Documents resubmitted. Waiting for admin review.'
  }
  return 'Pending admin review. You will be notified once a decision is made.'
})

const storedDocuments = computed(() =>
  documentFields
    .map((field) => {
      const value = String(profile[field.key] || '').trim()
      const url = resolveStoredFileUrl(value, '')
      const path = stripFileQuery(value).toLowerCase()
      return {
        key: field.key,
        label: field.label,
        value,
        url,
        name: value ? stripFileQuery(value).split('/').pop() : 'No saved file',
        previewable: Boolean(url),
        isImage: path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.webp'),
      }
    })
    .filter((doc) => doc.value)
)

const selectedDocuments = computed(() =>
  documentFields
    .map((field) => {
      const file = selectedDocumentMap[field.key]
      if (!file) return null
      return {
        key: field.key,
        label: field.label,
        name: file.name,
        url: selectedDocumentPreviewUrls[field.key] || '',
        previewable: Boolean(selectedDocumentPreviewUrls[field.key]),
        isImage: String(file.type || '').startsWith('image/'),
      }
    })
    .filter(Boolean)
)

const validateDocumentFile = (file) => {
  if (!(file instanceof File)) return 'No file selected.'
  const type = String(file.type || '').toLowerCase()
  const name = String(file.name || '').toLowerCase()
  const allowed = type.startsWith('image/')
    || type === 'application/pdf'
    || ['.jpg', '.jpeg', '.png', '.webp', '.pdf'].some((ext) => name.endsWith(ext))
  if (!allowed) return 'Please select a JPG, PNG, WEBP, or PDF file.'
  if (file.size > 50 * 1024 * 1024) return 'Maximum file size is 50MB.'
  return ''
}

const clearSelectedDocument = (field) => {
  const key = String(field || '').trim()
  if (!key || !(key in selectedDocumentMap)) return
  selectedDocumentMap[key] = null
  if (selectedDocumentPreviewUrls[key]) {
    URL.revokeObjectURL(selectedDocumentPreviewUrls[key])
    selectedDocumentPreviewUrls[key] = ''
  }
}

const clearAllSelectedDocuments = () => {
  documentFields.forEach((field) => clearSelectedDocument(field.key))
}

const applyLocalResubmission = () => {
  const nowIso = new Date().toISOString()
  markProfileResubmitted(profile, nowIso)
  profile.document_resubmitted_at = nowIso
  profile.latest_account_review_kind = 'resubmitted'
  profile.latest_account_review_title = 'Documents resubmitted'
  profile.latest_account_review_message = 'Your updated documents were submitted for review.'
  profile.latest_account_review_at = nowIso
  profile.latest_account_review_seen_at = null
  profile.status = 'pending'
  profile.approval_status = 'pending'
  profile.is_approved = false
}

const handleDocumentSelection = (field, event) => {
  const file = event?.target?.files?.[0]
  if (!file) return

  const validationMessage = validateDocumentFile(file)
  if (validationMessage) {
    Swal.fire('Invalid File', validationMessage, 'warning')
    event.target.value = ''
    clearSelectedDocument(field)
    return
  }

  clearSelectedDocument(field)
  selectedDocumentMap[field] = file
  selectedDocumentPreviewUrls[field] = URL.createObjectURL(file)
}

const openStoredDocument = (url) => {
  const target = trimString(url)
  if (!target) return
  window.open(target, '_blank', 'noopener')
}

const navigateTo = (_menu, url) => {
  if (!useHrShell.value) return
  if (isWorkspaceLocked.value) {
    Swal.fire('Workspace locked', 'Your company account can log in, but HR-managed tabs stay locked until admin approval.', 'info')
    return
  }
  router.visit(url)
}

const logout = async () => {
  await confirmAndLogout()
}

const submitDocuments = async () => {
  if (!selectedDocuments.value.length || uploadingDocuments.value) return
  uploadingDocuments.value = true
  const previousDocumentValues = documentFields.reduce((accumulator, field) => {
    accumulator[field.key] = trimString(profile[field.key])
    return accumulator
  }, {})
  try {
  const formData = new FormData()
  formData.append('_method', 'PUT')
  if (approvalState.value === 'rejected') {
    formData.append('force_resubmission', '1')
  }
    documentFields.forEach((field) => {
      const file = selectedDocumentMap[field.key]
      if (file instanceof File) {
        formData.append(field.key, file)
      }
    })
    const res = await axios.post('/user/profile', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    Object.assign(profile, res.data || {})
    documentFields.forEach((field) => {
      const file = selectedDocumentMap[field.key]
      if (!(file instanceof File)) return
      const currentValue = trimString(profile[field.key])
      const previousValue = trimString(previousDocumentValues[field.key])
      if (currentValue && currentValue !== previousValue) return
      profile[field.key] = buildTemporaryFilePath('files', profile.uid || profile.id || 'local', file.name, selectedDocumentPreviewUrls[field.key])
    })
    applyLocalResubmission()
    clearAllSelectedDocuments()
    Swal.fire('Success', 'Updated documents uploaded successfully and sent back for review.', 'success')
  } catch (err) {
    const fieldErrors = err?.response?.data?.errors || {}
    const firstFieldError = Object.values(fieldErrors).flat().find(Boolean)
    Swal.fire('Error', firstFieldError || err?.response?.data?.message || 'Failed to upload documents.', 'error')
  } finally {
    uploadingDocuments.value = false
  }
}

const fetchProfile = async () => {
  loading.value = true
  errorMessage.value = ''
  try {
    const res = await axios.get('/user/profile')
    Object.assign(profile, page.props?.auth?.user || {}, res.data || {})
  } catch (err) {
    Object.assign(profile, page.props?.auth?.user || {})
    errorMessage.value = err?.response?.data?.message || 'Unable to load profile.'
  } finally {
    loading.value = false
  }
}

onMounted(fetchProfile)
</script>
