// resources/js/Routes.js
import AdminDashboard from './Pages/Admin/AdminDashboard.vue'
import UserDashboard from './Pages/User/UserDashboard.vue'

export const routes = [
  { path: '/admin', component: AdminDashboard, meta: { role: 'admin' } },
  { path: '/user', component: UserDashboard, meta: { role: 'user' } },
]
