<template>
  <div class="space-y-6">
    <section class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
        <div>
          <p class="text-xs font-semibold uppercase tracking-[0.18em] text-cyan-700">System Settings</p>
          <h2 class="mt-2 text-3xl font-black text-slate-900">Shift-Based Fleet Allocation</h2>
          <p class="mt-3 max-w-3xl text-sm leading-6 text-slate-600">
            Assign truck IDs to each 8-hour shift. The booking scheduler uses these truck counts to decide how many customer slots stay open or get disabled.
          </p>
        </div>
        <div class="rounded-2xl border border-cyan-200 bg-cyan-50 px-4 py-3 text-sm text-cyan-900">
          <p class="font-semibold">Shift windows</p>
          <p class="mt-1 text-xs leading-5 text-cyan-800">Morning: 06:00-14:00, Evening: 14:00-22:00, Graveyard: 22:00-06:00</p>
        </div>
      </div>
    </section>

    <section class="grid grid-cols-1 gap-4 xl:grid-cols-3">
      <article
        v-for="shift in shifts"
        :key="shift.shift"
        class="rounded-3xl border border-slate-200 bg-white p-5 shadow-sm"
      >
        <div class="flex items-start justify-between gap-3">
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.16em] text-slate-500">{{ shift.shiftLabel }}</p>
            <h3 class="mt-1 text-xl font-extrabold text-slate-900">{{ shift.label }}</h3>
            <p class="mt-1 text-sm text-slate-600">{{ shift.start_time }} - {{ shift.end_time }}</p>
          </div>
          <span class="inline-flex rounded-full border border-slate-200 bg-slate-50 px-3 py-1 text-xs font-semibold text-slate-700">
            {{ shift.truck_ids.length }} truck{{ shift.truck_ids.length === 1 ? '' : 's' }}
          </span>
        </div>

        <div class="mt-4 rounded-2xl border border-slate-200 bg-slate-50 p-4">
          <label class="text-xs font-semibold uppercase tracking-wide text-slate-600">Truck IDs</label>
          <textarea
            v-model.trim="shift.truck_ids_text"
            rows="3"
            class="mt-2 w-full rounded-2xl border border-slate-300 bg-white px-3 py-3 text-sm text-slate-800 shadow-sm outline-none transition focus:border-sky-500 focus:ring-4 focus:ring-sky-100"
            placeholder="TRK-01, TRK-02, TRK-03"
          ></textarea>
          <p class="mt-2 text-xs leading-5 text-slate-500">
            Separate truck IDs with commas, spaces, or line breaks. The truck count becomes the available slot capacity for this shift.
          </p>
        </div>

        <div class="mt-4 grid grid-cols-2 gap-3">
          <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3">
            <p class="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500">Capacity</p>
            <p class="mt-1 text-lg font-black text-slate-900">{{ shift.truck_ids.length || DEFAULT_SHIFT_CAPACITY }}</p>
          </div>
          <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3">
            <p class="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500">Scope</p>
            <p class="mt-1 text-lg font-black text-slate-900">{{ shift.business_id ? 'Scoped' : 'Global' }}</p>
          </div>
        </div>

        <button
          type="button"
          class="mt-4 inline-flex w-full items-center justify-center rounded-2xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:bg-slate-300"
          :disabled="savingKey === shift.shift || loading"
          @click="saveShift(shift)"
        >
          {{ savingKey === shift.shift ? 'Saving...' : 'Save Shift' }}
        </button>
      </article>
    </section>

    <section class="rounded-3xl border border-amber-200 bg-amber-50 p-5 shadow-sm">
      <p class="text-xs font-semibold uppercase tracking-[0.16em] text-amber-700">Scheduler Reminder</p>
      <p class="mt-2 text-sm leading-6 text-amber-900">
        If a shift reaches its truck capacity, the matching time slots are automatically grayed out for new bookings. Emergency bookings still need geofence verification and proof upload.
      </p>
    </section>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'

const DEFAULT_SHIFT_CAPACITY = 3
const SHIFT_ORDER = ['morning', 'evening', 'graveyard']
const SHIFT_META = {
  morning: { label: 'Morning Shift', shiftLabel: 'Morning', start_time: '06:00', end_time: '14:00' },
  evening: { label: 'Evening Shift', shiftLabel: 'Evening', start_time: '14:00', end_time: '22:00' },
  graveyard: { label: 'Graveyard Shift', shiftLabel: 'Graveyard', start_time: '22:00', end_time: '06:00' },
}

const loading = ref(true)
const savingKey = ref('')
const shifts = ref([])

const parseTruckIds = (value) => Array.from(
  new Set(
    String(value || '')
      .split(/[,\n;]/)
      .map((entry) => String(entry || '').trim())
      .filter(Boolean)
  )
)

const normalizeShiftRow = (row = {}) => {
  const shift = SHIFT_ORDER.includes(String(row.shift || '').trim().toLowerCase())
    ? String(row.shift || '').trim().toLowerCase()
    : SHIFT_ORDER.find((key) => String(row.id || '').toLowerCase().includes(key)) || 'morning'
  const meta = SHIFT_META[shift]
  const truckIds = Array.isArray(row.truck_ids)
    ? row.truck_ids.map((entry) => String(entry || '').trim()).filter(Boolean)
    : parseTruckIds(row.truck_ids_text || row.trucks || '')
  return {
    id: String(row.id || shift).trim() || shift,
    shift,
    label: row.label || meta.label,
    shiftLabel: meta.shiftLabel,
    start_time: row.start_time || meta.start_time,
    end_time: row.end_time || meta.end_time,
    truck_ids: truckIds,
    truck_ids_text: truckIds.join(', '),
    business_id: String(row.business_id || '').trim(),
  }
}

const buildDefaultShifts = () => SHIFT_ORDER.map((shift) => normalizeShiftRow({ id: shift, shift }))

const hydrateShifts = (rows = []) => {
  const map = new Map(buildDefaultShifts().map((row) => [row.shift, row]))
  rows.forEach((row) => {
    const normalized = normalizeShiftRow(row)
    map.set(normalized.shift, normalized)
  })
  shifts.value = SHIFT_ORDER.map((shift) => map.get(shift)).filter(Boolean)
}

const fetchShifts = async () => {
  loading.value = true
  try {
    const res = await axios.get('/admin/fleet-shifts')
    hydrateShifts(Array.isArray(res?.data) ? res.data : [])
  } catch (error) {
    hydrateShifts([])
    Swal.fire('Error', 'Failed to load fleet shift settings.', 'error')
  } finally {
    loading.value = false
  }
}

const saveShift = async (shift) => {
  if (!shift?.shift) return
  savingKey.value = shift.shift
  try {
    const payload = {
      id: shift.id || shift.shift,
      shift: shift.shift,
      label: shift.label,
      start_time: shift.start_time,
      end_time: shift.end_time,
      truck_ids: parseTruckIds(shift.truck_ids_text),
      business_id: shift.business_id || '',
    }
    const res = await axios.post('/admin/fleet-shifts', payload)
    const saved = normalizeShiftRow(res?.data?.data || res?.data || payload)
    shifts.value = shifts.value.map((row) => (row.shift === saved.shift ? saved : row))
    Swal.fire('Saved', `${saved.label} updated successfully.`, 'success')
  } catch (error) {
    Swal.fire('Error', error?.response?.data?.message || 'Failed to save shift settings.', 'error')
  } finally {
    savingKey.value = ''
  }
}

onMounted(fetchShifts)
</script>
