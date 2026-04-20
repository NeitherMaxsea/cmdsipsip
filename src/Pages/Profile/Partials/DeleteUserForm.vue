<template>
  <div>
    <button
      @click="deleteAccount"
      class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
    >
      Delete Account
    </button>
  </div>
</template>

<script>
import { confirmAndDeleteAccount } from '@/lib/auth-flow'

export default {
  setup() {
    const deleteAccount = async () => {
      await confirmAndDeleteAccount()
    }

    return { deleteAccount }
  }
}
</script>
