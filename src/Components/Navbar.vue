<template>
  <nav class="flex h-[60px] items-center justify-between bg-sky-600 px-5 font-bold text-white">
    <h1>{{ title }}</h1>
    <button
      class="cursor-pointer rounded-md bg-red-500 px-3 py-1.5 text-white transition-colors hover:bg-red-600"
      @click="logout"
    >
      Logout
    </button>
  </nav>
</template>

<script>
import { confirmAndLogout } from '@/lib/auth-flow'

export default {
  props:['title'],
  methods:{
    async logout(){
      await confirmAndLogout({
        confirmText: 'Do you want to end this session?',
        confirmButtonText: 'Logout',
      })
    }
  }
}
</script>

