<template>
  <section class="space-y-6">
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-r from-sky-500 via-blue-500 to-indigo-500 p-6 shadow-lg text-white">
      <div class="absolute -top-6 -right-10 h-32 w-32 rounded-full bg-white/20"></div>
      <div class="absolute -bottom-8 -left-8 h-28 w-28 rounded-full bg-white/15"></div>
      <div class="relative flex flex-col md:flex-row md:items-center gap-6">
        <div class="w-20 h-20 rounded-2xl bg-white/20 backdrop-blur flex items-center justify-center text-2xl font-bold">
          {{ initials }}
        </div>
        <div class="flex-1">
          <h2 class="text-2xl font-bold">My Profile</h2>
          <p class="text-white/80 text-sm">Manage your account and service provider details.</p>
        </div>
        <div class="flex gap-2">
          <span class="px-3 py-1 rounded-full text-xs font-semibold bg-white/20">
            {{ provider?.is_available ? 'Available' : 'Busy' }}
          </span>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 bg-white rounded-2xl shadow-lg p-6">
        <div class="flex items-center gap-4">
          <div class="relative w-20 h-20">
            <img
              :src="avatarUrl"
              class="w-20 h-20 rounded-2xl object-cover border border-gray-100 shadow-sm"
              alt="Profile"
            />
            <button
              type="button"
              class="absolute -bottom-2 -right-2 h-8 w-8 rounded-full bg-sky-600 text-white shadow hover:bg-sky-700 flex items-center justify-center disabled:opacity-60"
              @click="triggerQuickPhotoPicker"
              :disabled="quickUploadLoading"
              title="Change profile photo"
            >
              <svg viewBox="0 0 24 24" fill="none" class="h-4 w-4" aria-hidden="true">
                <path d="M4 8h3l1.2-2h7.6L17 8h3v10H4V8Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
                <circle cx="12" cy="13" r="3.5" stroke="currentColor" stroke-width="1.8"/>
              </svg>
            </button>
            <input
              ref="quickPhotoInput"
              type="file"
              accept=".jpg,.jpeg,.png,.webp"
              class="hidden"
              @change="handleQuickProfilePhotoUpload"
            />
          </div>
          <div>
            <h3 class="text-2xl font-bold text-gray-800">{{ fullName }}</h3>
            <p class="text-sm text-gray-500">Service Provider Account</p>
          </div>
        </div>

        <div class="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
          <div class="p-4 rounded-xl bg-gray-50 border border-gray-100">
            <p class="text-xs text-gray-400">Contact Number</p>
            <p class="font-semibold text-gray-800 mt-1">{{ user?.contact_number || 'N/A' }}</p>
          </div>
          <div class="p-4 rounded-xl bg-gray-50 border border-gray-100">
            <p class="text-xs text-gray-400">Email</p>
            <p class="font-semibold text-gray-800 mt-1">{{ user?.email || 'N/A' }}</p>
          </div>
          <div class="p-4 rounded-xl bg-gray-50 border border-gray-100">
            <p class="text-xs text-gray-400">Category</p>
            <p class="font-semibold text-gray-800 mt-1 capitalize">{{ provider?.category || 'N/A' }}</p>
          </div>
          <div class="p-4 rounded-xl bg-gray-50 border border-gray-100">
            <p class="text-xs text-gray-400">Experience</p>
            <p class="font-semibold text-gray-800 mt-1">{{ provider?.experience_years || 0 }} years</p>
          </div>
        </div>

        <div class="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-3">
          <button
            @click="openProfileModal"
            class="w-full bg-sky-600 text-white py-3 rounded-xl shadow hover:bg-sky-700 transition font-semibold"
          >
            Edit Profile
          </button>
          <button
            @click="openProviderModal"
            class="w-full bg-emerald-500 text-white py-3 rounded-xl shadow hover:bg-emerald-600 transition font-semibold"
          >
            Update Service Info
          </button>
        </div>
      </div>

      <div class="bg-white rounded-2xl shadow-lg p-6 space-y-4">
        <h4 class="text-lg font-semibold text-gray-800">Service Provider Details</h4>
        <div class="p-4 rounded-xl border border-gray-100 bg-gray-50">
          <p class="text-xs text-gray-400">Description</p>
          <p class="text-sm text-gray-700 mt-1">{{ provider?.service_description || 'N/A' }}</p>
        </div>
        <div class="p-4 rounded-xl border border-gray-100 bg-white">
          <p class="text-xs text-gray-400">Business</p>
          <p class="font-semibold text-gray-800 mt-1">{{ provider?.business?.business_name || 'N/A' }}</p>
        </div>
        <div v-if="provider?.valid_id" class="p-4 rounded-xl border border-gray-100 bg-white">
          <p class="text-xs text-gray-400">Current Valid ID</p>
          <div class="mt-2 rounded-lg border bg-gray-50 overflow-hidden">
            <img
              v-if="isImageFile(provider.valid_id)"
              :src="fileUrl(provider.valid_id)"
              alt="Valid ID"
              class="w-full max-h-56 object-contain"
            />
            <div v-else class="p-3">
              <p class="text-sm text-gray-700 truncate">{{ fileName(provider.valid_id) }}</p>
            </div>
          </div>
          <button
            type="button"
            class="mt-2 text-sm font-semibold text-sky-700 hover:underline"
            @click="openFile(provider.valid_id)"
          >
            Open File
          </button>
        </div>
      </div>
    </div>

    <!-- EDIT PROFILE MODAL -->
    <div v-if="showProfileModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-2xl p-6 w-full max-w-lg shadow-xl relative">
        <button
          class="absolute top-4 right-4 text-gray-400 hover:text-gray-700 text-xl"
          @click="closeProfileModal"
        >
          &times;
        </button>
        <div class="mb-4">
          <h3 class="text-xl font-bold text-gray-800">Edit Profile</h3>
          <p class="text-sm text-gray-500">Update your account details.</p>
        </div>
        <form @submit.prevent="updateProfile" class="space-y-4">
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div class="flex flex-col sm:col-span-2">
              <label class="text-sm text-gray-600 mb-1">First Name</label>
              <input v-model="userForm.first_name" class="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-sky-100 focus:border-sky-500" />
            </div>
            <div class="flex flex-col">
              <label class="text-sm text-gray-600 mb-1">M.I.</label>
              <input v-model="userForm.middle_initial" maxlength="1" class="w-full border border-gray-200 rounded-lg px-3 py-2 text-center focus:ring-2 focus:ring-sky-100 focus:border-sky-500" />
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div class="flex flex-col">
              <label class="text-sm text-gray-600 mb-1">Last Name</label>
              <input v-model="userForm.last_name" class="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-sky-100 focus:border-sky-500" />
            </div>
            <div class="flex flex-col">
              <label class="text-sm text-gray-600 mb-1">Contact Number</label>
              <input v-model="userForm.contact_number" class="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-sky-100 focus:border-sky-500" />
            </div>
          </div>
          <div class="flex flex-col">
            <label class="text-sm text-gray-600 mb-1">Email (read-only)</label>
            <input v-model="userForm.email" disabled class="w-full border border-gray-100 rounded-lg px-3 py-2 bg-gray-50 text-gray-500 cursor-not-allowed" />
          </div>
          <div>
            <label class="text-sm text-gray-600 mb-1 block">Profile Photo (optional)</label>
            <div class="flex items-center gap-3">
              <label class="px-4 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 text-sm font-semibold text-gray-700 cursor-pointer">
                Choose Image
                <input type="file" accept=".jpg,.jpeg,.png,.webp" @change="handleProfilePhotoUpload" class="hidden" />
              </label>
              <span class="text-sm text-gray-500">
                {{ selectedProfilePhotoName }}
              </span>
            </div>
            <img
              v-if="selectedProfilePreviewUrl"
              :src="selectedProfilePreviewUrl"
              alt="Selected profile"
              class="mt-3 h-20 w-20 rounded-xl object-cover border border-gray-200"
            />
            <img
              v-else-if="avatarUrl"
              :src="avatarUrl"
              alt="Current profile"
              class="mt-3 h-20 w-20 rounded-xl object-cover border border-gray-200"
            />
          </div>
          <div class="flex justify-end gap-2 pt-2">
            <button type="button" @click="closeProfileModal" class="px-4 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 font-semibold text-gray-700">Cancel</button>
            <button type="submit" class="px-4 py-2 rounded-lg bg-sky-600 text-white hover:bg-sky-700 font-semibold">Save Changes</button>
          </div>
        </form>
      </div>
    </div>

    <!-- EDIT SERVICE INFO MODAL -->
    <div v-if="showProviderModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-2xl p-6 w-full max-w-lg shadow-xl relative">
        <button
          class="absolute top-4 right-4 text-gray-400 hover:text-gray-700 text-xl"
          @click="closeProviderModal"
        >
          &times;
        </button>
        <div class="mb-4">
          <h3 class="text-xl font-bold text-gray-800">Update Service Info</h3>
          <p class="text-sm text-gray-500">Update your category and description.</p>
        </div>
        <form @submit.prevent="updateProvider" class="space-y-4">
          <div>
            <label class="text-sm text-gray-600 mb-1 block">Category</label>
            <select v-model="providerForm.category" class="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-sky-100 focus:border-sky-500" required>
              <option value="" disabled>Select Category</option>
              <option value="plumbing">Plumbing</option>
              <option value="siphoning">Siphoning</option>
              <option value="both">Both</option>
            </select>
          </div>
          <div>
            <label class="text-sm text-gray-600 mb-1 block">Experience (years)</label>
            <div class="flex items-center gap-2">
              <button
                type="button"
                @click="adjustExperience(-1)"
                class="w-10 h-10 rounded-lg bg-gray-100 hover:bg-gray-200 font-semibold text-gray-700"
              >
                -
              </button>
              <input
                type="number"
                min="0"
                readonly
                v-model="providerForm.experience_years"
                class="w-full border border-gray-200 rounded-lg px-3 py-2 text-center focus:ring-2 focus:ring-sky-100 focus:border-sky-500"
                required
              />
              <button
                type="button"
                @click="adjustExperience(1)"
                class="w-10 h-10 rounded-lg bg-gray-100 hover:bg-gray-200 font-semibold text-gray-700"
              >
                +
              </button>
            </div>
          </div>
          <div>
            <label class="text-sm text-gray-600 mb-1 block">Service Description</label>
            <textarea v-model="providerForm.service_description" rows="4" class="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-sky-100 focus:border-sky-500" required></textarea>
          </div>
          <div>
            <label class="text-sm text-gray-600 mb-1 block">Location (Latitude / Longitude)</label>
            <div class="grid gap-2 md:grid-cols-2">
              <input
                v-model="providerForm.latitude"
                type="number"
                step="0.000001"
                placeholder="Latitude"
                class="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-sky-100 focus:border-sky-500"
              />
              <input
                v-model="providerForm.longitude"
                type="number"
                step="0.000001"
                placeholder="Longitude"
                class="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-sky-100 focus:border-sky-500"
              />
            </div>
            <div class="mt-2 flex flex-wrap items-center gap-2">
              <button
                type="button"
                class="px-3 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 text-sm font-semibold text-gray-700 disabled:opacity-60"
                :disabled="locationLoading"
                @click="useCurrentLocation"
              >
                {{ locationLoading ? 'Locating...' : 'Use My Location' }}
              </button>
              <p v-if="locationError" class="text-xs text-rose-600">{{ locationError }}</p>
            </div>
            <p class="text-xs text-gray-400 mt-1">Set this so map routes can draw from your location.</p>
          </div>
          <div>
            <label class="text-sm text-gray-600 mb-1 block">Upload Valid ID (optional)</label>
            <div class="flex items-center gap-3">
              <label class="px-4 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 text-sm font-semibold text-gray-700 cursor-pointer">
                Choose File
                <input type="file" accept=".jpg,.jpeg,.png,.pdf" @change="handleFileUpload" class="hidden" />
              </label>
              <span class="text-sm text-gray-500">
                {{ selectedFileName }}
              </span>
            </div>
            <div v-if="selectedFilePreviewUrl" class="mt-3 rounded-lg border bg-gray-50 overflow-hidden">
              <img :src="selectedFilePreviewUrl" alt="Selected Valid ID" class="w-full max-h-56 object-contain" />
            </div>
            <div v-else-if="provider?.valid_id && !selectedFile" class="mt-2 text-sm text-gray-500">
              Current file: {{ fileName(provider.valid_id) }}
              <button type="button" class="ml-2 font-semibold text-sky-700 hover:underline" @click="openFile(provider.valid_id)">View</button>
            </div>
            <p class="text-xs text-gray-400 mt-1">Accepted: JPG, PNG, PDF (max 2MB)</p>
          </div>
          <div class="flex justify-end gap-2 pt-2">
            <button type="button" @click="closeProviderModal" class="px-4 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 font-semibold text-gray-700">Cancel</button>
            <button type="submit" class="px-4 py-2 rounded-lg bg-emerald-600 text-white hover:bg-emerald-700 font-semibold">Save</button>
          </div>
        </form>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, reactive, ref, watch, onBeforeUnmount } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import { resolveStoredFileUrl, stripFileQuery } from '@/lib/file-url'

const props = defineProps({
  user: { type: Object, default: null },
  provider: { type: Object, default: null }
})

const emit = defineEmits(['refresh-data'])

const showProfileModal = ref(false)
const showProviderModal = ref(false)
const selectedFile = ref(null)
const selectedFilePreviewUrl = ref('')
const selectedProfilePhoto = ref(null)
const selectedProfilePreviewUrl = ref('')
const quickPhotoInput = ref(null)
const quickUploadLoading = ref(false)
const locationLoading = ref(false)
const locationError = ref('')

const userForm = reactive({
  first_name: '',
  middle_initial: '',
  last_name: '',
  email: '',
  contact_number: ''
})

const providerForm = reactive({
  category: '',
  experience_years: 0,
  service_description: '',
  latitude: '',
  longitude: ''
})

const syncUser = (u) => {
  if (!u) return
  userForm.first_name = u.first_name || ''
  userForm.middle_initial = u.middle_initial || ''
  userForm.last_name = u.last_name || ''
  userForm.email = u.email || ''
  userForm.contact_number = u.contact_number || ''
}

const syncProvider = (p) => {
  if (!p) return
  providerForm.category = p.category || ''
  providerForm.experience_years = Number(p.experience_years || 0)
  providerForm.service_description = p.service_description || ''
  providerForm.latitude = p.latitude ?? ''
  providerForm.longitude = p.longitude ?? ''
}

watch(() => props.user, (u) => syncUser(u), { immediate: true })
watch(() => props.provider, (p) => syncProvider(p), { immediate: true })

const initials = computed(() => {
  const first = props.user?.first_name?.[0] || 'S'
  const last = props.user?.last_name?.[0] || 'P'
  return `${first}${last}`.toUpperCase()
})

const fullName = computed(() => {
  const middle = props.user?.middle_initial ? `${props.user.middle_initial}. ` : ''
  return `${props.user?.first_name || ''} ${middle}${props.user?.last_name || ''}`.trim()
})

const avatarUrl = computed(() => {
  if (props.user?.profile_photo) return fileUrl(props.user.profile_photo)
  const name = encodeURIComponent(`${props.user?.first_name || 'Service'} ${props.user?.last_name || 'Provider'}`)
  return `https://ui-avatars.com/api/?name=${name}&background=ddd&color=555&size=128`
})

const selectedFileName = computed(() => selectedFile.value?.name || 'No file chosen')
const selectedProfilePhotoName = computed(() => selectedProfilePhoto.value?.name || 'No file chosen')

const openProfileModal = () => { showProfileModal.value = true }
const closeProfileModal = () => {
  showProfileModal.value = false
  clearSelectedProfilePhoto()
}
const openProviderModal = () => { showProviderModal.value = true }
const closeProviderModal = () => {
  showProviderModal.value = false
  clearSelectedFile()
}

const adjustExperience = (delta) => {
  const next = Math.max(0, Number(providerForm.experience_years || 0) + delta)
  providerForm.experience_years = next
}

const fileUrl = (value) => {
  return resolveStoredFileUrl(value, 'valid_ids')
}

const fileName = (value) => {
  if (!value) return ''
  const normalized = stripFileQuery(String(value).replace(/\\/g, '/'))
  return normalized.split('/').pop() || normalized
}

const isImageFile = (value) => {
  if (!value) return false
  const clean = String(value).toLowerCase().split('?')[0].split('#')[0]
  return clean.endsWith('.jpg') || clean.endsWith('.jpeg') || clean.endsWith('.png') || clean.endsWith('.webp') || clean.endsWith('.gif')
}

const openFile = (value) => {
  const url = fileUrl(value)
  if (!url) return
  window.open(url, '_blank', 'noopener')
}

const clearSelectedFile = () => {
  selectedFile.value = null
  if (selectedFilePreviewUrl.value) {
    URL.revokeObjectURL(selectedFilePreviewUrl.value)
    selectedFilePreviewUrl.value = ''
  }
}

const clearSelectedProfilePhoto = () => {
  selectedProfilePhoto.value = null
  if (selectedProfilePreviewUrl.value) {
    URL.revokeObjectURL(selectedProfilePreviewUrl.value)
    selectedProfilePreviewUrl.value = ''
  }
}

const handleFileUpload = (e) => {
  const file = e.target.files?.[0]
  if (!file) return

  const allowedExt = ['jpg', 'jpeg', 'png', 'pdf']
  const ext = file.name.split('.').pop()?.toLowerCase()
  const allowedMime = ['image/jpeg', 'image/png', 'application/pdf']

  if (!allowedExt.includes(ext) && !allowedMime.includes(file.type)) {
    Swal.fire('Invalid File', 'Only JPG, PNG, or PDF files are allowed.', 'warning')
    e.target.value = ''
    clearSelectedFile()
    return
  }

  if (file.size > 2 * 1024 * 1024) {
    Swal.fire('File Too Large', 'Maximum file size is 2MB.', 'warning')
    e.target.value = ''
    clearSelectedFile()
    return
  }

  if (selectedFilePreviewUrl.value) {
    URL.revokeObjectURL(selectedFilePreviewUrl.value)
    selectedFilePreviewUrl.value = ''
  }
  selectedFile.value = file
  if (file.type.startsWith('image/')) {
    selectedFilePreviewUrl.value = URL.createObjectURL(file)
  }
}

const handleProfilePhotoUpload = (e) => {
  const file = e.target.files?.[0]
  if (!file) return

  const allowedExt = ['jpg', 'jpeg', 'png', 'webp']
  const ext = file.name.split('.').pop()?.toLowerCase()
  const allowedMime = ['image/jpeg', 'image/png', 'image/webp']

  if (!allowedExt.includes(ext) && !allowedMime.includes(file.type)) {
    Swal.fire('Invalid File', 'Only JPG, PNG, or WEBP images are allowed.', 'warning')
    e.target.value = ''
    clearSelectedProfilePhoto()
    return
  }

  if (file.size > 2 * 1024 * 1024) {
    Swal.fire('File Too Large', 'Maximum file size is 2MB.', 'warning')
    e.target.value = ''
    clearSelectedProfilePhoto()
    return
  }

  if (selectedProfilePreviewUrl.value) {
    URL.revokeObjectURL(selectedProfilePreviewUrl.value)
  }
  selectedProfilePhoto.value = file
  selectedProfilePreviewUrl.value = URL.createObjectURL(file)
}

const triggerQuickPhotoPicker = () => {
  quickPhotoInput.value?.click?.()
}

const handleQuickProfilePhotoUpload = async (e) => {
  const file = e.target.files?.[0]
  if (!file) return

  const allowedExt = ['jpg', 'jpeg', 'png', 'webp']
  const ext = file.name.split('.').pop()?.toLowerCase()
  const allowedMime = ['image/jpeg', 'image/png', 'image/webp']

  if (!allowedExt.includes(ext) && !allowedMime.includes(file.type)) {
    Swal.fire('Invalid File', 'Only JPG, PNG, or WEBP images are allowed.', 'warning')
    e.target.value = ''
    return
  }

  if (file.size > 2 * 1024 * 1024) {
    Swal.fire('File Too Large', 'Maximum file size is 2MB.', 'warning')
    e.target.value = ''
    return
  }

  try {
    quickUploadLoading.value = true
    const formData = new FormData()
    formData.append('first_name', userForm.first_name || '')
    formData.append('middle_initial', userForm.middle_initial || '')
    formData.append('last_name', userForm.last_name || '')
    formData.append('contact_number', userForm.contact_number || '')
    formData.append('_method', 'PUT')
    formData.append('profile_photo', file)

    await axios.post('/user/profile', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })

    Swal.fire('Saved', 'Profile photo updated.', 'success')
    emit('refresh-data')
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to update profile photo', 'error')
  } finally {
    quickUploadLoading.value = false
    e.target.value = ''
  }
}

const updateProfile = async () => {
  try {
    const formData = new FormData()
    formData.append('first_name', userForm.first_name || '')
    formData.append('middle_initial', userForm.middle_initial || '')
    formData.append('last_name', userForm.last_name || '')
    formData.append('contact_number', userForm.contact_number || '')
    formData.append('_method', 'PUT')
    if (selectedProfilePhoto.value) {
      formData.append('profile_photo', selectedProfilePhoto.value)
    }

    await axios.post('/user/profile', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    Swal.fire('Success', 'Profile updated', 'success')
    closeProfileModal()
    emit('refresh-data')
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to update profile', 'error')
  }
}

const updateProvider = async () => {
  try {
    locationError.value = ''
    const rawLat = String(providerForm.latitude ?? '').trim()
    const rawLng = String(providerForm.longitude ?? '').trim()
    const hasLat = rawLat !== ''
    const hasLng = rawLng !== ''
    if ((hasLat && !hasLng) || (!hasLat && hasLng)) {
      Swal.fire('Missing location', 'Please provide both latitude and longitude.', 'warning')
      return
    }
    const lat = hasLat ? Number(rawLat) : null
    const lng = hasLng ? Number(rawLng) : null
    if (hasLat && (!Number.isFinite(lat) || lat < -90 || lat > 90)) {
      Swal.fire('Invalid latitude', 'Latitude must be between -90 and 90.', 'warning')
      return
    }
    if (hasLng && (!Number.isFinite(lng) || lng < -180 || lng > 180)) {
      Swal.fire('Invalid longitude', 'Longitude must be between -180 and 180.', 'warning')
      return
    }

    const formData = new FormData()
    formData.append('category', providerForm.category)
    formData.append('experience_years', providerForm.experience_years)
    formData.append('service_description', providerForm.service_description)
    if (hasLat && hasLng) {
      formData.append('latitude', String(lat))
      formData.append('longitude', String(lng))
    }
    if (selectedFile.value) formData.append('valid_id', selectedFile.value)

    await axios.post('/service-provider/update', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    Swal.fire('Success', 'Service info updated', 'success')
    closeProviderModal()
    emit('refresh-data')
  } catch (err) {
    Swal.fire('Error', err.response?.data?.message || 'Failed to update service info', 'error')
  }
}

const useCurrentLocation = () => {
  locationError.value = ''
  if (!navigator?.geolocation) {
    locationError.value = 'Geolocation is not supported in this browser.'
    return
  }
  locationLoading.value = true
  navigator.geolocation.getCurrentPosition(
    (pos) => {
      providerForm.latitude = Number(pos.coords.latitude).toFixed(6)
      providerForm.longitude = Number(pos.coords.longitude).toFixed(6)
      locationLoading.value = false
    },
    (err) => {
      locationError.value = err?.message || 'Unable to retrieve location.'
      locationLoading.value = false
    },
    { enableHighAccuracy: true, timeout: 15000, maximumAge: 0 }
  )
}

onBeforeUnmount(() => {
  if (selectedProfilePreviewUrl.value) {
    URL.revokeObjectURL(selectedProfilePreviewUrl.value)
  }
  if (selectedFilePreviewUrl.value) {
    URL.revokeObjectURL(selectedFilePreviewUrl.value)
  }
})
</script>

