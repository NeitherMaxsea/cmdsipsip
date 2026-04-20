<template>
  <section class="space-y-5">
    <div class="rounded-2xl bg-gradient-to-r from-amber-500 to-orange-500 text-white p-6 shadow-lg">
      <p class="text-xs uppercase tracking-[0.14em] text-white/85">Procurement Queue</p>
      <h2 class="text-2xl font-bold mt-1">Requests Awaiting Material</h2>
      <p class="text-sm text-white/90 mt-1">Prepare all required materials before marking a job as ready.</p>
    </div>

    <div v-if="loading" class="text-slate-500">Loading requests...</div>

    <div v-else class="space-y-4">
      <article
        v-for="req in requests"
        :key="req.id"
        class="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm"
      >
        <div class="flex flex-wrap items-start justify-between gap-3">
          <div>
            <p class="text-xs uppercase tracking-wide text-slate-400">Customer</p>
            <h3 class="text-xl font-bold text-slate-900">{{ fullName(req) }}</h3>
          </div>
          <span class="px-3 py-1 rounded-full text-xs font-semibold" :class="statusClass(req.status)">
            {{ req.status }}
          </span>
        </div>

        <div class="mt-4 grid grid-cols-1 md:grid-cols-4 gap-3 text-sm">
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-3">
            <p class="text-[11px] uppercase tracking-wide text-slate-400">Service</p>
            <p class="font-semibold text-indigo-700 mt-1">{{ req.service_type || 'N/A' }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-3">
            <p class="text-[11px] uppercase tracking-wide text-slate-400">Business</p>
            <p class="font-semibold text-slate-800 mt-1">{{ req.business_name || 'N/A' }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-3">
            <p class="text-[11px] uppercase tracking-wide text-slate-400">Preferred Date</p>
            <p class="font-semibold text-slate-800 mt-1">{{ formatDate(req.preferred_date) }}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-3">
            <p class="text-[11px] uppercase tracking-wide text-slate-400">Address</p>
            <p class="font-semibold text-slate-800 mt-1">{{ req.address_text || 'N/A' }}</p>
          </div>
        </div>

        <div class="mt-5 border border-slate-200 rounded-xl p-4 bg-slate-50/60">
          <p class="text-xs uppercase tracking-wide text-slate-500 mb-3">Materials Needed</p>
          <div class="grid grid-cols-1 md:grid-cols-4 gap-2">
            <select
              v-model="req.tempMaterial"
              class="border border-slate-300 rounded-lg px-3 py-2 text-sm bg-white"
            >
              <option disabled value="">Select material</option>
              <option v-for="m in getMaterialsForService(req.service_type)" :key="m" :value="m">
                {{ m }}
              </option>
            </select>
            <input
              v-model.number="req.tempQty"
              type="number"
              min="1"
              class="border border-slate-300 rounded-lg px-3 py-2 text-sm bg-white"
              placeholder="Qty"
            />
            <input
              v-model="req.tempUnit"
              type="text"
              class="border border-slate-300 rounded-lg px-3 py-2 text-sm bg-white"
              placeholder="Unit (pcs, box, meter)"
            />
            <input
              v-model.trim="req.tempNotes"
              type="text"
              maxlength="255"
              class="border border-slate-300 rounded-lg px-3 py-2 text-sm bg-white"
              placeholder="Reason / notes (optional)"
            />
            <button
              type="button"
              @click="addMaterial(req)"
              class="bg-slate-900 hover:bg-slate-800 text-white rounded-lg px-3 py-2 text-sm font-semibold"
            >
              Add Material
            </button>
          </div>

          <div class="mt-3 flex flex-wrap gap-2">
            <div
              v-for="(mat, index) in req.selectedMaterials"
              :key="`${mat.name}-${index}`"
              class="inline-flex items-center gap-2 rounded-full bg-indigo-100 text-indigo-700 px-3 py-1 text-xs font-semibold"
            >
              <span>{{ mat.name }} ({{ mat.qty }} {{ mat.unit }})<span v-if="mat.notes"> - {{ mat.notes }}</span></span>
              <button type="button" @click="removeMaterial(req, index)" class="text-rose-500">x</button>
            </div>
          </div>
        </div>

        <div class="mt-4 flex justify-end">
          <button
            @click="markReady(req)"
            class="bg-emerald-500 hover:bg-emerald-600 text-white px-5 py-2 rounded-lg text-sm font-semibold shadow"
          >
            Mark Job Ready
          </button>
        </div>
      </article>

      <div v-if="!requests.length" class="rounded-2xl border border-dashed border-slate-300 bg-white p-10 text-center text-slate-500">
        No requests awaiting materials.
      </div>
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'

const requests = ref([])
const loading = ref(true)

const serviceMaterials = {
  plumbing: ['Pipe', 'Valve', 'Teflon Tape', 'Wrench', 'Faucet'],
  siphoning: ['Vacuum Pump', 'Hose', 'Bucket', 'Gloves', 'Sealant'],
  both: ['Pipe', 'Valve', 'Teflon Tape', 'Wrench', 'Vacuum Pump', 'Hose', 'Gloves'],
}

const fullName = (r) =>
  `${r.first_name ?? ''} ${r.middle_initial ? `${r.middle_initial}.` : ''} ${r.last_name ?? ''}`.replace(/\s+/g, ' ').trim()

const formatDate = (date) =>
  date ? new Date(date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' }) : 'N/A'

const statusClass = (status) => {
  const classes = {
    awaiting_material: 'bg-amber-100 text-amber-700',
    job_ready: 'bg-teal-100 text-teal-700',
    in_progress: 'bg-indigo-100 text-indigo-700',
    completed: 'bg-emerald-100 text-emerald-700',
  }
  return classes[String(status || '').toLowerCase()] || 'bg-slate-100 text-slate-700'
}

const getMaterialsForService = (type) => serviceMaterials[String(type || '').toLowerCase()] || []

const normalizeRequest = (r) => ({
  ...r,
  selectedMaterials: Array.isArray(r.materials)
    ? r.materials.map((m) => ({
        name: m.name,
        qty: Number(m.qty) > 0 ? Number(m.qty) : 1,
        unit: m.unit || 'pcs',
        notes: m.notes || null,
      }))
    : [],
  tempMaterial: '',
  tempQty: 1,
  tempUnit: 'pcs',
  tempNotes: '',
})

const fetchRequests = async () => {
  loading.value = true
  try {
    const res = await axios.get('/procurement/requests-awaiting-material')
    requests.value = (res.data || []).map(normalizeRequest)
  } catch {
    Swal.fire('Error', 'Failed to fetch requests', 'error')
  } finally {
    loading.value = false
  }
}

const addMaterial = (req) => {
  if (!req.tempMaterial) return
  const qty = Number(req.tempQty) > 0 ? Number(req.tempQty) : 1
  const unit = String(req.tempUnit || 'pcs').trim() || 'pcs'
  const notes = String(req.tempNotes || '').trim()

  const existing = req.selectedMaterials.find((m) => m.name === req.tempMaterial && m.unit === unit)
  if (existing) {
    existing.qty += qty
    if (notes) {
      existing.notes = existing.notes ? `${existing.notes}; ${notes}` : notes
    }
  } else {
    req.selectedMaterials.push({ name: req.tempMaterial, qty, unit, notes: notes || null })
  }

  req.tempMaterial = ''
  req.tempQty = 1
  req.tempNotes = ''
}

const removeMaterial = (req, index) => {
  req.selectedMaterials.splice(index, 1)
}

const markReady = async (req) => {
  if (!req.selectedMaterials.length) {
    Swal.fire('Select Materials', 'Please add at least one material', 'warning')
    return
  }

  try {
    const res = await axios.post(`/procurement/mark-job-ready/${req.id}`, {
      materials: req.selectedMaterials,
    }, { skipGlobalLoading: true })
    const payload = res?.data || {}
    Swal.fire('Success', payload.message || 'Materials updated successfully.', payload.requires_procurement ? 'info' : 'success')
    fetchRequests().catch(() => {})
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || err.response?.data?.error || 'Failed to update request', 'error')
  }
}

onMounted(fetchRequests)
</script>

