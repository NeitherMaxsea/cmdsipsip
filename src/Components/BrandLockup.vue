<script setup>
import { computed } from 'vue'

const props = defineProps({
  theme: {
    type: String,
    default: 'light',
    validator: (value) => ['light', 'dark'].includes(value),
  },
  compact: {
    type: Boolean,
    default: false,
  },
})

const titleClass = computed(() => (
  props.theme === 'dark'
    ? 'text-[#0D1B2A]'
    : 'text-white'
))

const eyebrowClass = computed(() => (
  props.theme === 'dark'
    ? 'text-[#3B82F6]'
    : 'text-[#3B82F6]'
))

const iconSizeClass = computed(() => (props.compact ? 'h-10 w-10' : 'h-12 w-12'))
const titleSizeClass = computed(() => (props.compact ? 'text-base' : 'text-lg'))
</script>

<template>
  <div class="flex items-center gap-3">
    <div
      :class="iconSizeClass"
      class="flex items-center justify-center rounded-full bg-[#3B82F6] shadow-[0_12px_28px_rgba(59,130,246,0.28)]"
    >
      <svg viewBox="0 0 24 24" class="h-5 w-5 text-white" fill="none" stroke="currentColor" stroke-width="1.8">
        <path stroke-linecap="round" stroke-linejoin="round" d="M8 5h8v3h-2v3.5a4.5 4.5 0 1 1-4 0V8H8V5Z" />
      </svg>
    </div>
    <div>
      <p :class="eyebrowClass" class="text-[0.68rem] font-bold uppercase tracking-[0.3em]">Professional Service</p>
      <p :class="[titleClass, titleSizeClass]" class="font-extrabold tracking-[-0.03em]">Plumbing &amp; Siphoning</p>
    </div>
  </div>
</template>
