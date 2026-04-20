<template>
  <div>
    <form @submit.prevent="updatePassword" class="space-y-2">
      <input
        v-model="form.current_password"
        type="password"
        placeholder="Current Password"
        class="border px-3 py-2 w-full rounded"
        required
      />
      <input
        v-model="form.new_password"
        type="password"
        placeholder="New Password"
        class="border px-3 py-2 w-full rounded"
        required
      />
      <input
        v-model="form.confirm_password"
        type="password"
        placeholder="Confirm Password"
        class="border px-3 py-2 w-full rounded"
        required
      />
      <button
        type="submit"
        class="bg-yellow-500 text-white px-4 py-2 rounded hover:bg-yellow-600"
      >
        Update Password
      </button>
    </form>
  </div>
</template>

<script>
import { ref } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'

export default {
  setup() {
    const form = ref({
      current_password: '',
      new_password: '',
      confirm_password: ''
    })

    const updatePassword = async () => {
      if (form.value.new_password !== form.value.confirm_password) {
        await Swal.fire('Mismatch', 'Passwords do not match', 'warning')
        return
      }

      try {
        await axios.put('/user/password/update', form.value)
        await Swal.fire('Updated', 'Password updated successfully!', 'success')
        form.value.current_password = ''
        form.value.new_password = ''
        form.value.confirm_password = ''
      } catch (err) {
        console.error(err)
        await Swal.fire('Error', 'Failed to update password', 'error')
      }
    }

    return { form, updatePassword }
  }
}
</script>

