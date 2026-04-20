<template>
  <div class="h-screen overflow-hidden bg-slate-100 flex flex-col">
    <header class="z-50 h-16 shrink-0 bg-white border-b border-slate-200 flex items-center justify-between px-6">
      <div class="flex items-center space-x-3">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white flex items-center justify-center font-bold shadow-sm">
          A
        </div>
        <div>
          <h1 class="text-lg font-semibold text-slate-900">Admin Dashboard</h1>
          <p class="text-xs text-slate-500">Platform management workspace</p>
        </div>
      </div>

      <button
        @click="confirmLogout"
        class="text-sm px-4 py-2 rounded-xl border border-slate-300 text-slate-700 hover:bg-red-50 hover:text-red-600 transition"
      >
        Logout
      </button>
    </header>

    <div class="flex flex-1 min-h-0">
      <aside class="w-72 shrink-0 bg-white border-r border-slate-200 hidden md:flex flex-col h-full">
        <div class="px-6 pt-6">
          <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4">
            <p class="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500">Management</p>
            <p class="mt-2 text-sm leading-6 text-slate-600">
              Manage accounts, approvals, compliance, and access from one admin workspace.
            </p>
          </div>
        </div>

        <div class="px-6 pt-5 text-xs uppercase text-slate-400 font-semibold tracking-[0.16em]">
          Side Tabs
        </div>

        <nav class="px-4 pt-3 space-y-1.5 text-sm">
          <button
            v-for="item in menuItems"
            :key="item.key"
            @click="activeMenu = item.key"
            class="w-full flex items-start space-x-3 px-4 py-3 rounded-2xl border transition text-left"
            :class="activeMenu === item.key
              ? 'border-blue-200 bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-sm'
              : 'border-transparent text-slate-700 hover:border-slate-200 hover:bg-slate-50'"
          >
            <span
              class="mt-0.5 inline-flex h-9 w-9 items-center justify-center rounded-xl text-[11px] font-bold"
              :class="activeMenu === item.key ? 'bg-white/20 text-white' : 'bg-slate-100 text-slate-600'"
            >
              {{ item.short }}
            </span>
            <span class="min-w-0">
              <span class="block font-medium leading-5">{{ item.label }}</span>
              <span
                class="mt-1 block text-xs leading-4"
                :class="activeMenu === item.key ? 'text-blue-100' : 'text-slate-500'"
              >
                {{ item.description }}
              </span>
            </span>
          </button>
        </nav>

        <div class="mt-auto p-4 text-xs text-slate-400">
          © 2026 Admin System
        </div>
      </aside>

      <main class="flex-1 min-h-0 overflow-y-auto p-4 sm:p-6">
        <section
          v-if="activeMenu === 'overview'"
          class="space-y-6"
        >
          <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
            <p class="text-xs font-semibold uppercase tracking-[0.18em] text-cyan-700">Administrative Scope</p>
            <h2 class="mt-2 text-3xl font-black text-slate-900">Platform Governance Overview</h2>
            <p class="mt-3 max-w-3xl text-sm leading-6 text-slate-600">
              The administrator oversees platform accounts, company approval, permit visibility, provider monitoring, and access governance.
              Daily operational workflows remain under the assigned company offices.
            </p>
          </div>

          <div v-if="latestEmergencyAlert" class="rounded-3xl border border-rose-200 bg-rose-50 p-5 shadow-sm animate-pulse">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
              <div>
                <p class="text-xs font-semibold uppercase tracking-[0.18em] text-rose-700">High Priority Alert</p>
                <h3 class="mt-1 text-2xl font-black text-rose-950">{{ noteTitle(latestEmergencyAlert) }}</h3>
                <p class="mt-2 text-sm leading-6 text-rose-900">{{ noteMessage(latestEmergencyAlert) }}</p>
                <p class="mt-2 text-xs text-rose-700">
                  Location: {{ latestEmergencyAlert?.data?.address_text || latestEmergencyAlert?.address_text || 'Unavailable' }}
                </p>
                <p class="mt-1 text-xs text-rose-700">
                  Countdown: {{ emergencyCountdownLabel }}
                </p>
                <p v-if="latestEmergencyProofs.length" class="mt-1 text-xs text-rose-700">
                  Proofs: {{ latestEmergencyProofs.length }} file{{ latestEmergencyProofs.length === 1 ? '' : 's' }} attached
                </p>
                <div v-if="latestEmergencyProofs.length" class="mt-3 flex flex-wrap gap-2">
                  <a
                    v-for="proof in latestEmergencyProofs.slice(0, 3)"
                    :key="proof.url || proof.name"
                    :href="proof.url || undefined"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="rounded-full border border-rose-200 bg-white px-3 py-1 text-[11px] font-semibold text-rose-700 transition hover:bg-rose-100 hover:underline"
                  >
                    {{ proof.name }}
                  </a>
                </div>
              </div>
              <button
                type="button"
                class="rounded-2xl bg-rose-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-rose-700"
                @click="handleNotificationClick(latestEmergencyAlert)"
              >
                Open Alert
              </button>
            </div>
          </div>

          <div class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
            <article
              v-for="card in overviewCards"
              :key="card.title"
              class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm"
            >
              <p class="text-xs font-semibold uppercase tracking-[0.14em] text-slate-500">{{ card.eyebrow }}</p>
              <h3 class="mt-2 text-lg font-extrabold text-slate-900">{{ card.title }}</h3>
              <p class="mt-2 text-sm text-slate-600">{{ card.description }}</p>
            </article>
          </div>

          <div class="grid grid-cols-1 gap-5 xl:grid-cols-2">
            <article class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
              <p class="text-xs font-semibold uppercase tracking-[0.14em] text-cyan-700">Allowed Administrative Functions</p>
              <ul class="mt-4 space-y-3 text-sm text-slate-700">
                <li
                  v-for="item in allowedFunctions"
                  :key="item"
                  class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5"
                >
                  {{ item }}
                </li>
              </ul>
            </article>

            <article class="rounded-2xl border border-amber-200 bg-amber-50 p-5 shadow-sm">
              <p class="text-xs font-semibold uppercase tracking-[0.14em] text-amber-700">Not Handled By Admin</p>
              <ul class="mt-4 space-y-3 text-sm text-slate-700">
                <li
                  v-for="item in restrictedFunctions"
                  :key="item"
                  class="rounded-xl border border-amber-200 bg-white px-3 py-2.5"
                >
                  {{ item }}
                </li>
              </ul>
            </article>
          </div>
        </section>

        <UserManagement v-else-if="activeMenu === 'users'" />
        <BusinessManagement v-else-if="activeMenu === 'businesses'" />
        <BusinessPermitManagement v-else-if="activeMenu === 'permits'" />
        <ServiceProviderManagement v-else-if="activeMenu === 'providers'" />
        <RbacChecklist v-else-if="activeMenu === 'rbac'" />
        <SettingsDashboard v-else-if="activeMenu === 'settings'" />
      </main>
    </div>
  </div>
</template>

<script>
import { confirmAndLogout } from '@/lib/auth-flow'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import UserManagement from './UserManagement.vue'
import BusinessManagement from './BusinessManagement.vue'
import BusinessPermitManagement from './BusinessPermitManagement.vue'
import ServiceProviderManagement from './ServiceProviderManagement.vue'
import RbacChecklist from './RbacChecklist.vue'
import SettingsDashboard from './SettingsDashboard.vue'

const menuItems = [
  {
    key: 'overview',
    short: 'OV',
    label: 'Platform Overview',
    description: 'Administrative scope and summary.',
  },
  {
    key: 'users',
    short: 'UM',
    label: 'Account Administration',
    description: 'Accounts, roles, and approvals.',
  },
  {
    key: 'businesses',
    short: 'BM',
    label: 'Business Governance',
    description: 'Company approval and governance.',
  },
  {
    key: 'permits',
    short: 'PM',
    label: 'Permit Compliance',
    description: 'Business permit review and status.',
  },
  {
    key: 'providers',
    short: 'SP',
    label: 'Provider Oversight',
    description: 'Provider monitoring and approval.',
  },
  {
    key: 'rbac',
    short: 'RB',
    label: 'Access Control',
    description: 'Permissions and access validation.',
  },
  {
    key: 'settings',
    short: 'ST',
    label: 'System Configuration',
    description: 'Platform-level preferences.',
  },
]

const overviewCards = [
  {
    eyebrow: 'Provisioning',
    title: 'Account Administration',
    description: 'Create, approve, and classify accounts in one centralized admin workspace.',
  },
  {
    eyebrow: 'Governance',
    title: 'Business Oversight',
    description: 'Review company readiness, approval status, and administrative compliance.',
  },
  {
    eyebrow: 'Compliance',
    title: 'Permit Monitoring',
    description: 'Track permit records and maintain business compliance visibility.',
  },
  {
    eyebrow: 'Control',
    title: 'Access Assurance',
    description: 'Validate access rules and confirm the correct module visibility per role.',
  },
]

const allowedFunctions = [
  'Create and approve user accounts and role assignments.',
  'Review business and company registration readiness.',
  'Monitor business permits and service provider records.',
  'Validate RBAC access and system-level visibility.',
  'Maintain platform-level administrative settings.',
]

const restrictedFunctions = [
  'CSR intake review and request validation.',
  'Finance payment verification and billing clearance.',
  'Procurement ordering and stock replenishment.',
  'Operational scheduling and field assignment.',
  'Company-internal HR supervision and attendance workflows.',
]

export default {
  components: {
    UserManagement,
    BusinessManagement,
    BusinessPermitManagement,
    ServiceProviderManagement,
    RbacChecklist,
    SettingsDashboard,
  },

  data() {
    return {
      activeMenu: 'users',
      menuItems,
      overviewCards,
      allowedFunctions,
      restrictedFunctions,
      notifications: [],
      currentTimeTick: Date.now(),
      shownEmergencyAlertIds: [],
      notificationClockTimer: null,
      notificationRefreshTimer: null,
    }
  },

  computed: {
    emergencyNotifications() {
      return (this.notifications || []).filter((note) => this.isEmergencyNotification(note))
    },
    latestEmergencyAlert() {
      return this.emergencyNotifications.find((note) => !note.read_at) || this.emergencyNotifications[0] || null
    },
    latestEmergencyProofs() {
      return this.notificationProofs(this.latestEmergencyAlert)
    },
    emergencyCountdownLabel() {
      return this.formatCountdown(this.latestEmergencyAlert)
    },
  },

  methods: {
    notificationProofs(note) {
      const data = note?.data || {}
      const rawProofs = data.emergency_proofs || note?.emergency_proofs || data.emergency_proof_urls || note?.emergency_proof_urls || []
      const list = Array.isArray(rawProofs) ? rawProofs : []
      return list.map((entry, index) => {
        if (typeof entry === 'string') {
          const url = entry.trim()
          return url ? { name: `Proof ${index + 1}`, url } : null
        }
        const url = String(entry?.url || entry?.path || entry?.storage_url || '').trim()
        const name = String(entry?.name || entry?.file_name || entry?.original_name || `Proof ${index + 1}`).trim()
        if (!url && !name) return null
        return { url, name: name || `Proof ${index + 1}` }
      }).filter(Boolean)
    },
    escapeHtml(value) {
      return String(value ?? '').replace(/[&<>"']/g, (char) => ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;',
      })[char])
    },
    isEmergencyNotification(note) {
      return String(note?.priority || note?.data?.priority || '').toLowerCase() === 'high'
        || String(note?.category || note?.data?.category || '').toLowerCase() === 'emergency'
        || String(note?.type || note?.data?.type || '').toLowerCase() === 'emergency_booking'
    },
    noteTitle(note) {
      const data = note?.data || {}
      return note?.title || data.title || data.message || note?.message || 'Emergency Alert'
    },
    noteMessage(note) {
      const data = note?.data || {}
      return note?.message || data.message || data.details || 'Emergency booking requires immediate attention.'
    },
    formatCountdown(note) {
      const deadlineText = String(note?.response_deadline_at || note?.data?.response_deadline_at || note?.emergency_deadline_at || note?.data?.emergency_deadline_at || '').trim()
      if (!deadlineText) return 'Countdown unavailable'
      const target = new Date(deadlineText)
      if (Number.isNaN(target.getTime())) return 'Countdown unavailable'
      const diff = Math.max(0, target.getTime() - this.currentTimeTick)
      const totalSeconds = Math.floor(diff / 1000)
      const hours = Math.floor(totalSeconds / 3600)
      const minutes = Math.floor((totalSeconds % 3600) / 60)
      const seconds = totalSeconds % 60
      return `${hours}h ${minutes}m ${seconds}s`
    },
    openNotificationTarget(note) {
      const link = note?.link || note?.data?.link
      if (link) {
        window.location.assign(link)
        return
      }
      window.location.assign('/employee/notifications')
    },
    async markRead(id) {
      if (!id) return
      try {
        await axios.post(`/user/notifications/${id}/read`)
        const notification = this.notifications.find((row) => row.id === id)
        if (notification) notification.read_at = notification.read_at || new Date().toISOString()
      } catch {
        // Ignore notification read errors.
      }
    },
    async handleNotificationClick(note) {
      if (!note?.read_at && note?.id) {
        await this.markRead(note.id)
      }
      this.openNotificationTarget(note)
    },
    async fetchNotifications() {
      try {
        const res = await axios.get('/user/notifications')
        this.notifications = Array.isArray(res.data) ? res.data : []
        await this.showEmergencyAlertIfNeeded()
      } catch {
        this.notifications = []
      }
    },
    async showEmergencyAlertIfNeeded() {
      const note = this.emergencyNotifications.find((entry) => !entry.read_at) || null
      if (!note || this.shownEmergencyAlertIds.includes(note.id)) return
      this.shownEmergencyAlertIds.push(note.id)
      const proofs = this.notificationProofs(note).slice(0, 3)
      const proofMarkup = proofs.length
        ? `
          <div style="margin-top:12px;text-align:left;font-size:12px;line-height:1.6;color:#7f1d1d">
            <div style="font-weight:700;margin-bottom:4px;">Proof files:</div>
            <ul style="margin:0;padding-left:18px;">
              ${proofs.map((proof) => `
                <li>
                  ${proof.url
                    ? `<a href="${this.escapeHtml(proof.url)}" target="_blank" rel="noopener noreferrer" style="color:#b91c1c;text-decoration:underline;">${this.escapeHtml(proof.name)}</a>`
                    : this.escapeHtml(proof.name)
                  }
                </li>
              `).join('')}
            </ul>
          </div>
        `
        : ''
      const result = await Swal.fire({
        icon: 'warning',
        titleText: this.noteTitle(note),
        html: `
          <div style="text-align:left">
            <div style="font-weight:700;margin-bottom:8px;">${this.noteMessage(note)}</div>
            <div style="font-size:12px;line-height:1.6;color:#7f1d1d">
              <div><strong>Countdown:</strong> ${this.emergencyCountdownLabel}</div>
              <div><strong>Location:</strong> ${String(note?.data?.address_text || note?.address_text || 'Unavailable')}</div>
            </div>
            ${proofMarkup}
          </div>
        `,
        confirmButtonText: 'Open Alert',
        confirmButtonColor: '#dc2626',
        showCancelButton: true,
        cancelButtonText: 'Later',
      })
      if (result.isConfirmed) {
        await this.handleNotificationClick(note)
      }
    },
    startNotificationPolling() {
      this.stopNotificationPolling()
      this.notificationClockTimer = setInterval(() => {
        this.currentTimeTick = Date.now()
      }, 1000)
      this.notificationRefreshTimer = setInterval(() => {
        this.fetchNotifications()
      }, 15000)
    },
    stopNotificationPolling() {
      if (this.notificationClockTimer) {
        clearInterval(this.notificationClockTimer)
        this.notificationClockTimer = null
      }
      if (this.notificationRefreshTimer) {
        clearInterval(this.notificationRefreshTimer)
        this.notificationRefreshTimer = null
      }
    },
    async confirmLogout() {
      await confirmAndLogout({
        confirmText: 'Are you sure you want to logout?',
      })
    },
  },

  mounted() {
    this.fetchNotifications()
    this.startNotificationPolling()
  },

  beforeUnmount() {
    this.stopNotificationPolling()
  },
}
</script>
