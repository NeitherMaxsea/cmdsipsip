<template>
  <FinanceShell
    title="Procurement Approvals"
    subtitle="Approve or reject purchase requisitions for operations jobs."
    active-path="/finance/procurement-approvals"
  >
    <div class="stats-grid">
      <div class="stat-card">
        <p>Pending Review</p>
        <h3>{{ summary.pending }}</h3>
      </div>
      <div class="stat-card">
        <p>Approved</p>
        <h3>{{ summary.approved }}</h3>
      </div>
      <div class="stat-card">
        <p>Released Funds</p>
        <h3>{{ money(summary.releasedAmount) }}</h3>
      </div>
      <div class="stat-card">
        <p>Awaiting Settlement</p>
        <h3>{{ summary.awaitingSettlement }}</h3>
      </div>
    </div>

    <div class="panel">
      <h3>Purchase Requisition Queue</h3>
      <table>
        <thead>
          <tr>
            <th>PR Ref</th>
            <th>Job Order</th>
            <th>Material</th>
            <th>Qty</th>
            <th>Urgency</th>
            <th>Purchase Type</th>
            <th>Estimated Cost</th>
            <th>Released Amount</th>
            <th>Release Mode</th>
            <th>Release Status</th>
            <th>Status</th>
            <th>Finance Note</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in rowsState" :key="item.id">
            <td>{{ item.pr_reference }}</td>
            <td>{{ item.job_order_id ? `#${item.job_order_id}` : '-' }}</td>
            <td>{{ item.material_name }}</td>
            <td>{{ item.quantity }} {{ item.unit }}</td>
            <td>{{ item.urgency || '-' }}</td>
            <td>{{ item.purchase_type || '-' }}</td>
            <td>{{ money(item.estimated_cost) }}</td>
            <td>{{ money(item.finance_release_amount) }}</td>
            <td>{{ releaseModeLabel(item.finance_release_mode) }}</td>
            <td>
              <span class="badge" :class="releaseStatusClass(item.finance_release_status)">{{ releaseStatusLabel(item.finance_release_status) }}</span>
            </td>
            <td>
              <span class="badge" :class="statusBadgeClass(item.pr_status)">{{ prettyStatus(item.pr_status) }}</span>
            </td>
            <td>
              <input
                v-model="financeNoteById[item.id]"
                type="text"
                placeholder="Optional note"
                class="h-9 w-44 rounded-lg border border-slate-300 px-2.5 text-xs"
              />
            </td>
            <td>
              <button
                class="ok"
                :disabled="!canDecide(item) || decidingId === item.id"
                @click="setDecision(item, 'approve')"
              >
                Approve
              </button>
              <button
                class="reject"
                :disabled="!canDecide(item) || decidingId === item.id"
                @click="setDecision(item, 'reject')"
              >
                Reject
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </FinanceShell>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import axios from 'axios'
import Swal from '@/lib/sweetalert-toast-shim'
import FinanceShell from './Finance/FinanceShell.vue'

const props = defineProps({
  rows: {
    type: Array,
    default: () => [],
  },
})

const rowsState = ref(Array.isArray(props.rows) ? [...props.rows] : [])
const decidingId = ref(null)
const loading = ref(false)
const financeNoteById = ref(
  rowsState.value.reduce((acc, row) => {
    acc[row.id] = row.finance_note || ''
    return acc
  }, {})
)

const syncFinanceNotes = () => {
  financeNoteById.value = rowsState.value.reduce((acc, row) => {
    acc[row.id] = row.finance_note || ''
    return acc
  }, {})
}

const fetchRows = async () => {
  loading.value = true
  try {
    const res = await axios.get('/finance/procurement-approvals')
    rowsState.value = Array.isArray(res.data) ? res.data : []
    syncFinanceNotes()
  } catch (err) {
    Swal.fire('Error', err?.response?.data?.message || 'Failed to load procurement approvals queue.', 'error')
  } finally {
    loading.value = false
  }
}

const prettyStatus = (status) => {
  const s = String(status || '').trim().toLowerCase()
  return s ? s.replace(/_/g, ' ').replace(/\b\w/g, (m) => m.toUpperCase()) : '-'
}

const statusBadgeClass = (status) => {
  const s = String(status || '').toLowerCase()
  if (s === 'pending_finance_approval') return 'review'
  if (s === 'approved') return 'ok'
  if (s === 'rejected') return 'failed'
  return 'pending'
}

const money = (value) => {
  return new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP' }).format(Number(value) || 0)
}

const summary = computed(() => ({
  pending: rowsState.value.filter((item) => String(item?.pr_status || '').toLowerCase() === 'pending_finance_approval').length,
  approved: rowsState.value.filter((item) => String(item?.pr_status || '').toLowerCase() === 'approved').length,
  releasedAmount: rowsState.value.reduce((sum, item) => sum + (Number(item?.finance_release_amount) || 0), 0),
  awaitingSettlement: rowsState.value.filter((item) => ['awaiting_procurement_receipt', 'awaiting_receipt'].includes(String(item?.finance_settlement_status || '').toLowerCase())).length,
}))

const canDecide = (item) => String(item?.pr_status || '').toLowerCase() === 'pending_finance_approval'

const releaseStatusLabel = (value) => {
  const normalized = String(value || '').trim().toLowerCase()
  if (!normalized) return '-'
  return normalized.replace(/_/g, ' ').replace(/\b\w/g, (m) => m.toUpperCase())
}

const releaseStatusClass = (value) => {
  const normalized = String(value || '').trim().toLowerCase()
  if (normalized === 'released') return 'ok'
  if (normalized === 'awaiting_finance_approval') return 'review'
  if (normalized === 'not_released') return 'failed'
  return 'pending'
}

const defaultReleaseMode = (item) => {
  const purchaseType = String(item?.purchase_type || '').trim().toLowerCase()
  return ['physical', 'direct'].includes(purchaseType) ? 'cash_release' : 'online_payment'
}

const releaseModeLabel = (value) => {
  const normalized = String(value || '').trim().toLowerCase()
  if (normalized === 'cash_release') return 'Cash Release'
  if (normalized === 'online_payment') return 'Online Payment'
  return normalized ? normalized.replace(/_/g, ' ').replace(/\b\w/g, (m) => m.toUpperCase()) : '-'
}

const setDecision = async (item, action) => {
  if (!canDecide(item)) return
  let payload = {
    action,
    finance_note: financeNoteById.value[item.id] || null,
  }

  if (action === 'approve') {
    const approvalPrompt = await Swal.fire({
      title: `Approve ${item.pr_reference || `PR-${item.id}`}`,
      html: `
        <div style="display:grid;gap:8px;text-align:left">
          <input id="swal-release-amount" class="swal2-input" type="number" min="0" step="0.01" placeholder="Released amount" value="${item.finance_release_amount || item.estimated_cost || item.total_cost || ''}">
          <select id="swal-release-mode" class="swal2-input">
            <option value="online_payment" ${defaultReleaseMode(item) === 'online_payment' ? 'selected' : ''}>Online Payment</option>
            <option value="cash_release" ${defaultReleaseMode(item) === 'cash_release' ? 'selected' : ''}>Cash Release</option>
          </select>
          <input id="swal-release-reference" class="swal2-input" type="text" placeholder="Reference / voucher no. (optional)" value="${item.finance_release_reference || ''}">
          <textarea id="swal-release-note" class="swal2-textarea" placeholder="Finance note (optional)">${financeNoteById.value[item.id] || item.finance_note || ''}</textarea>
        </div>
      `,
      showCancelButton: true,
      confirmButtonText: 'Approve and Release Funds',
      preConfirm: () => {
        const releaseAmount = Number(document.getElementById('swal-release-amount')?.value || 0)
        const releaseMode = document.getElementById('swal-release-mode')?.value || ''
        const releaseReference = document.getElementById('swal-release-reference')?.value || ''
        const financeNote = document.getElementById('swal-release-note')?.value || ''
        if (!(releaseAmount > 0)) {
          Swal.showValidationMessage('Released amount must be greater than 0.')
          return false
        }
        if (!releaseMode) {
          Swal.showValidationMessage('Release mode is required.')
          return false
        }
        return {
          releaseAmount,
          releaseMode,
          releaseReference,
          financeNote,
        }
      },
    })

    if (!approvalPrompt.isConfirmed || !approvalPrompt.value) return
    financeNoteById.value[item.id] = approvalPrompt.value.financeNote || ''
    payload = {
      ...payload,
      finance_note: approvalPrompt.value.financeNote || null,
      release_amount: approvalPrompt.value.releaseAmount,
      release_mode: approvalPrompt.value.releaseMode,
      release_reference: approvalPrompt.value.releaseReference || null,
    }
  }

  decidingId.value = item.id
  try {
    const res = await axios.patch(`/finance/procurement-approvals/${item.id}`, payload)
    const nextStatus = res?.data?.pr_status || (action === 'approve' ? 'approved' : 'rejected')
    item.pr_status = nextStatus
    item.finance_note = financeNoteById.value[item.id] || ''
    await fetchRows()
    Swal.fire('Saved', `PR ${action}d successfully.`, 'success')
  } catch (err) {
    Swal.fire('Error', err?.response?.data?.message || 'Failed to update PR decision.', 'error')
  } finally {
    decidingId.value = null
  }
}

onMounted(() => {
  if (!rowsState.value.length) {
    fetchRows()
    return
  }
  syncFinanceNotes()
})
</script>

