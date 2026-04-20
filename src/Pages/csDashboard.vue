<template>
  <div class="min-h-screen h-screen grid grid-cols-1 lg:grid-cols-[320px_1fr] font-['Manrope'] text-slate-900 bg-[radial-gradient(1200px_500px_at_20%_-10%,rgba(59,130,246,0.12),transparent_70%),radial-gradient(900px_500px_at_90%_20%,rgba(14,116,144,0.12),transparent_70%),#f8fafc]">
    <aside class="bg-slate-900 text-slate-200 p-7 flex flex-col gap-6 overflow-y-auto lg:sticky lg:top-0 lg:z-10 shadow-[0_0_40px_rgba(14,116,144,0.25),0_0_80px_rgba(14,116,144,0.15)]">
      <div>
        <p class="text-[11px] tracking-[0.2em] uppercase text-sky-400 font-bold">Customer Service</p>
        <h1 class="mt-1.5 text-[26px] font-extrabold text-slate-50">Applicant Hub</h1>
        <p class="mt-1.5 text-[13px] text-slate-400">Track your application, assignments, and onboarding status.</p>
      </div>

      <button type="button" class="text-left bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl p-4 grid grid-cols-[auto_1fr] gap-3 items-center border border-slate-400/20" @click="openProfileFromMenu">
        <div v-if="profilePhotoSrc" class="h-12 w-12 rounded-2xl overflow-hidden border border-slate-400/20 bg-slate-800">
          <img :src="profilePhotoSrc" :key="profilePhotoKey" alt="Profile photo" class="h-full w-full object-cover" @error="handleProfileImageError" />
        </div>
        <div v-else class="h-12 w-12 rounded-2xl bg-sky-400 text-slate-900 font-bold grid place-items-center">{{ profile.avatar }}</div>
        <div>
          <p class="m-0 font-bold text-slate-50">{{ profile.name }}</p>
          <p class="mt-0.5 text-[12px] text-slate-400">{{ profile.role }}</p>
        </div>
        <span class="col-span-2 justify-self-start mt-2 bg-sky-400/20 text-sky-400 text-[11px] tracking-[0.12em] uppercase px-2.5 py-1.5 rounded-full">{{ profile.status }}</span>
      </button>

      <div>
        <h3 class="m-0 mb-2.5 text-[14px] text-slate-200">Next Action</h3>
        <div v-if="nextAction" class="bg-slate-800 rounded-2xl p-3.5 grid gap-2">
          <p class="m-0 font-semibold text-slate-50">{{ nextAction.title }}</p>
          <p class="m-0 text-[12px] text-slate-400">{{ nextAction.meta }}</p>
        </div>
        <p v-else class="mt-1.5 text-[11px] text-slate-400">No pending action.</p>
      </div>

      <div>
        <h3 class="m-0 mb-2.5 text-[14px] text-slate-200">Quick Links</h3>
        <div class="grid gap-2">
          <button type="button" class="border border-slate-400/40 bg-transparent text-slate-200 font-semibold px-3 py-2 rounded-full">Update Availability</button>
          <button type="button" class="border border-slate-400/40 bg-transparent text-slate-200 font-semibold px-3 py-2 rounded-full">Chat with Recruiter</button>
        </div>
      </div>

      <div>
        <h3 class="m-0 mb-2.5 text-[14px] text-slate-200">Schedule</h3>
        <div v-if="schedule" class="bg-slate-800 rounded-2xl p-3 grid gap-1.5">
          <p class="m-0 font-semibold text-slate-50">{{ schedule.title }}</p>
          <p class="m-0 text-[12px] text-slate-400">{{ schedule.meta }}</p>
          <p class="m-0 text-[11px] text-slate-500">{{ schedule.note }}</p>
        </div>
        <p v-else class="mt-1.5 text-[11px] text-slate-400">No upcoming schedule.</p>
      </div>

      <div>
        <h3 class="m-0 mb-2.5 text-[14px] text-slate-200">Profile Completeness</h3>
        <div class="grid grid-cols-[auto_1fr] gap-3 items-center p-3 rounded-2xl bg-slate-900 border border-slate-400/15">
          <div class="relative grid place-items-center text-slate-200 font-bold text-[12px] h-[54px] w-[54px] rounded-full" :style="ringStyle">
            <span class="absolute inset-[6px] rounded-full bg-slate-900"></span>
            <span class="relative z-10">{{ profileCompleteness }}%</span>
          </div>
          <div>
            <p class="m-0 text-[12px] font-bold text-slate-50">{{ profileCompleteness === 100 ? 'Done' : 'Almost there' }}</p>
            <p class="mt-1 text-[11px] text-slate-400">
              <span v-if="missingFields.length === 0">Profile complete.</span>
              <span v-else>Missing: {{ missingFields.join(', ') }}</span>
            </p>
          </div>
        </div>
      </div>
    </aside>

    <main class="flex min-h-0 flex-col overflow-hidden">
      <div class="flex items-center justify-end border-b border-slate-200/80 bg-white/90 px-10 py-4 max-[1024px]:px-6 max-[720px]:px-[18px]">
        <div class="flex items-center gap-2 px-2 py-2">
          <div class="relative">
            <button
              type="button"
              aria-label="Notifications"
              class="relative h-10 w-10 rounded-full border border-white/10 bg-[#6b7280]/35 text-slate-100 grid place-items-center hover:bg-[#6b7280]/50 transition"
              @click="toggleBellMenu"
            >
              <svg viewBox="0 0 24 24" class="h-5 w-5 fill-current" aria-hidden="true">
                <path d="M12 22a2.5 2.5 0 0 0 2.45-2h-4.9A2.5 2.5 0 0 0 12 22Zm7-5.5-1.27-1.3a2 2 0 0 1-.58-1.4v-3.3a5.15 5.15 0 0 0-3.8-5V4.7a1.35 1.35 0 1 0-2.7 0v.8a5.15 5.15 0 0 0-3.8 5v3.3a2 2 0 0 1-.58 1.4L5 16.5v1.5h14v-1.5Z" />
              </svg>
              <span v-if="unreadBellCount > 0" class="absolute -right-1 -top-1 min-w-4 h-4 px-1 rounded-full bg-red-500 text-[10px] text-white font-bold leading-4 text-center">
                {{ unreadBellCount > 9 ? '9+' : unreadBellCount }}
              </span>
            </button>
            <button v-if="showBellMenu" type="button" class="fixed inset-0 z-10 cursor-default" aria-label="Close notifications" @click="showBellMenu = false"></button>
            <div v-if="showBellMenu" class="absolute right-0 mt-2 z-20 w-[320px] max-h-[360px] overflow-y-auto rounded-xl border border-slate-300 bg-white p-2 shadow-[0_14px_24px_rgba(15,23,42,0.16)]">
              <div class="flex items-center justify-between px-2 py-1">
                <p class="m-0 text-[12px] font-bold text-slate-700">Notifications</p>
                <button type="button" class="text-[11px] text-slate-500 hover:text-slate-700" @click="refreshBellNotifications">Refresh</button>
              </div>
              <p v-if="bellLoading" class="px-2 py-2 text-[12px] text-slate-500">Loading...</p>
              <div v-else-if="bellNotifications.length > 0" class="grid gap-1.5 mt-1">
                <button
                  v-for="note in bellNotifications"
                  :key="note.id"
                  type="button"
                  class="w-full text-left rounded-lg border px-2.5 py-2 transition"
                  :class="note.read_at ? 'border-slate-200 bg-slate-50 hover:bg-slate-100' : 'border-sky-200 bg-sky-50 hover:bg-sky-100'"
                  @click="openBellNotification(note)"
                >
                  <p class="m-0 text-[12px] font-semibold text-slate-800">{{ note.title || 'Notification' }}</p>
                  <p class="m-0 mt-0.5 text-[11px] text-slate-600 line-clamp-2 break-words">{{ note.message }}</p>
                  <p class="m-0 mt-1 text-[10px] text-slate-400">{{ note.created_at }}</p>
                </button>
              </div>
              <p v-else class="px-2 py-2 text-[12px] text-slate-500">No notifications yet.</p>
            </div>
          </div>

          <div class="relative">
            <button
              type="button"
              class="relative h-10 w-10 rounded-full overflow-hidden border border-white/20 bg-slate-600 grid place-items-center text-white font-bold"
              @click="toggleProfileMenu"
            >
              <img v-if="profilePhotoSrc" :src="profilePhotoSrc" :key="profilePhotoKey" alt="Profile photo" class="h-full w-full object-cover" @error="handleProfileImageError" />
              <span v-else>{{ profile.avatar }}</span>
              <span class="absolute -right-1 -bottom-1 h-5 w-5 rounded-full border-2 border-[#161d2b] bg-[#737b88] text-white grid place-items-center">
                <svg viewBox="0 0 20 20" class="h-2.5 w-2.5 fill-current" aria-hidden="true">
                  <path d="M7.7 13.6 4.8 10.7l1.1-1.1 1.8 1.8 4.4-4.4 1.1 1.1-5.5 5.5Z" />
                </svg>
              </span>
            </button>
            <button v-if="showProfileMenu" type="button" class="fixed inset-0 z-10 cursor-default" aria-label="Close menu" @click="closeProfileMenu"></button>
            <div v-if="showProfileMenu" class="absolute right-0 mt-2 z-20 w-[150px] rounded-xl border border-slate-300 bg-white p-1.5 shadow-[0_14px_24px_rgba(15,23,42,0.16)]">
              <button type="button" class="w-full text-left px-3 py-2 text-[13px] font-semibold text-slate-700 rounded-lg hover:bg-slate-100" @click="openProfileFromMenu">Profile</button>
              <button type="button" class="w-full text-left px-3 py-2 text-[13px] font-semibold text-red-600 rounded-lg hover:bg-red-50" @click="logoutFromMenu">Logout</button>
            </div>
          </div>
        </div>
      </div>
      <div class="px-10 pb-8 pt-5 grid gap-6 overflow-y-auto max-[1024px]:px-6 max-[720px]:px-[18px]">
      <section class="bg-white rounded-[20px] p-6 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 border border-slate-300/30 shadow-[0_12px_22px_rgba(15,23,42,0.08)]">
        <div>
          <p class="text-[11px] tracking-[0.2em] uppercase text-sky-400 font-bold">Application Status</p>
          <h2 class="mt-1 text-[28px] font-extrabold">Almost there. Keep momentum.</h2>
          <p class="mt-1.5 text-[14px] text-slate-600">Finish the assessment and upload your documents to move to final interview.</p>
        </div>
        <div class="flex gap-2.5 flex-wrap">
          <button type="button" class="border-0 bg-gradient-to-br from-sky-400 to-blue-600 text-slate-900 font-bold px-4 py-2.5 rounded-full shadow-[0_10px_18px_rgba(37,99,235,0.25)] transition hover:-translate-y-0.5" @click="openUploadModal">Upload Requirements</button>
          <button type="button" class="border border-slate-300 bg-white text-slate-900 font-bold px-4 py-2.5 rounded-full">Reschedule Interview</button>
        </div>
      </section>

      <section class="grid gap-4 grid-cols-[repeat(auto-fit,minmax(210px,1fr))]">
        <div class="bg-white rounded-2xl p-4 border border-slate-300/25 shadow-[0_12px_20px_rgba(15,23,42,0.06)]" v-for="stat in stats" :key="stat.title">
          <p class="m-0 text-[11px] tracking-[0.18em] uppercase text-slate-400 font-bold">{{ stat.title }}</p>
          <div class="flex items-center justify-between mt-3">
            <h3 class="m-0 text-[24px] font-extrabold">{{ stat.value }}</h3>
            <span :class="['inline-flex items-center text-[11px] px-2.5 py-1 rounded-full font-bold', badgeClassMap[stat.badgeClass] || 'bg-slate-200 text-slate-600']">{{ stat.badge }}</span>
          </div>
          <p class="mt-2 text-[12px] text-slate-500">{{ stat.sub }}</p>
        </div>
      </section>

      <section class="bg-white rounded-[18px] p-5 border border-slate-300/25 shadow-[0_10px_18px_rgba(15,23,42,0.06)]">
        <div class="flex items-center justify-between gap-3 flex-wrap">
          <div>
            <h3 class="m-0">Application Journey</h3>
            <p class="mt-1 text-[13px] text-slate-500">Real-time progress across the screening pipeline.</p>
          </div>
          <button type="button" class="border border-slate-300/40 bg-transparent text-slate-900 font-semibold px-3 py-2 rounded-full">View Timeline</button>
        </div>
        <div class="mt-4 grid gap-3">
          <div class="grid grid-cols-[auto_1fr_auto] items-center gap-3 p-3 rounded-xl bg-slate-50" v-for="step in steps" :key="step.title">
            <div class="h-3 w-3 rounded-full" :class="stepDotClass(step.state)"></div>
            <div>
              <p class="m-0 font-semibold">{{ step.title }}</p>
              <p class="mt-0.5 text-[12px] text-slate-500">{{ step.sub }}</p>
            </div>
            <span class="text-[12px] text-slate-400">{{ step.date }}</span>
          </div>
        </div>
      </section>

      <section class="grid gap-4 grid-cols-1 lg:grid-cols-2">
        <div class="bg-white rounded-[18px] p-5 border border-slate-300/25 shadow-[0_10px_18px_rgba(15,23,42,0.06)]">
          <div>
            <h3 class="m-0">Applicant Checklist</h3>
            <p class="mt-1.5 text-[12px] text-slate-500">Everything you need to submit before final interview.</p>
          </div>
          <div class="mt-3.5 grid gap-2.5">
            <div class="grid grid-cols-[auto_1fr_auto] gap-2.5 items-center p-2.5 rounded-xl bg-slate-50" v-for="item in checklist" :key="item.title">
              <span class="h-2.5 w-2.5 rounded-full" :class="item.done ? 'bg-green-500' : 'bg-orange-500'"></span>
              <div>
                <p class="m-0 font-semibold">{{ item.title }}</p>
                <p class="mt-0.5 text-[12px] text-slate-500">{{ item.sub }}</p>
              </div>
              <span class="text-[11px] font-bold text-slate-900">{{ item.status }}</span>
            </div>
            <p v-if="checklist.length === 0" class="mt-1.5 text-[11px] text-slate-400">No checklist items yet.</p>
          </div>
        </div>

        <div class="bg-white rounded-[18px] p-5 border border-slate-300/25 shadow-[0_10px_18px_rgba(15,23,42,0.06)]">
          <div>
            <h3 class="m-0">Support Simulation</h3>
            <p class="mt-1.5 text-[12px] text-slate-500">Practice scenarios aligned with the role.</p>
          </div>
          <div class="mt-3.5 grid gap-2.5">
            <div class="flex items-center justify-between bg-slate-50 p-3 rounded-xl" v-for="sim in simulations" :key="sim.title">
              <div>
                <p class="m-0 font-semibold">{{ sim.title }}</p>
                <p class="mt-0.5 text-[12px] text-slate-500">{{ sim.sub }}</p>
              </div>
              <span class="text-[11px] font-bold text-blue-600 bg-blue-500/10 px-2.5 py-1 rounded-full">{{ sim.tag }}</span>
            </div>
            <p v-if="simulations.length === 0" class="mt-1.5 text-[11px] text-slate-400">No simulations assigned.</p>
          </div>
          <button type="button" class="mt-3 w-full border border-slate-300 bg-white text-slate-900 font-bold px-4 py-2.5 rounded-full">Open Simulation Center</button>
        </div>
      </section>

      <section class="bg-white rounded-[18px] p-5 border border-slate-300/25 shadow-[0_10px_18px_rgba(15,23,42,0.06)]">
        <div class="flex items-center justify-between">
          <h3 class="m-0">Recent Updates</h3>
          <button type="button" class="border border-slate-300/40 bg-transparent text-slate-900 font-semibold px-3 py-2 rounded-full">View All</button>
        </div>
        <div class="mt-4 grid gap-3">
          <div class="grid grid-cols-[auto_1fr_auto] gap-3 items-center bg-slate-50 p-3 rounded-xl" v-for="update in updates" :key="update.id || update.title">
            <div class="h-9 w-9 rounded-xl bg-slate-200 grid place-items-center font-bold text-slate-900">{{ update.initials }}</div>
            <div>
              <p class="m-0 font-semibold">{{ update.title }}</p>
              <p class="mt-0.5 text-[12px] text-slate-500">{{ update.sub }}</p>
            </div>
            <span class="text-[11px] text-slate-400">{{ update.time }}</span>
          </div>
          <p v-if="updates.length === 0" class="mt-1.5 text-[11px] text-slate-400">No updates yet.</p>
        </div>
      </section>
      </div>
    </main>

    <div v-if="showProfileModal" class="fixed inset-0 z-50 bg-slate-900/70 backdrop-blur-sm grid place-items-center p-4 sm:p-6" @click.self="closeProfileModal">
      <div class="w-full max-w-[560px] max-h-[calc(100vh-2rem)] overflow-y-auto bg-slate-900 text-slate-200 rounded-2xl border border-slate-400/20 p-5 sm:p-6 shadow-[0_20px_40px_rgba(15,23,42,0.35)]">
        <div class="flex items-center justify-between gap-3">
          <h3 class="m-0">Update Profile</h3>
          <button type="button" class="border border-slate-400/40 bg-transparent text-slate-200 font-semibold px-3 py-2 rounded-full" @click="closeProfileModal">Close</button>
        </div>
        <p class="mt-1.5 text-[12px] text-slate-400">Update your name, contact number, and profile photo.</p>
        <div class="mt-4 grid gap-3">
          <div class="grid gap-2">
            <label class="text-[12px] text-slate-400">First Name</label>
            <input v-model="profileForm.first_name" type="text" :readonly="!profileEditing" class="rounded-xl border border-slate-400/20 bg-slate-900 px-3 py-2 text-[13px] text-slate-100 focus:outline-none focus:ring-2 focus:ring-slate-400/40 read-only:opacity-60" @focus="enableProfileEdit" />
          </div>
          <div class="grid gap-2">
            <label class="text-[12px] text-slate-400">Middle Initial</label>
            <input v-model="profileForm.middle_initial" type="text" maxlength="1" :readonly="!profileEditing" class="rounded-xl border border-slate-400/20 bg-slate-900 px-3 py-2 text-[13px] text-slate-100 focus:outline-none focus:ring-2 focus:ring-slate-400/40 read-only:opacity-60" @focus="enableProfileEdit" />
          </div>
          <div class="grid gap-2">
            <label class="text-[12px] text-slate-400">Last Name</label>
            <input v-model="profileForm.last_name" type="text" :readonly="!profileEditing" class="rounded-xl border border-slate-400/20 bg-slate-900 px-3 py-2 text-[13px] text-slate-100 focus:outline-none focus:ring-2 focus:ring-slate-400/40 read-only:opacity-60" @focus="enableProfileEdit" />
          </div>
          <div class="grid gap-2">
            <label class="text-[12px] text-slate-400">Contact Number</label>
            <input v-model="profileForm.contact_number" type="text" :readonly="!profileEditing" class="rounded-xl border border-slate-400/20 bg-slate-900 px-3 py-2 text-[13px] text-slate-100 focus:outline-none focus:ring-2 focus:ring-slate-400/40 read-only:opacity-60" @focus="enableProfileEdit" />
          </div>
          <div class="grid gap-2">
            <label class="text-[12px] text-slate-400">Profile Photo</label>
        <div class="flex items-center gap-3">
          <div v-if="profileForm.photo_preview || profile.photo_url" class="h-14 w-14 rounded-xl overflow-hidden border border-slate-400/20 bg-slate-800">
            <img :src="profileForm.photo_preview || profile.photo_url" alt="Profile preview" class="h-full w-full object-cover" />
          </div>
          <input type="file" accept="image/*" class="text-[11px] text-slate-200" @change="onProfilePhotoChange" />
        </div>
        <div class="flex items-center gap-2">
          <button type="button" class="border border-slate-400/40 bg-transparent text-slate-200 font-semibold px-3 py-2 rounded-full disabled:opacity-60 disabled:cursor-not-allowed" :disabled="!profileEditing" @click="removeProfilePhoto">Remove Photo</button>
          <span v-if="profileForm.remove_photo" class="text-[11px] text-slate-400">Photo will be removed.</span>
        </div>
      </div>
        </div>
        <div class="mt-4 flex justify-end gap-2.5">
          <button type="button" class="border border-slate-300 bg-white text-slate-900 font-bold px-4 py-2.5 rounded-full" @click="closeProfileModal">Cancel</button>
          <button type="button" class="border-0 bg-gradient-to-br from-sky-400 to-blue-600 text-slate-900 font-bold px-4 py-2.5 rounded-full shadow-[0_10px_18px_rgba(37,99,235,0.25)] transition hover:-translate-y-0.5 disabled:opacity-60 disabled:cursor-not-allowed" :disabled="profileSaving || !profileEditing" @click="submitProfileUpdate">
            {{ profileSaving ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="showCropper" class="fixed inset-0 bg-slate-900/70 grid place-items-center z-50 p-6">
      <div class="w-full max-w-[520px] bg-slate-900 text-slate-200 rounded-[18px] border border-slate-400/20 p-4.5 shadow-[0_20px_40px_rgba(15,23,42,0.35)]">
        <div class="flex items-center justify-between gap-3">
          <h3 class="m-0">Crop Profile Photo</h3>
          <button type="button" class="border border-slate-400/40 bg-transparent text-slate-200 font-semibold px-3 py-2 rounded-full" @click="cancelCrop">Close</button>
        </div>
        <p class="mt-1.5 text-[12px] text-slate-400">Drag the image to position it. Use the slider to zoom. Recommended square.</p>
        <div class="mt-4 flex flex-col items-center gap-4">
          <div ref="cropperBoxRef" class="relative bg-slate-800 rounded-2xl border border-slate-400/20 overflow-hidden" :style="{ width: cropperSize + 'px', height: cropperSize + 'px' }">
            <img
              v-if="cropper.src"
              ref="cropperImgRef"
              :src="cropper.src"
              alt="Crop source"
              class="absolute top-0 left-0 select-none"
              :style="cropImageStyle"
              @load="onCropImageLoad"
              @mousedown.prevent="startCropDrag"
              @touchstart.prevent="startCropDrag"
              draggable="false"
            />
            <div class="absolute inset-0 pointer-events-none border border-white/70 rounded-2xl"></div>
          </div>
          <div class="w-full">
            <label class="text-[12px] text-slate-400">Zoom</label>
            <input type="range" class="w-full" :min="cropper.minScale" :max="cropper.maxScale" :step="0.01" v-model.number="cropper.scale" @input="onCropScaleChange" />
          </div>
        </div>
        <div class="mt-4 flex justify-end gap-2.5">
          <button type="button" class="border border-slate-300 bg-white text-slate-900 font-bold px-4 py-2.5 rounded-full" @click="cancelCrop">Cancel</button>
          <button type="button" class="border-0 bg-gradient-to-br from-sky-400 to-blue-600 text-slate-900 font-bold px-4 py-2.5 rounded-full shadow-[0_10px_18px_rgba(37,99,235,0.25)] transition hover:-translate-y-0.5" @click="applyCrop">
            Use Photo
          </button>
        </div>
      </div>
    </div>

    <div v-if="showUploadModal" class="fixed inset-0 z-50 bg-slate-900/70 backdrop-blur-sm grid place-items-center p-4 sm:p-6" @click.self="closeUploadModal">
      <div class="w-full max-w-[560px] max-h-[calc(100vh-2rem)] overflow-y-auto bg-slate-900 text-slate-200 rounded-2xl border border-slate-400/20 p-5 sm:p-6 shadow-[0_20px_40px_rgba(15,23,42,0.35)]">
        <div class="flex items-center justify-between gap-3">
          <h3 class="m-0">Upload Requirements</h3>
          <button type="button" class="border border-slate-400/40 bg-transparent text-slate-200 font-semibold px-3 py-2 rounded-full" @click="closeUploadModal">Close</button>
        </div>
        <p class="mt-1.5 text-[12px] text-slate-400">Upload the missing documents tied to your profile.</p>
        <div class="mt-4 grid gap-3">
          <p v-if="missingFields.length === 0" class="mt-1.5 text-[11px] text-slate-400">No missing requirements.</p>
          <div v-else class="grid gap-3">
            <div v-if="missingGovernmentId" class="flex items-center justify-between gap-4 p-3 rounded-xl bg-slate-900 border border-slate-400/20">
              <div>
                <p class="m-0 font-semibold text-slate-50 text-[13px]">Government ID</p>
                <p class="mt-1 text-[11px] text-slate-400">Upload a clear image (JPG/PNG).</p>
                <div v-if="governmentIdPreview" class="mt-2 grid gap-1.5">
                  <img :src="governmentIdPreview" alt="Government ID preview" class="w-40 rounded-lg border border-slate-400/20 object-cover" />
                  <p class="m-0 text-[11px] text-slate-400">{{ governmentIdName }}</p>
                  <button type="button" class="border border-slate-400/40 bg-transparent text-slate-200 font-semibold px-3 py-2 rounded-full" @click="clearGovernmentId">Remove</button>
                </div>
              </div>
              <input type="file" accept="image/*" class="text-[11px] text-slate-200 rounded-xl border border-slate-400/20 px-2 py-1" @change="onGovernmentIdChange" />
            </div>
            <div v-for="field in unsupportedMissingFields" :key="field" class="flex items-center justify-between gap-4 p-3 rounded-xl bg-slate-900 border border-slate-400/20">
              <div>
                <p class="m-0 font-semibold text-slate-50 text-[13px]">{{ field }}</p>
                <p class="mt-1 text-[11px] text-slate-400">Please update this in your profile.</p>
              </div>
              <span class="text-[11px] text-slate-400">Not uploadable here</span>
            </div>
          </div>
        </div>
        <div class="mt-4 flex justify-end gap-2.5">
          <button type="button" class="border border-slate-300 bg-white text-slate-900 font-bold px-4 py-2.5 rounded-full" @click="closeUploadModal">Cancel</button>
          <button type="button" class="border-0 bg-gradient-to-br from-sky-400 to-blue-600 text-slate-900 font-bold px-4 py-2.5 rounded-full shadow-[0_10px_18px_rgba(37,99,235,0.25)] transition hover:-translate-y-0.5 disabled:opacity-60 disabled:cursor-not-allowed" :disabled="uploading || !canSubmitUpload" @click="submitUploads">
            {{ uploading ? 'Uploading...' : 'Submit' }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="showNotificationDetail" class="fixed inset-0 z-50 bg-slate-900/70 backdrop-blur-sm grid place-items-center p-4 sm:p-6" @click.self="closeNotificationDetail">
      <div class="w-full max-w-[620px] max-h-[calc(100vh-2rem)] overflow-y-auto rounded-2xl border border-slate-300/20 bg-slate-900 p-5 text-slate-100 shadow-[0_20px_40px_rgba(2,6,23,0.45)] sm:p-6">
        <div class="flex items-start justify-between gap-3">
          <div>
            <p class="m-0 text-[11px] uppercase tracking-[0.14em] text-sky-300/90 font-semibold">Notification</p>
            <h3 class="m-0 mt-1 text-xl font-bold break-words">{{ activeNotification?.title || 'Notification' }}</h3>
            <p class="m-0 mt-1 text-[12px] text-slate-400">{{ activeNotification?.created_at || '' }}</p>
          </div>
          <button type="button" class="rounded-xl border border-slate-500/40 px-3 py-2 text-sm font-semibold text-slate-200 hover:bg-slate-800" @click="closeNotificationDetail">
            Close
          </button>
        </div>

        <div class="mt-4 rounded-xl border border-slate-500/30 bg-slate-800/50 p-4">
          <p class="m-0 whitespace-pre-wrap break-words text-sm text-slate-200">{{ activeNotification?.message || 'No message.' }}</p>
        </div>

        <div class="mt-4 flex justify-end gap-2.5">
          <button type="button" class="rounded-xl border border-slate-500/40 px-4 py-2 text-sm font-semibold text-slate-200 hover:bg-slate-800" @click="closeNotificationDetail">
            Done
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { router } from '@inertiajs/vue3';
import axios from 'axios';
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';
import { confirmAndLogout } from '@/lib/auth-flow';

const toast = (text, type = 'info') => {
  const colors = {
    success: 'linear-gradient(135deg, #22c55e, #16a34a)',
    error: 'linear-gradient(135deg, #ef4444, #b91c1c)',
    warning: 'linear-gradient(135deg, #f97316, #ea580c)',
    info: 'linear-gradient(135deg, #38bdf8, #2563eb)',
  };
  Toastify({
    text,
    duration: 2000,
    gravity: 'top',
    position: 'right',
    close: true,
    style: { background: colors[type] || colors.info, color: '#fff' },
  }).showToast();
};

const logout = async () => {
  await confirmAndLogout({
    confirmText: 'Do you want to end this session?',
    confirmButtonText: 'Logout',
    loadingText: 'Please wait while your session is closed.',
  });
};

const loading = ref(true);
const profile = ref({
  name: 'Applicant',
  role: 'Customer Service',
  status: 'Pending',
  avatar: 'CS',
  first_name: '',
  middle_initial: '',
  last_name: '',
  contact_number: '',
  photo_url: '',
});
const nextAction = ref(null);
const schedule = ref(null);
const stats = ref([]);
const steps = ref([]);

const profileCompleteness = ref(0);
const missingFields = ref([]);
const ringStyle = computed(() => ({
  background: `conic-gradient(#38bdf8 ${profileCompleteness.value * 3.6}deg, #1f2937 0deg)`
}));

const showUploadModal = ref(false);
const uploading = ref(false);
const governmentIdFile = ref(null);
const showProfileModal = ref(false);
const showProfileMenu = ref(false);
const showBellMenu = ref(false);
const bellLoading = ref(false);
const bellNotifications = ref([]);
const showNotificationDetail = ref(false);
const activeNotification = ref(null);
const profileSaving = ref(false);
const profileEditing = ref(false);
const showCropper = ref(false);
const cropperSize = 220;
const cropperBoxRef = ref(null);
const cropperImgRef = ref(null);
const profilePhotoVersion = ref(0);
const cropper = ref({
  src: '',
  imageEl: null,
  imageWidth: 0,
  imageHeight: 0,
  scale: 1,
  minScale: 1,
  maxScale: 3,
  offsetX: 0,
  offsetY: 0,
  dragging: false,
  dragStartX: 0,
  dragStartY: 0,
  dragOriginX: 0,
  dragOriginY: 0,
});
const profileForm = ref({
  first_name: '',
  middle_initial: '',
  last_name: '',
  contact_number: '',
  photo_file: null,
  photo_preview: '',
  remove_photo: false,
});

const missingGovernmentId = computed(() => missingFields.value.includes('Government ID'));
const unsupportedMissingFields = computed(() => missingFields.value.filter((field) => field !== 'Government ID'));
const canSubmitUpload = computed(() => missingGovernmentId.value && !!governmentIdFile.value);
const governmentIdPreview = computed(() => (
  governmentIdFile.value ? URL.createObjectURL(governmentIdFile.value) : ''
));
const governmentIdName = computed(() => governmentIdFile.value?.name || '');

const badgeClassMap = {
  'badge-warn': 'bg-red-100 text-red-500',
  'badge-good': 'bg-green-100 text-green-600',
  'badge-info': 'bg-blue-100 text-blue-600',
  'badge-neutral': 'bg-slate-200 text-slate-600',
};

const stepDotClass = (state) => {
  if (state === 'done') return 'bg-green-500';
  if (state === 'active') return 'bg-sky-400';
  return 'bg-slate-300';
};

const withCacheBuster = (value) => {
  if (!value) return '';
  const sep = value.includes('?') ? '&' : '?';
  return `${value}${sep}v=${Date.now()}`;
};

const profilePhotoSrc = computed(() => {
  if (!profile.value.photo_url) return '';
  const sep = profile.value.photo_url.includes('?') ? '&' : '?';
  return `${profile.value.photo_url}${sep}v=${profilePhotoVersion.value}`;
});

const profilePhotoKey = computed(() => `profile-photo-${profilePhotoVersion.value}`);
const unreadBellCount = computed(() => bellNotifications.value.filter((note) => !note.read_at).length);

const clampCropOffsets = () => {
  const displayWidth = cropper.value.imageWidth * cropper.value.scale;
  const displayHeight = cropper.value.imageHeight * cropper.value.scale;
  const minX = Math.min(0, cropperSize - displayWidth);
  const maxX = Math.max(0, cropperSize - displayWidth);
  const minY = Math.min(0, cropperSize - displayHeight);
  const maxY = Math.max(0, cropperSize - displayHeight);
  cropper.value.offsetX = Math.min(maxX, Math.max(minX, cropper.value.offsetX));
  cropper.value.offsetY = Math.min(maxY, Math.max(minY, cropper.value.offsetY));
};

const resetCropper = () => {
  cropper.value = {
    src: '',
    imageEl: null,
    imageWidth: 0,
    imageHeight: 0,
    scale: 1,
    minScale: 1,
    maxScale: 3,
    offsetX: 0,
    offsetY: 0,
    dragging: false,
    dragStartX: 0,
    dragStartY: 0,
    dragOriginX: 0,
    dragOriginY: 0,
  };
};

const cropImageStyle = computed(() => ({
  width: `${cropper.value.imageWidth * cropper.value.scale}px`,
  height: `${cropper.value.imageHeight * cropper.value.scale}px`,
  transform: `translate(${cropper.value.offsetX}px, ${cropper.value.offsetY}px)`,
  cursor: cropper.value.dragging ? 'grabbing' : 'grab',
}));

const setProfileFormFromProfile = () => {
  profileForm.value = {
    first_name: profile.value.first_name || '',
    middle_initial: profile.value.middle_initial || '',
    last_name: profile.value.last_name || '',
    contact_number: profile.value.contact_number || '',
    photo_file: null,
    photo_preview: '',
    remove_photo: false,
  };
};

const fetchDashboardData = async () => {
  try {
    const res = await axios.get('/employee/cs-dashboard-data');
    const data = res.data || {};
    profile.value = {
      ...profile.value,
      ...(data.profile || {}),
    };
    if (profile.value.photo_url) {
      profilePhotoVersion.value += 1;
    }
    if (data.profile?.first_name || data.profile?.last_name) {
      const initials = `${data.profile?.first_name?.[0] || ''}${data.profile?.last_name?.[0] || ''}`.toUpperCase();
      profile.value.avatar = initials || profile.value.avatar;
    }
    profileCompleteness.value = data.profile_completeness?.percent ?? 0;
    missingFields.value = data.profile_completeness?.missing ?? [];
    nextAction.value = data.next_action || null;
    schedule.value = data.schedule || null;
    stats.value = data.stats || [];
    steps.value = data.steps || [];
    checklist.value = data.checklist || [];
    simulations.value = data.simulations || [];
    updates.value = data.updates || [];
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const checklist = ref([]);
const simulations = ref([]);
const updates = ref([]);

const openUploadModal = () => {
  showUploadModal.value = true;
};

const closeUploadModal = () => {
  showUploadModal.value = false;
  clearGovernmentId();
};

const openProfileModal = () => {
  setProfileFormFromProfile();
  profileEditing.value = false;
  showProfileModal.value = true;
};

const toggleProfileMenu = () => {
  showBellMenu.value = false;
  showProfileMenu.value = !showProfileMenu.value;
};

const closeProfileMenu = () => {
  showProfileMenu.value = false;
};

const openProfileFromMenu = () => {
  closeProfileMenu();
  toast('Opening profile...', 'info');
  setTimeout(() => {
    router.visit('/employee/profile');
  }, 300);
};

const refreshBellNotifications = async () => {
  bellLoading.value = true;
  try {
    const res = await axios.get('/user/notifications');
    bellNotifications.value = Array.isArray(res.data) ? res.data : [];
  } catch (error) {
    console.error(error);
    toast('Failed to load notifications.', 'error');
  } finally {
    bellLoading.value = false;
  }
};

const toggleBellMenu = async () => {
  showProfileMenu.value = false;
  showBellMenu.value = !showBellMenu.value;
  if (showBellMenu.value) {
    await refreshBellNotifications();
  }
};

const openBellNotification = async (note) => {
  if (!note) return;
  try {
    if (!note.read_at) {
      await axios.post(`/user/notifications/${note.id}/read`);
      note.read_at = new Date().toISOString();
    }
  } catch (error) {
    console.error(error);
  }
  activeNotification.value = note;
  showNotificationDetail.value = true;
  showBellMenu.value = false;
};

const closeNotificationDetail = () => {
  showNotificationDetail.value = false;
  activeNotification.value = null;
};

const logoutFromMenu = () => {
  closeProfileMenu();
  logout();
};

const closeProfileModal = () => {
  showProfileModal.value = false;
  profileEditing.value = false;
  if (profileForm.value.photo_preview) {
    URL.revokeObjectURL(profileForm.value.photo_preview);
  }
  profileForm.value.photo_preview = '';
  profileForm.value.photo_file = null;
  profileForm.value.remove_photo = false;
};

const enableProfileEdit = () => {
  profileEditing.value = true;
};

const handleNextAction = () => {
  const actionText = nextAction.value?.action?.toLowerCase() || '';
  if (actionText.includes('update profile')) {
    openProfileFromMenu();
  }
};

const handleProfileImageError = () => {
  profile.value.photo_url = '';
  profilePhotoVersion.value += 1;
};

const onGovernmentIdChange = (event) => {
  const file = event.target.files?.[0];
  if (!file) {
    governmentIdFile.value = null;
    return;
  }

  if (!String(file.type || '').startsWith('image/')) {
    toast('Government ID must be an image file.', 'warning');
    governmentIdFile.value = null;
    event.target.value = '';
    return;
  }

  const maxBytes = 8 * 1024 * 1024;
  if (file.size > maxBytes) {
    toast('Government ID must be 8MB or smaller.', 'warning');
    governmentIdFile.value = null;
    event.target.value = '';
    return;
  }

  governmentIdFile.value = file;
};

const clearGovernmentId = () => {
  governmentIdFile.value = null;
};

const onProfilePhotoChange = (event) => {
  const file = event.target.files?.[0] || null;
  if (!file) return;
  enableProfileEdit();
  openCropperWithFile(file);
};

const openCropperWithFile = (file) => {
  if (cropper.value.src) {
    URL.revokeObjectURL(cropper.value.src);
  }
  resetCropper();
  cropper.value.src = URL.createObjectURL(file);
  showCropper.value = true;
};

const onCropImageLoad = (event) => {
  const img = event.target;
  cropper.value.imageEl = img;
  cropper.value.imageWidth = img.naturalWidth || img.width || cropperSize;
  cropper.value.imageHeight = img.naturalHeight || img.height || cropperSize;
  const baseScale = Math.max(cropperSize / cropper.value.imageWidth, cropperSize / cropper.value.imageHeight);
  cropper.value.minScale = baseScale;
  cropper.value.maxScale = baseScale * 3;
  cropper.value.scale = baseScale;
  cropper.value.offsetX = (cropperSize - cropper.value.imageWidth * cropper.value.scale) / 2;
  cropper.value.offsetY = (cropperSize - cropper.value.imageHeight * cropper.value.scale) / 2;
  clampCropOffsets();
};

const onCropScaleChange = () => {
  clampCropOffsets();
};

const startCropDrag = (event) => {
  const point = 'touches' in event ? event.touches[0] : event;
  cropper.value.dragging = true;
  cropper.value.dragStartX = point.clientX;
  cropper.value.dragStartY = point.clientY;
  cropper.value.dragOriginX = cropper.value.offsetX;
  cropper.value.dragOriginY = cropper.value.offsetY;
  window.addEventListener('mousemove', onCropDragMove);
  window.addEventListener('mouseup', stopCropDrag);
  window.addEventListener('touchmove', onCropDragMove, { passive: false });
  window.addEventListener('touchend', stopCropDrag);
};

const onCropDragMove = (event) => {
  if (!cropper.value.dragging) return;
  const point = 'touches' in event ? event.touches[0] : event;
  cropper.value.offsetX = cropper.value.dragOriginX + (point.clientX - cropper.value.dragStartX);
  cropper.value.offsetY = cropper.value.dragOriginY + (point.clientY - cropper.value.dragStartY);
  clampCropOffsets();
};

const stopCropDrag = () => {
  cropper.value.dragging = false;
  window.removeEventListener('mousemove', onCropDragMove);
  window.removeEventListener('mouseup', stopCropDrag);
  window.removeEventListener('touchmove', onCropDragMove);
  window.removeEventListener('touchend', stopCropDrag);
};

const applyCrop = async () => {
  const img = cropper.value.imageEl || cropperImgRef.value;
  if (!img) return;
  const cropSize = cropperSize;
  let sx = 0;
  let sy = 0;
  let sWidth = cropper.value.imageWidth;
  let sHeight = cropper.value.imageHeight;

  const boxEl = cropperBoxRef.value;
  if (boxEl && img.getBoundingClientRect) {
    const boxRect = boxEl.getBoundingClientRect();
    const imgRect = img.getBoundingClientRect();
    const scaleX = (img.naturalWidth || cropper.value.imageWidth) / imgRect.width;
    const scaleY = (img.naturalHeight || cropper.value.imageHeight) / imgRect.height;
    sx = Math.max(0, (boxRect.left - imgRect.left) * scaleX);
    sy = Math.max(0, (boxRect.top - imgRect.top) * scaleY);
    sWidth = boxRect.width * scaleX;
    sHeight = boxRect.height * scaleY;
  } else {
    const displayWidth = cropper.value.imageWidth * cropper.value.scale;
    const displayHeight = cropper.value.imageHeight * cropper.value.scale;
    const ratioX = cropper.value.imageWidth / displayWidth;
    const ratioY = cropper.value.imageHeight / displayHeight;
    sx = Math.max(0, -cropper.value.offsetX * ratioX);
    sy = Math.max(0, -cropper.value.offsetY * ratioY);
    sWidth = cropSize * ratioX;
    sHeight = cropSize * ratioY;
  }
  const canvas = document.createElement('canvas');
  canvas.width = 512;
  canvas.height = 512;
  const ctx = canvas.getContext('2d');
  ctx.drawImage(img, sx, sy, sWidth, sHeight, 0, 0, canvas.width, canvas.height);
  const blob = await new Promise((resolve) => canvas.toBlob(resolve, 'image/jpeg', 0.9));
  if (!blob) return;
  if (profileForm.value.photo_preview) {
    URL.revokeObjectURL(profileForm.value.photo_preview);
  }
  const file = new File([blob], `profile_${Date.now()}.jpg`, { type: 'image/jpeg' });
  profileForm.value.photo_file = file;
  profileForm.value.photo_preview = URL.createObjectURL(blob);
  profileForm.value.remove_photo = false;
  showCropper.value = false;
  if (cropper.value.src) {
    URL.revokeObjectURL(cropper.value.src);
  }
  resetCropper();
};

const cancelCrop = () => {
  showCropper.value = false;
  if (cropper.value.src) {
    URL.revokeObjectURL(cropper.value.src);
  }
  resetCropper();
};

const removeProfilePhoto = () => {
  if (profileForm.value.photo_preview) {
    URL.revokeObjectURL(profileForm.value.photo_preview);
  }
  profileForm.value.photo_preview = '';
  profileForm.value.photo_file = null;
  profileForm.value.remove_photo = true;
};

const submitProfileUpdate = async () => {
  profileSaving.value = true;
  try {
    const formData = new FormData();
    formData.append('_method', 'PUT');
    formData.append('first_name', profileForm.value.first_name || '');
    formData.append('middle_initial', profileForm.value.middle_initial || '');
    formData.append('last_name', profileForm.value.last_name || '');
    formData.append('contact_number', profileForm.value.contact_number || '');
    if (profileForm.value.photo_file) {
      formData.append('profile_photo', profileForm.value.photo_file);
    }
    if (profileForm.value.remove_photo) {
      formData.append('remove_profile_photo', '1');
    }
    const res = await axios.post('/employee/profile', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    if (res?.data) {
      profile.value.first_name = res.data.first_name ?? profile.value.first_name;
      profile.value.middle_initial = res.data.middle_initial ?? profile.value.middle_initial;
      profile.value.last_name = res.data.last_name ?? profile.value.last_name;
      profile.value.contact_number = res.data.contact_number ?? profile.value.contact_number;
      if (res.data.profile_photo_url) {
        profile.value.photo_url = res.data.profile_photo_url;
        profilePhotoVersion.value += 1;
      } else if (res.data.profile_photo_url === null) {
        profile.value.photo_url = '';
        profilePhotoVersion.value += 1;
      }
      if (profile.value.first_name || profile.value.last_name) {
        const initials = `${profile.value.first_name?.[0] || ''}${profile.value.last_name?.[0] || ''}`.toUpperCase();
        profile.value.avatar = initials || profile.value.avatar;
      }
    }
    await fetchDashboardData();
    closeProfileModal();
    toast('Your profile was updated successfully.', 'success');
  } catch (error) {
    console.error(error);
    toast('Profile update failed. Please try again.', 'error');
  } finally {
    profileSaving.value = false;
  }
};

const submitUploads = async () => {
  if (!canSubmitUpload.value) {
    toast('Please select a Government ID image to upload.', 'warning');
    return;
  }

  const formData = new FormData();
  if (governmentIdFile.value) {
    formData.append('government_id', governmentIdFile.value);
  }

  uploading.value = true;
  try {
    await axios.post('/employee/upload-requirements', formData);
    await fetchDashboardData();
    closeUploadModal();
    toast('Your requirement was uploaded successfully.', 'success');
  } catch (error) {
    console.error(error);
    const apiMessage = error?.response?.data?.message;
    const govIdErrors = error?.response?.data?.errors?.government_id;
    const firstGovIdError = Array.isArray(govIdErrors) ? govIdErrors[0] : null;
    const fallback = 'Upload failed. Please try again.';
    const message = firstGovIdError || apiMessage || fallback;
    toast(message, 'error');
  } finally {
    uploading.value = false;
  }
};

onMounted(() => {
  fetchDashboardData();
  refreshBellNotifications();
});
</script>

