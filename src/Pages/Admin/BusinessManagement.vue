<template>
  <div class="space-y-6">
    <section class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
      <p class="text-xs font-semibold uppercase tracking-[0.14em] text-cyan-700">Business Managed</p>
      <h2 class="mt-2 text-2xl font-black text-slate-900">Business Management Dashboard</h2>
      <p class="mt-2 text-sm text-slate-600">
        When you click Business Management, this workspace shows team, pricing, and reporting controls for business-managed flow.
      </p>
    </section>

    <section class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
      <article
        v-for="item in dashboardModules"
        :key="item.title"
        class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm"
      >
        <p class="text-xs font-semibold uppercase tracking-wide text-slate-500">Dashboard Shows</p>
        <h3 class="mt-2 text-base font-extrabold text-slate-900">{{ item.title }}</h3>
        <p class="mt-2 text-sm text-slate-600">{{ item.description }}</p>
      </article>
    </section>

    <section class="grid grid-cols-1 gap-5 xl:grid-cols-2">
      <article class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
        <div class="flex items-start justify-between gap-3">
          <h3 class="text-lg font-black text-slate-900">4. Employee Management</h3>
          <span class="rounded-full bg-cyan-50 px-2.5 py-1 text-xs font-bold text-cyan-700">Core</span>
        </div>
        <ul class="mt-4 space-y-3 text-sm text-slate-700">
          <li
            v-for="task in employeeManagementTasks"
            :key="task"
            class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5"
          >
            {{ task }}
          </li>
        </ul>
      </article>

      <article class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
        <div class="flex items-start justify-between gap-3">
          <h3 class="text-lg font-black text-slate-900">5. Service Pricing Management</h3>
          <span class="rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-bold text-emerald-700">Pricing Engine</span>
        </div>
        <ul class="mt-4 space-y-3 text-sm text-slate-700">
          <li
            v-for="task in servicePricingTasks"
            :key="task"
            class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5"
          >
            {{ task }}
          </li>
        </ul>
      </article>

      <article class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
        <div class="flex items-start justify-between gap-3">
          <h3 class="text-lg font-black text-slate-900">6. Team / Service Overview</h3>
          <span class="rounded-full bg-indigo-50 px-2.5 py-1 text-xs font-bold text-indigo-700">Monitoring</span>
        </div>
        <ul class="mt-4 space-y-3 text-sm text-slate-700">
          <li
            v-for="task in teamOverviewTasks"
            :key="task"
            class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5"
          >
            {{ task }}
          </li>
        </ul>
      </article>

      <article class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
        <div class="flex items-start justify-between gap-3">
          <h3 class="text-lg font-black text-slate-900">7. Reports</h3>
          <span class="rounded-full bg-amber-50 px-2.5 py-1 text-xs font-bold text-amber-700">Insights</span>
        </div>
        <ul class="mt-4 space-y-3 text-sm text-slate-700">
          <li
            v-for="task in reportTasks"
            :key="task"
            class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5"
          >
            {{ task }}
          </li>
        </ul>
      </article>
    </section>

    <section class="rounded-2xl border border-rose-200 bg-rose-50 p-4 sm:p-5">
      <p class="text-sm font-semibold text-rose-700">
        Note: No operational control over schedules. Scheduling is handled by HR.
      </p>
    </section>
  </div>
</template>

<script setup>
const dashboardModules = [
  {
    title: 'Employee / Service Provider Management',
    description: 'Create, approve, and assign employees and service providers based on business needs.',
  },
  {
    title: 'Service Pricing Management',
    description: 'Set base prices and dynamic pricing rules that are automatically applied on bookings.',
  },
  {
    title: 'Team Overview',
    description: 'Track teams, assigned employees, offered services, bookings, and revenue direction.',
  },
  {
    title: 'Reports / Analytics',
    description: 'Generate service, revenue, and workforce reports for business-level performance review.',
  },
]

const employeeManagementTasks = [
  'Create employee accounts: enter name, contact, credentials, and role.',
  'Approve employees: approve or reject employee onboarding for the business.',
  'Assign employees to teams: map employees to specific service teams.',
]

const servicePricingTasks = [
  'Select service to set price (example: Siphoning, Minor Plumbing, Major Plumbing).',
  'Enter base price (example: Siphoning = PHP 5,500).',
  'Add dynamic modifiers: distance fee, urgency fee, and complexity percentage.',
  'Save pricing rules so all bookings use the same pricing engine automatically.',
]

const teamOverviewTasks = [
  'View teams and assigned employees.',
  'View services offered and applied pricing rules.',
  'Monitor high-level KPIs like total bookings and revenue trends.',
]

const reportTasks = [
  'Generate total bookings per service.',
  'Generate revenue trend reports.',
  'Generate employee and team overview reports.',
]
</script>
