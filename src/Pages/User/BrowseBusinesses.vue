<template>
  <div class="rounded-2xl border border-gray-200 bg-white p-4 sm:p-5">
    <div v-if="showHeader" class="mb-3.5 flex items-center justify-between gap-3">
      <div>
        <h3 class="text-[1.05rem] font-bold text-slate-900">Nearby Businesses</h3>
        <p class="text-xs text-slate-500">Nearest badge appears when a business is within your range.</p>
      </div>
    </div>

    <div class="my-2 mb-4 flex flex-wrap items-center gap-3">
      <div class="text-xs font-semibold text-slate-400" v-if="!hasUserLocation">
        Location not available. Nearest is hidden.
      </div>
      <div class="text-xs font-semibold text-slate-400" v-else-if="requestLocked">
        {{ lockMessage }}
      </div>
      <div class="text-xs font-semibold text-teal-700" v-else-if="inRangeBusinesses.length">
        Nearest business within {{ rangeKm }} km.
      </div>
      <div class="text-xs font-semibold text-slate-400" v-else>
        No businesses within {{ rangeKm }} km.
      </div>
    </div>
    <!-- BUSINESS CARDS GRID -->
    <div v-if="sortedBusinesses.length" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="b in sortedBusinesses"
        :key="b.id"
        @click="openBusinessModal(b)"
        class="cursor-pointer rounded-2xl border border-gray-200 bg-white p-4 shadow-sm transition hover:-translate-y-0.5 hover:shadow-lg"
      >
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center">
            <img
              :src="`https://ui-avatars.com/api/?name=${b.business_name}&background=ddd&color=555&size=64`"
              class="w-12 h-12 rounded-full mr-3"
            />
            <div>
              <h3 class="text-lg font-bold tracking-tight text-gray-800">{{ b.business_name }}</h3>
              <p class="text-gray-500 text-sm">Owner: {{ b.owner_name }}</p>
            </div>
          </div>
          <span
            v-if="hasUserLocation && nearestInRangeId !== null && businessIdentity(b.id) === nearestInRangeId"
            class="rounded-full bg-cyan-50 px-2 py-1 text-[0.7rem] font-bold text-cyan-700"
          >Nearest</span>
          <span
            v-else-if="hasUserLocation && b.has_location && b.distance_km !== null && b.distance_km <= rangeKm"
            class="rounded-full bg-emerald-50 px-2 py-1 text-[0.7rem] font-bold text-emerald-700"
          >Near</span>
          <span
            v-else-if="hasUserLocation && b.has_location && (b.distance_km === null || b.distance_km > rangeKm)"
            class="ml-1.5 rounded-full border border-orange-200 bg-orange-50 px-1.5 py-0.5 text-[0.7rem] font-semibold text-orange-500"
          >Far</span>
          <span
            v-else-if="!b.has_location"
            class="ml-1.5 rounded-full border border-orange-200 bg-orange-50 px-1.5 py-0.5 text-[0.7rem] font-semibold text-orange-500"
          >No location</span>
        </div>
        <div class="mt-1.5 flex flex-wrap gap-1.5">
          <span class="rounded-full bg-indigo-100 px-2.5 py-1 text-xs font-semibold text-indigo-700">{{ b.category }}</span>
          <span class="rounded-full bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600">{{ b.business_type }}</span>
        </div>
        <div class="mt-3 inline-flex rounded-full border border-amber-100 bg-amber-50 px-2.5 py-1 text-[0.72rem] font-semibold text-amber-700">
          {{ reviewSummaryLabel(b) }}
        </div>
      </div>
    </div>

    <p v-else class="text-gray-500 italic text-center mt-10">No registered businesses available.</p>

    <!-- BUSINESS DETAILS MODAL -->
    <transition enter-active-class="transition-opacity duration-200" enter-from-class="opacity-0" enter-to-class="opacity-100" leave-active-class="transition-opacity duration-200" leave-from-class="opacity-100" leave-to-class="opacity-0">
      <div v-if="showBusinessModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
        <div class="max-h-[calc(100vh-3rem)] overflow-auto bg-white rounded-2xl shadow-2xl w-full max-w-3xl p-5 sm:p-8 relative space-y-6">
          <button
            @click="closeBusinessModal"
            class="absolute top-4 right-5 text-gray-400 hover:text-gray-700 text-2xl font-bold"
          >&times;</button>

          <div class="flex items-center gap-4">
            <img
              :src="`https://ui-avatars.com/api/?name=${selectedBusiness.business_name}&background=ddd&color=555&size=96`"
              class="w-16 h-16 rounded-full border border-gray-200 bg-white"
            />
            <div class="flex-1">
              <h3 class="text-xl sm:text-2xl font-extrabold tracking-tight text-gray-800">{{ selectedBusiness.business_name }}</h3>
              <p class="text-sm text-gray-500">Owner: {{ selectedBusiness.owner_name }}</p>
            </div>
            <div class="flex gap-2">
              <span class="rounded-full bg-indigo-100 px-2.5 py-1 text-xs font-semibold text-indigo-700">{{ selectedBusiness.category }}</span>
              <span class="rounded-full bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600">{{ selectedBusiness.business_type }}</span>
            </div>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-gray-700">
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Address</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.address }}</p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Address Unit</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.address_unit || '-' }}</p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Street</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.address_street || '-' }}</p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Barangay</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.address_barangay || '-' }}</p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">City</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.address_city || '-' }}</p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Province</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.address_province || '-' }}</p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Postal</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.address_postal || '-' }}</p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Contact</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.contact_number }}</p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Business Ownership</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.business_ownership || '-' }}</p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Management Flow</p>
              <p class="text-sm font-semibold text-slate-900">{{ managementModeLabel }}</p>
              <p v-if="hasSelectedBusinessFixedPrice" class="mt-1 text-xs font-semibold text-teal-700">
                Fixed Price: {{ money(selectedBusinessFixedPrice) }}
              </p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Years in Operation</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.years_in_operation || '-' }}</p>
            </div>
            <div class="rounded-xl border border-gray-200 bg-white p-3" v-if="selectedBusiness.services && selectedBusiness.services.length">
              <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Services</p>
              <p class="text-sm text-slate-900">{{ selectedBusiness.services.join(', ') }}</p>
            </div>
          </div>

          <div class="rounded-xl border border-amber-100 bg-amber-50/70 p-4">
            <div class="flex flex-wrap items-start justify-between gap-3">
              <div>
                <p class="text-xs font-semibold uppercase tracking-wide text-amber-700">Customer Feedback</p>
                <p class="mt-1 text-sm text-slate-600">Visible to other customers after successful completion.</p>
              </div>
              <span class="inline-flex rounded-full bg-white px-3 py-1 text-xs font-semibold text-amber-700 shadow-sm">
                {{ reviewSummaryLabel(selectedBusiness) }}
              </span>
            </div>
            <div v-if="recentReviewsForBusiness(selectedBusiness).length" class="mt-4 space-y-3">
              <article
                v-for="review in recentReviewsForBusiness(selectedBusiness).slice(0, 3)"
                :key="review.id || `${review.user_name}-${review.submitted_at}`"
                class="rounded-lg border border-amber-100 bg-white p-3 shadow-sm"
              >
                <div class="flex flex-wrap items-center justify-between gap-2">
                  <p class="text-sm font-semibold text-slate-900">{{ review.user_name || 'Customer' }}</p>
                  <p class="text-xs text-slate-500">{{ formatDateTime(review.submitted_at) }}</p>
                </div>
                <p class="mt-1 text-xs font-semibold text-amber-700">Rating: {{ Number(review.rating || 0) }}/5</p>
                <p v-if="review.feedback" class="mt-1 whitespace-pre-wrap text-sm text-slate-700">{{ review.feedback }}</p>
              </article>
            </div>
            <p v-else class="mt-3 text-sm text-slate-600">No customer reviews yet.</p>
          </div>

          <div v-if="selectedBusiness.latitude && selectedBusiness.longitude" class="rounded-xl border border-gray-200 bg-white p-3">
            <p class="mb-1 text-xs uppercase tracking-wide text-slate-400">Location Map</p>
            <iframe
              :src="mapEmbed(selectedBusiness.latitude, selectedBusiness.longitude)"
              class="w-full h-56 rounded-lg border"
              loading="lazy"
            ></iframe>
          </div>

          <button
            v-if="enableRequest"
            @click="openRequestModal(selectedBusiness)"
            class="mt-2 w-full bg-teal-600 text-white py-3 rounded-xl hover:bg-teal-700 font-semibold transition disabled:opacity-50"
            :disabled="lockedForSelected"
          >
            {{ lockedForSelected ? 'Request Locked' : 'Request Service' }}
          </button>
          <button
            v-if="hasPendingForSelected"
            @click="cancelPendingRequest"
            class="mt-2 w-full bg-rose-50 text-rose-700 py-3 rounded-xl hover:bg-rose-100 font-semibold transition"
          >
            Cancel Request
          </button>
        </div>
      </div>
    </transition>

    <!-- REQUEST SERVICE MODAL -->
    <transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0 scale-95" enter-to-class="opacity-100 scale-100" leave-active-class="transition duration-200 ease-in" leave-from-class="opacity-100 scale-100" leave-to-class="opacity-0 scale-95">
      <div v-if="showRequestModal && enableRequest" class="fixed inset-0 bg-black/60 flex items-start md:items-center justify-center z-50 p-3 md:p-4 overflow-y-auto">
        <div class="max-h-[calc(100vh-1.5rem)] overflow-y-auto bg-white rounded-2xl shadow-2xl w-full max-w-2xl p-5 sm:p-8 relative space-y-6 transform transition-transform duration-300 scale-95 opacity-0"
             :class="{'scale-100 opacity-100': showRequestModal}"
             ref="requestModalRef">

          <button
            @click="closeRequestModal"
            class="absolute top-4 right-5 text-gray-400 hover:text-gray-700 text-2xl font-bold"
          >&times;</button>

          <div class="flex items-center justify-between border-b pb-3">
            <div>
              <h3 class="text-xl md:text-2xl font-extrabold tracking-tight text-gray-800">Request Service</h3>
              <p class="text-sm text-gray-500 mt-1">{{ selectedBusiness.business_name }}</p>
            </div>
            <div class="hidden md:flex gap-2">
              <span class="rounded-full bg-indigo-100 px-2.5 py-1 text-xs font-semibold text-indigo-700">{{ selectedBusiness.category }}</span>
              <span class="rounded-full bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600">{{ selectedBusiness.business_type }}</span>
            </div>
          </div>

          <form @submit.prevent="submitServiceRequest" class="space-y-5">

            <!-- SERVICE TYPE -->
            <div>
              <label class="block text-gray-700 font-semibold mb-2">Service Type</label>
              <select
                v-model="requestForm.service_type"
                :disabled="isServiceTypeFixed"
                class="w-full border border-gray-300 py-3 px-3 rounded-lg focus:border-teal-600 focus:ring-2 focus:ring-teal-100 disabled:bg-gray-100 disabled:cursor-not-allowed"
              >
                <option disabled value="">Select Service</option>
                <option
                  v-for="service in serviceTypeOptions"
                  :key="`svc-${service}`"
                  :value="service"
                >
                  {{ service }}
                </option>
              </select>
            </div>

            <!-- USER ADDRESS -->
            <div class="space-y-3">
              <label class="block text-gray-700 font-semibold">Your Address</label>
              <input
                v-model="requestForm.address_line"
                placeholder="House No., Street, Subdivision, Purok"
                class="w-full border border-gray-300 py-3 outline-none focus:border-teal-600 focus:ring-2 focus:ring-teal-100 rounded-lg px-3"
                ref="addressInput"
              />
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <select
                  v-model="requestForm.province"
                  disabled
                  class="w-full border border-gray-300 py-3 px-3 rounded-lg bg-gray-100 cursor-not-allowed"
                >
                  <option disabled value="">Select Province</option>
                  <option v-for="name in provinceOptions" :key="`prov-${name}`" :value="name">
                    {{ name }}
                  </option>
                </select>
                <select
                  v-model="requestForm.city"
                  :disabled="!requestForm.province"
                  class="w-full border border-gray-300 py-3 px-3 rounded-lg focus:border-teal-600 focus:ring-2 focus:ring-teal-100 disabled:bg-gray-100 disabled:cursor-not-allowed"
                >
                  <option disabled value="">Select City / Municipality</option>
                  <option v-for="name in cityOptions" :key="`city-${name}`" :value="name">
                    {{ name }}
                  </option>
                </select>
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <select
                  v-model="requestForm.barangay"
                  :disabled="!requestForm.city"
                  class="w-full border border-gray-300 py-3 px-3 rounded-lg focus:border-teal-600 focus:ring-2 focus:ring-teal-100 disabled:bg-gray-100 disabled:cursor-not-allowed"
                >
                  <option disabled value="">Select Barangay</option>
                  <option v-for="name in barangayOptions" :key="`brgy-${name}`" :value="name">
                    {{ name }}
                  </option>
                </select>
                <input
                  v-model="requestForm.postal_code"
                  maxlength="10"
                  placeholder="ZIP Code"
                  class="w-full border border-gray-300 py-3 outline-none focus:border-teal-600 focus:ring-2 focus:ring-teal-100 rounded-lg px-3"
                />
              </div>
              <p v-if="barangayLoading" class="text-xs text-gray-400">Loading barangays...</p>
              <p v-else-if="requestForm.city && !barangayOptions.length" class="text-xs text-amber-600">
                No barangay data found for selected city. Please reselect city.
              </p>
              <p v-else-if="requestForm.city && barangayOptions.length" class="text-xs text-teal-700 font-semibold">
                Barangays loaded: {{ barangayOptions.length }}
              </p>
              <p class="text-xs text-gray-400">Select Cavite city/municipality first, then barangay. ZIP is auto-filled.</p>
            </div>

            <!-- CONTACT NUMBER -->
            <div>
              <label class="block text-gray-700 font-semibold mb-2">Contact Number</label>
              <input v-model="requestForm.contact_number"
                     readonly
                     class="w-full border border-gray-200 py-3 bg-gray-100 cursor-not-allowed rounded-lg px-3"
              />
            </div>

            <!-- PROBLEM DESCRIPTION -->
            <div>
              <label class="block text-gray-700 font-semibold mb-2">
                Problem Description <span class="text-sm text-gray-400">(max 200 characters)</span>
              </label>
              <textarea v-model="requestForm.description"
                        placeholder="Enter additional details"
                        maxlength="200"
                        class="w-full border border-gray-300 py-3 outline-none focus:border-teal-600 focus:ring-2 focus:ring-teal-100 rounded-lg px-3 resize-none"
                        @input="updateDescriptionCount"
              ></textarea>
              <p class="text-right text-sm text-gray-400">{{ descriptionCount }}/200</p>
            </div>

            <div>
              <label class="block text-gray-700 font-semibold mb-2">Preferred Time</label>
              <select
                v-model="requestForm.preferred_time"
                class="w-full border border-gray-300 py-3 px-3 rounded-lg focus:border-teal-600 focus:ring-2 focus:ring-teal-100"
                :disabled="!availableTimeSlots.length"
              >
                <option disabled value="">{{ availableTimeSlots.length ? 'Select Time' : 'No slots available' }}</option>
                <option v-for="slot in availableTimeSlots" :key="slot" :value="slot" :disabled="blockedTimes.includes(slot)">
                  {{ formatTimeLabel(slot) }}{{ blockedTimes.includes(slot) ? ' (Booked)' : '' }}
                </option>
              </select>
              <p v-if="blockedTimesLoading" class="mt-1 text-xs text-gray-400">Checking availability...</p>
              <p v-else-if="isPreferredTimeBlocked" class="mt-1 text-xs text-rose-600">Selected time is already booked.</p>
              <p v-else-if="blockedTimes.length" class="mt-1 text-xs text-amber-600">Some times are already booked for this date.</p>
              <p v-else-if="scheduleNotice" class="mt-1 text-xs text-slate-500">{{ scheduleNotice }}</p>
            </div>

            <!-- PAYMENT CHOICE + OPTIONAL DOWNPAYMENT -->
            <div>
              <label class="block text-gray-700 font-semibold mb-2">Payment Method</label>
              <select
                v-model="requestForm.payment_choice"
                class="w-full border border-gray-300 py-3 px-3 rounded-lg focus:border-teal-600 focus:ring-2 focus:ring-teal-100"
              >
                <option disabled value="">Select Payment Method</option>
                <option value="cash">Cash</option>
                <option value="card">Card</option>
                <option value="e_wallet">E-wallet</option>
              </select>
            </div>

            <div>
              <label class="block text-gray-700 font-semibold mb-2">Downpayment (Optional)</label>
              <select
                v-model="requestForm.downpayment_opt_in"
                class="w-full border border-gray-300 py-3 px-3 rounded-lg focus:border-teal-600 focus:ring-2 focus:ring-teal-100"
              >
                <option :value="false">No</option>
                <option :value="true">Yes</option>
              </select>
            </div>

            <div v-if="requestForm.downpayment_opt_in">
              <label class="block text-gray-700 font-semibold mb-2">Downpayment Amount (PHP)</label>
              <input
                v-model.number="requestForm.downpayment_amount"
                type="number"
                min="1"
                :max="MAX_DOWNPAYMENT_AMOUNT"
                step="0.01"
                placeholder="Optional advance payment amount"
                class="w-full border border-gray-300 py-3 outline-none focus:border-teal-600 focus:ring-2 focus:ring-teal-100 rounded-lg px-3"
              />
              <p class="text-xs text-gray-500 mt-1">
                You can skip downpayment, or enter any amount if you want to pay in advance.
              </p>
            </div>

            <div
              v-if="requestForm.downpayment_opt_in"
              class="rounded-xl border border-amber-200 bg-amber-50 p-4"
            >
              <p class="text-sm font-semibold text-amber-900">Warning: Downpayment Terms</p>
              <p class="mt-1 text-sm text-amber-700">
                Booking is for survey/inspection first. Downpayment is optional and will be logged as advance payment.
                If cancelled after dispatch, cancellation policy applies.
              </p>
            </div>

            <div>
              <label class="block text-gray-700 font-semibold mb-2">Notes / Landmark (Optional)</label>
              <textarea
                v-model="requestForm.landmark_notes"
                placeholder="Ex: Landmark, gate color, nearest tricycle terminal"
                maxlength="200"
                class="w-full border border-gray-300 py-3 outline-none focus:border-teal-600 focus:ring-2 focus:ring-teal-100 rounded-lg px-3 resize-none"
              ></textarea>
            </div>

            <div>
              <label class="block text-gray-700 font-semibold mb-2">Photo Attachment (Optional)</label>
              <input
                type="file"
                multiple
                accept="image/*"
                @change="onSurveyPhotosChange"
                class="w-full border border-gray-300 py-2.5 px-3 rounded-lg focus:border-teal-600 focus:ring-2 focus:ring-teal-100"
              />
              <p class="text-xs text-gray-500 mt-1">You can upload up to 5 photos for initial survey reference.</p>
            </div>

            <!-- PREFERRED DATE -->
            <div>
              <label class="block text-gray-700 font-semibold mb-2">Preferred Date</label>
              <div class="relative">
                <input
                  ref="dateInputRef"
                  type="date"
                  v-model="requestForm.preferred_date"
                  :min="minDate"
                  :max="maxDate"
                  class="w-full border border-gray-300 py-3 pr-12 outline-none focus:border-teal-600 focus:ring-2 focus:ring-teal-100 rounded-lg px-3"
                />
                <button
                  type="button"
                  @click="openDatePicker"
                  class="absolute inset-y-0 right-3 my-auto h-8 w-8 rounded-md text-gray-500 hover:text-teal-700 hover:bg-teal-50"
                  aria-label="Open date picker"
                >
                  📅
                </button>
              </div>
              <p class="text-xs text-gray-400 mt-1">Only available dates from today until end of current month are allowed.</p>
            </div>

            <!-- MAP LINK -->
            <div v-if="selectedBusiness.latitude && selectedBusiness.longitude" class="text-sm">
              <a :href="mapLink(selectedBusiness.latitude, selectedBusiness.longitude)"
                 target="_blank"
                 class="text-teal-700 hover:underline font-semibold"
              >View Business Location</a>
            </div>

            <!-- ACTION BUTTONS -->
            <div class="flex justify-end gap-4 mt-6">
              <button type="button"
                      @click="closeRequestModal"
                      class="px-5 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 font-semibold text-gray-700">
                Cancel
              </button>
              <button type="submit"
                      class="px-5 py-2 rounded-lg bg-teal-600 text-white hover:bg-teal-700 font-semibold disabled:opacity-50"
                      :disabled="!requestForm.service_type || !requestForm.address_line || !requestForm.barangay || !requestForm.city || !requestForm.province || !requestForm.postal_code || !requestForm.preferred_date || !requestForm.preferred_time || !requestForm.contact_number || !requestForm.payment_choice || (requestForm.downpayment_opt_in && (!requestForm.downpayment_amount || Number(requestForm.downpayment_amount) <= 0 || Number(requestForm.downpayment_amount) > MAX_DOWNPAYMENT_AMOUNT))"
              >
                Submit Request
              </button>
            </div>

          </form>
        </div>
      </div>
    </transition>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick, computed, watch } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'

const props = defineProps({
  showHeader: { type: Boolean, default: true },
  businesses: { type: Array, default: null },
  authUser: { type: Object, default: null },
  enableRequest: { type: Boolean, default: true },
  fetchBusinesses: { type: Boolean, default: true },
  requestLocked: { type: Boolean, default: false },
  lockMessage: { type: String, default: 'You already have an active service request.' },
  pendingRequest: { type: Object, default: null }
})
const emit = defineEmits(['request-submitted', 'request-cancelled'])

// State
const businesses = ref([])
const rangeKm = ref(10)
const authUser = reactive({
  id: null,
  first_name: '',
  middle_initial: '',
  last_name: '',
  email: '',
  contact_number: '',
  latitude: null,
  longitude: null,
  address: ''
})

const toRad = (v) => (v * Math.PI) / 180
const parseCoord = (value) => {
  if (value === null || value === undefined || value === '') return null
  const num = Number(value)
  return Number.isFinite(num) ? num : null
}
const isValidLatLng = (lat, lng) => {
  if (lat === null || lng === null) return false
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return false
  // Treat (0,0) as missing location in this app context.
  if (lat === 0 && lng === 0) return false
  return true
}
const distanceKm = (lat1, lon1, lat2, lon2) => {
  const R = 6371
  const dLat = toRad(lat2 - lat1)
  const dLon = toRad(lon2 - lon1)
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2)
  return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

const sortedBusinesses = computed(() => {
  const userLat = parseCoord((props.authUser || authUser).latitude)
  const userLng = parseCoord((props.authUser || authUser).longitude)
  const userHasLoc = isValidLatLng(userLat, userLng)
  const list = (props.businesses ?? businesses.value).map(b => {
    const lat = parseCoord(b.latitude)
    const lng = parseCoord(b.longitude)
    const hasLoc = userHasLoc && isValidLatLng(lat, lng)
    return {
      ...b,
      distance_km: hasLoc ? distanceKm(userLat, userLng, lat, lng) : null,
      has_location: isValidLatLng(lat, lng)
    }
  })
  return list.sort((a, b) => {
    if (a.distance_km === null && b.distance_km === null) return 0
    if (a.distance_km === null) return 1
    if (b.distance_km === null) return -1
    return a.distance_km - b.distance_km
  })
})

const inRangeBusinesses = computed(() => {
  const max = Number(rangeKm.value || 0)
  return sortedBusinesses.value.filter(b => b.distance_km !== null && b.distance_km <= max)
})

const businessIdentity = (value) => String(value ?? '').trim()

const nearestInRangeId = computed(() => {
  if (!hasUserLocation.value) return null
  const max = Number(rangeKm.value || 0)
  const inRange = sortedBusinesses.value.filter(
    b => b.distance_km !== null && b.distance_km <= max
  )
  return inRange.length ? businessIdentity(inRange[0].id) : null
})

const hasUserLocation = computed(() => {
  const lat = parseCoord((props.authUser || authUser).latitude)
  const lng = parseCoord((props.authUser || authUser).longitude)
  return isValidLatLng(lat, lng)
})

const formatDateTime = (value) => {
  if (!value) return 'N/A'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return 'N/A'
  return d.toLocaleString()
}

const reviewSummaryForBusiness = (business = {}) => {
  const summary = business?.review_summary || {}
  const reviewCount = Math.max(0, Math.trunc(Number(summary.review_count ?? business?.review_count ?? 0) || 0))
  const averageRating = Number(summary.average_rating ?? business?.average_rating ?? 0)
  return {
    review_count: reviewCount,
    average_rating: Number.isFinite(averageRating) ? averageRating : 0,
    latest_review_at: String(summary.latest_review_at || business?.latest_review_at || '').trim(),
  }
}

const recentReviewsForBusiness = (business = {}) => {
  if (Array.isArray(business?.recent_reviews)) return business.recent_reviews
  if (Array.isArray(business?.reviews)) return business.reviews
  return []
}

const reviewSummaryLabel = (business = {}) => {
  const summary = reviewSummaryForBusiness(business)
  if (!summary.review_count) return 'No reviews yet'
  return `${summary.average_rating.toFixed(1)}/5 from ${summary.review_count} review${summary.review_count === 1 ? '' : 's'}`
}

// Modals
const showBusinessModal = ref(false)
const showRequestModal = ref(false)
const selectedBusiness = reactive({})
const requestForm = reactive({
  service_type: '',
  contact_number: '',
  address_line: '',
  barangay: '',
  city: '',
  province: '',
  postal_code: '',
  description: '',
  preferred_time: '',
  preferred_date: '',
  payment_choice: '',
  downpayment_opt_in: false,
  downpayment_amount: null,
  landmark_notes: '',
  survey_photos: [],
})
const blockedTimes = ref([])
const blockedTimesLoading = ref(false)
const scheduleCache = ref({})
const businessSchedule = reactive({
  date: '',
  time_from: '',
  time_to: '',
})
const MAX_DOWNPAYMENT_AMOUNT = 999999
const MANAGEMENT_FLOW_LABELS = Object.freeze({
  hr: 'HR-Managed',
  business: 'Business-Managed',
})
const MANAGEMENT_FLOW_PRICES = Object.freeze({
  hr: 3500,
  business: 3000,
})

const normalizeManagementMode = (value) => String(value || '').trim().toLowerCase()
const selectedBusinessManagementMode = computed(() => normalizeManagementMode(selectedBusiness.management_mode))
const selectedBusinessFixedPrice = computed(() => {
  const raw = Number(selectedBusiness.fixed_price)
  if (Number.isFinite(raw) && raw > 0) return raw
  const mode = selectedBusinessManagementMode.value
  if (Object.prototype.hasOwnProperty.call(MANAGEMENT_FLOW_PRICES, mode)) {
    return MANAGEMENT_FLOW_PRICES[mode]
  }
  return null
})
const hasSelectedBusinessFixedPrice = computed(() => selectedBusinessFixedPrice.value !== null)
const managementModeLabel = computed(() =>
  MANAGEMENT_FLOW_LABELS[selectedBusinessManagementMode.value] || 'Not set'
)
const timeSlots = ['06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00']
const formatTimeLabel = (value) => {
  const raw = String(value || '').trim()
  const match = raw.match(/^(\d{1,2}):(\d{2})$/)
  if (!match) return raw
  const hours = Number(match[1])
  const minutes = Number(match[2])
  if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return raw
  const suffix = hours >= 12 ? 'PM' : 'AM'
  const h12 = hours % 12 || 12
  return `${h12}:${String(minutes).padStart(2, '0')} ${suffix}`
}
const parseMinutes = (value) => {
  const raw = String(value || '').trim()
  const match = raw.match(/^(\d{1,2}):(\d{2})$/)
  if (!match) return null
  const hours = Number(match[1])
  const minutes = Number(match[2])
  if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return null
  return hours * 60 + minutes
}
const buildTimeSlotsFromSchedule = (timeFrom, timeTo) => {
  const start = parseMinutes(timeFrom)
  const end = parseMinutes(timeTo)
  if (start === null || end === null || end <= start) return []
  const slots = []
  for (let minutes = start; minutes <= end; minutes += 60) {
    const hours = Math.floor(minutes / 60)
    const mins = minutes % 60
    slots.push(`${String(hours).padStart(2, '0')}:${String(mins).padStart(2, '0')}`)
  }
  return slots
}
const hasScheduleWindow = computed(() =>
  String(businessSchedule.date || '').trim() !== '' &&
  String(businessSchedule.time_from || '').trim() !== '' &&
  String(businessSchedule.time_to || '').trim() !== ''
)
const scheduleNotice = computed(() => {
  if (!hasScheduleWindow.value) {
    return 'Team schedule not available. Please choose another business.'
  }
  if (requestForm.preferred_date && requestForm.preferred_date !== businessSchedule.date) {
    return `Available schedule is on ${businessSchedule.date} (${formatTimeLabel(businessSchedule.time_from)} - ${formatTimeLabel(businessSchedule.time_to)}).`
  }
  return ''
})
const availableTimeSlots = computed(() => {
  if (!hasScheduleWindow.value) return []
  if (requestForm.preferred_date && requestForm.preferred_date !== businessSchedule.date) return []
  const slots = buildTimeSlotsFromSchedule(businessSchedule.time_from, businessSchedule.time_to)
  return slots.length ? slots : timeSlots
})
const isPreferredTimeBlocked = computed(() => {
  const timeValue = String(requestForm.preferred_time || '').trim()
  if (!timeValue) return false
  return blockedTimes.value.includes(timeValue)
})
const money = (value) => new Intl.NumberFormat('en-PH', {
  style: 'currency',
  currency: 'PHP',
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
}).format(Number(value || 0))

const businessCategory = computed(() =>
  String(selectedBusiness.category || '').trim().toLowerCase()
)

const serviceTypeOptions = computed(() => {
  if (businessCategory.value === 'both') {
    return ['Plumbing', 'Siphoning']
  }

  if (businessCategory.value === 'plumbing') return ['Plumbing']
  if (businessCategory.value === 'siphoning') return ['Siphoning']

  const raw = String(selectedBusiness.category || '').trim()
  return raw ? [raw] : ['Plumbing', 'Siphoning']
})

const isServiceTypeFixed = computed(() => serviceTypeOptions.value.length === 1)

const normalizeText = (value) => String(value || '').trim()
const normalizeKey = (value) =>
  normalizeText(value)
    .toLowerCase()
    .replace(/^city of\s+/i, '')
    .replace(/[.\-]/g, '')
    .replace(/\s+/g, ' ')
    .trim()

const CAVITE_PROVINCE = 'Cavite'
const CAVITE_LGUS = [
  { code: '042101000', type: 'municipality', name: 'Alfonso', zip: '4123' },
  { code: '042102000', type: 'municipality', name: 'Amadeo', zip: '4119' },
  { code: '042103000', type: 'city', name: 'Bacoor', zip: '4102' },
  { code: '042104000', type: 'municipality', name: 'Carmona', zip: '4116' },
  { code: '042105000', type: 'city', name: 'Cavite City', zip: '4100' },
  { code: '042106000', type: 'city', name: 'Dasmarinas', zip: '4114' },
  { code: '042107000', type: 'municipality', name: 'General Emilio Aguinaldo', zip: '4124' },
  { code: '042108000', type: 'city', name: 'General Trias', zip: '4107' },
  { code: '042109000', type: 'city', name: 'Imus', zip: '4103' },
  { code: '042110000', type: 'municipality', name: 'Indang', zip: '4122' },
  { code: '042111000', type: 'municipality', name: 'Kawit', zip: '4104' },
  { code: '042112000', type: 'municipality', name: 'Magallanes', zip: '4113' },
  { code: '042113000', type: 'municipality', name: 'Maragondon', zip: '4112' },
  { code: '042114000', type: 'municipality', name: 'Mendez', zip: '4121' },
  { code: '042115000', type: 'municipality', name: 'Naic', zip: '4110' },
  { code: '042116000', type: 'municipality', name: 'Noveleta', zip: '4105' },
  { code: '042117000', type: 'municipality', name: 'Rosario', zip: '4106' },
  { code: '042118000', type: 'municipality', name: 'Silang', zip: '4118' },
  { code: '042119000', type: 'city', name: 'Tagaytay', zip: '4120' },
  { code: '042120000', type: 'municipality', name: 'Tanza', zip: '4108' },
  { code: '042121000', type: 'municipality', name: 'Ternate', zip: '4111' },
  { code: '042122000', type: 'city', name: 'Trece Martires', zip: '4109' },
  { code: '042123000', type: 'municipality', name: 'General Mariano Alvarez', zip: '4117' },
]

const findCaviteLguByName = (rawName) => {
  const key = normalizeKey(rawName)
  return CAVITE_LGUS.find((lgu) => normalizeKey(lgu.name) === key) || null
}

const provinceOptions = computed(() => [CAVITE_PROVINCE])

const cityOptions = computed(() => {
  if (normalizeKey(requestForm.province) !== normalizeKey(CAVITE_PROVINCE)) return []
  return CAVITE_LGUS.map((lgu) => lgu.name).sort((a, b) => a.localeCompare(b))
})

const selectedCaviteLgu = computed(() => findCaviteLguByName(requestForm.city))
const barangaysByLguCode = ref({})
const barangayLoading = ref(false)
const normalizeBarangayRows = (rows) =>
  (Array.isArray(rows) ? rows : [])
    .map((r) => normalizeText(r?.name))
    .filter(Boolean)

const selectedCityBarangays = computed(() => {
  const code = selectedCaviteLgu.value?.code
  if (!code) return []
  return barangaysByLguCode.value[code] || []
})

const fallbackBarangaysFromBusinesses = computed(() => {
  const cityKey = normalizeKey(requestForm.city)
  const provinceKey = normalizeKey(requestForm.province)
  const set = new Set()
  ;(Array.isArray(businesses.value) ? businesses.value : []).forEach((b) => {
    const bCity = normalizeKey(b?.address_city)
    const bProvince = normalizeKey(b?.address_province)
    const bBarangay = normalizeText(b?.address_barangay)
    if (bBarangay && bCity === cityKey && bProvince === provinceKey) {
      set.add(bBarangay)
    }
  })
  return Array.from(set).sort((a, b) => a.localeCompare(b))
})

const barangayOptions = computed(() => {
  const base = selectedCityBarangays.value.length ? selectedCityBarangays.value : fallbackBarangaysFromBusinesses.value
  const set = new Set((base || []).map((v) => normalizeText(v)).filter(Boolean))
  if (requestForm.barangay) set.add(requestForm.barangay)
  return Array.from(set).sort((a, b) => a.localeCompare(b))
})

const fetchBarangaysByLgu = async (lgu) => {
  // Primary source: local backend proxy (avoids browser CORS issues).
  try {
    const res = await axios.get(`/user/cavite/barangays/${lgu.code}`, {
      params: { type: lgu.type },
    })
    const names = normalizeBarangayRows((res.data || []).map((name) => ({ name })))
    if (names.length) return names
  } catch {}

  // Fallback source: direct PSGC endpoint in case local proxy is unreachable.
  try {
    const segment = lgu.type === 'city' ? 'cities' : 'municipalities'
    const url = `https://psgc.gitlab.io/api/${segment}/${lgu.code}/barangays/`
    const res = await axios.get(url)
    return normalizeBarangayRows(res.data)
  } catch {
    return []
  }
}

const fetchBarangaysForSelectedCity = async () => {
  const lgu = selectedCaviteLgu.value
  if (!lgu || normalizeKey(requestForm.province) !== normalizeKey(CAVITE_PROVINCE)) return
  if (Array.isArray(barangaysByLguCode.value[lgu.code]) && barangaysByLguCode.value[lgu.code].length) return

  barangayLoading.value = true
  try {
    const names = await fetchBarangaysByLgu(lgu)
    barangaysByLguCode.value = {
      ...barangaysByLguCode.value,
      [lgu.code]: names.length ? names : fallbackBarangaysFromBusinesses.value,
    }
  } catch {
    barangaysByLguCode.value = {
      ...barangaysByLguCode.value,
      [lgu.code]: fallbackBarangaysFromBusinesses.value,
    }
  } finally {
    barangayLoading.value = false
  }
}

const buildAddressText = () =>
  [
    requestForm.address_line,
    requestForm.barangay ? `Brgy. ${requestForm.barangay}` : '',
    requestForm.city,
    requestForm.province,
    requestForm.postal_code,
  ]
    .map((v) => String(v || '').trim())
    .filter(Boolean)
    .join(', ')

const resolveScheduleForBusiness = (teams, businessId) => {
  const rows = (Array.isArray(teams) ? teams : [])
    .filter((row) => businessIdentity(row?.business_id) === businessIdentity(businessId))
    .filter((row) => row?.team_schedule_date && row?.team_schedule_time_from && row?.team_schedule_time_to)
  if (!rows.length) return null
  rows.sort((a, b) => {
    const dateA = String(a.team_schedule_date || '')
    const dateB = String(b.team_schedule_date || '')
    if (dateA !== dateB) return dateA.localeCompare(dateB)
    const fromA = String(a.team_schedule_time_from || '')
    const fromB = String(b.team_schedule_time_from || '')
    return fromA.localeCompare(fromB)
  })
  const chosen = rows[0]
  return {
    date: String(chosen.team_schedule_date || ''),
    time_from: String(chosen.team_schedule_time_from || '').slice(0, 5),
    time_to: String(chosen.team_schedule_time_to || '').slice(0, 5),
  }
}

const fetchBusinessSchedule = async (businessId) => {
  if (!businessId) {
    businessSchedule.date = ''
    businessSchedule.time_from = ''
    businessSchedule.time_to = ''
    return
  }
  if (scheduleCache.value[businessId]) {
    Object.assign(businessSchedule, scheduleCache.value[businessId])
    return
  }
  try {
    const res = await axios.get('/user/formed-teams', { timeout: 10000 })
    const schedule = resolveScheduleForBusiness(res?.data || [], businessId)
    if (schedule) {
      scheduleCache.value[businessId] = schedule
      Object.assign(businessSchedule, schedule)
      return
    }
  } catch {}
  scheduleCache.value[businessId] = { date: '', time_from: '', time_to: '' }
  businessSchedule.date = ''
  businessSchedule.time_from = ''
  businessSchedule.time_to = ''
}

const fetchBlockedTimes = async () => {
  const businessId = businessIdentity(selectedBusiness.id)
  if (!businessId || !requestForm.preferred_date) {
    blockedTimes.value = []
    return
  }
  blockedTimesLoading.value = true
  try {
    const res = await axios.get('/user/service-requests/blocked-times', {
      params: {
        business_id: businessId,
        preferred_date: requestForm.preferred_date,
      },
      timeout: 10000,
    })
    const times = Array.isArray(res?.data?.times) ? res.data.times : []
    blockedTimes.value = times.filter(Boolean)
  } catch {
    blockedTimes.value = []
  } finally {
    blockedTimesLoading.value = false
    if (isPreferredTimeBlocked.value) {
      requestForm.preferred_time = ''
    }
  }
}

watch(
  () => requestForm.province,
  (next, prev) => {
    if (next === prev) return
    requestForm.city = ''
    requestForm.barangay = ''
    requestForm.postal_code = ''
  }
)

watch(
  () => requestForm.city,
  async (next, prev) => {
    if (next === prev) return
    requestForm.barangay = ''
    requestForm.postal_code = selectedCaviteLgu.value?.zip || ''
    await fetchBarangaysForSelectedCity()
  }
)
watch(
  [() => requestForm.preferred_date, () => selectedBusiness.id],
  () => {
    fetchBlockedTimes()
    if (!availableTimeSlots.value.length) {
      requestForm.preferred_time = ''
    }
  }
)
const descriptionCount = ref(0)
const requestModalRef = ref(null)
const dateInputRef = ref(null)

// Fetch businesses
const fetchBusinesses = async () => {
  try {
    const res = await axios.get('/user/all-businesses')
    businesses.value = res.data
  } catch {
    businesses.value = []
  }
}

// Business modal
const openBusinessModal = (b) => {
  Object.assign(selectedBusiness, b)
  if(!selectedBusiness.services) {
    selectedBusiness.services = []
    if(selectedBusiness.category && selectedBusiness.category !== 'Both') selectedBusiness.services.push(selectedBusiness.category)
  }
  showBusinessModal.value = true
}
const closeBusinessModal = () => showBusinessModal.value = false

const hasPendingForSelected = computed(() =>
  props.pendingRequest && String(props.pendingRequest.business_id) === String(selectedBusiness.id)
)
const pendingRequestId = computed(() => props.pendingRequest?.id || null)
const lockedForSelected = computed(() =>
  props.requestLocked && !hasPendingForSelected.value
)


// Request modal
const normalizeContact = (value) => {
  let digits = String(value || '').replace(/\D/g, '')
  if (digits.startsWith('0') && digits.length === 11) {
    return `63${digits.slice(1)}`
  }
  if (digits.startsWith('63') && digits.length === 12) {
    return digits
  }
  return digits
}

const toLocalContact = (value) => {
  const digits = normalizeContact(value)
  if (digits.startsWith('63') && digits.length === 12) {
    return `0${digits.slice(2)}`
  }
  return digits
}

const openRequestModal = async (b) => {
  if (props.requestLocked) {
    Swal.fire('Request Locked', props.lockMessage, 'info')
    return
  }
  Object.assign(selectedBusiness, b)

  // Service Type behavior:
  // - Both: user chooses from dropdown
  // - Plumbing/Siphoning only: auto-filled and fixed
  if (String(b.category || '').trim().toLowerCase() === 'both') {
    requestForm.service_type = ''
  } else if (String(b.category || '').trim()) {
    requestForm.service_type = serviceTypeOptions.value[0] || String(b.category || '').trim()
  } else {
    requestForm.service_type = ''
  }

  const currentUser = props.authUser || authUser
  requestForm.address_line = currentUser.address || selectedBusiness.address_street || selectedBusiness.address || ''
  requestForm.province = CAVITE_PROVINCE
  const matchedCity = findCaviteLguByName(selectedBusiness.address_city || '')
  requestForm.city = matchedCity?.name || ''
  requestForm.barangay = selectedBusiness.address_barangay || ''
  requestForm.postal_code = matchedCity?.zip || selectedBusiness.address_postal || ''
  fetchBarangaysForSelectedCity()
  requestForm.contact_number = toLocalContact(currentUser.contact_number)
  requestForm.description = ''
  requestForm.preferred_time = ''
  requestForm.payment_choice = ''
  requestForm.downpayment_opt_in = false
  requestForm.downpayment_amount = null
  requestForm.landmark_notes = ''
  requestForm.survey_photos = []
  
  // ✅ Set default preferred_date to today if empty
  await fetchBusinessSchedule(businessIdentity(selectedBusiness.id))
  if (businessSchedule.date) {
    requestForm.preferred_date = businessSchedule.date
  } else {
    requestForm.preferred_date = new Date().toISOString().split('T')[0]
  }
  await fetchBlockedTimes()

  descriptionCount.value = 0

  if (!props.enableRequest) return
  showRequestModal.value = true
  nextTick(() => requestModalRef.value?.querySelector('input, select')?.focus())
}


const closeRequestModal = () => showRequestModal.value = false

const cancelPendingRequest = async () => {
  if (!pendingRequestId.value) return
  const confirm = await Swal.fire({
    title: 'Cancel request?',
    text: 'You can only cancel while it is still pending.',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Yes, cancel',
  })
  if (!confirm.isConfirmed) return
  try {
    await axios.post(`/user/service-requests/${pendingRequestId.value}/cancel`)
    Swal.fire({
      icon: 'success',
      title: 'Cancelled',
      text: 'Your request was cancelled.',
      timer: 1000,
      showConfirmButton: false,
    })
    emit('request-cancelled', { id: pendingRequestId.value, status: 'cancelled' })
    closeBusinessModal()
  } catch (err) {
    Swal.fire('Error', err.response?.data?.error || 'Failed to cancel request', 'error')
  }
}

// Description counter
const updateDescriptionCount = () => {
  descriptionCount.value = requestForm.description.length
}

const openDatePicker = () => {
  if (!dateInputRef.value) return
  if (typeof dateInputRef.value.showPicker === 'function') {
    dateInputRef.value.showPicker()
    return
  }
  dateInputRef.value.focus()
}

const onSurveyPhotosChange = (event) => {
  const files = Array.from(event?.target?.files || []).filter(Boolean).slice(0, 5)
  requestForm.survey_photos = files
}

// Map link
const mapLink = (lat, lng) => `https://www.google.com/maps?q=${lat},${lng}`
const mapEmbed = (lat, lng) => `https://www.google.com/maps?q=${lat},${lng}&z=17&output=embed`

// Date limits: current month/year only, from today to month end
const today = new Date()
const minDate = new Date(today.getFullYear(), today.getMonth(), today.getDate()).toISOString().split('T')[0]
const maxDate = new Date(today.getFullYear(), today.getMonth() + 1, 0).toISOString().split('T')[0]

// Submit request
const submitServiceRequest = async () => {
  if (props.requestLocked) {
    closeRequestModal()
    return Swal.fire('Request Locked', props.lockMessage, 'warning')
  }

  if (
    !requestForm.service_type ||
    !requestForm.address_line ||
    !requestForm.barangay ||
    !requestForm.city ||
    !requestForm.province ||
    !requestForm.postal_code ||
    !requestForm.preferred_date ||
    !requestForm.preferred_time ||
    !requestForm.contact_number
  ) {
    return Swal.fire('Error', 'Please fill all required fields', 'error')
  }
  if (!availableTimeSlots.value.length) {
    return Swal.fire('Schedule Required', 'Selected business has no available schedule for this date.', 'warning')
  }
  await fetchBlockedTimes()
  if (isPreferredTimeBlocked.value) {
    return Swal.fire('Time Unavailable', 'Selected time is already booked. Please choose another slot.', 'warning')
  }
  if (requestForm.preferred_date < minDate || requestForm.preferred_date > maxDate) {
    return Swal.fire('Invalid Date', 'Pick a date from today until the end of this month only.', 'warning')
  }
  if (!requestForm.payment_choice) {
    return Swal.fire('Error', 'Please select a payment method', 'error')
  }
  if (requestForm.downpayment_opt_in) {
    if (requestForm.payment_choice === 'cash') {
      return Swal.fire('Payment Method', 'Downpayment requires Card or E-wallet.', 'warning')
    }
    const amount = Number(requestForm.downpayment_amount)
    if (!amount || amount <= 0) {
      return Swal.fire('Error', 'Downpayment amount is required when downpayment is enabled.', 'error')
    }
    if (amount > MAX_DOWNPAYMENT_AMOUNT) {
      return Swal.fire('Error', `Maximum downpayment amount is PHP ${MAX_DOWNPAYMENT_AMOUNT}.`, 'error')
    }
  }

  const contact = normalizeContact(requestForm.contact_number)
  const paymentMethod = requestForm.downpayment_opt_in ? 'downpayment' : 'personal'
  const paymentChoiceLabelMap = {
    cash: 'Cash',
    card: 'Card',
    e_wallet: 'E-wallet',
  }
  const paymentChannelMap = {
    cash: null,
    card: 'bank_transfer',
    e_wallet: 'gcash',
  }
  const paymentChoiceLabel = paymentChoiceLabelMap[requestForm.payment_choice] || requestForm.payment_choice
  const paymentChannel = requestForm.downpayment_opt_in ? paymentChannelMap[requestForm.payment_choice] : null
  const noteLines = [
    requestForm.description ? `Problem: ${requestForm.description}` : '',
    requestForm.landmark_notes ? `Landmark: ${requestForm.landmark_notes}` : '',
    'Booking Type: Survey / Inspection',
    `Payment Method: ${paymentChoiceLabel}`,
    `Downpayment: ${requestForm.downpayment_opt_in ? `Yes (PHP ${Number(requestForm.downpayment_amount || 0).toFixed(2)})` : 'No'}`,
    `Preferred Time: ${requestForm.preferred_time}`,
  ].filter(Boolean)
  const notesCombined = noteLines.join('\n')
  const addressText = buildAddressText()
  const fixedPrice = selectedBusinessFixedPrice.value
  const totalAmount = Number.isFinite(fixedPrice) && fixedPrice > 0 ? fixedPrice : null
  if (requestForm.downpayment_opt_in && totalAmount === null) {
    return Swal.fire('Error', 'Service amount is required for downpayment.', 'error')
  }

  const payload = new FormData()
  payload.append('business_id', String(selectedBusiness.id))
  payload.append('business_name', String(selectedBusiness.business_name || selectedBusiness.company_name || ''))
  payload.append('company_name', String(selectedBusiness.company_name || selectedBusiness.business_name || ''))
  payload.append('business_type', String(selectedBusiness.business_type || ''))
  payload.append('management_mode', String(selectedBusiness.management_mode || ''))
  payload.append('service_type', String(requestForm.service_type))
  payload.append('payment_method', paymentMethod)
  payload.append('payment_choice', String(requestForm.payment_choice))
  payload.append('payment_channel', paymentChannel || '')
  payload.append('downpayment_amount', requestForm.downpayment_opt_in ? String(Number(requestForm.downpayment_amount || 0)) : '0')
  if (totalAmount !== null) {
    payload.append('total_amount', String(totalAmount))
  }
  payload.append('contact_number', contact)
  payload.append('address_text', addressText)
  payload.append('notes', notesCombined)
  payload.append('preferred_date', requestForm.preferred_date)
  payload.append('preferred_time', requestForm.preferred_time)
  payload.append('latitude', String((props.authUser || authUser).latitude ?? ''))
  payload.append('longitude', String((props.authUser || authUser).longitude ?? ''))
  ;(requestForm.survey_photos || []).slice(0, 5).forEach((file) => payload.append('photos[]', file))

  try {
    const res = await axios.post('/user/service-requests', payload, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    const submitted = res?.data || {}
    const targetBusinessName = submitted.business_name || selectedBusiness.business_name || 'selected business'
    if (submitted.invoice_url) {
      window.location.assign(submitted.invoice_url)
      return
    }

    Swal.fire({
      icon: 'success',
      title: 'Request Sent',
      text: submitted.invoice_url
        ? `Submitted to ${targetBusinessName}. Please pay using the generated checkout link.`
        : `Submitted to ${targetBusinessName}. Waiting for business approval.`,
      timer: 1000,
      showConfirmButton: false,
    })

    emit('request-submitted', {
      ...submitted,
      business_id: submitted.business_id || selectedBusiness.id,
      business_name: targetBusinessName,
      status: submitted.status || 'pending',
    })

    closeRequestModal()
    closeBusinessModal()
    if (typeof window !== 'undefined') {
      window.location.assign('/serviceprovider?section=requests')
    }
  } catch (err) {
    const apiErrors = err?.response?.data?.errors
    const firstFieldError = apiErrors && typeof apiErrors === 'object'
      ? Object.values(apiErrors).flat().find((msg) => typeof msg === 'string' && msg.trim() !== '')
      : ''
    const message = firstFieldError
      || err?.response?.data?.error
      || err?.response?.data?.message
      || 'Failed to submit request'
    Swal.fire('Error', message, 'error')
  }
}

// Mounted
onMounted(async () => {
  if (!props.authUser) {
    try {
      const res = await axios.get('/user/profile')
      Object.assign(authUser, res.data)
    } catch {}
  }
  if (props.fetchBusinesses && !props.businesses) {
    fetchBusinesses()
  }
})
</script>








