<template>
  <section class="space-y-5">
    <section class="flex flex-wrap items-start justify-between gap-3 rounded-[18px] border border-slate-200 bg-white p-5 shadow-[0_8px_18px_rgba(15,23,42,0.06)]">
      <div>
        <p class="m-0 text-[11px] font-bold uppercase tracking-[0.12em] text-green-600">Service Provider Operations</p>
        <h2 class="mt-1.5 text-[30px] font-extrabold leading-[1.1] text-slate-900">Service Attendance</h2>
        <p class="mt-2 text-sm text-slate-600">Clock in/out daily and monitor your attendance summary.</p>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <input v-model="selectedMonth" type="month" class="rounded-[10px] border border-slate-300 bg-white px-2.5 py-2 text-[13px] text-slate-700" @change="fetchAttendance" />
        <button
          class="rounded-full border border-slate-900 bg-[linear-gradient(135deg,#0f172a_0%,#1e293b_100%)] px-3.5 py-2 text-xs font-bold text-white disabled:cursor-not-allowed disabled:opacity-50"
          :disabled="!canClockIn"
          @click="clockIn"
        >
          {{ clockInButtonLabel }}
        </button>
        <button
          class="rounded-full border border-slate-300 bg-white px-3.5 py-2 text-xs font-bold text-slate-700 disabled:cursor-not-allowed disabled:opacity-50"
          :disabled="!canClockOut"
          @click="clockOut"
        >
          {{ clockOutButtonLabel }}
        </button>
      </div>
      <div class="mt-3 w-full rounded-xl border border-slate-200 bg-slate-50 p-3">
        <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-slate-500">Attendance Proof Image</p>
        <div class="mt-2 flex flex-wrap items-center gap-2">
          <input
            ref="proofInputRef"
            type="file"
            accept="image/*"
            capture="environment"
            class="rounded-lg border border-slate-300 bg-white px-2 py-1.5 text-xs text-slate-700"
            @change="onProofFileChange"
          />
          <button
            type="button"
            class="rounded-lg border border-slate-300 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 disabled:opacity-50"
            :disabled="!proofFile || proofUploading"
            @click="clearProofSelection"
          >
            Clear
          </button>
          <span class="text-xs text-slate-500">Proof image is required before clock in/out and QR scan.</span>
          <span v-if="proofUploading" class="text-xs font-semibold text-sky-700">Uploading...</span>
          <span v-else-if="proofReady" class="text-xs font-semibold text-emerald-700">Proof ready for next clock action.</span>
        </div>
        <div v-if="proofPreviewUrl" class="mt-2">
          <img :src="proofPreviewUrl" alt="Attendance proof preview" class="h-20 w-20 rounded-md border border-slate-200 object-cover" />
        </div>
      </div>
    </section>

    <section class="rounded-[18px] border border-slate-200 bg-white p-4 shadow-[0_8px_18px_rgba(15,23,42,0.06)]">
      <div class="flex flex-wrap items-start justify-between gap-3">
        <div>
          <p class="m-0 text-[11px] font-bold uppercase tracking-[0.12em] text-slate-500">Attendance QR</p>
          <h3 class="mt-1 text-lg font-bold text-slate-900">Scan To {{ qrActionLabel }}</h3>
          <p class="mt-1 text-sm text-slate-600">QR updates automatically after a successful scan. Valid for 3 minutes per code.</p>
        </div>
        <button
          type="button"
          class="rounded-full border border-slate-300 bg-white px-3.5 py-2 text-xs font-bold text-slate-700 disabled:cursor-not-allowed disabled:opacity-50"
          :disabled="qrLoading"
          @click="requestQrSession(false)"
        >
          {{ qrLoading ? 'Preparing...' : 'Regenerate QR' }}
        </button>
      </div>

      <div v-if="qrLockedMessage" class="mt-3 rounded-xl border border-amber-200 bg-amber-50 px-3.5 py-3 text-sm text-amber-800">
        {{ qrLockedMessage }}
      </div>

      <div v-else-if="qrScanUrl" class="mt-4 grid gap-4 md:grid-cols-[220px_1fr]">
        <div class="rounded-xl border border-slate-200 bg-slate-50 p-3">
          <img :src="qrImageUrl" alt="Attendance QR code" class="h-[200px] w-[200px] rounded-md border border-slate-200 bg-white p-2" />
        </div>
        <div class="space-y-2 rounded-xl border border-slate-200 bg-slate-50 p-3.5">
          <p class="text-sm font-semibold text-slate-800">Next Action: <span class="text-slate-900">{{ qrActionLabel }}</span></p>
          <p class="text-sm text-slate-700">Expires In: <span class="font-semibold text-slate-900">{{ qrExpiresInLabel }}</span></p>
          <p v-if="activeShiftInfoLabel" class="text-xs text-slate-600">{{ activeShiftInfoLabel }}</p>
          <a :href="qrScanUrl" target="_blank" rel="noopener" class="inline-flex rounded-lg border border-slate-300 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 hover:bg-slate-100">
            Open Scan Link
          </a>
          <p class="text-[11px] text-slate-500">Use your logged-in account to scan this QR and confirm attendance.</p>
          <p v-if="qrError" class="text-xs text-rose-600">{{ qrError }}</p>
        </div>
      </div>

      <div v-else class="mt-3 rounded-xl border border-slate-200 bg-slate-50 px-3.5 py-3 text-sm text-slate-600">
        {{ qrError || 'Generating secure QR session...' }}
      </div>
    </section>

    <section class="grid grid-cols-1 gap-3 md:grid-cols-4">
      <div class="rounded-[14px] border border-slate-200 bg-white p-3.5 shadow-[0_8px_18px_rgba(15,23,42,0.05)]">
        <p class="m-0 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-500">Present Days</p>
        <p class="mt-1.5 text-[24px] font-extrabold leading-[1.2] text-slate-900">{{ summary.present_days }}</p>
      </div>
      <div class="rounded-[14px] border border-slate-200 bg-white p-3.5 shadow-[0_8px_18px_rgba(15,23,42,0.05)]">
        <p class="m-0 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-500">Late Days</p>
        <p class="mt-1.5 text-[24px] font-extrabold leading-[1.2] text-slate-900">{{ summary.late_days }}</p>
      </div>
      <div class="rounded-[14px] border border-slate-200 bg-white p-3.5 shadow-[0_8px_18px_rgba(15,23,42,0.05)]">
        <p class="m-0 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-500">Absent Days</p>
        <p class="mt-1.5 text-[24px] font-extrabold leading-[1.2] text-slate-900">{{ summary.absent_days }}</p>
      </div>
      <div class="rounded-[14px] border border-slate-200 bg-white p-3.5 shadow-[0_8px_18px_rgba(15,23,42,0.05)]">
        <p class="m-0 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-500">Worked Hours</p>
        <p class="mt-1.5 text-[24px] font-extrabold leading-[1.2] text-slate-900">{{ summary.worked_hours }}</p>
      </div>
    </section>

    <section class="rounded-[18px] border border-slate-200 bg-white p-3.5 shadow-[0_8px_18px_rgba(15,23,42,0.06)]">
      <div class="mb-2.5 flex items-center justify-between">
        <h3>Attendance Log</h3>
        <button class="rounded-full border border-slate-300 bg-white px-3.5 py-2 text-xs font-bold text-slate-600 disabled:cursor-not-allowed disabled:opacity-50" :disabled="loading" @click="fetchAttendance">Refresh</button>
      </div>

      <div v-if="loading" class="p-2 text-sm text-slate-500">Loading attendance...</div>
      <div v-else-if="records.length" class="overflow-x-auto">
        <table class="w-full min-w-[760px] text-sm [&_th]:border-b [&_th]:border-slate-200 [&_th]:px-3 [&_th]:py-2.5 [&_th]:text-left [&_th]:text-[11px] [&_th]:uppercase [&_th]:tracking-wide [&_th]:text-slate-500 [&_td]:border-b [&_td]:border-slate-100 [&_td]:px-3 [&_td]:py-2.5 [&_td]:text-slate-700">
          <thead>
            <tr>
              <th>Date</th>
              <th>Clock In</th>
              <th>Clock Out</th>
              <th>Status</th>
              <th>Proof</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in records" :key="row.id">
              <td>{{ formatDate(row.attendance_date) }}</td>
              <td>{{ row.clock_in_at || '-' }}</td>
              <td>{{ row.clock_out_at || '-' }}</td>
              <td>
                <span class="rounded-full px-2 py-1 text-[11px] font-bold uppercase tracking-wide" :class="statusClass(row.status)">{{ row.status }}</span>
              </td>
              <td>
                <button
                  v-if="resolveProofUrl(row)"
                  type="button"
                  class="inline-flex rounded-md border border-slate-300 bg-white px-2 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-100"
                  @click="openProofModal(row)"
                >
                  View
                </button>
                <span v-else>-</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-else class="p-2 text-sm text-slate-500">No attendance logs for this month yet.</div>
    </section>

    <div
      v-if="proofModalOpen"
      class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/70 p-4"
      @click.self="closeProofModal"
    >
      <div class="w-full max-w-3xl rounded-2xl bg-white p-4 shadow-2xl">
        <div class="mb-3 flex items-center justify-between">
          <p class="text-sm font-semibold text-slate-800">Attendance Proof {{ proofModalDateLabel ? `(${proofModalDateLabel})` : '' }}</p>
          <button
            type="button"
            class="rounded-md border border-slate-300 bg-white px-2.5 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-100"
            @click="closeProofModal"
          >
            Close
          </button>
        </div>
        <div class="max-h-[70vh] overflow-auto rounded-lg border border-slate-200 bg-slate-50 p-2">
          <img
            v-if="proofModalUrl"
            :src="proofModalUrl"
            alt="Attendance proof image"
            class="mx-auto max-h-[65vh] w-auto max-w-full rounded-md object-contain"
          />
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'

const loading = ref(false)
const submitting = ref(false)
const records = ref([])
const todayRecord = ref(null)
const activeShift = ref(null)
const summary = ref({
  present_days: 0,
  late_days: 0,
  absent_days: 0,
  worked_hours: 0,
})
const selectedMonth = ref(new Date().toISOString().slice(0, 7))

const qrLoading = ref(false)
const qrError = ref('')
const qrLockedMessage = ref('')
const qrSessionId = ref('')
const qrScanUrl = ref('')
const qrAction = ref('clock_in')
const qrExpiresAt = ref('')
const qrExpiresInSeconds = ref(0)
const qrStatusLoading = ref(false)
const proofInputRef = ref(null)
const proofFile = ref(null)
const proofPreviewUrl = ref('')
const proofUploading = ref(false)
const proofReady = ref(false)
const hasPendingProof = ref(false)
const proofModalOpen = ref(false)
const proofModalUrl = ref('')
const proofModalDateLabel = ref('')

let qrPollInterval = null
let qrCountdownInterval = null
let lastQrConsumedSignature = ''

const hasActiveShift = computed(() =>
  Boolean(activeShift.value?.clock_in_at && !activeShift.value?.clock_out_at)
)
const hasClockedInToday = computed(() => Boolean(todayRecord.value?.clock_in_at))
const hasProofForClockIn = computed(() => proofReady.value || hasPendingProof.value || Boolean(todayRecord.value?.proof_image_path))
const hasProofForClockOut = computed(() => hasProofForClockIn.value || Boolean(activeShift.value?.proof_image_path))
const canClockIn = computed(() =>
  !submitting.value && !proofUploading.value && !hasActiveShift.value && !hasClockedInToday.value && hasProofForClockIn.value
)
const canClockOut = computed(() =>
  !submitting.value && !proofUploading.value && hasActiveShift.value && hasProofForClockOut.value
)

const clockInButtonLabel = computed(() => {
  if (hasActiveShift.value) return 'Shift Active'
  return hasClockedInToday.value ? 'Clocked In' : 'Clock In'
})
const clockOutButtonLabel = computed(() => {
  if (hasActiveShift.value) return 'Clock Out'
  return todayRecord.value?.clock_out_at ? 'Clocked Out' : 'Clock Out'
})

const qrActionLabel = computed(() => {
  if (qrAction.value === 'clock_out') return 'Clock Out'
  if (qrAction.value === 'clock_in') return 'Clock In'
  return 'No Action'
})
const qrImageUrl = computed(() => {
  if (!qrScanUrl.value) return ''
  return `https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent(qrScanUrl.value)}`
})
const qrExpiresInLabel = computed(() => {
  if (!qrSessionId.value) return '--:--'
  const seconds = Math.max(0, Number(qrExpiresInSeconds.value || 0))
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
})
const activeShiftInfoLabel = computed(() => {
  if (!hasActiveShift.value) return ''
  const date = formatDate(activeShift.value?.attendance_date)
  const time = activeShift.value?.clock_in_at || '-'
  return `Active shift started on ${date} at ${time}.`
})

const statusClass = (status) => {
  const normalized = String(status || '').toLowerCase()
  if (normalized === 'late') return 'bg-amber-100 text-amber-700'
  if (normalized === 'absent') return 'bg-rose-100 text-rose-700'
  return 'bg-emerald-100 text-emerald-700'
}

const formatDate = (value) => {
  if (!value) return '-'
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return value
  return parsed.toLocaleDateString()
}

const openProofModal = (row) => {
  proofModalUrl.value = resolveProofUrl(row)
  proofModalDateLabel.value = formatDate(row?.attendance_date)
  proofModalOpen.value = proofModalUrl.value !== ''
}

const closeProofModal = () => {
  proofModalOpen.value = false
  proofModalUrl.value = ''
  proofModalDateLabel.value = ''
}

const resolveProofUrl = (row) => String(row?.proof_image_view_url || row?.proof_image_url || '')

const clearProofSelection = () => {
  if (proofPreviewUrl.value) {
    URL.revokeObjectURL(proofPreviewUrl.value)
  }
  proofPreviewUrl.value = ''
  proofFile.value = null
  proofReady.value = false
  proofUploading.value = false
  if (proofInputRef.value) {
    proofInputRef.value.value = ''
  }
}

const uploadPendingProof = async (file) => {
  proofUploading.value = true
  proofReady.value = false
  try {
    const form = new FormData()
    form.append('proof_image', file)
    await axios.post('/service-provider/attendance/proof', form)
    proofReady.value = true
    hasPendingProof.value = true
  } catch (error) {
    proofReady.value = false
    throw error
  } finally {
    proofUploading.value = false
  }
}

const onProofFileChange = async (event) => {
  const file = event?.target?.files?.[0] || null
  if (!file) {
    clearProofSelection()
    return
  }

  if (!String(file.type || '').startsWith('image/')) {
    clearProofSelection()
    Swal.fire('Invalid file', 'Please select an image file for attendance proof.', 'warning')
    return
  }

  if (proofPreviewUrl.value) {
    URL.revokeObjectURL(proofPreviewUrl.value)
  }
  proofFile.value = file
  proofPreviewUrl.value = URL.createObjectURL(file)
  try {
    await uploadPendingProof(file)
  } catch (error) {
    Swal.fire('Error', error?.response?.data?.message || 'Failed to upload attendance proof.', 'error')
  }
}

const stopQrPolling = () => {
  if (qrPollInterval) {
    clearInterval(qrPollInterval)
    qrPollInterval = null
  }
}

const stopQrCountdown = () => {
  if (qrCountdownInterval) {
    clearInterval(qrCountdownInterval)
    qrCountdownInterval = null
  }
}

const refreshQrCountdown = () => {
  const raw = String(qrExpiresAt.value || '').trim()
  if (!raw) {
    qrExpiresInSeconds.value = 0
    return
  }

  const expiresAtMs = new Date(raw).getTime()
  if (Number.isNaN(expiresAtMs)) {
    qrExpiresInSeconds.value = 0
    return
  }

  const nextSeconds = Math.floor((expiresAtMs - Date.now()) / 1000)
  qrExpiresInSeconds.value = Math.max(0, nextSeconds)
}

const fetchAttendance = async (silent = false) => {
  loading.value = true
  try {
    const res = await axios.get('/service-provider/attendance-data', {
      params: { month: selectedMonth.value },
    })
    records.value = res.data.records || []
    todayRecord.value = res.data.today || null
    activeShift.value = res.data.active_shift || null
    summary.value = res.data.summary || summary.value
    hasPendingProof.value = Boolean(res.data.has_pending_proof)
    if (hasPendingProof.value) {
      proofReady.value = true
    }
  } catch (error) {
    if (!silent) {
      Swal.fire('Error', error.response?.data?.message || 'Failed to load attendance data.', 'error')
    }
  } finally {
    loading.value = false
  }
}

const requestQrSession = async (showErrorModal = true) => {
  qrLoading.value = true
  qrError.value = ''
  qrLockedMessage.value = ''
  stopQrPolling()
  stopQrCountdown()
  try {
    const res = await axios.get('/service-provider/attendance/qr-session')
    const payload = res.data || {}

    qrSessionId.value = String(payload.session_id || '')
    qrScanUrl.value = String(payload.scan_url || '')
    qrAction.value = String(payload.action || 'none')
    qrExpiresAt.value = String(payload.expires_at || '')

    if (payload.status === 'locked' || qrAction.value === 'none' || !qrSessionId.value || !qrScanUrl.value) {
      qrLockedMessage.value = String(payload.message || 'Attendance for today is already completed.')
      qrSessionId.value = ''
      qrScanUrl.value = ''
      qrExpiresAt.value = ''
      qrExpiresInSeconds.value = 0
      return
    }

    refreshQrCountdown()
    qrCountdownInterval = setInterval(refreshQrCountdown, 1000)
    qrPollInterval = setInterval(checkQrSessionStatus, 3000)
  } catch (error) {
    qrError.value = error.response?.data?.message || 'Failed to generate attendance QR.'
    if (error?.response?.status === 422) {
      qrLockedMessage.value = qrError.value
      qrSessionId.value = ''
      qrScanUrl.value = ''
      qrExpiresAt.value = ''
      qrExpiresInSeconds.value = 0
    }
    if (showErrorModal) {
      Swal.fire('Error', qrError.value, 'error')
    }
  } finally {
    qrLoading.value = false
  }
}

const checkQrSessionStatus = async () => {
  if (!qrSessionId.value || qrStatusLoading.value) return
  qrStatusLoading.value = true
  try {
    const res = await axios.get('/service-provider/attendance/qr-session/status', {
      params: { session_id: qrSessionId.value },
    })
    const payload = res.data || {}
    const status = String(payload.status || '').toLowerCase()

    if (status === 'consumed') {
      const signature = `${payload.consumed_at || ''}:${payload.record?.id || ''}`
      if (signature !== '' && signature !== lastQrConsumedSignature) {
        lastQrConsumedSignature = signature
        await fetchAttendance(true)
        Swal.fire('Success', payload.message || 'Attendance scan accepted.', 'success')
      }
      await requestQrSession(false)
      return
    }

    if (status === 'failed') {
      await fetchAttendance(true)
      await requestQrSession(false)
      return
    }

    if (status === 'expired') {
      await requestQrSession(false)
      return
    }
  } catch {
    // Keep polling resilient to intermittent network issues.
  } finally {
    qrStatusLoading.value = false
  }
}

const clockIn = async () => {
  submitting.value = true
  try {
    const res = await axios.post('/service-provider/attendance/clock-in')
    Swal.fire('Success', res.data?.message || 'Clock in recorded.', 'success')
    clearProofSelection()
    await fetchAttendance(true)
    await requestQrSession(false)
  } catch (error) {
    Swal.fire('Error', error.response?.data?.message || 'Clock in failed.', 'error')
  } finally {
    submitting.value = false
  }
}

const clockOut = async () => {
  submitting.value = true
  try {
    const res = await axios.post('/service-provider/attendance/clock-out')
    Swal.fire('Success', res.data?.message || 'Clock out recorded.', 'success')
    clearProofSelection()
    await fetchAttendance(true)
    await requestQrSession(false)
  } catch (error) {
    Swal.fire('Error', error.response?.data?.message || 'Clock out failed.', 'error')
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  await fetchAttendance()
  await requestQrSession(false)
})

onBeforeUnmount(() => {
  stopQrPolling()
  stopQrCountdown()
  closeProofModal()
  clearProofSelection()
})
</script>




