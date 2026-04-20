<template>
  <div class="h-screen flex flex-col bg-gray-100 text-gray-900 font-sans overflow-hidden">
    <nav class="sticky top-0 z-20 flex items-center justify-between gap-3 border-b border-slate-200 bg-white px-6 py-[14px] shadow-[0_1px_2px_rgba(15,23,42,0.06)] max-sm:px-3.5">
      <div class="flex items-center gap-3">
        <div>
          <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-slate-400">Finance Workspace</p>
          <h1 class="text-xl font-extrabold text-slate-900 max-sm:text-lg">{{ title }}</h1>
          <p class="text-xs text-slate-500">{{ subtitle || 'Budget review, payment verification, and finance reporting' }}</p>
        </div>
      </div>
      <div class="top-actions relative flex items-center gap-2.5">
        <div @click="showProfileMenu = false">
          <WorkspaceNotificationBell
            list-endpoint="/finance/notifications"
            mark-read-base="/finance/notifications"
            empty-text="No unread finance notifications."
            :poll-interval-ms="12000"
            width-class="w-80 max-sm:w-[300px]"
          />
        </div>

        <div class="relative">
          <button
            type="button"
            class="inline-flex h-10 min-w-10 items-center gap-2 rounded-full border border-slate-200 bg-white px-3 text-slate-700 transition hover:bg-slate-50"
            @click="toggleProfileMenu"
            aria-label="Profile menu"
          >
            <span class="inline-flex h-7 w-7 items-center justify-center rounded-full bg-teal-600 text-xs font-bold text-white">F</span>
            <span class="text-xs font-semibold">Profile</span>
          </button>
          <div v-if="showProfileMenu" class="absolute right-0 mt-2 w-40 overflow-hidden rounded-xl border border-slate-200 bg-white py-1 shadow-xl">
            <Link :href="profilePath" class="block w-full px-4 py-2 text-left text-sm text-slate-700 transition hover:bg-slate-50" @click="closeMenus">Profile</Link>
            <button type="button" class="block w-full px-4 py-2 text-left text-sm text-rose-600 transition hover:bg-rose-50" @click="logout">Logout</button>
          </div>
        </div>
      </div>
    </nav>

    <div class="flex min-h-0 flex-1 overflow-hidden max-lg:flex-col">
      <aside ref="sidebarScrollEl" class="w-64 shrink-0 overflow-y-auto border-r border-gray-200 bg-white px-4 py-5 shadow-[2px_0_10px_rgba(15,23,42,0.04)] max-lg:max-h-[38vh] max-lg:w-full max-lg:border-b max-lg:border-r-0 max-sm:px-2.5 max-sm:py-3">
        <div class="mb-5">
          <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-slate-400">Navigation</p>
          <p class="mt-1 text-xs text-slate-500">Finance verifies payments, procurement budget requests, and release records</p>
        </div>

        <section v-for="section in groupedMenu" :key="section.title" class="mb-4 rounded-[14px] border border-slate-200 bg-white px-2.5 py-3">
          <p class="mb-2 px-2 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400">{{ section.title }}</p>
          <ul class="space-y-1">
            <li v-for="item in section.items" :key="item.path">
              <button
                v-if="hasChildren(item)"
                type="button"
                class="group flex w-full items-start gap-2 rounded-lg border border-transparent px-2.5 py-2 text-left text-slate-600 transition hover:border-cyan-200 hover:bg-cyan-50 hover:text-teal-700 [&.active]:border-cyan-200 [&.active]:bg-cyan-50 [&.active]:text-teal-700"
                :class="{ active: isMenuActive(item) }"
                :title="item.hint"
                @click="toggleMenu(item.path)"
              >
                <span class="w-6 text-center text-sm">{{ item.icon }}</span>
                <span class="inline-flex min-w-0 flex-col">
                  <span class="text-sm font-bold">{{ item.label }}</span>
                  <span class="mt-0.5 text-[11px] leading-tight text-slate-500">{{ item.hint }}</span>
                </span>
              </button>
              <Link
                v-else
                :href="item.path"
                class="group flex w-full items-start gap-2 rounded-lg border border-transparent px-2.5 py-2 text-left text-slate-600 transition hover:border-cyan-200 hover:bg-cyan-50 hover:text-teal-700 [&.active]:border-cyan-200 [&.active]:bg-cyan-50 [&.active]:text-teal-700"
                :class="{ active: activePath === item.path }"
                :title="item.hint"
                preserve-scroll
                prefetch
                @click="saveSidebarScroll"
              >
                <span class="w-6 text-center text-sm">{{ item.icon }}</span>
                <span class="inline-flex min-w-0 flex-col">
                  <span class="text-sm font-bold">{{ item.label }}</span>
                  <span class="mt-0.5 text-[11px] leading-tight text-slate-500">{{ item.hint }}</span>
                </span>
              </Link>

              <ul
                v-if="hasChildren(item) && isMenuOpen(item.path)"
                class="mt-1 space-y-1 pl-6"
              >
                <li v-for="child in item.children" :key="child.path">
                  <Link
                    :href="child.path"
                    class="group flex items-start gap-2 rounded-lg border border-transparent px-2.5 py-2 text-slate-600 transition hover:border-cyan-200 hover:bg-cyan-50 hover:text-teal-700 [&.active]:border-cyan-200 [&.active]:bg-cyan-50 [&.active]:text-teal-700"
                    :class="{ active: activePath === child.path }"
                    :title="child.hint"
                    preserve-scroll
                    prefetch
                    @click="saveSidebarScroll"
                  >
                    <span class="w-6 text-center text-sm">{{ child.icon }}</span>
                    <span class="inline-flex min-w-0 flex-col">
                      <span class="text-sm font-bold">{{ child.label }}</span>
                      <span class="mt-0.5 text-[11px] leading-tight text-slate-500">{{ child.hint }}</span>
                    </span>
                  </Link>
                </li>
              </ul>
            </li>
          </ul>
        </section>
      </aside>

      <main class="flex-1 overflow-y-auto p-5 max-lg:p-4 max-sm:p-3">
        <section class="grid gap-3.5 [&_.tools]:flex [&_.tools]:flex-wrap [&_.tools]:items-center [&_.tools]:gap-2.5 [&_input]:h-[42px] [&_input]:rounded-xl [&_input]:border [&_input]:border-slate-300 [&_input]:bg-slate-50 [&_input]:px-3 [&_input]:text-slate-900 [&_select]:h-[42px] [&_select]:rounded-xl [&_select]:border [&_select]:border-slate-300 [&_select]:bg-slate-50 [&_select]:px-3 [&_label]:inline-flex [&_label]:items-center [&_label]:gap-2 [&_label]:font-semibold [&_label]:text-slate-700 [&_.stats-grid]:grid [&_.stats-grid]:gap-3.5 [&_.stats-grid]:[grid-template-columns:repeat(auto-fit,minmax(220px,1fr))] [&_.stat-card]:rounded-2xl [&_.stat-card]:border [&_.stat-card]:border-slate-200 [&_.stat-card]:bg-white [&_.stat-card]:p-4 [&_.stat-card]:shadow-lg [&_.stat-card]:shadow-slate-900/5 [&_.panel]:rounded-2xl [&_.panel]:border [&_.panel]:border-slate-200 [&_.panel]:bg-white [&_.panel]:p-4 [&_.panel]:shadow-lg [&_.panel]:shadow-slate-900/5 [&_.panel_h3]:m-0 [&_.panel_h3]:text-lg [&_.panel_h3]:font-bold [&_.panel_h3]:text-slate-900 [&_.stat-card_h3]:m-0 [&_.stat-card_h3]:text-lg [&_.stat-card_h3]:font-bold [&_.stat-card_h3]:text-slate-900 [&_.stat-card_p]:mb-2 [&_.stat-card_p]:text-xs [&_.stat-card_p]:font-bold [&_.stat-card_p]:uppercase [&_.stat-card_p]:tracking-wider [&_.stat-card_p]:text-slate-500 [&_.label]:mb-2 [&_.label]:text-xs [&_.label]:font-bold [&_.label]:uppercase [&_.label]:tracking-wider [&_.label]:text-slate-500 [&_table]:mt-2.5 [&_table]:w-full [&_table]:border-collapse [&_table]:overflow-hidden [&_table]:rounded-xl [&_table]:bg-white [&_th]:border-b [&_th]:border-slate-200 [&_th]:px-2.5 [&_th]:py-3 [&_th]:text-left [&_th]:text-xs [&_th]:font-bold [&_th]:uppercase [&_th]:tracking-wider [&_th]:text-slate-600 [&_td]:border-b [&_td]:border-slate-100 [&_td]:px-2.5 [&_td]:py-3 [&_td]:text-left [&_td]:text-sm [&_td]:font-medium [&_td]:text-slate-900 [&_.badge]:inline-flex [&_.badge]:items-center [&_.badge]:rounded-full [&_.badge]:px-3 [&_.badge]:py-1 [&_.badge]:text-xs [&_.badge]:font-bold [&_.badge]:uppercase [&_.badge]:tracking-wide [&_.badge.paid]:bg-emerald-100 [&_.badge.paid]:text-emerald-800 [&_.badge.posted]:bg-emerald-100 [&_.badge.posted]:text-emerald-800 [&_.badge.released]:bg-emerald-100 [&_.badge.released]:text-emerald-800 [&_.badge.ok]:bg-emerald-100 [&_.badge.ok]:text-emerald-800 [&_.badge.pending]:bg-amber-100 [&_.badge.pending]:text-amber-800 [&_.badge.review]:bg-amber-100 [&_.badge.review]:text-amber-800 [&_.badge.overdue]:bg-rose-100 [&_.badge.overdue]:text-rose-800 [&_.badge.failed]:bg-rose-100 [&_.badge.failed]:text-rose-800 [&_button]:cursor-pointer [&_button]:rounded-lg [&_button]:border [&_button]:border-transparent [&_button]:px-3 [&_button]:py-2 [&_button]:font-bold [&_.ok]:bg-emerald-600 [&_.ok]:text-white [&_.reject]:bg-rose-600 [&_.reject]:text-white [&_.status]:ml-1 [&_.status]:text-sm [&_.status]:text-slate-600 [&_form]:mt-3 [&_.grid]:mb-3.5 [&_.grid]:grid [&_.grid]:gap-3 [&_.grid]:[grid-template-columns:repeat(2,minmax(0,1fr))] max-lg:[&_.grid]:grid-cols-1" scroll-region>
          <slot />
        </section>
      </main>
    </div>
  </div>
</template>

<script setup>
import { Link } from '@inertiajs/vue3'
import { computed, nextTick, onBeforeUnmount, onMounted, ref } from 'vue'
import { confirmAndLogout } from '@/lib/auth-flow'
import WorkspaceNotificationBell from '@/Components/WorkspaceNotificationBell.vue'

const props = defineProps({
  title: {
    type: String,
    required: true,
  },
  subtitle: {
    type: String,
    default: '',
  },
  activePath: {
    type: String,
    required: true,
  },
})

const menuItems = [
  { label: 'Finance Overview', path: '/finance', icon: 'DB', section: 'Core', hint: 'Budget status, collections, and release monitoring' },
  { label: 'Invoices', path: '/finance/invoice', icon: 'IV', section: 'Collections', hint: 'Track invoice lifecycle, official receipts, and due dates' },
  { label: 'Billing Automation', path: '/finance/billing-auto', icon: 'BA', section: 'Collections', hint: 'Manage recurring billing and collection rules' },
  { label: 'Pending & Overdue', path: '/finance/pending-overdue', icon: 'OD', section: 'Collections', hint: 'Follow up unsettled and overdue receivables' },
  { label: 'Payment Processing', path: '/finance/payment-process', icon: 'PP', section: 'Collections', hint: 'Review captured payment transactions and methods' },
  { label: 'Payment Verification', path: '/finance/payment-verify', icon: 'PV', section: 'Collections', hint: 'Confirm online and physical settlements against expected payments' },
  { label: 'Payment Review Queue', path: '/finance/payment-approvals', icon: 'PA', section: 'Approvals', hint: 'Resolve flagged payments before release or assignment' },
  { label: 'Refund Management', path: '/finance/refunds', icon: 'RF', section: 'Approvals', hint: 'Process and track refund decisions' },
  { label: 'Procurement Budget Review', path: '/finance/procurement-approvals', icon: 'PR', section: 'Approvals', hint: 'Approve or reject purchase requisitions from Procurement' },
  { label: 'Payout Monitoring', path: '/finance/payouts', icon: 'PM', section: 'Approvals', hint: 'Track payout release and audit history' },
  { label: 'Revenue Reports', path: '/finance/revenue-reports', icon: 'RR', section: 'Reports', hint: 'Review finance totals by reporting period' },
  { label: 'Service Earnings', path: '/finance/service-earnings', icon: 'SE', section: 'Reports', hint: 'Review earnings by service category' },
  { label: 'Field Team Earnings', path: '/finance/technician-earnings', icon: 'TE', section: 'Reports', hint: 'Track workforce and partner earnings for payroll and payout review' },
  { label: 'Invoice Audit Logs', path: '/finance/invoice-audit-logs', icon: 'AL', section: 'System', hint: 'Trace invoice activity history and finance accountability' },
  { label: 'System Health', path: '/finance/health', icon: 'HL', section: 'System', hint: 'Check finance module readiness and table availability' },
  { label: 'Profile', path: '/finance/profile', icon: 'AC', section: 'Account', hint: 'Account settings' },
]

const groupedMenu = computed(() => {
  const grouped = menuItems.reduce((acc, item) => {
    if (!acc[item.section]) acc[item.section] = []
    acc[item.section].push(item)
    return acc
  }, {})

  return Object.entries(grouped).map(([title, items]) => ({ title, items }))
})

const sidebarScrollEl = ref(null)
const SIDEBAR_SCROLL_KEY = 'finance-sidebar-scroll-top'
const showProfileMenu = ref(false)
const profilePath = '/finance/profile'
const openDropdowns = ref({})

function saveSidebarScroll() {
  if (!sidebarScrollEl.value) return
  sessionStorage.setItem(SIDEBAR_SCROLL_KEY, String(sidebarScrollEl.value.scrollTop))
}

function restoreSidebarScroll() {
  if (!sidebarScrollEl.value) return
  const raw = sessionStorage.getItem(SIDEBAR_SCROLL_KEY)
  if (raw === null) return
  const top = Number(raw)
  if (!Number.isNaN(top)) {
    sidebarScrollEl.value.scrollTop = top
  }
}

onMounted(() => {
  nextTick(() => {
    initializeDropdownMenus()
    restoreSidebarScroll()
    sidebarScrollEl.value?.addEventListener('scroll', saveSidebarScroll, { passive: true })
  })
  document.addEventListener('click', handleDocumentClick)
})

onBeforeUnmount(() => {
  saveSidebarScroll()
  sidebarScrollEl.value?.removeEventListener('scroll', saveSidebarScroll)
  document.removeEventListener('click', handleDocumentClick)
})

function closeMenus() {
  showProfileMenu.value = false
}

function toggleProfileMenu() {
  showProfileMenu.value = !showProfileMenu.value
}

function handleDocumentClick(event) {
  const target = event.target
  if (!(target instanceof Element)) return
  if (!target.closest('.top-actions')) closeMenus()
}

function hasChildren(item) {
  return Array.isArray(item.children) && item.children.length > 0
}

function isMenuOpen(path) {
  return Boolean(openDropdowns.value[path])
}

function isMenuActive(item) {
  if (props.activePath === item.path) return true
  if (!hasChildren(item)) return false
  return item.children.some((child) => child.path === props.activePath)
}

function toggleMenu(path) {
  openDropdowns.value[path] = !isMenuOpen(path)
}

function initializeDropdownMenus() {
  menuItems.forEach((item) => {
    if (!hasChildren(item)) return
    openDropdowns.value[item.path] = isMenuActive(item)
  })
}

async function logout() {
  await confirmAndLogout({
    confirmText: 'Do you want to end this session?',
    confirmButtonText: 'Logout',
  })
}
</script>



