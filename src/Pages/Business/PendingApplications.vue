<template>
  <div class="p-6 space-y-4">
    <div class="rounded-2xl bg-gradient-to-r from-teal-600 via-emerald-600 to-cyan-600 p-5 text-white shadow-lg">
      <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <h2 class="text-2xl font-bold">Pending Applications</h2>
          <p class="text-sm text-white/85">Review new applicants and manage approvals.</p>
        </div>
        <button
          type="button"
          class="self-start rounded-lg bg-white/20 px-4 py-2 text-sm font-semibold hover:bg-white/30"
          @click="emit('refresh')"
        >
          Refresh
        </button>
      </div>
    </div>

    <div v-if="loading" class="bg-white rounded-2xl border border-gray-100 p-6 text-gray-500 shadow-sm">
      Loading applications...
    </div>

    <div v-else-if="applications.length === 0" class="bg-white rounded-2xl border border-gray-100 p-8 text-center text-gray-500 shadow-sm">
      No pending applications.
    </div>

    <div v-else class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <table class="min-w-full text-sm">
        <thead class="bg-gray-50 text-gray-500 uppercase text-xs border-b">
          <tr>
            <th class="px-4 py-3 text-left">Applicant</th>
            <th class="px-4 py-3 text-left">Category</th>
            <th class="px-4 py-3 text-right">Action</th>
          </tr>
        </thead>
        <tbody class="divide-y">
          <tr
            v-for="app in applications"
            :key="app.id"
            class="hover:bg-gray-50/60 transition"
          >
            <td class="px-4 py-3 font-medium text-gray-800">
              <div class="flex items-center gap-3">
                <div class="w-9 h-9 rounded-full bg-teal-50 text-teal-700 flex items-center justify-center font-semibold">
                  {{ (fullName(app) || '?').slice(0,1).toUpperCase() }}
                </div>
                <div>
                  <div class="font-semibold text-gray-800">{{ fullName(app) }}</div>
                  <div class="text-xs text-gray-400">Applicant</div>
                </div>
              </div>
            </td>
            <td class="px-4 py-3">
              <span class="px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 capitalize">
                {{ app.category }}
              </span>
            </td>
            <td class="px-4 py-3 text-right">
              <button
                @click="openView(app)"
                class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-teal-50 text-teal-700 hover:bg-teal-100 transition"
              >
                View
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- VIEW MODAL -->
    <div
      v-if="showModal && selected"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
      <div class="bg-white w-full max-w-3xl p-6 rounded-2xl shadow-lg relative">
        <button
          class="absolute top-3 right-4 text-xl text-gray-400 hover:text-gray-700"
          @click="closeModal"
        >
          &times;
        </button>

        <h3 class="text-xl font-bold mb-4 text-gray-800">
          Application Details
        </h3>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-gray-700">
          <div class="border rounded-lg p-3 bg-gray-50">
            <p class="text-xs text-gray-500 mb-1">Name</p>
            <p class="font-semibold">{{ fullName(selected) }}</p>
          </div>
          <div class="border rounded-lg p-3 bg-gray-50">
            <p class="text-xs text-gray-500 mb-1">Category</p>
            <p class="font-semibold capitalize">{{ selected?.category }}</p>
          </div>
          <div class="border rounded-lg p-3 bg-gray-50">
            <p class="text-xs text-gray-500 mb-1">Experience</p>
            <p class="font-semibold">{{ selected?.experience_years || 'N/A' }} years</p>
          </div>
          <div class="border rounded-lg p-3 bg-gray-50 sm:col-span-2">
            <p class="text-xs text-gray-500 mb-1">Description</p>
            <p class="font-semibold">{{ selected?.service_description || 'N/A' }}</p>
          </div>
          <div v-if="selected?.valid_id" class="border rounded-lg p-3 bg-gray-50 sm:col-span-2">
            <p class="text-xs text-gray-500 mb-2">Valid ID</p>
            <div class="rounded-lg border bg-white overflow-hidden">
              <div v-if="previewLoading" class="p-4 text-sm text-gray-600">Loading preview…</div>
              <img
                v-else-if="(isImage(selected.valid_id) || previewType === 'image') && !validIdPreviewError"
                :src="fileUrl(selected.valid_id)"
                class="w-full max-h-64 object-contain cursor-zoom-in"
                @error="validIdPreviewError = true; previewType = 'file'"
                @click="openZoom(fileUrl(selected.valid_id))"
              />
              <div v-else-if="(isImage(selected.valid_id) || previewType === 'image') && validIdPreviewError" class="p-4 text-sm text-gray-600">
                Image preview unavailable. Please use the button below to open the file.
              </div>
              <iframe
                v-else-if="isPdf(selected.valid_id) || previewType === 'pdf'"
                :src="fileUrl(selected.valid_id)"
                class="w-full h-64"
              ></iframe>
              <div v-else class="p-4 text-sm text-gray-600">
                <button
                  type="button"
                  class="text-left text-blue-600 hover:underline"
                  @click="openFile(selected.valid_id)"
                >
                  File: {{ fileName(selected.valid_id) }}
                </button>
              </div>
            </div>
            <button
              type="button"
              class="inline-block mt-2 text-sm font-semibold text-blue-600 hover:underline"
              @click="openFile(selected.valid_id)"
            >
              Open File
            </button>
          </div>
        </div>

        <!-- ACTIONS -->
        <div class="flex justify-end gap-3 mt-6">
          <button
            @click="handleApprove"
            class="bg-emerald-600 text-white px-4 py-2 rounded-md text-sm font-semibold hover:bg-emerald-700"
          >
            Approve
          </button>

          <button
            @click="handleReject"
            class="bg-rose-600 text-white px-4 py-2 rounded-md text-sm font-semibold hover:bg-rose-700"
          >
            Reject
          </button>
        </div>
      </div>
    </div>

    <!-- ZOOM MODAL -->
    <div
      v-if="zoomOpen"
      class="fixed inset-0 bg-black/80 flex items-center justify-center z-[60] p-4"
      @click.self="closeZoom"
    >
      <button
        class="absolute top-4 right-4 text-white text-2xl"
        @click="closeZoom"
      >
        &times;
      </button>
      <img
        :src="zoomSrc"
        class="max-h-[90vh] max-w-[90vw] object-contain rounded-lg shadow-2xl cursor-zoom-out"
        @click="closeZoom"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import Swal from '@/lib/sweetalert-toast-shim'
import axios from 'axios'
import { resolveStoredFileUrl, stripFileQuery } from '@/lib/file-url'

defineProps({
  applications: {
    type: Array,
    required: true
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['review', 'refresh'])

const showModal = ref(false)
const selected = ref({}) // default to empty object to avoid null errors
const validIdPreviewError = ref(false)
const zoomOpen = ref(false)
const zoomSrc = ref('')
const previewType = ref('file') // image | pdf | file
const previewLoading = ref(false)

const fullName = (app) => {
  if (!app) return 'N/A'
  if (app.user_name) return app.user_name
  const first = app.user?.first_name || ''
  const mi = app.user?.middle_initial ? app.user.middle_initial + '.' : ''
  const last = app.user?.last_name || ''
  return `${first} ${mi} ${last}`.replace(/\s+/g, ' ').trim() || 'N/A'
}

const fileUrl = (path) => {
  return resolveStoredFileUrl(path, 'valid_ids')
}
const fileExt = (path) => {
  if (!path) return ''
  let p = stripFileQuery(String(path)).replace(/\\/g, '/')
  const name = p.split('/').pop() || ''
  const parts = name.split('.')
  return parts.length > 1 ? parts.pop().toLowerCase() : ''
}
const isImage = (path) => ['jpg','jpeg','png','gif','webp','bmp'].includes(fileExt(path))
const isPdf = (path) => fileExt(path) === 'pdf'
const fileName = (path) => {
  const clean = stripFileQuery(String(path || '').replace(/\\/g, '/'))
  return clean.split('/').pop() || clean
}

const guessPreviewType = (path) => {
  if (isImage(path)) return 'image'
  if (isPdf(path)) return 'pdf'
  return 'file'
}

const detectPreviewType = async (path) => {
  if (!path) {
    previewType.value = 'file'
    return
  }
  previewLoading.value = true
  previewType.value = guessPreviewType(path)
  try {
    const res = await fetch(fileUrl(path), { method: 'HEAD' })
    const ct = res.headers.get('content-type') || ''
    if (ct.startsWith('image/')) previewType.value = 'image'
    else if (ct.includes('pdf')) previewType.value = 'pdf'
  } catch {
    // keep guessed type
  } finally {
    previewLoading.value = false
  }
}

/* OPEN MODAL */
const openView = (app) => {
  selected.value = { ...app }
  validIdPreviewError.value = false
  zoomOpen.value = false
  zoomSrc.value = ''
  previewType.value = guessPreviewType(app?.valid_id)
  detectPreviewType(app?.valid_id)
  showModal.value = true
}

/* CLOSE MODAL */
const closeModal = () => {
  showModal.value = false
  selected.value = {}
  validIdPreviewError.value = false
  zoomOpen.value = false
  zoomSrc.value = ''
  previewType.value = 'file'
  previewLoading.value = false
}

const openZoom = (src) => {
  if (!src) return
  zoomSrc.value = src
  zoomOpen.value = true
}
const closeZoom = () => {
  zoomOpen.value = false
  zoomSrc.value = ''
}

const openFile = (path) => {
  const url = fileUrl(path)
  if (!url) return
  if (isImage(path)) {
    openZoom(url)
    return
  }
  window.open(url, '_blank', 'noopener')
}

const handleReview = async ({ id, action, reason = null }) => {
  try {
    await axios.post(`/business/service-providers/${id}/review`, {
      action,
      reason
    })

    // 🔥 REMOVE from list immediately (NO refresh needed)
    applications.value = applications.value.filter(app => app.id !== id)

    Swal.fire({
      icon: 'success',
      title: action === 'approve'
        ? 'Application Approved'
        : 'Application Rejected'
    })

  } catch (error) {
    console.error(error)

    Swal.fire({
      icon: 'error',
      title: 'Action failed',
      text: error.response?.data?.message || 'Something went wrong'
    })
  }
}

/* APPROVE */
const handleApprove = async () => {
  const confirm = await Swal.fire({
    title: 'Approve this application?',
    text: 'The applicant will become a service provider.',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Yes, approve'
  })

  if (!confirm.isConfirmed) return

  emit('review', {
    id: selected.value.id,
    action: 'approve'
  })

  closeModal()
}

/* REJECT */
const handleReject = async () => {
  const result = await Swal.fire({
    title: 'Reject Application',
    input: 'textarea',
    inputLabel: 'Reason for rejection',
    inputPlaceholder: 'Type reason here...',
    showCancelButton: true,
    inputValidator: (value) => {
      if (!value) return 'Reason is required'
    }
  })

  if (!result.isConfirmed || !result.value) return

  emit('review', {
    id: selected.value.id,
    action: 'reject',
    reason: result.value
  })

  closeModal()
}
</script>

