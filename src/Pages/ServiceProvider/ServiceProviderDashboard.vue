<template>
  <div class="h-screen flex flex-col !bg-gray-100">
    <!-- NAVBAR -->
    <nav class="!bg-white shadow-md px-6 py-4 flex justify-between items-center sticky top-0 z-50">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-teal-500 to-emerald-500 text-white flex items-center justify-center font-bold">
          SP
        </div>
        <div>
          <h1 class="text-2xl font-bold text-gray-800">Service Provider Dashboard</h1>
          <p class="text-xs text-gray-500">Welcome back</p>
        </div>
      </div>
      <div class="flex items-center gap-3 relative">
        <div class="relative">
          <button
            type="button"
            class="relative h-10 w-10 rounded-full border border-gray-200 bg-white text-gray-600 hover:bg-gray-50"
            @click="toggleNotificationsMenu"
            aria-label="Notifications"
          >
            <svg viewBox="0 0 24 24" fill="none" class="mx-auto h-5 w-5" aria-hidden="true">
              <path d="M15 17H9m9-2V11a6 6 0 1 0-12 0v4l-2 2h16l-2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M10.5 20a1.5 1.5 0 0 0 3 0" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
            <span
              v-if="unreadCount"
              class="absolute -top-1 -right-1 min-w-[18px] h-[18px] px-1 rounded-full bg-rose-500 text-white text-[10px] font-bold leading-[18px]"
            >
              {{ unreadCount > 99 ? '99+' : unreadCount }}
            </span>
          </button>

          <div
            v-if="showNotificationsMenu"
            class="absolute right-0 mt-2 w-96 rounded-xl border border-gray-200 bg-white shadow-xl z-50"
          >
            <div class="flex items-center justify-between px-4 py-3 border-b border-gray-100">
              <p class="text-sm font-semibold text-gray-800">Notifications</p>
              <button type="button" class="text-xs font-semibold text-teal-700 hover:underline" @click="fetchNotifications">
                Refresh
              </button>
            </div>
            <div class="max-h-[340px] overflow-y-auto">
              <div v-if="notifications.length === 0" class="px-4 py-6 text-sm text-gray-500">
                No notifications yet.
              </div>
              <div v-else class="divide-y divide-gray-100">
                <div
                  v-for="note in notifications"
                  :key="`nav-note-${note.id}`"
                  class="px-4 py-3 flex items-start gap-3 cursor-pointer hover:bg-gray-50"
                  @click="handleNotificationClick(note)"
                >
                  <div class="w-2 h-2 mt-2 rounded-full" :class="note.read_at ? 'bg-gray-300' : 'bg-teal-500'"></div>
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-semibold text-gray-800 truncate">{{ note.title }}</p>
                    <p class="text-xs text-gray-600 mt-0.5 break-words">{{ note.message }}</p>
                    <p class="text-[11px] text-gray-400 mt-1">{{ note.created_at }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="relative">
          <button
            type="button"
            class="h-10 min-w-10 px-3 rounded-full border border-gray-200 bg-white text-gray-700 hover:bg-gray-50 flex items-center gap-2"
            @click="toggleProfileMenu"
          >
            <img
              v-if="profileImageUrl"
              :src="profileImageUrl"
              alt="Profile"
              class="h-7 w-7 rounded-full object-cover border border-gray-200"
            />
            <span v-else class="inline-flex h-7 w-7 items-center justify-center rounded-full bg-teal-600 text-white text-xs font-bold">
              {{ userInitials }}
            </span>
            <span class="text-xs font-semibold hidden sm:inline">Profile</span>
          </button>

          <div
            v-if="showProfileMenu"
            class="absolute right-0 mt-2 w-44 rounded-xl border border-gray-200 bg-white shadow-xl z-50 py-1"
          >
            <button type="button" class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-50" @click="openProfile">
              Profile
            </button>
            <button type="button" class="w-full text-left px-4 py-2 text-sm text-rose-600 hover:bg-rose-50" @click="confirmLogout">
              Logout
            </button>
          </div>
        </div>
      </div>
    </nav>

    <div class="flex flex-1 overflow-hidden">
      <!-- SIDEBAR -->
      <aside class="w-64 !bg-white shadow-r px-4 py-6 flex-shrink-0 h-full overflow-y-auto">
        <div class="mb-6 px-3">
          <p class="text-xs uppercase tracking-wide text-gray-400">Navigation</p>
        </div>
        <ul class="space-y-2">
          <li v-for="item in sidebarItems" :key="item.key"
              @click="setSection(item.key)"
              :class="menuClass(item.key)"
              class="px-3 py-2 rounded-lg cursor-pointer flex items-center gap-2">
            <span class="text-sm">{{ item.icon }}</span>
            <span>{{ item.label }}</span>
            <span
              v-if="sidebarBadge(item.key)"
              class="ml-auto text-xs font-semibold px-2 py-0.5 rounded-full"
              :class="sidebarBadgeClass(item.key)"
            >
              {{ sidebarBadge(item.key) }}
            </span>
          </li>
        </ul>
        <div class="mt-8 px-3">
          <div class="rounded-xl border border-dashed border-gray-200 p-3 text-xs text-gray-500">
            DB, SR, TM, DS, PM, WC, RP modules for service requests, dispatch, payments, warranty, and reports.
          </div>
        </div>
      </aside>

      <!-- MAIN CONTENT -->
      <main class="flex-1 p-8 overflow-y-auto">
        <div v-if="loading" class="text-gray-500">Loading dashboard...</div>

        <section v-else-if="user && !isProviderApproved" class="bg-white shadow-md rounded-2xl p-6">
          <h2 class="text-2xl font-bold text-gray-800 mb-2">Account Pending Approval</h2>
          <p class="text-gray-600">Your account is not approved yet. Wait for admin approval before accessing dashboard modules.</p>
        </section>

        <section v-else-if="section === 'dashboard'" class="space-y-4">
          <section
            v-if="hrQueueCount > 0"
            class="rounded-2xl border border-amber-200 bg-amber-50 p-4"
          >
            <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p class="text-sm font-semibold text-amber-900">Ready job update</p>
                <p class="text-xs text-amber-800">
                  {{ isEmployeeRole
                    ? `You have ${hrQueueCount} active team request${hrQueueCount > 1 ? 's' : ''} in Service Requests.`
                    : `You have ${hrQueueCount} active service request${hrQueueCount > 1 ? 's' : ''} ready for review and dispatch.` }}
                </p>
              </div>
              <button
                type="button"
                class="inline-flex items-center rounded-lg bg-amber-600 px-4 py-2 text-xs font-semibold text-white hover:bg-amber-700"
                @click="setSection('hr-queue')"
              >
                Open Service Requests
              </button>
            </div>
          </section>

          <section class="rounded-2xl border border-teal-200 bg-white p-5 shadow-sm">
            <div class="flex flex-wrap items-start justify-between gap-3">
              <div>
                <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-teal-700">Service Provider Modules</p>
                <h2 class="mt-1 text-xl font-extrabold text-slate-900">DB, SR, TM, DS, PM, WC, RP</h2>
                <p class="mt-1 text-sm text-slate-600">Operations overview for service requests, dispatch, payments, warranty, and reporting.</p>
              </div>
              <span class="inline-flex items-center rounded-full border border-teal-200 bg-teal-50 px-3 py-1 text-xs font-semibold text-teal-700">
                Service Provider View
              </span>
            </div>

            <div class="mt-4 grid gap-3 md:grid-cols-3">
              <article class="rounded-xl border border-slate-200 bg-slate-50 px-4 py-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-slate-500">Profile Name</p>
                <p class="mt-1 text-sm font-bold text-slate-900">{{ serviceProviderProfileName }}</p>
              </article>
              <article class="rounded-xl border border-slate-200 bg-slate-50 px-4 py-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-slate-500">Category</p>
                <p class="mt-1 text-sm font-bold text-slate-900">{{ serviceProviderCategory }}</p>
              </article>
              <article class="rounded-xl border border-slate-200 bg-slate-50 px-4 py-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-slate-500">Contact Details</p>
                <p class="mt-1 text-sm font-bold text-slate-900">{{ serviceProviderContact }}</p>
              </article>
            </div>

            <div class="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
              <article class="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-amber-700">Active Service Requests</p>
                <p class="mt-1 text-xl font-extrabold text-amber-900">{{ reportMetrics.activeCount }}</p>
              </article>
              <article class="rounded-xl border border-indigo-200 bg-indigo-50 px-4 py-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-indigo-700">Pending Approvals</p>
                <p class="mt-1 text-xl font-extrabold text-indigo-900">{{ pendingApprovalsCount }}</p>
              </article>
              <article class="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-emerald-700">Completed Jobs</p>
                <p class="mt-1 text-xl font-extrabold text-emerald-900">{{ reportMetrics.completedCount }}</p>
              </article>
              <article class="rounded-xl border border-cyan-200 bg-cyan-50 px-4 py-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-cyan-700">Revenue Summary</p>
                <p class="mt-1 text-xl font-extrabold text-cyan-900">{{ formatCurrency(reportMetrics.grossTotal) }}</p>
              </article>
            </div>

            <div class="mt-4 grid gap-3 md:grid-cols-2 xl:grid-cols-3">
              <article
                v-for="module in serviceProviderModules"
                :key="`workflow-module-${module.code}`"
                class="rounded-xl border border-slate-200 bg-white px-4 py-3"
              >
                <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-slate-500">{{ module.code }}</p>
                <p class="mt-1 text-sm font-bold text-slate-900">{{ module.title }}</p>
                <p class="mt-1 text-xs text-slate-600">{{ module.description }}</p>
              </article>
            </div>

            <article class="mt-4 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3">
              <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-emerald-700">Module Summary</p>
              <p class="mt-1 text-sm text-emerald-900">{{ moduleSummary }}</p>
            </article>
          </section>

          <DashboardView
            :businesses="businesses"
            :user="user"
            :provider="provider"
            :revenueSummary="revenueSummary"
            :requestLocked="requestLocked"
            :lockMessage="lockMessage"
            :pendingRequest="pendingUserRequest"
            @request-submitted="handleUserRequestSubmitted"
            @request-cancelled="handleUserRequestCancelled"
          />
        </section>

        <section v-else-if="section === 'team-assignment'" class="space-y-6">
          <section class="relative overflow-hidden rounded-3xl border border-slate-200/90 bg-[linear-gradient(165deg,#f8fbff_0%,#eef7f8_45%,#f8fafc_100%)] shadow-[0_20px_55px_rgba(15,23,42,0.09)]">
            <div class="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top_right,rgba(20,184,166,0.16),transparent_42%),radial-gradient(circle_at_bottom_left,rgba(14,165,233,0.1),transparent_48%)]"></div>

            <div class="relative p-6 sm:p-7">
              <div class="rounded-2xl border border-slate-200/80 bg-white/95 p-4 shadow-[0_10px_30px_rgba(15,23,42,0.06)] sm:p-5">
                <div class="flex flex-wrap items-start justify-between gap-4">
                  <div class="flex items-start gap-3">
                    <span class="inline-flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-slate-900 via-slate-800 to-slate-700 text-[11px] font-bold tracking-[0.08em] text-white shadow-sm ring-1 ring-slate-700/20">TA</span>
                    <div>
                      <p class="text-[11px] font-semibold uppercase tracking-[0.18em] text-slate-500">Team Assignment</p>
                      <h2 class="mt-1.5 text-2xl font-extrabold tracking-[-0.02em] text-slate-900">{{ teamAssignmentHeading }}</h2>
                      <p v-if="teamAssignmentSourceLabel" class="mt-1 text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">
                        {{ teamAssignmentSourceLabel }}
                      </p>
                      <p class="mt-2 text-sm text-slate-600">{{ teamAssignmentDescription }}</p>
                    </div>
                  </div>
                  <span
                    class="inline-flex items-center rounded-full border px-3.5 py-1 text-xs font-semibold shadow-sm"
                    :class="teamAssignmentBadgeClass"
                  >
                    {{ teamAssignmentStatusLabel }}
                  </span>
                </div>
              </div>

              <template v-if="isEmployeeRole && employeeData?.team">
                <div class="mt-4 grid gap-3 md:grid-cols-3">
                  <article class="rounded-2xl border border-slate-200/90 bg-white p-4 shadow-[0_8px_24px_rgba(15,23,42,0.05),inset_0_1px_0_rgba(255,255,255,0.9)]">
                    <p class="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500">Assigned Team</p>
                    <p class="mt-2 text-lg font-bold text-slate-900">{{ employeeData?.team || 'Unassigned' }}</p>
                  </article>
                  <article class="rounded-2xl border border-slate-200/90 bg-white p-4 shadow-[0_8px_24px_rgba(15,23,42,0.05),inset_0_1px_0_rgba(255,255,255,0.9)]">
                    <p class="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500">Group Schedule</p>
                    <p class="mt-2 text-sm font-semibold text-slate-800">Date: {{ groupScheduleDateLabel }}</p>
                    <p class="mt-1 text-sm font-semibold text-slate-800">Time: {{ groupScheduleTimeLabel }}</p>
                    <p v-if="showScheduleMissingHint" class="mt-1.5 text-[11px] text-amber-700">
                      No published schedule yet for your assigned team ({{ employeeData?.team }}).
                    </p>
                  </article>
                  <article class="rounded-2xl border border-slate-200/90 bg-white p-4 shadow-[0_8px_24px_rgba(15,23,42,0.05),inset_0_1px_0_rgba(255,255,255,0.9)]">
                    <p class="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500">Last Update</p>
                    <p class="mt-2 text-sm font-semibold text-slate-800">{{ teamAssignmentRespondedAtLabel }}</p>
                  </article>
                </div>

                <section class="mt-4 rounded-2xl border border-slate-200/90 bg-white/95 p-4 shadow-[0_10px_28px_rgba(15,23,42,0.05)] sm:p-5">
                  <div class="flex items-center justify-between gap-2">
                    <p class="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500">Team Members</p>
                    <span class="inline-flex items-center rounded-full bg-slate-900 px-3 py-1 text-[11px] font-semibold text-white shadow-sm">
                      {{ teamMembers.length }} members
                    </span>
                  </div>

                  <div class="mt-3 grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
                    <article
                      v-for="member in teamMembers"
                      :key="`ta-member-${member.id}`"
                      class="rounded-xl border border-slate-200/90 bg-[linear-gradient(145deg,#f8fafc_0%,#ffffff_100%)] px-3.5 py-3 shadow-[0_6px_18px_rgba(15,23,42,0.04)] transition hover:-translate-y-0.5 hover:shadow-[0_12px_22px_rgba(15,23,42,0.09)]"
                    >
                      <div class="flex items-start justify-between gap-2">
                        <div class="flex items-start gap-2.5">
                          <span class="inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-slate-900 text-[10px] font-bold text-white">
                            {{ memberInitials(member.name) }}
                          </span>
                          <div>
                            <p class="text-sm font-semibold leading-tight text-slate-900">
                              {{ member.name }}
                              <span v-if="member.is_you" class="ml-1 text-xs font-semibold text-teal-700">(You)</span>
                            </p>
                            <p class="mt-1 text-xs text-slate-600">{{ member.role || 'No role assigned' }}</p>
                          </div>
                        </div>
                        <span class="inline-flex items-center rounded-full px-2.5 py-1 text-[10px] font-semibold shadow-sm" :class="teamMemberStatusClass(member.team_assignment_status)">
                          {{ teamMemberStatusLabel(member.team_assignment_status) }}
                        </span>
                      </div>
                    </article>
                  </div>

                  <div
                    v-if="teamAssignmentPending || teamAssignmentAccepted"
                    class="mt-4 rounded-xl border border-slate-200 bg-[linear-gradient(180deg,#f8fafc_0%,#f1f5f9_100%)] px-3.5 py-3.5 shadow-[inset_0_1px_0_rgba(255,255,255,0.9)]"
                  >
                    <p class="text-sm font-semibold text-slate-900">
                      {{ teamAssignmentPending ? 'Please confirm this assignment to proceed.' : 'Team assignment is already accepted.' }}
                    </p>
                    <p class="mt-1 text-xs text-slate-600">
                      {{ teamAssignmentPending
                        ? 'Select Accept Team to confirm, or Request Reassignment if you need a different team placement.'
                        : `If this assignment is not workable, you may request reassignment from ${assignmentManagerLabel}.` }}
                    </p>
                    <div v-if="teamAssignmentPending" class="mt-3 flex flex-wrap items-center gap-2.5">
                      <button
                        type="button"
                        class="rounded-lg bg-emerald-600 px-4 py-2 text-xs font-semibold text-white shadow-sm transition hover:-translate-y-0.5 hover:bg-emerald-700 disabled:opacity-60"
                        :disabled="submittingTeamDecision"
                        @click="respondTeamAssignment('accept')"
                      >
                        {{ submittingTeamDecision ? 'Saving...' : 'Accept Team' }}
                      </button>
                      <button
                        type="button"
                        class="rounded-lg border border-amber-300 bg-white px-4 py-2 text-xs font-semibold text-amber-700 shadow-sm transition hover:-translate-y-0.5 hover:bg-amber-50 disabled:opacity-60"
                        :disabled="submittingTeamDecision"
                        @click="respondTeamAssignment('reject')"
                      >
                        {{ submittingTeamDecision ? 'Saving...' : 'Request Reassignment' }}
                      </button>
                    </div>
                    <div
                      v-else-if="teamAssignmentAccepted"
                      class="mt-3 inline-flex items-center gap-2 rounded-full border border-emerald-300 bg-emerald-50 px-3 py-1.5 text-xs font-semibold text-emerald-700"
                    >
                      <span aria-hidden="true">✓</span>
                      <span>Accepted</span>
                    </div>
                  </div>
                </section>

                <div v-if="employeeData?.team_assignment_response_note" class="mt-3 rounded-2xl border border-amber-200 bg-amber-50 px-4 py-3 shadow-[inset_0_1px_0_rgba(255,255,255,0.8)]">
                  <p class="text-[11px] font-semibold uppercase tracking-[0.14em] text-amber-700">Your Note</p>
                  <p class="mt-1 text-sm text-amber-900">{{ employeeData?.team_assignment_response_note }}</p>
                </div>

              </template>

              <div v-else class="mt-5 rounded-2xl border border-slate-200 bg-white/90 px-4 py-6 text-center shadow-[inset_0_1px_0_rgba(255,255,255,0.85)]">
                <p class="text-sm font-semibold text-slate-700">{{ teamAssignmentPendingPublish ? 'Team assignment is not visible yet.' : 'No team assignment right now.' }}</p>
                <p class="mt-1 text-xs text-slate-500">
                  {{ teamAssignmentPendingPublish
                    ? `Your team is assigned but still waiting for schedule publish by ${assignmentManagerLabel}.`
                    : 'HR Manager or Business Manager will notify you through the bell when a team is assigned.' }}
                </p>
              </div>
            </div>
          </section>
        </section>

        <AssignedRequestsView
          v-else-if="section === 'assigned' || section === 'requests'"
          :assignedRequests="requestHistory"
          :loading="assignedLoading"
          :allowDecisionActions="false"
          :showStartJob="false"
          :showCompleteJob="false"
          :allowArchiveActions="true"
          :allowUserRequestActions="true"
          title="My Service Requests"
          subtitle="All service requests you submitted."
          @refresh-data="refreshRequestsTab"
          @archive-request="archiveMyRequest"
          @restore-request="restoreMyRequest"
          @archive-many="archiveManyRequests"
          @request-cancelled="handleUserRequestCancelled"
        />

        <AssignedRequestsView
          v-else-if="section === 'hr-queue'"
          :assignedRequests="hrQueueRequests"
          :loading="assignedLoading"
          :forcedStatuses="['assigned', 'awaiting_material']"
            :allowDecisionActions="canDecideFromHrQueue"
            :showStartJob="canStartFromHrQueue"
            :showCompleteJob="canCompleteFromHrQueue"
            :allowPaymentLogging="canApproveWork"
            :title="bookingQueueTitle"
            :subtitle="bookingQueueSubtitle"
            @refresh-data="fetchAssignedRequests"
            @request-accepted="setSection('schedules')"
          />

        <section v-else-if="section === 'employees'" class="space-y-4">
          <div class="rounded-2xl border border-sky-200 bg-white p-5 shadow-sm">
            <div class="flex flex-wrap items-center justify-between gap-3">
              <div>
                <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-sky-700">Team</p>
                <h2 class="mt-1 text-2xl font-extrabold text-slate-900">Linked Team Members</h2>
                <p class="mt-1 text-sm text-slate-600">Approved HR-linked team members with availability, assigned jobs, and RBAC roles.</p>
              </div>
              <button
                type="button"
                class="rounded-lg border border-sky-300 bg-sky-50 px-4 py-2 text-xs font-semibold text-sky-700 hover:bg-sky-100"
                @click="setSection('hr-queue')"
              >
                Open Service Requests
              </button>
            </div>

            <div v-if="linkedEmployees.length === 0" class="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-4 text-sm text-slate-600">
              No linked employees yet.
            </div>
            <div v-else class="mt-4 grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-3">
              <article
                v-for="employee in pagedLinkedEmployees"
                :key="`linked-emp-${employee.id}`"
                class="rounded-xl border border-slate-200 bg-slate-50 p-4"
              >
                <p class="text-sm font-bold text-slate-900">{{ employee.name }}</p>
                <p v-if="employee.email" class="mt-1 text-xs text-slate-500">{{ employee.email }}</p>
                <p class="mt-2 text-xs text-slate-600">Role: <span class="font-semibold text-slate-800">{{ employee.role || 'N/A' }}</span></p>
                <p class="mt-2 text-xs text-slate-600">Active Jobs: <span class="font-semibold text-slate-800">{{ employee.active_jobs }}</span></p>
                <p class="text-xs text-slate-600">Completed Jobs: <span class="font-semibold text-slate-800">{{ employee.completed_jobs }}</span></p>
                <span
                  class="mt-2 inline-flex rounded-full px-2.5 py-1 text-[11px] font-semibold"
                  :class="employee.active_jobs > 0 ? 'bg-amber-100 text-amber-700' : 'bg-emerald-100 text-emerald-700'"
                >
                  {{ employee.active_jobs > 0 ? 'On Dispatch' : 'Available' }}
                </span>
              </article>
            </div>
            <div v-if="linkedEmployees.length > LINKED_EMPLOYEES_PAGE_SIZE" class="mt-4 flex flex-wrap items-center justify-between gap-3 rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-xs text-slate-600">
              <p>
                Page {{ linkedEmployeesPage }} of {{ linkedEmployeesTotalPages }} · Showing {{ linkedEmployeesPageRange.start }}-{{ linkedEmployeesPageRange.end }} of {{ linkedEmployees.length }}
              </p>
              <div class="flex items-center gap-2">
                <button
                  type="button"
                  class="rounded-lg border border-slate-300 bg-white px-3 py-1.5 font-semibold text-slate-700 disabled:cursor-not-allowed disabled:opacity-50"
                  :disabled="linkedEmployeesPage <= 1"
                  @click="prevLinkedEmployeesPage"
                >
                  Prev
                </button>
                <button
                  type="button"
                  class="rounded-lg border border-slate-300 bg-white px-3 py-1.5 font-semibold text-slate-700 disabled:cursor-not-allowed disabled:opacity-50"
                  :disabled="linkedEmployeesPage >= linkedEmployeesTotalPages"
                  @click="nextLinkedEmployeesPage"
                >
                  Next
                </button>
              </div>
            </div>
            <p class="mt-3 text-xs text-slate-500">
              Team leader handling for multi-employee dispatch is applied in the service request workflow before job start.
            </p>
          </div>
        </section>

        <section v-else-if="section === 'schedules'" class="space-y-4">
          <AssignedRequestsView
            :assignedRequests="dispatchQueueRequests"
            :loading="assignedLoading"
            :forcedStatuses="['awaiting_material']"
            :allowDecisionActions="false"
            :showStartJob="false"
            :showCompleteJob="false"
            :allowPaymentLogging="false"
            :allowDispatchAssign="true"
            :dispatchEmployees="linkedEmployees"
            title="Dispatch Requests"
            subtitle="Assign a linked employee/team for dispatch. After dispatch, it will return to Service Requests as Materials Pickup."
            @refresh-data="fetchAssignedRequests"
            @dispatch-assigned="setSection('hr-queue')"
          />
        </section>

        <AssignedRequestsView
          v-else-if="section === 'payments'"
          :assignedRequests="paymentQueueRequests"
          :loading="assignedLoading"
          :forcedStatuses="['assigned', 'awaiting_material', 'job_ready', 'in_progress', 'completed']"
          :allowDecisionActions="false"
          :showStartJob="false"
          :showCompleteJob="false"
          :allowPaymentLogging="canApproveWork"
          title="Payments"
          subtitle="Track job payments with amount, method, and receipt reference after team-leader payment logging."
          @refresh-data="fetchAssignedRequests"
        />

        <AssignedRequestsView
          v-else-if="section === 'warranty'"
          :assignedRequests="warrantyQueueRequests"
          :loading="assignedLoading"
          :forcedStatuses="['warranty_pending', 'warranty_rework', 'assigned', 'awaiting_material', 'job_ready', 'in_progress', 'completed']"
          :allowDecisionActions="canDecideFromHrQueue"
          :showStartJob="canStartFromHrQueue"
          :showCompleteJob="canCompleteFromHrQueue"
          :allowPaymentLogging="false"
          title="Warranty"
          subtitle="Handle warranty requests within 2 weeks through re-inspection and repair with no additional charges."
          @refresh-data="fetchAssignedRequests"
        />

        <section v-else-if="section === 'reports'" class="space-y-4">
          <div class="rounded-2xl border border-emerald-200 bg-white p-5 shadow-sm">
            <p class="text-[11px] font-semibold uppercase tracking-[0.12em] text-emerald-700">Reports</p>
            <h2 class="mt-1 text-2xl font-extrabold text-slate-900">Performance & Service Metrics</h2>
            <p class="mt-1 text-sm text-slate-600">Service history, customer feedback, and metrics for business analysis and HR oversight.</p>

            <div class="mt-4 grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-4">
              <article class="rounded-xl border border-slate-200 bg-slate-50 p-4">
                <p class="text-xs uppercase tracking-wide text-slate-500">Active Service Requests</p>
                <p class="mt-1 text-2xl font-bold text-slate-900">{{ reportMetrics.activeCount }}</p>
              </article>
              <article class="rounded-xl border border-slate-200 bg-slate-50 p-4">
                <p class="text-xs uppercase tracking-wide text-slate-500">Completed Jobs</p>
                <p class="mt-1 text-2xl font-bold text-slate-900">{{ reportMetrics.completedCount }}</p>
              </article>
              <article class="rounded-xl border border-slate-200 bg-slate-50 p-4">
                <p class="text-xs uppercase tracking-wide text-slate-500">Rejected Jobs</p>
                <p class="mt-1 text-2xl font-bold text-slate-900">{{ reportMetrics.rejectedCount }}</p>
              </article>
              <article class="rounded-xl border border-slate-200 bg-slate-50 p-4">
                <p class="text-xs uppercase tracking-wide text-slate-500">Total Requests</p>
                <p class="mt-1 text-2xl font-bold text-slate-900">{{ reportMetrics.totalCount }}</p>
              </article>
            </div>

            <div class="mt-3 grid grid-cols-1 gap-3 md:grid-cols-3">
              <article class="rounded-xl border border-emerald-200 bg-emerald-50 p-4">
                <p class="text-xs uppercase tracking-wide text-emerald-700">Gross Revenue</p>
                <p class="mt-1 text-xl font-bold text-emerald-900">{{ formatCurrency(reportMetrics.grossTotal) }}</p>
              </article>
              <article class="rounded-xl border border-cyan-200 bg-cyan-50 p-4">
                <p class="text-xs uppercase tracking-wide text-cyan-700">Business Total</p>
                <p class="mt-1 text-xl font-bold text-cyan-900">{{ formatCurrency(reportMetrics.businessTotal) }}</p>
              </article>
              <article class="rounded-xl border border-sky-200 bg-sky-50 p-4">
                <p class="text-xs uppercase tracking-wide text-sky-700">Employee Pool Total</p>
                <p class="mt-1 text-xl font-bold text-sky-900">{{ formatCurrency(reportMetrics.employeePoolTotal) }}</p>
              </article>
            </div>
            <div class="mt-3 grid grid-cols-1 gap-3 md:grid-cols-2">
              <article class="rounded-xl border border-slate-200 bg-slate-50 p-4">
                <p class="text-xs uppercase tracking-wide text-slate-500">Employee Performance</p>
                <p class="mt-1 text-sm font-semibold text-slate-900">{{ topEmployeeSummary }}</p>
              </article>
              <article class="rounded-xl border border-slate-200 bg-slate-50 p-4">
                <p class="text-xs uppercase tracking-wide text-slate-500">Customer Satisfaction</p>
                <p class="mt-1 text-sm font-semibold text-slate-900">{{ customerSatisfactionSummary }}</p>
              </article>
            </div>
          </div>
        </section>

        <ProfileView
          v-else-if="section === 'profile'"
          :user="user"
          :provider="provider"
          @refresh-data="fetchData"
        />

      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, computed, watch } from 'vue'
import Swal from '@/lib/sweetalert-toast-shim'
import axios from 'axios'
import { usePage } from '@inertiajs/vue3'
import { confirmAndLogout } from '@/lib/auth-flow'

import DashboardView from './DashboardView.vue'
import AssignedRequestsView from './AssignedRequestsView.vue'
import ProfileView from './ProfileView.vue'

const provider = ref(null)
const user = ref(null)
const businesses = ref([])
const revenueSummary = ref(null)
const assignedRequests = ref([])
const linkedEmployeeRows = ref([])
const LINKED_EMPLOYEES_PAGE_SIZE = 10
const linkedEmployeesPage = ref(1)
const providerReviews = ref([])
const userRequestsCache = ref([])
const loading = ref(true)
const assignedLoading = ref(false)
const notifications = ref([])
const showProfileMenu = ref(false)
const showNotificationsMenu = ref(false)
const seenRequestIds = ref(new Set())
const employeeData = ref(null)
const submittingTeamDecision = ref(false)
const hasNotifFetchError = ref(false)
const DASHBOARD_REQUEST_TIMEOUT_MS = 15000
let realtimeChannel = null
const page = usePage()
const props = defineProps({
  section: { type: String, default: 'dashboard' },
})

const normalizedRole = computed(() => {
  const currentRole = String(user.value?.role || '').trim().toLowerCase()
  if (currentRole) return currentRole
  return String(page?.props?.auth?.user?.role || '').trim().toLowerCase()
})
const isEmployeeRole = computed(() => normalizedRole.value === 'employee')
const staffPermissions = computed(() => ({
  can_view: employeeData.value?.staff_permissions?.can_view ?? true,
  can_manage: employeeData.value?.staff_permissions?.can_manage ?? false,
  can_approve: employeeData.value?.staff_permissions?.can_approve ?? false,
}))
const employeeAccessLevel = computed(() => {
  if (!isEmployeeRole.value) return 'approve'
  if (staffPermissions.value.can_approve) return 'approve'
  if (staffPermissions.value.can_manage) return 'manage'
  if (staffPermissions.value.can_view) return 'view'
  return 'none'
})
const baseEmployeeSidebarItems = [
  { key: 'dashboard', label: 'Dashboard', icon: 'DB' },
  { key: 'team-assignment', label: 'Team Assignment', icon: 'TA' },
  { key: 'hr-queue', label: 'Service Requests', icon: 'SR' },
  { key: 'employees', label: 'Team', icon: 'TM' },
  { key: 'schedules', label: 'Dispatch', icon: 'DS' },
  { key: 'payments', label: 'Payments', icon: 'PM' },
  { key: 'warranty', label: 'Warranty', icon: 'WC' },
  { key: 'reports', label: 'Reports', icon: 'RP' },
  { key: 'requests', label: 'My Requests', icon: 'RQ' },
  { key: 'profile', label: 'Profile', icon: 'PR' },
]
const employeeAllowedKeys = computed(() => {
  if (!isEmployeeRole.value) return []
  const keys = new Set(['dashboard', 'team-assignment', 'profile'])
  if (employeeAccessLevel.value !== 'none') {
    keys.add('requests')
  }
  if (staffPermissions.value.can_view || staffPermissions.value.can_manage || staffPermissions.value.can_approve) {
    keys.add('hr-queue')
    keys.add('employees')
    keys.add('reports')
  }
  if (staffPermissions.value.can_manage || staffPermissions.value.can_approve) {
    keys.add('schedules')
  }
  if (staffPermissions.value.can_approve) {
    keys.add('payments')
    keys.add('warranty')
  }
  return Array.from(keys)
})
const employeeSidebarItems = computed(() => {
  if (!isEmployeeRole.value) return []
  const allowed = new Set(employeeAllowedKeys.value)
  return baseEmployeeSidebarItems.filter((item) => allowed.has(item.key))
})
const serviceProviderSidebarItems = [
  { key: 'dashboard', label: 'Dashboard', icon: 'DB' },
  { key: 'hr-queue', label: 'Service Requests', icon: 'SR' },
  { key: 'employees', label: 'Team', icon: 'TM' },
  { key: 'schedules', label: 'Dispatch', icon: 'DS' },
  { key: 'payments', label: 'Payments', icon: 'PM' },
  { key: 'warranty', label: 'Warranty', icon: 'WC' },
  { key: 'reports', label: 'Reports', icon: 'RP' },
]
const allowedSections = computed(() => {
  if (isEmployeeRole.value) {
    const keys = employeeSidebarItems.value.map((item) => item.key)
    return keys.length ? keys : ['dashboard']
  }
  const keys = new Set(serviceProviderSidebarItems.map((item) => item.key))
  keys.add('profile')
  keys.add('requests')
  return Array.from(keys)
})
const normalizeSection = (value) => {
  const next = String(value || '').toLowerCase()
  if (next === 'assigned-requests' || next === 'assigned') return 'hr-queue'
  if (next === 'warranty-claims') return 'warranty'
  return allowedSections.value.includes(next) ? next : 'dashboard'
}
const getSectionFromUrl = () => {
  if (typeof window === 'undefined') return normalizeSection(props.section)
  const params = new URLSearchParams(window.location.search)
  return normalizeSection(params.get('section') || props.section)
}
const setSectionInUrl = (name) => {
  if (typeof window === 'undefined') return
  const url = new URL(window.location.href)
  // Always persist the selected sidebar section, including dashboard,
  // so refresh restores the exact same active item.
  url.searchParams.set('section', name)
  window.history.replaceState({}, '', `${url.pathname}${url.search}`)
}
const section = ref(getSectionFromUrl())

const sidebarItems = computed(() =>
  isEmployeeRole.value ? employeeSidebarItems.value : serviceProviderSidebarItems
)
const serviceProviderModules = [
  {
    code: 'DB',
    title: 'Dashboard',
    description: 'Overview of active service requests, pending approvals, completed jobs, and revenue summary for performance monitoring.',
  },
  {
    code: 'SR',
    title: 'Service Requests',
    description: 'Customer request list with Approve/Reject actions, dispatch flow, and request details including location and service type.',
  },
  {
    code: 'TM',
    title: 'Team',
    description: 'Approved HR-linked team members with availability, assigned jobs, and RBAC roles for dispatch planning.',
  },
  {
    code: 'DS',
    title: 'Dispatch',
    description: 'Upcoming inspection and service schedules to coordinate dispatch and avoid overlap.',
  },
  {
    code: 'PM',
    title: 'Payments',
    description: 'Payment tracking per job including amount, method, and receipt reference after team-leader logging.',
  },
  {
    code: 'WC',
    title: 'Warranty',
    description: 'Warranty requests within two weeks with redispatch and repair flow at no additional charge.',
  },
  {
    code: 'RP',
    title: 'Reports',
    description: 'Service history, customer feedback, and summary metrics for revenue, employee performance, and satisfaction.',
  },
]
const moduleSummary = 'Service Provider modules cover service request review, team dispatch, payment monitoring, warranty handling, and report generation for operational accountability.'
const menuClass = (key) =>
  section.value === key ? 'font-bold text-blue-600 bg-teal-50' : 'text-gray-700 hover:bg-gray-100'

const setSection = (key) => {
  const target = normalizeSection(key)
  if (target === section.value) return
  section.value = target
  setSectionInUrl(target)
  if (target === 'requests') {
    refreshRequestsTab()
    markRequestsAsSeen()
  }
  if (target === 'employees') {
    fetchLinkedEmployees()
    fetchAssignedRequests()
  }
  if (['hr-queue', 'schedules', 'payments', 'warranty', 'reports'].includes(target)) {
    fetchAssignedRequests()
  }
}

const httpGet = (url, config = {}) =>
  axios.get(url, { timeout: DASHBOARD_REQUEST_TIMEOUT_MS, ...config })

const fetchDashboard = async () => {
  const res = await httpGet('/service-provider/dashboard-data')
  provider.value = res.data.provider
  user.value = res.data.user
  businesses.value = res.data.businesses || []
  revenueSummary.value = res.data.revenue_summary || null
  providerReviews.value = Array.isArray(res.data.reviews) ? res.data.reviews : []
}

const fetchAssignedRequests = async () => {
  try {
    const assigned = await httpGet('/user/service-provider/assigned-requests')
    assignedRequests.value = assigned.data || []
  } catch {
    assignedRequests.value = []
  }
}

const fetchLinkedEmployees = async () => {
  try {
    const res = await httpGet('/service-provider/linked-employees')
    linkedEmployeeRows.value = Array.isArray(res.data) ? res.data : []
  } catch {
    linkedEmployeeRows.value = []
  }
}

const fetchUserRequests = async () => {
  try {
    const res = await httpGet('/user/service-requests')
    return res.data || []
  } catch {
    return []
  }
}

const refreshRequestsTab = async () => {
  userRequestsCache.value = await fetchUserRequests()
}

const archiveMyRequest = async (req) => {
  const confirm = await Swal.fire({
    title: 'Archive this request?',
    text: 'Archived requests are hidden by default, but can be restored anytime.',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Archive'
  })
  if (!confirm.isConfirmed) return

  try {
    await axios.post(`/user/service-requests/${req.id}/archive`)
    await refreshRequestsTab()
    Swal.fire('Archived', 'Request archived successfully.', 'success')
  } catch (err) {
    Swal.fire('Error', err.response?.data?.error || 'Failed to archive request.', 'error')
  }
}

const restoreMyRequest = async (req) => {
  try {
    await axios.post(`/user/service-requests/${req.id}/restore`)
    await refreshRequestsTab()
    Swal.fire('Restored', 'Request restored successfully.', 'success')
  } catch (err) {
    Swal.fire('Error', err.response?.data?.error || 'Failed to restore request.', 'error')
  }
}

const archiveManyRequests = async (ids = []) => {
  const uniqueIds = [...new Set((ids || []).map((x) => Number(x)).filter((x) => Number.isFinite(x) && x > 0))]
  if (!uniqueIds.length) return

  const confirm = await Swal.fire({
    title: `Archive ${uniqueIds.length} request(s)?`,
    text: 'Archived requests are hidden by default, but can be restored anytime.',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Archive'
  })
  if (!confirm.isConfirmed) return

  try {
    await Promise.all(uniqueIds.map((id) => axios.post(`/user/service-requests/${id}/archive`)))
    await refreshRequestsTab()
    Swal.fire('Archived', `${uniqueIds.length} request(s) archived.`, 'success')
  } catch (err) {
    Swal.fire('Error', err.response?.data?.error || 'Failed to archive selected requests.', 'error')
  }
}

const handleUserRequestSubmitted = async () => {
  userRequestsCache.value = await fetchUserRequests()
}

const handleUserRequestCancelled = async (payload = null) => {
  const cancelledId = payload?.id
  if (cancelledId) {
    userRequestsCache.value = (userRequestsCache.value || []).map((r) => {
      if (String(r?.id) !== String(cancelledId)) return r
      return { ...r, status: 'cancelled' }
    })
  } else {
    userRequestsCache.value = (userRequestsCache.value || []).filter(
      (r) => String(r?.status || '').trim().toLowerCase() !== 'pending'
    )
  }
  userRequestsCache.value = await fetchUserRequests()
}

const fetchData = async () => {
  loading.value = true
  try {
    const [dashboardRes, assignedRes, userReqs, employeeRes, linkedEmployeesRes] = await Promise.all([
      httpGet('/service-provider/dashboard-data'),
      httpGet('/user/service-provider/assigned-requests').catch(() => ({ data: [] })),
      fetchUserRequests(),
      httpGet('/employee/dashboard-data').catch(() => ({ data: null })),
      httpGet('/service-provider/linked-employees').catch(() => ({ data: [] })),
    ])
    provider.value = dashboardRes.data.provider
    user.value = dashboardRes.data.user
    businesses.value = dashboardRes.data.businesses || []
    revenueSummary.value = dashboardRes.data.revenue_summary || null
    providerReviews.value = Array.isArray(dashboardRes?.data?.reviews) ? dashboardRes.data.reviews : []
    assignedRequests.value = assignedRes.data || []
    linkedEmployeeRows.value = Array.isArray(linkedEmployeesRes?.data) ? linkedEmployeesRes.data : []
    userRequestsCache.value = userReqs || []
    employeeData.value = employeeRes?.data?.employee || null
  } catch (error) {
    try {
      const profileRes = await httpGet('/user/profile')
      if (profileRes?.data) user.value = profileRes.data
    } catch {}
    Swal.fire('Error', error?.response?.data?.message || 'Failed to load dashboard', 'error')
  } finally {
    loading.value = false
  }
}

const fetchNotifications = async () => {
  try {
    const res = await httpGet('/user/notifications')
    notifications.value = res.data || []
    hasNotifFetchError.value = false
  } catch {
    notifications.value = []
    if (!hasNotifFetchError.value) {
      hasNotifFetchError.value = true
      Swal.fire('Error', 'Failed to fetch notifications.', 'error')
    }
  }
}

const markRead = async (id) => {
  try {
    await axios.post(`/user/notifications/${id}/read`)
    const n = notifications.value.find(x => x.id === id)
    if (n) n.read_at = new Date().toISOString()
  } catch {}
}

const markAllNotificationsRead = async () => {
  const unread = (notifications.value || []).filter((n) => !n.read_at)
  if (!unread.length) return
  await Promise.all(unread.map((n) => markRead(n.id)))
}

const normalizeNotificationLink = (link) => {
  const raw = String(link || '').trim()
  if (!raw) return ''
  if (raw.startsWith('/service-provider/dashboard')) {
    return '/serviceprovider?section=hr-queue'
  }
  if (raw.startsWith('/serviceprovider?section=assigned-requests')) {
    return '/serviceprovider?section=hr-queue'
  }
  return raw
}

const openNotificationTarget = (note) => {
  const type = String(note?.type || '').toLowerCase()
  if (['hr_assignment', 'business_assignment'].includes(type)) {
    closeMenus()
    setSection('hr-queue')
    return
  }
  if (['employee_team_assignment', 'hr_team_assignment'].includes(type)) {
    closeMenus()
    setSection('team-assignment')
    return
  }

  const link = normalizeNotificationLink(note?.link)
  if (!link) return

  if (link.startsWith('/serviceprovider')) {
    try {
      const targetUrl = new URL(link, window.location.origin)
      const targetSection = normalizeSection(targetUrl.searchParams.get('section') || 'dashboard')
      closeMenus()
      setSection(targetSection)
      return
    } catch {}
  }

  window.location.assign(link)
}

const handleNotificationClick = async (note) => {
  if (!note?.read_at && note?.id) {
    await markRead(note.id)
  }
  openNotificationTarget(note)
}

const unreadCount = computed(() => notifications.value.filter(n => !n.read_at).length)
const userInitials = computed(() => {
  const first = String(user.value?.first_name || '').trim().charAt(0)
  const last = String(user.value?.last_name || '').trim().charAt(0)
  const result = `${first}${last}`.toUpperCase()
  return result || 'SP'
})
const serviceProviderProfileName = computed(() => {
  const name = String(user.value?.name || '').trim()
  if (name) return name

  const first = String(user.value?.first_name || '').trim()
  const middle = String(user.value?.middle_initial || '').trim()
  const last = String(user.value?.last_name || '').trim()
  const fallback = [first, middle ? `${middle}.` : '', last].filter(Boolean).join(' ').trim()
  return fallback || 'Service Provider'
})
const serviceProviderCategory = computed(() => {
  const category = String(provider.value?.category || '').trim()
  return category || 'General Service'
})
const serviceProviderContact = computed(() => {
  const phone = String(user.value?.contact_number || '').trim()
  const email = String(user.value?.email || '').trim()
  if (phone && email) return `${phone} | ${email}`
  return phone || email || 'No contact details'
})
const profileImageUrl = computed(() => {
  const raw = String(user.value?.profile_photo || '').trim()
  if (!raw) return ''
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw
  let normalized = raw.replace(/^\/+/, '').replace(/\\/g, '/')
  normalized = normalized.replace(/^storage\/app\/public\//, '')
  normalized = normalized.replace(/^public\//, '')
  normalized = normalized.replace(/^storage\//, '')
  return `/user/file?path=${encodeURIComponent(normalized)}`
})
const isProviderApproved = computed(() => {
  const userApproved = Boolean(user.value?.is_approved)
  const providerApproved = provider.value?.is_approved
  if (typeof providerApproved === 'undefined' || providerApproved === null) {
    return userApproved
  }
  return userApproved && Boolean(providerApproved)
})
const isCurrentEmployeeLeader = computed(() => {
  const ownRole = String(employeeData.value?.role || '').trim().toLowerCase()
  if (ownRole.includes('lead') || ownRole.includes('leader')) return true
  const me = (teamMembers.value || []).find((row) => Boolean(row?.is_you))
  const teamRole = String(me?.role || '').trim().toLowerCase()
  return teamRole.includes('lead') || teamRole.includes('leader')
})
const canManageWork = computed(() => {
  if (!isEmployeeRole.value) return true
  return staffPermissions.value.can_manage || staffPermissions.value.can_approve
})
const canApproveWork = computed(() => {
  if (!isEmployeeRole.value) return true
  return staffPermissions.value.can_approve
})
const canStartFromHrQueue = computed(() => {
  if (!isEmployeeRole.value) return true
  if (!canManageWork.value) return false
  return isCurrentEmployeeLeader.value
})
const canDecideFromHrQueue = computed(() => {
  if (!isEmployeeRole.value) return true
  if (!canManageWork.value) return false
  return isCurrentEmployeeLeader.value
})
const canCompleteFromHrQueue = computed(() => {
  if (!isEmployeeRole.value) return true
  if (!canApproveWork.value) return false
  return isCurrentEmployeeLeader.value
})
const normalizedScheduleTimeFrom = computed(() =>
  String(employeeData.value?.team_schedule_time_from || employeeData.value?.team_schedule_time || '').trim().slice(0, 5)
)
const normalizedScheduleTimeTo = computed(() =>
  String(employeeData.value?.team_schedule_time_to || '').trim().slice(0, 5)
)
const groupScheduleDateLabel = computed(() => {
  const date = String(employeeData.value?.team_schedule_date || '').trim()
  return date || 'Not set yet'
})
const groupScheduleTimeLabel = computed(() => {
  const timeFrom = normalizedScheduleTimeFrom.value
  const timeTo = normalizedScheduleTimeTo.value
  if (!timeFrom && !timeTo) return 'Not set yet'
  if (!timeTo) return timeFrom
  return `${timeFrom} - ${timeTo}`
})
const showScheduleMissingHint = computed(() => {
  const hasTeam = String(employeeData.value?.team || '').trim() !== ''
  const hasDate = groupScheduleDateLabel.value !== 'Not set yet'
  const hasTime = groupScheduleTimeLabel.value !== 'Not set yet'
  return hasTeam && !hasDate && !hasTime
})
const teamMembers = computed(() => {
  const rows = employeeData.value?.team_members
  return Array.isArray(rows) ? rows : []
})
const memberInitials = (name) => {
  const parts = String(name || '').trim().split(/\s+/).filter(Boolean)
  if (!parts.length) return 'TM'
  const first = parts[0]?.charAt(0) || ''
  const second = parts.length > 1 ? (parts[parts.length - 1]?.charAt(0) || '') : ''
  return `${first}${second}`.toUpperCase() || 'TM'
}
const teamMemberStatusLabel = (value) => {
  const status = String(value || '').trim().toLowerCase()
  if (status === 'accepted') return 'Accepted'
  if (status === 'pending') return 'Pending'
  if (status === 'rejected') return 'Reassigned'
  return 'Member'
}
const teamMemberStatusClass = (value) => {
  const status = String(value || '').trim().toLowerCase()
  if (status === 'accepted') return 'bg-emerald-100 text-emerald-700'
  if (status === 'pending') return 'bg-amber-100 text-amber-700'
  if (status === 'rejected') return 'bg-rose-100 text-rose-700'
  return 'bg-slate-100 text-slate-700'
}
const normalizedTeamAssignmentStatus = computed(() => {
  const raw = String(employeeData.value?.team_assignment_status || '').trim().toLowerCase()
  if (raw === 'accepted' || raw === 'pending' || raw === 'rejected') return raw
  const hasTeam = String(employeeData.value?.team || '').trim() !== ''
  return hasTeam ? 'accepted' : 'unassigned'
})
const normalizedTeamAssignmentSource = computed(() => {
  const raw = String(employeeData.value?.team_assignment_source || '').trim().toLowerCase()
  if (raw === 'hr' || raw === 'business') return raw
  const note = String(employeeData.value?.team_assignment_response_note || '').trim().toLowerCase()
  if (note.includes('business manager')) return 'business'
  return 'hr'
})
const teamAssignmentSourceLabel = computed(() => {
  const hasTeam = String(employeeData.value?.team || '').trim() !== ''
  if (!hasTeam || !isEmployeeRole.value) return ''
  return normalizedTeamAssignmentSource.value === 'business' ? 'Business-Managed' : 'HR-Managed'
})
const assignmentManagerLabel = computed(() =>
  normalizedTeamAssignmentSource.value === 'business' ? 'Business Manager' : 'HR Manager'
)
const teamAssignmentHeading = computed(() => {
  if (!isEmployeeRole.value) return 'Team Assignment'
  const hasTeam = String(employeeData.value?.team || '').trim() !== ''
  if (!hasTeam) return 'Team Assignment'
  return normalizedTeamAssignmentSource.value === 'business'
    ? 'Business Team Confirmation'
    : 'HR Team Confirmation'
})
const teamAssignmentPendingPublish = computed(() => Boolean(employeeData.value?.team_assignment_pending_publish))
const teamAssignmentPending = computed(() => normalizedTeamAssignmentStatus.value === 'pending')
const teamAssignmentAccepted = computed(() => normalizedTeamAssignmentStatus.value === 'accepted')
const teamAssignmentStatusLabel = computed(() => {
  const status = normalizedTeamAssignmentStatus.value
  if (status === 'accepted') return 'Accepted by you'
  if (status === 'pending') return 'Waiting for your approval'
  if (status === 'rejected') return 'Reassignment requested'
  return 'No team assignment yet'
})
const teamAssignmentBadgeClass = computed(() => {
  const status = normalizedTeamAssignmentStatus.value
  if (status === 'accepted') return 'border-emerald-300 bg-emerald-50 text-emerald-700'
  if (status === 'pending') return 'border-amber-300 bg-amber-50 text-amber-700'
  if (status === 'rejected') return 'border-rose-300 bg-rose-50 text-rose-700'
  return 'border-slate-300 bg-slate-100 text-slate-700'
})
const teamAssignmentDescription = computed(() => {
  if (!isEmployeeRole.value) {
    return 'This page is only for employee team confirmation.'
  }
  if (teamAssignmentPendingPublish.value) {
    return `Your team is assigned but still waiting for schedule publish by ${assignmentManagerLabel.value}.`
  }
  const status = normalizedTeamAssignmentStatus.value
  if (status === 'pending') {
    return `Your assigned team needs your confirmation before ${assignmentManagerLabel.value} finalizes your placement.`
  }
  if (status === 'accepted') {
    return 'Your team assignment is confirmed. You can proceed with assigned work items or request reassignment if needed.'
  }
  if (status === 'rejected') {
    return `You requested reassignment. ${assignmentManagerLabel.value} can provide a new team assignment.`
  }
  return 'No published team assignment has been issued yet.'
})
const teamAssignmentRespondedAtLabel = computed(() => {
  const raw = employeeData.value?.team_assignment_responded_at
  if (!raw) return 'Not responded yet'
  const date = new Date(raw)
  if (Number.isNaN(date.getTime())) return 'Updated recently'
  return date.toLocaleString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  })
})

const closeMenus = () => {
  showProfileMenu.value = false
  showNotificationsMenu.value = false
}

const toggleProfileMenu = () => {
  showProfileMenu.value = !showProfileMenu.value
  if (showProfileMenu.value) showNotificationsMenu.value = false
}

const toggleNotificationsMenu = async () => {
  const next = !showNotificationsMenu.value
  showNotificationsMenu.value = next
  if (next) {
    showProfileMenu.value = false
    await fetchNotifications()
    await markAllNotificationsRead()
  }
}

const openProfile = () => {
  closeMenus()
  setSection('profile')
}

const handleDocumentClick = (event) => {
  const nav = event.target?.closest?.('nav')
  if (!nav) {
    closeMenus()
  }
}
const requestHistory = computed(() =>
  (userRequestsCache.value || []).map((r) => ({
    ...r,
    first_name: r?.first_name || user.value?.first_name || 'N/A',
    middle_initial: r?.middle_initial || user.value?.middle_initial || '',
    last_name: r?.last_name || user.value?.last_name || 'N/A',
    business_name: r?.business?.business_name || r?.business_name || 'N/A',
  }))
)
const requestSeenStorageKey = computed(() => {
  const uid = String(user.value?.id || '').trim()
  return uid ? `sp_seen_requests_${uid}` : ''
})

const loadSeenRequestIds = () => {
  const key = requestSeenStorageKey.value
  if (!key) return
  try {
    const raw = localStorage.getItem(key)
    const list = raw ? JSON.parse(raw) : []
    const normalized = Array.isArray(list) ? list.map((x) => String(x)) : []
    seenRequestIds.value = new Set(normalized)
  } catch {
    seenRequestIds.value = new Set()
  }
}

const saveSeenRequestIds = () => {
  const key = requestSeenStorageKey.value
  if (!key) return
  try {
    localStorage.setItem(key, JSON.stringify([...seenRequestIds.value]))
  } catch {}
}

const markRequestsAsSeen = () => {
  const ids = (requestHistory.value || [])
    .map((r) => String(r?.id || '').trim())
    .filter(Boolean)
  if (!ids.length) return
  const next = new Set(seenRequestIds.value)
  let changed = false
  ids.forEach((id) => {
    if (next.has(id)) return
    next.add(id)
    changed = true
  })
  if (!changed) return
  seenRequestIds.value = next
  saveSeenRequestIds()
}

const unseenRequestCount = computed(() =>
  (requestHistory.value || []).filter((r) => {
    const id = String(r?.id || '').trim()
    if (!id) return false
    return !seenRequestIds.value.has(id)
  }).length
)

const hasAssignedInspector = (request) => {
  const employeeId = Number(request?.employee_id || 0)
  if (Number.isFinite(employeeId) && employeeId > 0) return true
  if (String(request?.assigned_employee_name || '').trim()) return true
  if (String(request?.assigned_team || '').trim()) return true
  return false
}
const hrQueueRequests = computed(() =>
  (assignedRequests.value || []).filter((r) => {
    const status = String(r?.status || '').toLowerCase()
    const fromHr = Number(r?.assigned_by_user_id || 0) > 0 || !!r?.assigned_at
    if (status === 'assigned') return fromHr || status === 'assigned'
    if (status === 'awaiting_material') return hasAssignedInspector(r)
    return false
  })
)
const hrQueueCount = computed(() => hrQueueRequests.value.length)
const bookingQueueTitle = computed(() => 'Service Requests')
const bookingQueueSubtitle = computed(() =>
  isEmployeeRole.value
    ? 'Inspection, completion, payment logging, and warranty handling.'
    : 'Review assigned requests, accept them into materials readiness, dispatch linked employees, and complete service follow-through.'
)
const linkedEmployees = computed(() => {
  const statsByEmployeeId = new Map()
  const statsByEmployeeName = new Map()
  const activeStatuses = new Set(['assigned', 'awaiting_material', 'job_ready', 'in_progress'])

  ;(assignedRequests.value || []).forEach((request) => {
    const status = String(request?.status || '').trim().toLowerCase()
    const isActive = activeStatuses.has(status)
    const isCompleted = status === 'completed'
    if (!isActive && !isCompleted) return

    const employeeId = Number(request?.employee_id || 0)
    const employeeName = String(request?.assigned_employee_name || '').trim().toLowerCase()

    if (employeeId > 0) {
      const current = statsByEmployeeId.get(employeeId) || { active_jobs: 0, completed_jobs: 0 }
      if (isActive) current.active_jobs += 1
      if (isCompleted) current.completed_jobs += 1
      statsByEmployeeId.set(employeeId, current)
    }

    if (employeeName) {
      const currentByName = statsByEmployeeName.get(employeeName) || { active_jobs: 0, completed_jobs: 0 }
      if (isActive) currentByName.active_jobs += 1
      if (isCompleted) currentByName.completed_jobs += 1
      statsByEmployeeName.set(employeeName, currentByName)
    }
  })

  return (linkedEmployeeRows.value || []).map((employeeRaw, index) => {
    const employeeId = Number(employeeRaw?.id || 0)
    const name = String(employeeRaw?.name || '').trim()
    const nameKey = name.toLowerCase()
    const stats =
      (employeeId > 0 ? statsByEmployeeId.get(employeeId) : null) ||
      (nameKey ? statsByEmployeeName.get(nameKey) : null) ||
      { active_jobs: 0, completed_jobs: 0 }

    return {
      id: employeeId > 0 ? employeeId : `employee-${nameKey || String(employeeRaw?.user_id || index)}`,
      name: name || (employeeId > 0 ? `Employee #${employeeId}` : 'Employee'),
      email: String(employeeRaw?.email || '').trim(),
      role: String(employeeRaw?.role || '').trim(),
      team: String(employeeRaw?.team || '').trim(),
      status: String(employeeRaw?.status || '').trim(),
      active_jobs: Number(stats.active_jobs || 0),
      completed_jobs: Number(stats.completed_jobs || 0),
    }
  }).sort((a, b) => {
    if (b.active_jobs !== a.active_jobs) return b.active_jobs - a.active_jobs
    return String(a.name || '').localeCompare(String(b.name || ''))
  })
})
const linkedEmployeesTotalPages = computed(() => Math.max(1, Math.ceil(linkedEmployees.value.length / LINKED_EMPLOYEES_PAGE_SIZE)))
const pagedLinkedEmployees = computed(() => {
  const start = (Math.max(Number(linkedEmployeesPage.value) || 1, 1) - 1) * LINKED_EMPLOYEES_PAGE_SIZE
  return linkedEmployees.value.slice(start, start + LINKED_EMPLOYEES_PAGE_SIZE)
})
const linkedEmployeesPageRange = computed(() => {
  if (!linkedEmployees.value.length) {
    return { start: 0, end: 0 }
  }
  const page = Math.max(Number(linkedEmployeesPage.value) || 1, 1)
  return {
    start: (page - 1) * LINKED_EMPLOYEES_PAGE_SIZE + 1,
    end: Math.min(page * LINKED_EMPLOYEES_PAGE_SIZE, linkedEmployees.value.length),
  }
})
const clampLinkedEmployeesPage = () => {
  const next = Math.min(Math.max(Number(linkedEmployeesPage.value) || 1, 1), linkedEmployeesTotalPages.value)
  if (next !== linkedEmployeesPage.value) {
    linkedEmployeesPage.value = next
  }
}
const nextLinkedEmployeesPage = () => {
  if (linkedEmployeesPage.value < linkedEmployeesTotalPages.value) {
    linkedEmployeesPage.value += 1
  }
}
const prevLinkedEmployeesPage = () => {
  if (linkedEmployeesPage.value > 1) {
    linkedEmployeesPage.value -= 1
  }
}
watch(linkedEmployees, clampLinkedEmployeesPage, { immediate: true })
const dispatchQueueRequests = computed(() =>
  (assignedRequests.value || []).filter((request) => {
    const status = String(request?.status || '').trim().toLowerCase()
    if (status !== 'awaiting_material') return false
    return !hasAssignedInspector(request)
  })
)
const upcomingSchedules = computed(() =>
  dispatchQueueRequests.value
    .map((request) => ({
      id: request?.id,
      preferred_date: String(request?.preferred_date || '').trim(),
      service_time: String(request?.service_time || '').trim(),
      customer: `${String(request?.first_name || '').trim()} ${String(request?.last_name || '').trim()}`.trim() || 'N/A',
      service_type: request?.service_type || 'N/A',
      assigned_employee_name: request?.assigned_employee_name || 'Unassigned',
      status: request?.status || 'N/A',
    }))
    .filter((row) => /^\d{4}-\d{2}-\d{2}$/.test(row.preferred_date))
    .sort((a, b) => a.preferred_date.localeCompare(b.preferred_date))
)
const paymentQueueRequests = computed(() =>
  (assignedRequests.value || []).filter((request) => {
    const status = String(request?.status || '').trim().toLowerCase()
    return status === 'completed'
  })
)
const warrantyQueueRequests = computed(() =>
  (assignedRequests.value || []).filter((request) => {
    const status = String(request?.status || '').trim().toLowerCase()
    const warrantyStatus = String(request?.warranty_status || '').trim().toLowerCase()
    return (
      status === 'warranty_pending'
      || status === 'warranty_rework'
      || warrantyStatus === 'claimed'
      || warrantyStatus === 'rework_scheduled'
      || (String(request?.notes || '').toUpperCase().includes('[WARRANTY_CLAIM:') && status !== 'completed')
    )
  })
)
const warrantyQueueCount = computed(() => warrantyQueueRequests.value.length)
const reportMetrics = computed(() => {
  const rows = assignedRequests.value || []
  const activeCount = rows.filter((request) => {
    const status = String(request?.status || '').trim().toLowerCase()
    return ['assigned', 'awaiting_material', 'job_ready', 'in_progress'].includes(status)
  }).length
  const completedCount = rows.filter((request) =>
    String(request?.status || '').trim().toLowerCase() === 'completed'
  ).length
  const rejectedCount = rows.filter((request) =>
    String(request?.status || '').trim().toLowerCase() === 'rejected'
  ).length
  return {
    activeCount,
    completedCount,
    rejectedCount,
    totalCount: rows.length,
    grossTotal: Number(revenueSummary.value?.gross_total || 0),
    businessTotal: Number(revenueSummary.value?.business_total || 0),
    employeePoolTotal: Number(revenueSummary.value?.employee_pool_total || 0),
  }
})
const pendingApprovalsCount = computed(() =>
  (assignedRequests.value || []).filter((request) => {
    const status = String(request?.status || '').trim().toLowerCase()
    return status === 'assigned'
  }).length
)
const topEmployeeSummary = computed(() => {
  const rows = linkedEmployees.value || []
  if (!rows.length) return 'No linked employee performance data yet.'
  const top = [...rows].sort((a, b) => {
    if (b.completed_jobs !== a.completed_jobs) return b.completed_jobs - a.completed_jobs
    if (b.active_jobs !== a.active_jobs) return b.active_jobs - a.active_jobs
    return String(a.name || '').localeCompare(String(b.name || ''))
  })[0]
  return `${top.name} - ${top.completed_jobs} completed job${top.completed_jobs === 1 ? '' : 's'}, ${top.active_jobs} active.`
})
const customerSatisfactionSummary = computed(() => {
  const rows = Array.isArray(providerReviews.value) ? providerReviews.value : []
  if (!rows.length) return 'No customer feedback ratings yet.'
  const ratings = rows
    .map((row) => Number(row?.rating || 0))
    .filter((value) => Number.isFinite(value) && value > 0)
  if (!ratings.length) return 'No customer feedback ratings yet.'
  const average = ratings.reduce((total, value) => total + value, 0) / ratings.length
  return `${average.toFixed(1)}/5 average rating from ${ratings.length} feedback entr${ratings.length === 1 ? 'y' : 'ies'}.`
})
const formatCurrency = (value) => {
  const amount = Number(value || 0)
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP' }).format(
    Number.isFinite(amount) ? amount : 0
  )
}
const formatScheduleDate = (value) => {
  const raw = String(value || '').trim()
  if (!raw) return 'N/A'
  const parsed = new Date(`${raw}T00:00:00`)
  if (Number.isNaN(parsed.getTime())) return raw
  return parsed.toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  })
}
const formatScheduleStatus = (value) => {
  const s = String(value || '').trim().toLowerCase()
  if (s === 'awaiting_material') return 'Awaiting Materials'
  if (s === 'job_ready') return 'Ready for Dispatch'
  if (s === 'in_progress' || s === 'ongoing') return 'Work in Progress'
  if (s === 'completed') return 'Completed'
  if (s === 'assigned') return 'Awaiting Acceptance'
  return value || 'N/A'
}
const sidebarBadge = (key) => {
  if (key === 'team-assignment' && teamAssignmentPending.value) return '!'
  if (key === 'hr-queue' && hrQueueCount.value > 0) return hrQueueCount.value
  if (key === 'requests' && unseenRequestCount.value > 0) return unseenRequestCount.value
  if (key === 'employees' && linkedEmployees.value.length > 0) return linkedEmployees.value.length
  if (key === 'schedules' && upcomingSchedules.value.length > 0) return upcomingSchedules.value.length
  if (key === 'payments' && paymentQueueRequests.value.length > 0) return paymentQueueRequests.value.length
  if (key === 'warranty' && warrantyQueueCount.value > 0) return warrantyQueueCount.value
  return null
}
const sidebarBadgeClass = (key) => {
  if (key === 'warranty') return 'bg-rose-100 text-rose-700'
  if (key === 'payments') return 'bg-emerald-100 text-emerald-700'
  return 'bg-amber-100 text-amber-700'
}

const pendingUserRequest = computed(() =>
  (userRequestsCache.value || []).find(r => String(r.status || '').trim().toLowerCase() === 'pending') || null
)

const requestLocked = computed(() => !!pendingUserRequest.value)

const lockMessage = computed(() => {
  if (!pendingUserRequest.value) return ''
  const name = pendingUserRequest.value.business?.business_name || pendingUserRequest.value.business_name || 'a business'
  return `You already requested ${name}. Cancel it before requesting another.`
})

const showApprovalGreeting = async () => {
  const note = notifications.value.find(
    n => !n.read_at && n.type === 'service_provider_application' && String(n.title || '').toLowerCase().includes('approved')
  )
  if (!note) return
  await Swal.fire({
    title: `Welcome, ${user.value?.first_name || 'Provider'}!`,
    text: note.message,
    icon: 'success'
  })
  await markRead(note.id)
}

const startRealtime = () => {
  if(!window.Echo || !user.value?.id || realtimeChannel) return
  realtimeChannel = window.Echo.private(`users.${user.value.id}`)
  realtimeChannel.listen('.user.notification', async (e)=>{
    if(e?.notification){
      notifications.value = [e.notification, ...notifications.value]
      await showApprovalGreeting()
    } else {
      fetchNotifications()
    }
  })
}

const stopRealtime = () => {
  if(!window.Echo || !user.value?.id || !realtimeChannel) return
  window.Echo.leave(`users.${user.value.id}`)
  realtimeChannel = null
}

const respondTeamAssignment = async (action) => {
  if (!isEmployeeRole.value) return
  if (!employeeData.value?.id || !employeeData.value?.team) {
    Swal.fire('Warning', 'No team assignment found.', 'warning')
    return
  }

  let reason = null
  if (action === 'reject') {
    const result = await Swal.fire({
      title: 'Request reassignment?',
      text: `Provide a reason so ${assignmentManagerLabel.value} can review and assign you to another team.`,
      input: 'text',
      inputLabel: 'Reason (optional)',
      inputPlaceholder: 'e.g. Skill mismatch',
      showCancelButton: true,
      confirmButtonText: 'Submit Request',
      confirmButtonColor: '#dc2626',
    })
    if (!result.isConfirmed) return
    reason = result.value || null
  } else {
    const result = await Swal.fire({
      title: 'Accept team assignment?',
      text: `Confirm assignment to ${employeeData.value.team}.`,
      icon: 'question',
      showCancelButton: true,
      confirmButtonText: 'Accept Team',
    })
    if (!result.isConfirmed) return
  }

  submittingTeamDecision.value = true
  try {
    const res = await axios.patch('/employee/team-assignment/respond', { action, reason })
    if (res?.data?.employee) {
      employeeData.value = { ...employeeData.value, ...res.data.employee }
    }
    Swal.fire('Success', res?.data?.message || 'Team assignment updated.', 'success')
    await fetchNotifications()
  } catch (err) {
    Swal.fire('Error', err?.response?.data?.message || 'Failed to update team assignment.', 'error')
  } finally {
    submittingTeamDecision.value = false
  }
}

const confirmLogout = ()=> {
  confirmAndLogout()
}

onMounted(async () => {
  setSectionInUrl(section.value)
  await Promise.all([fetchData(), fetchNotifications()])
  await showApprovalGreeting()
  startRealtime()
  document.addEventListener('click', handleDocumentClick)
})

onBeforeUnmount(() => {
  stopRealtime()
  document.removeEventListener('click', handleDocumentClick)
})

watch(() => user.value?.id, (id)=>{
  if(id) {
    startRealtime()
    loadSeenRequestIds()
    if (section.value === 'requests') markRequestsAsSeen()
  }
})

watch(
  () => requestHistory.value.map((r) => String(r?.id || '')).join(','),
  () => {
    if (section.value === 'requests') markRequestsAsSeen()
  }
)
</script>






