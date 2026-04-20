<template>
  <div class="workspace-notification-wrap relative">
    <button
      type="button"
      class="relative inline-flex h-10 w-10 items-center justify-center rounded-full border border-slate-200 bg-white text-slate-600 transition hover:bg-slate-50 hover:text-slate-900"
      aria-label="Notifications"
      @click="toggleMenu"
    >
      <svg viewBox="0 0 24 24" fill="none" class="h-5 w-5" aria-hidden="true">
        <path d="M15 17H9m9-2V11a6 6 0 1 0-12 0v4l-2 2h16l-2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
        <path d="M10.5 20a1.5 1.5 0 0 0 3 0" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
      </svg>
      <span
        v-if="unreadCount > 0"
        class="absolute -right-1 -top-1 inline-flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-red-500 px-1 text-[10px] font-bold leading-[18px] text-white"
      >
        {{ unreadCount > maxBadge ? `${maxBadge}+` : unreadCount }}
      </span>
    </button>

    <div
      v-if="showMenu"
      :class="panelClass"
    >
      <div class="flex items-center justify-between border-b border-slate-100 px-3 py-2.5">
        <p class="text-sm font-semibold text-slate-800">{{ title }}</p>
        <div class="flex items-center gap-2">
          <span v-if="loading" class="text-[11px] font-semibold text-slate-400">Checking...</span>
          <button type="button" class="text-xs font-semibold text-teal-700 hover:underline" @click="loadNotifications">
            Refresh
          </button>
        </div>
      </div>

      <div class="max-h-80 overflow-y-auto">
        <div v-if="loading && visibleNotifications.length === 0" class="px-4 py-6 text-sm text-slate-500">
          Loading notifications...
        </div>
        <div v-else-if="visibleNotifications.length === 0" class="px-4 py-6 text-sm text-slate-500">
          {{ emptyText }}
        </div>
        <div v-else class="divide-y divide-slate-100">
          <button
            v-for="note in visibleNotifications"
            :key="`workspace-note-${note.id}`"
            type="button"
            class="flex w-full gap-2.5 bg-white px-3 py-2.5 text-left hover:bg-slate-50"
            @click="handleNotificationClick(note)"
          >
            <span class="mt-[7px] h-2 w-2 shrink-0 rounded-full bg-teal-500"></span>
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
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { router } from '@inertiajs/vue3'
import axios from 'axios'

const props = defineProps({
  title: {
    type: String,
    default: 'Notifications',
  },
  listEndpoint: {
    type: String,
    default: '/user/notifications',
  },
  markReadBase: {
    type: String,
    default: '/user/notifications',
  },
  emptyText: {
    type: String,
    default: 'No unread notifications.',
  },
  maxBadge: {
    type: Number,
    default: 99,
  },
  widthClass: {
    type: String,
    default: 'w-[360px] max-sm:w-[300px]',
  },
  pollIntervalMs: {
    type: Number,
    default: 15000,
  },
})

const notifications = ref([])
const showMenu = ref(false)
const loading = ref(false)
let poller = null

const sortNotifications = (rows = []) => (
  [...rows].sort((left, right) => (
    new Date(right?.created_at || 0).getTime() - new Date(left?.created_at || 0).getTime()
  ))
)

const unreadNotifications = (rows = []) => (
  rows.filter((note) => !String(note?.read_at || '').trim())
)

const visibleNotifications = computed(() => unreadNotifications(notifications.value || []))
const unreadCount = computed(() => visibleNotifications.value.length)
const panelClass = computed(() => ([
  'absolute right-0 z-40 mt-2 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-[0_12px_30px_rgba(15,23,42,0.14)]',
  props.widthClass,
]))

const loadNotifications = async () => {
  if (loading.value) return
  loading.value = true
  try {
    const res = await axios.get(props.listEndpoint)
    notifications.value = sortNotifications(Array.isArray(res.data) ? res.data : [])
  } catch {
    notifications.value = []
  } finally {
    loading.value = false
  }
}

const removeNotification = (noteId) => {
  notifications.value = (notifications.value || []).filter((note) => String(note?.id || '') !== String(noteId || ''))
}

const markRead = async (note) => {
  if (!note?.id) return
  try {
    await axios.post(`${props.markReadBase}/${note.id}/read`)
  } catch {
    // Best-effort read tracking only.
  } finally {
    removeNotification(note.id)
  }
}

const handleNotificationClick = async (note) => {
  await markRead(note)
  showMenu.value = false
  if (note?.link) {
    router.visit(note.link)
  }
}

const refreshVisibleNotifications = async () => {
  if (document.hidden) return
  await loadNotifications()
}

const toggleMenu = async () => {
  showMenu.value = !showMenu.value
  if (showMenu.value) {
    await loadNotifications()
  }
}

const onVisibilityChange = () => {
  if (!document.hidden) {
    refreshVisibleNotifications()
  }
}

const onDocumentClick = (event) => {
  const target = event?.target
  if (!(target instanceof HTMLElement)) return
  if (!target.closest('.workspace-notification-wrap')) {
    showMenu.value = false
  }
}

onMounted(async () => {
  await loadNotifications()
  document.addEventListener('click', onDocumentClick)
  document.addEventListener('visibilitychange', onVisibilityChange)
  if (props.pollIntervalMs > 0) {
    poller = window.setInterval(() => {
      refreshVisibleNotifications()
    }, props.pollIntervalMs)
  }
})

onBeforeUnmount(() => {
  document.removeEventListener('click', onDocumentClick)
  document.removeEventListener('visibilitychange', onVisibilityChange)
  if (poller) {
    window.clearInterval(poller)
    poller = null
  }
})
</script>
