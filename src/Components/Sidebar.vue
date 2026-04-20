<!-- Components/Sidebar.vue -->
<template>
  <aside class="flex h-screen w-[220px] flex-col bg-slate-800 p-5 text-white">
    <h2 class="mb-5 text-lg">{{ title }}</h2>
    <ul class="list-none p-0">
      <li
        v-for="item in menuItems"
        :key="item.name"
        class="mb-2.5 cursor-pointer rounded-md px-[15px] py-2.5 transition-colors hover:bg-slate-700"
        @click="$emit('navigate', item.link)"
      >
        {{ item.name }}
      </li>
    </ul>
  </aside>
</template>

<script>
export default {
  props: ['dashboard'], // "procurement", "hr", or "finance"
  computed: {
    title() {
      if (this.dashboard === 'procurement') return 'Procurement';
      if (this.dashboard === 'hr') return 'HR';
      if (this.dashboard === 'finance') return 'Finance';
      return 'Dashboard';
    },
    menuItems() {
      if (this.dashboard === 'procurement') {
        return [
          { name: 'Inventory Levels', link: 'inventory' },
          { name: 'Purchase Orders', link: 'po' },
          { name: 'Supplier Performance', link: 'supplier' },
          { name: 'Cost Tracking', link: 'cost' },
          { name: 'Top-used Materials', link: 'top_materials' }
        ];
      }
      if (this.dashboard === 'hr') {
        return [
          { name: 'Employee Headcount', link: 'headcount' },
          { name: 'Attendance & Work Hours', link: 'attendance' },
          { name: 'Training & Certification', link: 'training' },
          { name: 'Leaves & Absences', link: 'leaves' },
          { name: 'Performance Metrics', link: 'performance' },
          { name: 'Safety Incidents', link: 'safety' }
        ];
      }
      if (this.dashboard === 'finance') {
        return [
          { name: 'Project Expenses vs Budget', link: 'expenses' },
          { name: 'Revenue Tracking', link: 'revenue' },
          { name: 'Accounts Payable & Receivable', link: 'accounts' },
          { name: 'Cash Flow Forecast', link: 'cashflow' },
          { name: 'Profitability Metrics', link: 'profit' },
          { name: 'Cost Breakdown', link: 'costbreakdown' }
        ];
      }
      return [];
    }
  }
}
</script>
