<script setup>
import { computed, defineAsyncComponent } from 'vue';

const props = defineProps({
    pagePath: {
        type: String,
        required: true,
    },
    pages: {
        type: Object,
        required: true,
    },
});

const key = computed(() => {
    const normalized = Array.isArray(props.pagePath)
        ? props.pagePath.map((segment) => String(segment || '').trim()).filter(Boolean).join('/')
        : String(props.pagePath || '').trim().replace(/^\/+/, '').replace(/\/+$/, '');
    if (!normalized) return null;
    return `./Pages/${normalized}.vue`;
});

const component = computed(() => {
    if (!key.value) return null;
    const loader = props.pages[key.value];
    if (!loader) return null;
    return defineAsyncComponent(loader);
});
</script>

<template>
    <component :is="component" v-if="component" />
    <div v-else class="p-6">
        <h1 class="text-xl font-semibold">Page not found</h1>
        <p class="mt-2 text-slate-600">No matching Vue page for this route.</p>
    </div>
</template>
