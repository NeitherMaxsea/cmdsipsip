<template>
  <div class="flex min-h-screen bg-slate-50 font-sans">
    <HrSidebarNav :active-menu="activeMenu" @navigate="navigateTo" />

    <div class="flex flex-1 flex-col bg-slate-50">
      <HrTopbar @logout="logout" />
      <div class="hr-content space-y-4 p-6">
        <section class="relative isolate flex items-start justify-between gap-3 overflow-hidden rounded-[18px] border border-blue-100 border-t-4 border-t-[var(--hero-accent)] bg-[linear-gradient(180deg,#ffffff_0%,#f8fafc_100%)] p-5 text-slate-900 shadow-[0_8px_20px_rgba(15,23,42,0.05)]">
          <span class="pointer-events-none absolute -left-12 -top-28 z-0 h-[210px] w-[210px] rounded-full bg-[radial-gradient(circle_at_35%_35%,rgba(22,163,74,0.22),rgba(22,163,74,0))]"></span>
          <span class="pointer-events-none absolute -bottom-32 -right-24 z-0 h-[240px] w-[240px] rounded-full bg-[radial-gradient(circle_at_35%_35%,rgba(74,222,128,0.16),rgba(74,222,128,0))]"></span>
          <div>
            <p class="relative z-[1] m-0 text-[11px] font-bold uppercase tracking-[0.12em] text-[var(--hero-accent)]">HR Workspace</p>
            <h1 class="relative z-[1] mt-1.5 text-[34px] font-extrabold leading-[1.1] text-slate-900">Accepted Requests</h1>
            <p class="relative z-[1] mt-2 text-sm text-slate-600">View accepted requests that may affect staffing, payroll readiness, or procurement handoff.</p>
          </div>
          <button class="rounded-full border border-slate-900 bg-[linear-gradient(135deg,#0f172a_0%,#1e293b_100%)] px-4 py-[9px] text-xs font-bold text-white shadow-[0_8px_18px_rgba(15,23,42,0.2)] transition-all hover:-translate-y-px hover:brightness-[1.03] hover:shadow-[0_12px_22px_rgba(15,23,42,0.25)]" @click="fetchRequests">Refresh</button>
        </section>

        <section class="flex items-center gap-2.5 rounded-[14px] border border-slate-200 bg-white p-3">
          <input
            v-model.trim="search"
            type="text"
            placeholder="Search by user, business, service, or address..."
            class="flex-1 rounded-[10px] border border-slate-300 bg-white px-3 py-[9px] text-[13px] text-slate-700 placeholder:text-slate-400"
          />
          <div class="rounded-full bg-slate-200 px-2.5 py-1.5 text-xs font-bold text-slate-700">{{ filteredRequests.length }} records</div>
        </section>

        <section class="rounded-[14px] border border-slate-200 bg-white p-3">
          <div v-if="loading" class="p-2.5 text-sm text-slate-500">Loading accepted requests...</div>
          <div v-else-if="filteredRequests.length" class="overflow-x-auto">
            <table class="min-w-[850px] w-full border-collapse [&_th]:border-b [&_th]:border-slate-100 [&_th]:px-2 [&_th]:py-2.5 [&_th]:text-left [&_th]:text-[11px] [&_th]:uppercase [&_th]:tracking-[0.08em] [&_th]:text-slate-600 [&_td]:border-b [&_td]:border-slate-100 [&_td]:px-2 [&_td]:py-2.5 [&_td]:text-left [&_td]:text-[13px] [&_td]:text-slate-700 [&_tbody_tr:nth-child(even)]:bg-slate-50 [&_tbody_tr:hover]:bg-blue-50">
              <thead>
                <tr>
                  <th>User</th>
                  <th>Business</th>
                  <th>Service</th>
                  <th>Preferred Date</th>
                  <th>Address</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="req in filteredRequests" :key="req.id">
                  <td>{{ fullName(req.user) }}</td>
                  <td>{{ req.business?.business_name || 'N/A' }}</td>
                  <td>{{ req.service_type || 'N/A' }}</td>
                  <td>{{ formatDate(req.preferred_date) }}</td>
                  <td>{{ req.address_text || 'N/A' }}</td>
                  <td>
                    <span class="rounded-full bg-emerald-100 px-2 py-1 text-[11px] font-bold capitalize text-emerald-800">
                      {{ req.status }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-else class="rounded-xl border border-dashed border-slate-300 p-7 text-center">
            <p class="font-semibold text-slate-700">No accepted requests found.</p>
            <p class="text-sm text-slate-500 mt-1">Try changing your search query or refresh the data.</p>
          </div>
        </section>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { router } from '@inertiajs/vue3'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import HrSidebarNav from '@/Components/HrSidebarNav.vue'
import HrTopbar from '@/Components/HrTopbar.vue'
import { confirmAndLogout } from '@/lib/auth-flow'

const activeMenu = ref('Accepted Requests')
const loading = ref(true)
const requests = ref([])
const search = ref('')

function navigateTo(menu, url) {
  activeMenu.value = menu
  router.visit(url)
}

const logout = async () => {
  await confirmAndLogout()
}

const fetchRequests = async () => {
  loading.value = true
  try {
    const res = await axios.get('/hr/service-requests/accepted')
    requests.value = res.data
  } catch {
    Swal.fire('Error', 'Failed to load accepted requests', 'error')
  } finally {
    loading.value = false
  }
}

const fullName = (user) => {
  if (!user) return 'N/A'
  const first = user.first_name || ''
  const mi = user.middle_initial ? `${user.middle_initial}.` : ''
  const last = user.last_name || ''
  return `${first} ${mi} ${last}`.replace(/\s+/g, ' ').trim() || 'N/A'
}

const formatDate = (value) => {
  if (!value) return 'TBD'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return value
  return d.toLocaleDateString()
}

const filteredRequests = computed(() => {
  const q = search.value.toLowerCase()
  if (!q) return requests.value
  return requests.value.filter((req) => {
    const haystack = [
      fullName(req.user),
      req.business?.business_name || '',
      req.service_type || '',
      req.address_text || '',
      req.preferred_date || '',
      req.status || '',
    ].join(' ').toLowerCase()
    return haystack.includes(q)
  })
})

onMounted(fetchRequests)
</script>









