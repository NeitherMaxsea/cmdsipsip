<template>
  <aside class="sticky top-0 flex h-screen w-64 flex-col gap-3 overflow-y-auto border-r border-slate-200 bg-white p-4 text-slate-900 shadow-[2px_0_10px_rgba(15,23,42,0.04)] max-[960px]:static max-[960px]:h-auto max-[960px]:w-full max-[960px]:overflow-y-visible">
    <div class="rounded-[14px] border border-slate-200 bg-white p-3.5">
      <p class="m-0 text-[11px] font-bold uppercase tracking-[0.12em]" :class="isEmployeeRole ? 'text-sky-500' : 'text-teal-500'">
        {{ isEmployeeRole ? 'Employee Workspace' : 'Human Resources' }}
      </p>
      <h2 class="m-0 mt-1.5 text-[40px] font-extrabold leading-[1.1] tracking-[-0.02em]">
        {{ isEmployeeRole ? 'Employee View' : 'HR Workspace' }}
      </h2>
      <p class="m-0 mt-2 text-[13px] text-slate-500">
        {{ isEmployeeRole ? 'HR modules filtered by RBAC.' : (locked ? 'Company account review is still in progress. Tabs stay locked until admin approval.' : 'Workforce, accreditation, payroll, and team oversight') }}
      </p>
    </div>

    <div class="rounded-[14px] border border-slate-200 bg-white px-2.5 py-3" v-for="group in navGroups" :key="group.title">
      <button
        type="button"
        class="mx-0.5 mb-2 flex w-full items-center justify-between bg-transparent px-1 py-0 text-left"
        @click="toggleGroup(group.title)"
      >
        <span class="m-0 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">{{ group.title }}</span>
        <span class="text-sm text-slate-400 transition-transform duration-200" :class="{ 'rotate-180': isGroupOpen(group.title) }">v</span>
      </button>
      <nav v-show="isGroupOpen(group.title)" class="flex flex-col gap-1.5">
        <button
          v-for="item in group.items"
          :key="item.path"
          type="button"
          :disabled="locked && !isEmployeeRole"
          class="flex w-full items-center gap-2.5 rounded-xl px-3 py-[11px] text-left text-[13px] font-semibold transition-all"
          :class="[
            isItemActive(item)
              ? 'border border-teal-500 bg-teal-500 text-white shadow-[0_6px_16px_rgba(20,184,166,0.28)] hover:border-teal-500 hover:bg-teal-500 hover:text-white'
              : 'border border-transparent bg-white text-slate-700 hover:border-slate-200 hover:bg-slate-50 hover:text-slate-900',
            locked && !isEmployeeRole ? 'cursor-not-allowed opacity-55 hover:border-transparent hover:bg-white hover:text-slate-700' : '',
          ]"
          @click="handleItemClick(item)"
        >
          <span
            class="inline-flex h-[30px] w-[30px] shrink-0 items-center justify-center rounded-lg text-[11px] font-extrabold"
            :class="isItemActive(item)
              ? 'border border-white/35 bg-white/20 text-white'
              : 'border border-slate-200 bg-slate-50 text-slate-600'"
          >
            {{ item.icon }}
          </span>
          <span class="leading-[1.2]">{{ item.label }}</span>
        </button>
      </nav>
    </div>

  </aside>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { usePage } from '@inertiajs/vue3'
import {
  employeeSidebarItems,
  resolveEmployeeAccessLevel,
  resolveEmployeeModuleAccessLevel,
  resolveEmployeeModuleKeyFromPath,
} from '@/lib/employee-rbac'

const props = defineProps({
  activeMenu: {
    type: String,
    default: '',
  },
  locked: {
    type: Boolean,
    default: false,
  },
})
const emit = defineEmits(['navigate'])

const page = usePage()
const isHrManager = computed(() => Boolean(page.props?.auth?.flags?.is_hr_manager))
const isEmployeeRole = computed(
  () => String(page.props?.auth?.user?.role || '').trim().toLowerCase() === 'employee'
)
const employeeRbac = computed(() => page.props?.auth?.employee_rbac || null)
const employeeMenuItems = computed(() => employeeSidebarItems(employeeRbac.value))
const employeeMenuGroups = computed(() => {
  const items = employeeMenuItems.value
  const pick = (labels) => items.filter((item) => labels.includes(item.label))
    return [
      { title: 'Core', items: pick(['Dashboard', 'Assigned Requests']) },
      { title: 'People', items: pick(['Provider Accreditation', 'Employee Management', 'Approval Queue', 'Team Assignment']) },
      { title: 'Approvals', items: pick(['Payroll']) },
    { title: 'Reports', items: pick(['Reports']) },
    { title: 'Settings', items: pick(['Settings']) },
  ].filter((group) => group.items.length > 0)
})
const employeeAccessLevel = computed(() => resolveEmployeeAccessLevel(employeeRbac.value || {}))
const employeeAccessLabel = computed(() => {
  if (!isEmployeeRole.value) return ''
  if (employeeAccessLevel.value === 'view') return 'View only'
  if (employeeAccessLevel.value === 'manage') return 'Manage'
  if (employeeAccessLevel.value === 'approve') return 'Approve'
  return ''
})
const currentUrl = computed(() => String(page.url || ''))
const currentPath = computed(() => {
  const url = String(page.url || '')
  return url.split('?')[0] || ''
})
const normalizeEmployeeHrPath = (path) => {
  const value = String(path || '')
  if (!value) return value
  if (value.startsWith('/employee/hr')) return value
  if (value === '/hr') return '/employee/hr'
  if (value.startsWith('/hr/')) return `/employee${value}`
  return value
}
const normalizedPath = computed(() =>
  isEmployeeRole.value ? normalizeEmployeeHrPath(currentPath.value) : currentPath.value
)
const normalizedUrl = computed(() =>
  isEmployeeRole.value ? normalizeEmployeeHrPath(currentUrl.value) : currentUrl.value
)
const isEmployeeHrRoute = computed(() =>
  isEmployeeRole.value && normalizedPath.value.startsWith('/employee/hr')
)
const currentEmployeeModuleKey = computed(() => {
  const match = employeeMenuItems.value.find((item) =>
    normalizeEmployeeHrPath(item.path) === normalizedPath.value
    || normalizeEmployeeHrPath(item.path) === normalizedUrl.value
  )
  if (match?.moduleKey) return match.moduleKey
  return resolveEmployeeModuleKeyFromPath(normalizedPath.value)
})
const employeeModuleAccessLevel = computed(() =>
  resolveEmployeeModuleAccessLevel(employeeRbac.value || {}, currentEmployeeModuleKey.value)
)
const openGroupTitle = ref('')

const navGroups = computed(() => {
  if (isEmployeeRole.value) {
    return employeeMenuGroups.value.length
      ? employeeMenuGroups.value
      : [{ title: 'HR Modules', items: [] }]
  }

  return [
    {
      title: 'Core Workflow',
      items: [
        { label: 'Dashboard', path: '/HR/HrBusinessShell', icon: 'DB' },
      ],
    },
    {
      title: 'People',
        items: [
          { label: 'Provider Accreditation', path: '/hr/service-providers', icon: 'PA' },
          { label: 'Employee Management', path: '/hr/recruitment', icon: 'EM' },
          { label: 'Approval Queue', path: '/hr/approval-queue', icon: 'AQ' },
          { label: 'Team Assignment', path: '/hr/linked-employees', icon: 'TA' },
          { label: 'Payroll', path: '/hr/payroll', icon: 'PY' },
        ],
    },
    {
      title: 'Reports',
      items: [
        { label: 'Reports', path: '/hr/reports', icon: 'RP' },
      ],
    },
    {
      title: 'Workspace',
      items: [
        { label: 'Settings', path: '/hr/settings', icon: 'ST' },
      ],
    },
  ]
})

const resolveGroupForActiveMenu = (menu) => {
  if (isEmployeeRole.value) {
    const byPath = navGroups.value.find((group) =>
      (group.items || []).some((item) => normalizeEmployeeHrPath(item.path) === normalizedPath.value)
    )
    return byPath?.title || navGroups.value[0]?.title || ''
  }
  const byLabel = navGroups.value.find((group) =>
    (group.items || []).some((item) => item.label === menu)
  )
  if (byLabel?.title) return byLabel.title

  const byPath = navGroups.value.find((group) =>
    (group.items || []).some((item) => item.path === currentPath.value)
  )
  return byPath?.title || 'Core Workflow'
}

watch(
  () => props.activeMenu,
  (menu) => {
    openGroupTitle.value = resolveGroupForActiveMenu(menu)
  },
  { immediate: true }
)

const isGroupOpen = (title) => openGroupTitle.value === title

const toggleGroup = (title) => {
  openGroupTitle.value = openGroupTitle.value === title ? '' : title
}

const isItemActive = (item) => {
  if (!item || !item.path) return false
  if (isEmployeeRole.value) {
    if (item.path.includes('?')) {
      return normalizedUrl.value === normalizeEmployeeHrPath(item.path)
    }
    return normalizedPath.value === normalizeEmployeeHrPath(item.path)
  }
  if (props.activeMenu) {
    return props.activeMenu === item.label
  }
  if (item.path.includes('?')) {
    return currentUrl.value === item.path
  }
  return currentPath.value === item.path
}

const handleItemClick = (item) => {
  if (props.locked && !isEmployeeRole.value) return
  emit('navigate', item.label, item.path)
}

watch(
  [normalizedPath, employeeMenuGroups],
  () => {
    if (!isEmployeeRole.value) return
    const match = employeeMenuGroups.value.find((group) =>
      group.items.some((item) => normalizeEmployeeHrPath(item.path) === normalizedPath.value)
    )
    if (match?.title) {
      openGroupTitle.value = match.title
      return
    }
    if (!openGroupTitle.value && employeeMenuGroups.value[0]) {
      openGroupTitle.value = employeeMenuGroups.value[0].title
    }
  },
  { immediate: true }
)

const updateBodyViewOnlyClass = () => {
  if (typeof document === 'undefined') return
  const shouldEnable = isEmployeeRole.value
    && currentEmployeeModuleKey.value
    && employeeModuleAccessLevel.value === 'view'
  document.body.classList.toggle('employee-view-only', shouldEnable)
}

watch([isEmployeeRole, employeeModuleAccessLevel, currentEmployeeModuleKey], updateBodyViewOnlyClass, { immediate: true })

onMounted(updateBodyViewOnlyClass)

onBeforeUnmount(() => {
  if (typeof document !== 'undefined') {
    document.body.classList.remove('employee-view-only')
  }
})
</script>
