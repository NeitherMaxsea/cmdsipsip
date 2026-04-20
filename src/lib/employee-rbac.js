export const normalizeStaffPermissions = (raw, options = {}) => {
  const hasEmployee = options?.hasEmployee ?? true
  if (!hasEmployee) {
    return { can_view: false, can_manage: false, can_approve: false }
  }

  return {
    can_view: raw?.can_view ?? true,
    can_manage: raw?.can_manage ?? false,
    can_approve: raw?.can_approve ?? false,
  }
}

const normalizeModulePermissions = (value, fallback = null) => ({
  can_view: value?.can_view ?? fallback?.can_view ?? false,
  can_manage: value?.can_manage ?? fallback?.can_manage ?? false,
  can_approve: value?.can_approve ?? fallback?.can_approve ?? false,
})

export const resolveEmployeeAccessLevel = (permissions) => {
  if (permissions?.modules && typeof permissions.modules === 'object') {
    const rows = Object.values(permissions.modules)
    const canApprove = rows.some((row) => row?.can_approve)
    const canManage = rows.some((row) => row?.can_manage)
    const canView = rows.some((row) => row?.can_view)
    if (canApprove) return 'approve'
    if (canManage) return 'manage'
    if (canView) return 'view'
    return 'none'
  }

  if (permissions?.can_approve) return 'approve'
  if (permissions?.can_manage) return 'manage'
  if (permissions?.can_view) return 'view'
  return 'none'
}

export const resolveEmployeeModuleAccessLevel = (permissions, moduleKey) => {
  if (!moduleKey) return 'none'
  const modulePermissions = permissions?.modules?.[moduleKey]
  const fallback = permissions?.modules && typeof permissions.modules === 'object' ? null : permissions
  const normalized = normalizeModulePermissions(modulePermissions, fallback)
  if (normalized.can_approve) return 'approve'
  if (normalized.can_manage) return 'manage'
  if (normalized.can_view) return 'view'
  return 'none'
}

const moduleEnabled = (permissions) => {
  return Boolean(
    permissions?.can_view ||
    permissions?.can_manage ||
    permissions?.can_approve
  )
}

const resolveModulePermissions = (permissions, moduleKey) => {
  const fallback = permissions?.modules && typeof permissions.modules === 'object' ? null : permissions
  return normalizeModulePermissions(permissions?.modules?.[moduleKey], fallback)
}

export const employeeSidebarItems = (permissions) => {
  const items = [
    { key: 'dashboard', label: 'Dashboard', icon: 'DB', path: '/employee/dashboard', moduleKey: null },
    { key: 'assigned-requests', label: 'Assigned Requests', icon: 'AR', path: '/employee/assigned-requests', moduleKey: null },
  ]

  const hrItems = [
    { key: 'service-providers', label: 'Provider Accreditation', icon: 'PA', path: '/employee/hr/service-providers', moduleKey: 'service_providers' },
    { key: 'employee-management', label: 'Employee Management', icon: 'EM', path: '/employee/hr/recruitment', moduleKey: 'employee_management' },
    { key: 'approval-queue', label: 'Approval Queue', icon: 'AQ', path: '/employee/hr/approval-queue', moduleKey: 'approval_queue' },
    { key: 'linked-employees', label: 'Team Assignment', icon: 'TA', path: '/employee/hr/linked-employees', moduleKey: 'linked_employees' },
    { key: 'payroll', label: 'Payroll', icon: 'PY', path: '/employee/hr/payroll', moduleKey: 'payroll' },
    { key: 'reports', label: 'Reports', icon: 'RP', path: '/employee/hr/reports', moduleKey: 'reports' },
  ].filter((item) => moduleEnabled(resolveModulePermissions(permissions, item.moduleKey)))

  return items.concat(hrItems)
}

export const employeeSidebarNote = (permissions) => {
  const level = resolveEmployeeAccessLevel(permissions)
  if (level === 'none') {
    return 'No modules enabled. Ask HR to grant view access.'
  }

  const label = level === 'approve'
    ? 'Approve'
    : level === 'manage'
      ? 'Manage'
      : 'View'

  return `HR modules enabled (${label} level).`
}

export const resolveEmployeeModuleKeyFromPath = (path) => {
  const value = `${path || ''}`.split('?')[0]
  if (!value) return null
  if (value.startsWith('/employee/hr/service-providers') || value.startsWith('/hr/service-providers')) return 'service_providers'
  if (value.startsWith('/employee/hr/linked-employees') || value.startsWith('/hr/linked-employees')) return 'linked_employees'
  if (value.startsWith('/employee/hr/recruitment') || value.startsWith('/hr/recruitment')) return 'employee_management'
  if (value.startsWith('/employee/hr/approval-queue') || value.startsWith('/hr/approval-queue') || value.startsWith('/hr/hr-manager')) return 'approval_queue'
  if (value.startsWith('/employee/hr/payroll') || value.startsWith('/hr/payroll')) return 'payroll'
  if (value.startsWith('/employee/hr/reports') || value.startsWith('/hr/reports')) return 'reports'
  return null
}

const trimText = (value) => String(value ?? '').trim()
const normalizeRbacRole = (row = {}) => trimText(
  row?.role
  || row?.staff_role
  || row?.position
  || row?.job_title
  || row?.designation
).toLowerCase().replace(/[\s-]+/g, '_')

const selectableRbacRoles = new Set(['employee', 'hr'])

export const isSelectableRbacEmployeeRow = (row = {}) => {
  const role = normalizeRbacRole(row)
  if (!role) return true
  return selectableRbacRoles.has(role)
}

const resolveEmployeeDisplayName = (row = {}) => {
  const directName = trimText(row?.name || row?.display_name || row?.fullName)
  if (directName) return directName

  const firstName = trimText(row?.first_name || row?.given_name)
  const middleInitial = trimText(row?.middle_initial || row?.middle_name)
  const lastName = trimText(row?.last_name)

  return [firstName, middleInitial ? `${middleInitial}.` : '', lastName]
    .filter(Boolean)
    .join(' ')
    .replace(/\s+/g, ' ')
    .trim()
}

export const formatEmployeeOptionLabel = (row = {}, options = {}) => {
  const statusLabel = trimText(options?.statusLabel)
  const includeEmail = options?.includeEmail !== false
  const displayName = resolveEmployeeDisplayName(row) || trimText(row?.email) || `Employee #${trimText(row?.id || row?.uid || '0')}`
  const email = trimText(row?.email)
  const sameAsEmail = Boolean(email && displayName.toLowerCase() === email.toLowerCase())

  let label = displayName
  if (statusLabel) {
    label = `${label} - ${statusLabel}`
  }
  if (includeEmail && email && !sameAsEmail) {
    label = `${label} (${email})`
  }

  return label
}
