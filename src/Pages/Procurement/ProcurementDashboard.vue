<template>
  <div class="h-screen bg-slate-100 flex flex-col overflow-hidden">
    <nav class="sticky top-0 z-20 flex items-center justify-between gap-3 border-b border-slate-200 bg-white px-6 py-[14px] shadow-[0_1px_2px_rgba(15,23,42,0.06)] shrink-0">
      <div>
        <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-slate-400">Procurement Office</p>
        <h1 class="text-xl font-extrabold text-slate-900">Procurement Workspace</h1>
        <p class="text-xs text-slate-500">Materials review, purchase requests, and delivery coordination</p>
      </div>
      <div class="top-actions relative flex items-center gap-3">
        <WorkspaceNotificationBell
          list-endpoint="/procurement/notifications"
          mark-read-base="/procurement/notifications"
          empty-text="No unread procurement notifications."
          :poll-interval-ms="12000"
          width-class="w-80 max-sm:w-[300px]"
        />
        <button
          @click="logout"
          class="rounded-full border border-red-200 bg-white px-3.5 py-2 text-xs font-bold text-red-600 transition-all hover:border-red-300 hover:bg-rose-50"
        >
          Logout
        </button>
      </div>
    </nav>

    <div class="flex flex-1 min-h-0 overflow-hidden max-lg:flex-col">
      <aside class="w-64 h-full shrink-0 overflow-y-auto border-r border-slate-200 bg-white px-4 py-5 shadow-[2px_0_10px_rgba(15,23,42,0.04)] max-lg:max-h-[38vh] max-lg:w-full max-lg:border-b max-lg:border-r-0">
        <div class="rounded-[14px] border border-slate-200 bg-white p-3.5">
          <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-teal-500">Procurement Office</p>
          <h2 class="mt-1.5 text-[30px] font-extrabold leading-[1.1] tracking-[-0.02em] text-slate-900">Procurement</h2>
          <p class="mt-2 text-[13px] text-slate-500">Materials, purchase requests, stock movement, and delivery coordination.</p>
        </div>

        <div class="mt-4 rounded-[14px] border border-slate-200 bg-white px-2.5 py-3">
          <p class="mx-1 mb-2 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">Navigation</p>
          <p class="mb-1 px-1 text-xs text-slate-500">Procurement enters after Operations confirms material requirements.</p>
          <p class="mb-1 px-1 text-xs text-slate-500">Submit the PR in <span class="font-semibold text-slate-700">PR & Supply Chain</span>.</p>
          <p class="mb-3 px-1 text-xs text-slate-500">Finance receives it in <span class="font-semibold text-slate-700">Finance &gt; Procurement Budget Review</span>.</p>
          <ul class="space-y-2">
          <li
            v-for="item in sidebarItems"
            :key="item.key"
            class="rounded-xl border transition text-sm font-semibold"
            :class="section === item.key ? 'border-teal-500 bg-teal-500 text-white shadow-[0_6px_16px_rgba(20,184,166,0.28)]' : 'border-transparent text-slate-700 hover:border-slate-200 hover:bg-slate-50'"
          >
            <Link
              :href="sectionPath(item.key)"
              preserve-scroll
              class="block rounded-xl px-3 py-[11px]"
            >
              {{ item.label }}
            </Link>
          </li>
          </ul>
        </div>
      </aside>

      <main class="flex-1 min-h-0 p-6 overflow-y-auto">
        <component :is="currentComponent" :embedded="true" />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { Link, usePage } from '@inertiajs/vue3'
import WorkspaceNotificationBell from '@/Components/WorkspaceNotificationBell.vue'
import { confirmAndLogout } from '@/lib/auth-flow'
import ProcureOverview from './ProcureOverview.vue'
import ProcureRequest from './ProcureRequest.vue'
import ProcureSCM from './ProcureSCM.vue'
import ProcureStock from './ProcureStock.vue'

const sidebarItems = [
  { key: 'dashboard', label: 'Inventory Overview' },
  { key: 'requests', label: 'Awaiting Materials' },
  { key: 'stocks', label: 'Purchase Orders & Deliveries' },
  { key: 'supply-chain', label: 'PR & Supply Chain' },
]
const validSections = new Set(sidebarItems.map((x) => x.key))
const page = usePage()

const sectionFromUrl = () => {
  const path = window.location.pathname.toLowerCase()
  const params = new URLSearchParams(window.location.search || '')
  const querySection = params.get('section')
  if (querySection && validSections.has(querySection)) {
    return querySection
  }
  if (path.endsWith('/procurerequest')) return 'requests'
  if (path.endsWith('/procurestock')) return 'stocks'
  if (path.endsWith('/procurescm')) return 'supply-chain'

  const propSection = page.props?.section
  const value = typeof propSection === 'string' && propSection.trim() !== '' ? propSection : 'dashboard'
  return validSections.has(value) ? value : 'dashboard'
}

const section = ref('dashboard')

const sectionPath = (key) => {
  const nextSection = validSections.has(key) ? key : 'dashboard'
  return `/Procurement/ProcurementDashboard?section=${nextSection}`
}

const currentComponent = computed(() => {
  if (section.value === 'requests') return ProcureRequest
  if (section.value === 'stocks') return ProcureStock
  if (section.value === 'supply-chain') return ProcureSCM
  return ProcureOverview
})

const logout = async () => {
  await confirmAndLogout()
}

onMounted(() => {
  section.value = sectionFromUrl()
})

watch(
  () => page.url,
  () => {
    section.value = sectionFromUrl()
  },
)
</script>


