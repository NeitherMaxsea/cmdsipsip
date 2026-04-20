<template>
  <h3 class="mb-4 text-[1.35rem] font-bold tracking-[-0.03em] text-[#0D1B2A]">{{ title }}</h3>
</template>

<script setup>
defineProps({
  title: { type: String, required: true }
})
</script>
