<script setup>
import { computed, onMounted } from 'vue'
import { Head, router, usePage } from '@inertiajs/vue3'
import { getDashboardPathForRole } from '@/lib/firebase-auth'

const page = usePage()
const redirectPath = computed(() => getDashboardPathForRole(page.props?.auth?.user || { role: 'guest' }))

onMounted(() => {
  const target = redirectPath.value
  if (!target) return
  const current = String(page.url || '').split('?')[0] || ''
  if (target !== current) {
    router.visit(target)
  }
})
</script>

<template>
  <Head title="Dashboard" />
  <div class="flex min-h-screen items-center justify-center bg-slate-50">
    <p class="text-sm text-slate-500">Redirecting to your dashboard...</p>
  </div>
</template>
