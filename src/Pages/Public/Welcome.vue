<script setup>
import { Head, usePage } from '@inertiajs/vue3'
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  canLogin: {
    type: Boolean,
    default: true,
  },
  canRegister: {
    type: Boolean,
    default: true,
  },
})

const page = usePage()
const router = useRouter()
const isPageLoading = ref(false)
const pageLoadingText = ref('')
const activeSection = ref('home')

const isAuthenticated = computed(() => Boolean(page.props.auth?.user?.uid))
let revealObserver = null
let handleScroll = null

const navItems = [
  { label: 'Home', href: '#home' },
  { label: 'About', href: '#about' },
  { label: 'Services', href: '#services' },
  { label: 'Contact', href: '#contact' },
]

const aboutCards = [
  {
    title: 'Residential Sink Repair',
    description: 'Quick repair and diagnostics for clogged, leaking, or damaged sink lines in residential spaces.',
  },
  {
    title: 'Commercial Waste Solutions',
    description: 'Structured siphoning and wastewater support for offices, shops, and larger commercial properties.',
  },
  {
    title: 'Septic Tank Siphoning',
    description: 'Safe tank emptying and sanitation handling for routine maintenance and emergency response calls.',
  },
]

const serviceShowcase = [
  {
    tag: 'Residential',
    title: 'Residential Plumbing Repair',
    description: 'Professional sink, drain, and household pipe services delivered with neat workmanship and reliable scheduling.',
    image: '/images/landing-plumbing-hero.png',
  },
  {
    tag: 'Maintenance',
    title: 'Kitchen and Fixture Maintenance',
    description: 'Preventive maintenance and focused repair work for kitchen lines, under-sink systems, and everyday plumbing fixtures.',
    image: '/images/service-plumbing.jfif',
  },
  {
    tag: 'Commercial',
    title: 'Field Siphoning Operations',
    description: 'Commercial and septic siphoning support using organized site handling, proper equipment, and efficient waste removal.',
    image: '/images/service-siphoning-1.jfif',
  },
]

const sectionIdFromHref = (href) => String(href || '').replace(/^#/, '') || 'home'

const isActiveNav = (href) => activeSection.value === sectionIdFromHref(href)

function updateActiveSectionFromScroll() {
  if (typeof window === 'undefined') return

  const sections = navItems
    .map((item) => document.getElementById(sectionIdFromHref(item.href)))
    .filter(Boolean)

  if (!sections.length) return

  const scrollMarker = window.scrollY + 180
  let currentSection = sections[0].id

  sections.forEach((section) => {
    const top = section.offsetTop
    const bottom = top + section.offsetHeight

    if (scrollMarker >= top && scrollMarker < bottom) {
      currentSection = section.id
    }
  })

  if (window.scrollY <= 40) {
    currentSection = 'home'
  }

  activeSection.value = currentSection
}

const goToRoute = (path) => {
  const target = String(path || '/')
  return router.push(target).catch(() => {
    window.location.assign(target)
  })
}

function navigateWithLoading(path, label) {
  if (typeof window === 'undefined' || isPageLoading.value) return
  isPageLoading.value = true
  pageLoadingText.value = label
  window.setTimeout(() => {
    void goToRoute(path)
  }, 160)
}

onMounted(() => {
  updateActiveSectionFromScroll()
  handleScroll = () => updateActiveSectionFromScroll()
  window.addEventListener('scroll', handleScroll, { passive: true })

  const revealTargets = Array.from(document.querySelectorAll('.reveal-on-scroll'))
  if (!revealTargets.length) return

  revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return
        entry.target.classList.add('is-visible')
        revealObserver?.unobserve(entry.target)
      })
    },
    {
      rootMargin: '0px 0px -12% 0px',
      threshold: 0.14,
    }
  )

  revealTargets.forEach((element) => revealObserver?.observe(element))
})

onBeforeUnmount(() => {
  if (handleScroll) {
    window.removeEventListener('scroll', handleScroll)
  }
  revealObserver?.disconnect()
})
</script>

<template>
  <Head title="Plumbing & Siphoning" />

  <div class="landing-shell min-h-screen bg-[#07111d] text-slate-100">
    <transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="isPageLoading"
        class="fixed inset-0 z-[90] flex flex-col items-center justify-center bg-[rgba(4,10,18,0.66)] px-6 text-center backdrop-blur-md"
      >
        <span
          class="h-14 w-14 rounded-full border-2 border-white/15 border-t-[#3B82F6] animate-spin"
          aria-hidden="true"
        ></span>
        <p class="mt-5 text-lg font-extrabold tracking-[-0.03em] text-white">Opening page</p>
        <p class="mt-2 max-w-sm text-sm leading-6 text-slate-300">{{ pageLoadingText }}</p>
      </div>
    </transition>

    <header class="fixed inset-x-0 top-4 z-50 px-4 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-[1580px]">
        <div class="landing-fade rounded-full border border-white/10 bg-[rgba(10,22,36,0.88)] px-5 py-4 shadow-[0_20px_50px_rgba(2,8,20,0.35)] backdrop-blur-xl">
          <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <div class="flex items-center gap-3">
              <div class="flex h-12 w-12 items-center justify-center rounded-full bg-[#3B82F6] shadow-[0_12px_28px_rgba(59,130,246,0.28)]">
                <svg viewBox="0 0 24 24" class="h-5 w-5 text-white" fill="none" stroke="currentColor" stroke-width="1.8">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M8 5h8v3h-2v3.5a4.5 4.5 0 1 1-4 0V8H8V5Z" />
                </svg>
              </div>
              <div>
                <p class="text-[0.68rem] font-bold uppercase tracking-[0.3em] text-[#3B82F6]">Professional Service</p>
                <p class="text-lg font-extrabold tracking-[-0.03em] text-white">Plumbing & Siphoning</p>
              </div>
            </div>

            <nav class="flex flex-wrap items-center justify-center gap-2 text-sm text-slate-300">
              <a
                v-for="item in navItems"
                :key="item.label"
                :href="item.href"
                :class="isActiveNav(item.href)
                  ? 'nav-link nav-link-active rounded-full bg-[#3B82F6]/18 px-4 py-2 text-white shadow-[inset_0_0_0_1px_rgba(59,130,246,0.42)]'
                  : 'nav-link rounded-full px-4 py-2 transition hover:bg-white/8 hover:text-white'"
              >
                <span>{{ item.label }}</span>
                <span class="nav-link-underline" aria-hidden="true"></span>
              </a>
            </nav>

            <div class="flex flex-wrap items-center justify-end gap-3">
              <a
                v-if="props.canLogin && !isAuthenticated"
                href="/login"
                @click.prevent="navigateWithLoading('/login', 'Opening login...')"
                class="inline-flex items-center justify-center rounded-full bg-[#3B82F6] px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-[#3B82F6]/90"
              >
                Login
              </a>
              <a
                v-if="props.canRegister && !isAuthenticated"
                href="/register"
                @click.prevent="navigateWithLoading('/register', 'Opening registration...')"
                class="inline-flex items-center justify-center rounded-full border border-[#3B82F6]/60 bg-[#3B82F6]/14 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-[#3B82F6]/22"
              >
                Register
              </a>
              <a
                v-if="isAuthenticated"
                href="/dashboard"
                @click.prevent="navigateWithLoading('/dashboard', 'Opening dashboard...')"
                class="inline-flex items-center justify-center rounded-full bg-[#3B82F6] px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-[#3B82F6]/90"
              >
                Dashboard
              </a>
            </div>
          </div>
        </div>
      </div>
    </header>

    <section id="home" class="relative isolate overflow-hidden border-b border-white/8 scroll-mt-36">
      <img
        src="/images/landing-plumbing-hero.png"
        alt="Plumbing service team at work"
        class="absolute inset-0 h-full w-full object-cover"
      />
      <div class="absolute inset-0 bg-[linear-gradient(180deg,rgba(5,12,20,0.34),rgba(5,12,20,0.76)_52%,rgba(5,12,20,0.96))]"></div>
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(59,130,246,0.2),transparent_28%),radial-gradient(circle_at_82%_18%,rgba(59,130,246,0.14),transparent_22%)]"></div>

      <div class="relative mx-auto flex min-h-screen w-full max-w-[1380px] flex-col px-6 pb-24 pt-36 sm:px-10 sm:pt-40 lg:px-12 lg:pb-28 lg:pt-44">
        <div class="flex flex-1 items-center">
          <div class="landing-fade landing-fade-delay relative max-w-[760px] py-20 sm:py-24 lg:py-28">
            <div class="pointer-events-none absolute inset-y-0 -left-8 -right-12 -z-10 rounded-[36px] bg-[linear-gradient(90deg,rgba(5,12,20,0.4),rgba(5,12,20,0.24)_60%,rgba(5,12,20,0))]"></div>
            <p class="inline-flex rounded-full border border-[#3B82F6]/20 bg-[#3B82F6]/10 px-4 py-2 text-[0.72rem] font-bold uppercase tracking-[0.24em] text-[#3B82F6]">
              Reliable service for homes and facilities
            </p>

            <h1 class="mt-8 max-w-[12ch] text-[clamp(3.2rem,8vw,6.5rem)] font-extrabold leading-[0.9] tracking-[-0.06em] text-white">
              Expert Residential & Commercial Siphoning
            </h1>

            <p class="mt-8 max-w-[42rem] text-lg leading-8 text-slate-300">
              Clean, efficient, and professional plumbing support for residential properties, business establishments,
              and septic systems. Built for a polished presentation with clear structure, generous spacing, and a calm
              premium tone.
            </p>

            <div class="mt-10 flex flex-wrap gap-3">
              <a
                href="#services"
                class="inline-flex items-center justify-center rounded-full bg-[#3B82F6] px-6 py-3.5 text-sm font-semibold text-white transition hover:bg-[#3B82F6]/90"
              >
                View Services
              </a>
              <a
                href="#contact"
                class="inline-flex items-center justify-center rounded-full border border-[#3B82F6]/60 bg-[#3B82F6]/12 px-6 py-3.5 text-sm font-semibold text-white transition hover:bg-[#3B82F6]/20"
              >
                Contact Us
              </a>
            </div>

            <div class="mt-16 grid gap-4 sm:grid-cols-3">
              <div class="rounded-[24px] border border-white/10 bg-[rgba(9,19,30,0.62)] px-5 py-5 backdrop-blur-md">
                <p class="text-[0.7rem] font-semibold uppercase tracking-[0.18em] text-[#3B82F6]">Availability</p>
                <p class="mt-2 text-2xl font-extrabold tracking-[-0.04em] text-white">24/7</p>
                <p class="mt-2 text-sm leading-6 text-slate-300">Emergency response support for urgent siphoning and drainage issues.</p>
              </div>
              <div class="rounded-[24px] border border-white/10 bg-[rgba(9,19,30,0.62)] px-5 py-5 backdrop-blur-md">
                <p class="text-[0.7rem] font-semibold uppercase tracking-[0.18em] text-[#3B82F6]">Execution</p>
                <p class="mt-2 text-2xl font-extrabold tracking-[-0.04em] text-white">Clean</p>
                <p class="mt-2 text-sm leading-6 text-slate-300">Professional workmanship with organized equipment handling and neat service delivery.</p>
              </div>
              <div class="rounded-[24px] border border-white/10 bg-[rgba(9,19,30,0.62)] px-5 py-5 backdrop-blur-md">
                <p class="text-[0.7rem] font-semibold uppercase tracking-[0.18em] text-[#3B82F6]">Reputation</p>
                <p class="mt-2 text-2xl font-extrabold tracking-[-0.04em] text-white">Trusted</p>
                <p class="mt-2 text-sm leading-6 text-slate-300">Built for residential clients, commercial properties, and scheduled septic maintenance.</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section id="about" class="bg-[#091624] scroll-mt-36">
      <div class="mx-auto grid max-w-[1380px] gap-16 px-6 py-24 sm:px-10 lg:grid-cols-[0.92fr_1.08fr] lg:items-center lg:px-12 lg:py-28">
        <div class="reveal-on-scroll">
          <p class="text-[0.76rem] font-bold uppercase tracking-[0.28em] text-[#3B82F6]">About</p>
          <h2 class="mt-5 max-w-[12ch] text-[clamp(2.4rem,4.8vw,4.5rem)] font-extrabold leading-[0.95] tracking-[-0.05em] text-white">
            Organized field service with a clean professional standard.
          </h2>
          <p class="mt-8 max-w-[34rem] text-lg font-semibold leading-9 text-slate-200">
            We deliver dependable plumbing and siphoning work for households, commercial sites, and sanitation
            facilities with a focus on safety, speed, and clear coordination. The layout is intentionally spacious so
            the content feels confident, readable, and presentation-ready.
          </p>
        </div>

        <div class="grid content-center gap-5">
          <article
            v-for="(card, index) in aboutCards"
            :key="card.title"
            class="reveal-on-scroll rounded-[30px] border border-white/10 bg-[linear-gradient(180deg,rgba(15,30,48,0.96),rgba(11,23,37,0.96))] px-6 py-7 shadow-[0_18px_40px_rgba(2,6,23,0.28)]"
            :style="{ transitionDelay: `${index * 120}ms` }"
          >
            <div class="flex items-center gap-4">
              <span class="inline-flex h-11 w-11 flex-none items-center justify-center rounded-full bg-[#3B82F6]/16 text-[#3B82F6]">
                <svg viewBox="0 0 24 24" class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M7 7h10M9 4h6v3H9zM8 10v3a4 4 0 0 0 8 0v-3" />
                </svg>
              </span>
              <div>
                <p class="text-xl font-bold tracking-[-0.03em] text-white">{{ card.title }}</p>
                <p class="mt-3 max-w-[32rem] text-sm leading-7 text-slate-300">{{ card.description }}</p>
              </div>
            </div>
          </article>
        </div>
      </div>
    </section>

    <section id="services" class="border-y border-white/8 bg-[#07111d] scroll-mt-36">
      <div class="mx-auto max-w-[1380px] px-6 py-24 sm:px-10 lg:px-12 lg:py-28">
        <div class="reveal-on-scroll flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <p class="text-[0.76rem] font-bold uppercase tracking-[0.28em] text-[#3B82F6]">Services</p>
            <h2 class="mt-5 max-w-[12ch] text-[clamp(2.3rem,4.6vw,4.2rem)] font-extrabold leading-[0.95] tracking-[-0.05em] text-white">
              Dedicated service cards with image, title, and description.
            </h2>
          </div>
          <p class="max-w-[34rem] text-base leading-8 text-slate-300">
            This section is separate now, so when you click the Services link in the sticky navbar, it jumps directly
            to a complete services showcase.
          </p>
        </div>

        <div class="mt-12 grid auto-rows-fr gap-6 lg:grid-cols-3">
          <article
            v-for="(service, index) in serviceShowcase"
            :key="service.title"
            class="reveal-on-scroll group flex h-full flex-col rounded-[32px] border border-white/10 bg-[linear-gradient(180deg,rgba(15,30,48,0.96),rgba(11,23,37,0.96))] p-4 shadow-[0_22px_54px_rgba(2,6,23,0.3)] transition duration-300 hover:-translate-y-1.5 hover:border-[#3B82F6]/30"
            :style="{ transitionDelay: `${index * 120}ms` }"
          >
            <div class="relative h-64 overflow-hidden rounded-[16px]">
              <img :src="service.image" :alt="service.title" class="h-full w-full object-cover transition duration-500 group-hover:scale-[1.03]" />
              <div class="absolute inset-0 bg-[linear-gradient(180deg,rgba(5,12,20,0.08),rgba(5,12,20,0.68))]"></div>
              <span class="absolute left-4 top-4 inline-flex items-center rounded-full bg-[rgba(7,18,30,0.78)] px-3 py-1 text-[0.68rem] font-semibold uppercase tracking-[0.16em] text-[#3B82F6]">
                {{ service.tag }}
              </span>
            </div>
            <div class="flex flex-1 flex-col px-2 pb-2 pt-6">
              <p class="text-xl font-bold tracking-[-0.03em] text-white">{{ service.title }}</p>
              <p class="mt-3 text-sm leading-7 text-slate-300">{{ service.description }}</p>
              <div class="mt-auto pt-5 text-[0.74rem] font-semibold uppercase tracking-[0.18em] text-[#3B82F6]">
                Professional service coverage
              </div>
            </div>
          </article>
        </div>
      </div>
    </section>

    <section id="contact" class="bg-[#091624] scroll-mt-36">
      <div class="mx-auto max-w-[1380px] px-6 py-24 sm:px-10 lg:px-12 lg:py-28">
        <div class="rounded-[36px] border border-white/10 bg-[linear-gradient(135deg,rgba(17,34,54,0.96),rgba(10,20,32,0.96))] px-8 py-12 sm:px-10 lg:grid lg:grid-cols-[minmax(0,65%)_minmax(0,35%)] lg:items-end lg:gap-10">
          <div class="reveal-on-scroll max-w-[42rem]">
            <p class="text-[0.76rem] font-bold uppercase tracking-[0.28em] text-[#3B82F6]">Centralized Help Desk</p>
            <h2 class="mt-4 text-[clamp(2rem,4vw,3.4rem)] font-extrabold leading-[0.96] tracking-[-0.05em] text-white">
              Centralized support for maintenance requests across partner companies.
            </h2>
            <p class="mt-6 text-base leading-8 text-slate-300">
              This section serves as the Centralized Help Desk. While multiple companies use the platform, the website
              owner acts as the System Administrator to ensure all maintenance requests are handled correctly and to
              provide technical support to our partner companies.
            </p>
          </div>

          <div class="contact-info-block reveal-on-scroll mt-10 flex h-full flex-col justify-end lg:mt-0 lg:justify-self-end lg:pb-1" style="transition-delay: 140ms">
            <div class="space-y-5">
              <div class="flex items-center gap-3">
                <span class="inline-flex h-9 w-9 items-center justify-center rounded-full bg-[#3B82F6]/12 text-[#3B82F6]">
                    <svg viewBox="0 0 24 24" class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.8">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M4 7.5 12 13l8-5.5M5 6h14a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1Z" />
                    </svg>
                </span>
                <div>
                  <p class="text-[13px] font-semibold uppercase tracking-[0.18em] text-[#3B82F6]">Technical Support</p>
                  <a href="mailto:support@plumbingsiphoning.com" class="mt-1 inline-flex text-[14px] leading-6 text-[#FFFFFF] transition hover:text-[#BFDBFE]">
                    support@plumbingsiphoning.com
                  </a>
                </div>
              </div>

              <div class="flex items-center gap-3">
                <span class="inline-flex h-9 w-9 items-center justify-center rounded-full bg-[#3B82F6]/12 text-[#3B82F6]">
                    <svg viewBox="0 0 24 24" class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.8">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M22 16.92v2a2 2 0 0 1-2.18 2 19.86 19.86 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6A19.86 19.86 0 0 1 2.12 3.18 2 2 0 0 1 4.11 1h2a2 2 0 0 1 2 1.72c.12.9.33 1.79.63 2.65a2 2 0 0 1-.45 2.11L7.09 8.91a16 16 0 0 0 6 6l1.43-1.2a2 2 0 0 1 2.11-.45c.86.3 1.75.51 2.65.63A2 2 0 0 1 22 16.92Z" />
                    </svg>
                </span>
                <div>
                  <p class="text-[13px] font-semibold uppercase tracking-[0.18em] text-[#3B82F6]">System Administrator</p>
                  <a href="tel:+639123456789" class="mt-1 inline-flex text-[14px] leading-6 text-[#FFFFFF] transition hover:text-[#BFDBFE]">
                    +63 912 345 6789
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Manrope:wght@400;500;600;700;800&display=swap');

html {
  scroll-behavior: smooth;
}

.landing-shell {
  font-family: 'Manrope', sans-serif;
}

.nav-link {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.nav-link-underline {
  position: absolute;
  bottom: 0.3rem;
  left: 1rem;
  right: 1rem;
  height: 2px;
  border-radius: 999px;
  background: #3B82F6;
  transform: scaleX(0);
  transform-origin: center;
  transition: transform 220ms ease;
}

.nav-link:hover .nav-link-underline,
.nav-link-active .nav-link-underline {
  transform: scaleX(1);
}

.landing-fade {
  animation: landingFade 700ms cubic-bezier(0.2, 0.7, 0.2, 1) both;
}

.landing-fade-delay {
  animation-delay: 120ms;
}

.contact-info-block {
  font-family: 'Inter', sans-serif;
}

.reveal-on-scroll {
  opacity: 0;
  transform: translateY(26px);
  transition: opacity 700ms cubic-bezier(0.2, 0.7, 0.2, 1), transform 700ms cubic-bezier(0.2, 0.7, 0.2, 1);
}

.reveal-on-scroll.is-visible {
  opacity: 1;
  transform: translateY(0);
}

@keyframes landingFade {
  from {
    opacity: 0;
    transform: translateY(20px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
