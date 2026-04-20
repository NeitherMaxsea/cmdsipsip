import sqlDump from '../../thesis_capstone (6).sql?raw'

const USERS_COLUMNS = [
  'id',
  'first_name',
  'middle_initial',
  'last_name',
  'email',
  'latitude',
  'longitude',
  'contact_number',
  'email_verified_at',
  'password',
  'remember_token',
  'created_at',
  'updated_at',
  'is_approved',
  'role',
  'status',
  'rejection_reason',
]

const WORKSPACE_TYPE_LABELS = {
  platform_admin: 'Platform Administrator',
  business_owner: 'Business Owner',
  company_staff: 'Company Staff',
  service_provider: 'Service Provider',
  service_team: 'Service Team',
  customer_portal: 'Customer Portal User',
}

const ACCOUNT_SOURCE_LABELS = {
  legacy_snapshot: 'Legacy Snapshot',
  admin_created: 'Admin-Created Account',
  self_registered: 'Self-Registered Account',
  offline_registered: 'Offline Registered Account',
  firebase_auth: 'Firebase Authentication',
  auth_table: 'Auth Table',
  admin_snapshot: 'Admin Snapshot',
  cache: 'Cache',
}

const trimString = (value) => String(value ?? '').trim()
const normalizeEmail = (value) => trimString(value).toLowerCase()
const normalizeRole = (value) => trimString(value).toLowerCase().replace(/[\s-]+/g, '_')

const titleCase = (value) => trimString(value)
  .split('_')
  .filter(Boolean)
  .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
  .join(' ')

const deriveWorkspaceType = (role) => {
  switch (normalizeRole(role)) {
    case 'admin':
      return 'platform_admin'
    case 'business':
      return 'business_owner'
    case 'serviceprovider':
      return 'service_provider'
    case 'service_provider':
      return 'service_provider'
    case 'employee':
    case 'hr':
    case 'finance':
    case 'procurement':
    case 'operational':
    case 'operational_management':
    case 'csr':
      return 'company_staff'
    case 'user':
      return 'customer_portal'
    default:
      return normalizeRole(role) || 'general_workspace'
  }
}

const parseSqlLiteral = (token) => {
  const value = trimString(token)
  if (!value || /^null$/i.test(value)) {
    return null
  }

  if (value.startsWith("'") && value.endsWith("'")) {
    const inner = value.slice(1, -1)
      .replace(/\\'/g, "'")
      .replace(/\\\\/g, '\\')
      .replace(/''/g, "'")
    return inner
  }

  if (/^-?\d+(?:\.\d+)?$/.test(value)) {
    return Number(value)
  }

  return value
}

const splitValuesBlock = (block) => {
  const rows = []
  let currentField = ''
  let currentFields = []
  let depth = 0
  let inString = false
  let escaped = false

  const pushField = () => {
    currentFields.push(parseSqlLiteral(currentField))
    currentField = ''
  }

  const finalizeRow = () => {
    if (currentFields.length) {
      rows.push(currentFields)
    }
    currentFields = []
  }

  for (let index = 0; index < block.length; index += 1) {
    const char = block[index]

    if (inString) {
      currentField += char
      if (escaped) {
        escaped = false
        continue
      }
      if (char === '\\') {
        escaped = true
        continue
      }
      if (char === "'") {
        if (block[index + 1] === "'") {
          currentField += block[index + 1]
          index += 1
          continue
        }
        inString = false
      }
      continue
    }

    if (char === "'") {
      inString = true
      currentField += char
      continue
    }

    if (char === '(') {
      depth += 1
      if (depth === 1) {
        currentField = ''
        currentFields = []
        continue
      }
    }

    if (char === ')') {
      if (depth === 1) {
        if (currentField.length || currentFields.length) {
          pushField()
        }
        finalizeRow()
        depth = 0
        continue
      }
      depth = Math.max(depth - 1, 0)
    }

    if (!depth) {
      continue
    }

    if (char === ',' && depth === 1) {
      pushField()
      continue
    }

    currentField += char
  }

  return rows
}

const normalizeSeedUser = (values) => {
  const [
    id,
    first_name,
    middle_initial,
    last_name,
    email,
    latitude,
    longitude,
    contact_number,
    email_verified_at,
    password,
    remember_token,
    created_at,
    updated_at,
    is_approved,
    role,
    status,
    rejection_reason,
  ] = values

  const firstName = trimString(first_name)
  const middleInitial = trimString(middle_initial)
  const lastName = trimString(last_name)
  const emailValue = normalizeEmail(email)
  const normalizedRole = normalizeRole(role)
  const workspaceType = deriveWorkspaceType(normalizedRole)
  const displayName = [firstName, middleInitial ? `${middleInitial}.` : '', lastName]
    .filter(Boolean)
    .join(' ')
    .replace(/\s+/g, ' ')
    .trim()

  const hasApprovedFlag = Number(is_approved) === 1 || is_approved === true || is_approved === '1'
  const normalizedStatus = trimString(status) || (hasApprovedFlag ? 'approved' : 'pending')
  const userId = trimString(id) || emailValue
  const name = displayName || emailValue || `User #${userId}`

  return {
    id: userId,
    uid: userId,
    firebase_uid: userId,
    first_name: firstName,
    middle_initial: middleInitial,
    last_name: lastName,
    display_name: name,
    name,
    email: emailValue,
    latitude,
    longitude,
    contact_number: trimString(contact_number),
    email_verified_at,
    password,
    remember_token,
    created_at,
    updated_at,
    is_approved: hasApprovedFlag,
    role: normalizedRole,
    status: normalizedStatus,
    approval_status: normalizedStatus,
    rejection_reason,
    workspace_type: workspaceType,
    workspace_type_label: WORKSPACE_TYPE_LABELS[workspaceType] || titleCase(workspaceType),
    account_source: 'legacy_snapshot',
    account_source_label: ACCOUNT_SOURCE_LABELS.legacy_snapshot,
    source_trace: ['Legacy Snapshot'],
    source_trace_label: 'Legacy Snapshot',
    source_missing: [],
    source_missing_label: '',
    has_viewed: false,
  }
}

let cachedSeedUsers = null

export const getSqlSeedUsers = () => {
  if (cachedSeedUsers) {
    return cachedSeedUsers.map((entry) => ({ ...entry }))
  }

  const match = String(sqlDump || '').match(/INSERT INTO\s+`users`[\s\S]*?VALUES\s*([\s\S]*?);/m)
  if (!match) {
    cachedSeedUsers = []
    return []
  }

  cachedSeedUsers = splitValuesBlock(match[1])
    .filter((row) => row.length === USERS_COLUMNS.length)
    .map((row) => normalizeSeedUser(row))

  return cachedSeedUsers.map((entry) => ({ ...entry }))
}
