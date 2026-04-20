<script setup>
defineProps({
    type: {
        type: String,
        default: 'submit',
    },
});
</script>

<template>
    <button
        :type="type"
        class="inline-flex items-center justify-center rounded-full border border-transparent bg-[#0D1B2A] px-5 py-2.5 text-sm font-semibold text-white transition duration-150 hover:bg-[#11263b] focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 active:bg-[#091624] disabled:cursor-not-allowed disabled:opacity-60"
    >
        <slot />
    </button>
</template>
