<script setup>
import { computed, onMounted } from 'vue'
import { useTheme } from '@/Composables/useTheme'

const props = defineProps({
  placement: {
    type: String,
    default: 'floating',
  },
})

const { isDark, initTheme, toggleTheme } = useTheme()

const label = computed(() => (isDark.value ? 'Light' : 'Dark'))
const isFloating = computed(() => props.placement === 'floating')
const toneClass = computed(() => (
  isDark.value
    ? 'border-slate-500 bg-slate-800/95 text-slate-100 hover:bg-slate-700'
    : 'border-slate-900 bg-slate-900 text-white hover:bg-slate-800'
))

onMounted(() => {
  initTheme()
})
</script>

<template>
  <button
    type="button"
    @click="toggleTheme"
    class="rounded-full border px-4 py-2 text-xs font-semibold shadow transition"
    :class="[toneClass, isFloating ? 'fixed bottom-4 right-4 z-[1000] backdrop-blur shadow-lg' : 'inline-flex items-center']"
    :aria-label="`Switch to ${label} mode`"
  >
    <span class="inline-flex h-4 w-4 items-center justify-center" aria-hidden="true">
      <svg viewBox="0 0 24 24" class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="8" />
        <path d="M12 4v16" stroke-linecap="round" />
      </svg>
    </span>
    <span>Theme</span>
  </button>
</template>
