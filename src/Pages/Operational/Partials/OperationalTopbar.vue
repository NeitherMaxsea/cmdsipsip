<template>
  <nav class="sticky top-0 z-20 flex items-center justify-end gap-2.5 border-b border-slate-200 bg-white px-6 py-[14px] shadow-[0_1px_2px_rgba(15,23,42,0.06)]">
    <button
      type="button"
      class="rounded-full border border-slate-300 bg-white px-3.5 py-2 text-xs font-bold text-slate-700 transition-all hover:border-slate-400 hover:bg-slate-50"
      @click="$emit('refresh')"
    >
      Refresh
    </button>
    <button
      type="button"
      class="rounded-full border border-red-200 bg-white px-3.5 py-2 text-xs font-bold text-red-600 transition-all hover:border-red-300 hover:bg-rose-50"
      @click="$emit('logout')"
    >
      Logout
    </button>
  </nav>
</template>

<script setup>
defineEmits(['refresh', 'logout'])
</script>
