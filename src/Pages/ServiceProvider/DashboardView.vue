<template>
  <section class="space-y-6">
    <div class="grid grid-cols-1 gap-6">
      <div class="bg-gradient-to-r from-sky-500 to-blue-600 text-white rounded-2xl p-6 shadow-lg">
        <h2 class="text-2xl font-bold mb-2">Welcome, {{ user?.first_name || 'Provider' }}!</h2>
        <p class="text-sm text-sky-100">Here are your registered business details.</p>
        <div class="mt-4 bg-white/15 rounded-xl p-4">
          <p class="text-white/90">
            Status:
            <span class="font-semibold">
              {{ provider?.is_available ? 'Available' : 'Busy' }}
            </span>
          </p>
        </div>
      </div>

      <div class="grid grid-cols-1 gap-4 md:grid-cols-3">
        <article class="rounded-2xl border border-emerald-100 bg-emerald-50 p-4">
          <p class="text-[11px] font-semibold uppercase tracking-[0.08em] text-emerald-700">Business Revenue (40%)</p>
          <p class="mt-2 text-xl font-bold text-emerald-900">{{ money(revenueSummary?.business_total || 0) }}</p>
          <p class="mt-1 text-xs text-emerald-700">Total share accumulated</p>
        </article>
        <article class="rounded-2xl border border-cyan-100 bg-cyan-50 p-4">
          <p class="text-[11px] font-semibold uppercase tracking-[0.08em] text-cyan-700">Employee Pool (60%)</p>
          <p class="mt-2 text-xl font-bold text-cyan-900">{{ money(revenueSummary?.employee_pool_total || 0) }}</p>
          <p class="mt-1 text-xs text-cyan-700">Distributed to assigned workers</p>
        </article>
        <article class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
          <p class="text-[11px] font-semibold uppercase tracking-[0.08em] text-slate-600">Processed Jobs</p>
          <p class="mt-2 text-xl font-bold text-slate-900">{{ Number(revenueSummary?.request_count || 0) }}</p>
          <p class="mt-1 text-xs text-slate-600">Jobs with recorded split</p>
        </article>
      </div>
    </div>

    <div class="bg-white rounded-2xl shadow-md p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold text-gray-800">Registered Businesses</h3>
        <span class="text-xs text-gray-400">Your affiliation</span>
      </div>
    <BrowseBusinesses
        :showHeader="false"
        :businesses="businesses"
        :authUser="effectiveUser"
        :enableRequest="true"
        :fetchBusinesses="false"
        :requestLocked="requestLocked"
        :lockMessage="lockMessage"
        :pendingRequest="pendingRequest"
        @request-submitted="emitRequestSubmitted"
        @request-cancelled="emitRequestCancelled"
      />
    </div>
  </section>
</template>

<script setup>
import { defineProps, defineEmits, computed } from 'vue'
import BrowseBusinesses from '../User/BrowseBusinesses.vue'

const props = defineProps({
  businesses: { type: Array, default: () => [] },
  user: { type: Object, default: null },
  provider: { type: Object, default: null },
  revenueSummary: { type: Object, default: null },
  requestLocked: { type: Boolean, default: false },
  lockMessage: { type: String, default: '' },
  pendingRequest: { type: Object, default: null },
})
const emit = defineEmits(['request-submitted', 'request-cancelled'])

const emitRequestSubmitted = (payload) => emit('request-submitted', payload)
const emitRequestCancelled = (payload) => emit('request-cancelled', payload)

const effectiveUser = computed(() => {
  if (props.provider?.latitude && props.provider?.longitude) {
    return { ...(props.user || {}), latitude: props.provider.latitude, longitude: props.provider.longitude }
  }
  return props.user
})

const money = (value) => new Intl.NumberFormat('en-PH', {
  style: 'currency',
  currency: 'PHP',
}).format(Number(value || 0))

</script>
