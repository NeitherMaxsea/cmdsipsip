<template>
  <nav class="sticky top-0 z-20 flex items-center justify-end gap-3 border-b border-slate-200 bg-white px-6 py-[14px] shadow-[0_1px_2px_rgba(15,23,42,0.06)]">
    <div class="flex items-center gap-2.5">
      <span
        v-if="employeeAccessLabel"
        class="rounded-full border border-slate-200 bg-slate-50 px-2.5 py-1 text-[10px] font-bold uppercase tracking-[0.12em] text-slate-600"
      >
        {{ employeeAccessLabel }}
      </span>
      <div class="hr-notification-wrap relative">
        <button
          type="button"
          class="relative inline-flex h-[38px] w-[38px] items-center justify-center rounded-full border border-slate-200 bg-white text-slate-600 transition-all hover:bg-slate-50 hover:text-slate-900"
          aria-label="Notifications"
          @click="toggleNotifications"
        >
          <svg viewBox="0 0 24 24" fill="none" class="h-5 w-5" aria-hidden="true">
            <path d="M15 17H9m9-2V11a6 6 0 1 0-12 0v4l-2 2h16l-2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M10.5 20a1.5 1.5 0 0 0 3 0" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
          </svg>
          <span
            v-if="unreadCount > 0"
            class="absolute -right-1 -top-1 inline-flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-red-500 px-1 text-[10px] font-bold leading-[18px] text-white"
          >
            {{ unreadCount > 99 ? '99+' : unreadCount }}
          </span>
        </button>

        <div v-if="showNotifications" class="absolute right-0 z-40 mt-2 w-[360px] rounded-xl border border-slate-200 bg-white shadow-[0_12px_30px_rgba(15,23,42,0.14)] max-sm:w-[300px]">
          <div class="flex items-center justify-between border-b border-slate-100 px-3 py-2.5">
            <p class="text-sm font-semibold text-slate-800">Notifications</p>
            <button type="button" class="text-xs font-semibold text-teal-700 hover:underline" @click="loadNotifications">
              Refresh
            </button>
          </div>

          <div class="max-h-80 overflow-y-auto">
            <div v-if="unreadNotifications.length === 0" class="px-4 py-6 text-sm text-slate-500">
              No unread notifications.
            </div>
            <div v-else class="divide-y divide-slate-100">
              <button
                v-for="note in unreadNotifications"
                :key="`hr-note-${note.id}`"
                type="button"
                class="flex w-full gap-2.5 bg-white px-3 py-2.5 text-left hover:bg-slate-50"
                @click="handleNotificationClick(note)"
              >
                <span
                  class="mt-[7px] h-2 w-2 shrink-0 rounded-full"
                  :class="note.read_at ? 'bg-slate-300' : 'bg-teal-500'"
                ></span>
                <span class="min-w-0 flex-1">
                  <span class="block truncate text-sm font-semibold text-slate-800">{{ note.title || 'Notification' }}</span>
                  <span class="mt-0.5 block text-left text-xs text-slate-600">{{ note.message || 'No details' }}</span>
                  <span class="mt-1 block text-left text-[11px] text-slate-400">{{ note.created_at || '' }}</span>
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="hr-profile-wrap relative">
        <button
          type="button"
          class="flex h-[38px] min-w-[38px] items-center gap-2 rounded-full border border-slate-200 bg-white px-2.5 text-slate-700 transition-all hover:bg-slate-50 hover:text-slate-900"
          aria-label="Profile menu"
          @click="toggleProfileMenu"
        >
          <span class="inline-flex h-7 w-7 items-center justify-center rounded-full bg-teal-600 text-[11px] font-bold text-white">
            {{ profileInitials }}
          </span>
          <span class="hidden text-xs font-semibold sm:inline">Profile</span>
        </button>

        <div
          v-if="showProfileMenu"
          class="absolute right-0 z-40 mt-2 w-44 rounded-xl border border-slate-200 bg-white py-1 shadow-[0_12px_30px_rgba(15,23,42,0.14)]"
        >
          <button
            type="button"
            class="w-full px-4 py-2 text-left text-sm text-slate-700 hover:bg-slate-50"
            @click="openProfile"
          >
            Profile
          </button>
          <button
            type="button"
            class="w-full px-4 py-2 text-left text-sm text-rose-600 hover:bg-rose-50"
            @click="emitLogout"
          >
            Logout
          </button>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import axios from 'axios'
import {
  resolveEmployeeAccessLevel,
  resolveEmployeeModuleAccessLevel,
  resolveEmployeeModuleKeyFromPath,
} from '@/lib/employee-rbac'

const emit = defineEmits(['logout'])

const notifications = ref([])
const showNotifications = ref(false)
const showProfileMenu = ref(false)
const page = usePage()
let notificationPoller = null
const isEmployeeRole = computed(
  () => String(page.props?.auth?.user?.role || '').trim().toLowerCase() === 'employee'
)
const profileInitials = computed(() => {
  const first = String(page.props?.auth?.user?.first_name || '').trim().charAt(0)
  const last = String(page.props?.auth?.user?.last_name || '').trim().charAt(0)
  const business = String(page.props?.auth?.user?.business_name || page.props?.auth?.user?.company_name || '').trim()
  const businessInitials = business
    ? business.split(/\s+/).slice(0, 2).map((part) => part.charAt(0)).join('')
    : ''
  const value = `${first}${last}`.toUpperCase() || businessInitials.toUpperCase()
  return value || 'PR'
})
const currentPath = computed(() => String(page.url || '').split('?')[0] || '')
const employeeAccessLevel = computed(() =>
  resolveEmployeeAccessLevel(page.props?.auth?.employee_rbac || {})
)
const employeeModuleKey = computed(() => resolveEmployeeModuleKeyFromPath(currentPath.value))
const employeeModuleAccessLevel = computed(() =>
  resolveEmployeeModuleAccessLevel(page.props?.auth?.employee_rbac || {}, employeeModuleKey.value)
)
const effectiveEmployeeAccessLevel = computed(() =>
  employeeModuleKey.value ? employeeModuleAccessLevel.value : employeeAccessLevel.value
)
const employeeAccessLabel = computed(() => {
  if (!isEmployeeRole.value) return ''
  if (effectiveEmployeeAccessLevel.value === 'view') return 'View only'
  if (effectiveEmployeeAccessLevel.value === 'manage') return 'Manage'
  if (effectiveEmployeeAccessLevel.value === 'approve') return 'Approve'
  return ''
})

const unreadCount = computed(() =>
  (notifications.value || []).filter((note) => !note?.read_at).length
)

const unreadNotifications = computed(() =>
  (notifications.value || []).filter((note) => !note?.read_at)
)

const sortNotifications = (rows = []) => (
  [...rows].sort((left, right) => (
    new Date(right?.created_at || 0).getTime() - new Date(left?.created_at || 0).getTime()
  ))
)

const loadNotifications = async () => {
  try {
    const res = await axios.get('/user/notifications')
    notifications.value = sortNotifications(Array.isArray(res.data) ? res.data : [])
  } catch {
    notifications.value = []
  }
}

const markRead = async (note) => {
  if (!note?.id) return
  try {
    await axios.post(`/user/notifications/${note.id}/read`)
  } catch {
    // Ignore read errors in topbar.
  } finally {
    notifications.value = (notifications.value || []).filter((entry) => String(entry?.id || '') !== String(note.id || ''))
  }
}

const handleNotificationClick = async (note) => {
  await markRead(note)
  showNotifications.value = false
  if (note?.link) {
    router.visit(note.link)
  }
}

const toggleNotifications = async () => {
  showNotifications.value = !showNotifications.value
  if (showNotifications.value) {
    showProfileMenu.value = false
  }
  if (showNotifications.value) {
    await loadNotifications()
  }
}

const toggleProfileMenu = () => {
  showProfileMenu.value = !showProfileMenu.value
  if (showProfileMenu.value) {
    showNotifications.value = false
  }
}

const openProfile = () => {
  showProfileMenu.value = false
  if (isEmployeeRole.value) {
    router.visit('/employee/profile')
    return
  }
  router.visit('/Profile/Profile')
}

const emitLogout = () => {
  showNotifications.value = false
  showProfileMenu.value = false
  emit('logout')
}

const onDocumentClick = (event) => {
  const target = event?.target
  if (!(target instanceof HTMLElement)) return
  if (!target.closest('.hr-notification-wrap')) {
    showNotifications.value = false
  }
  if (!target.closest('.hr-profile-wrap')) {
    showProfileMenu.value = false
  }
}

const onVisibilityChange = () => {
  if (!document.hidden) {
    loadNotifications()
  }
}

onMounted(async () => {
  await loadNotifications()
  document.addEventListener('click', onDocumentClick)
  document.addEventListener('visibilitychange', onVisibilityChange)
  notificationPoller = window.setInterval(() => {
    if (!document.hidden) {
      loadNotifications()
    }
  }, 15000)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', onDocumentClick)
  document.removeEventListener('visibilitychange', onVisibilityChange)
  if (notificationPoller) {
    window.clearInterval(notificationPoller)
    notificationPoller = null
  }
})
</script>
