<script lang="ts">
	import { goto } from '$app/navigation';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	function handleGetStarted() {
		if (data.session) {
			goto('/dashboard');
		} else {
			goto('/auth/signup');
		}
	}
</script>

<svelte:head>
	<title>LidForm - Create Beautiful Forms in Seconds</title>
	<meta name="description" content="Build beautiful forms, collect responses, and export data. No coding required. Perfect for feedback, surveys, contact forms, and more." />
	<meta name="keywords" content="form builder, survey tool, contact forms, data collection, form creator, online forms" />
	<meta property="og:title" content="LidForm - Create Beautiful Forms in Seconds" />
	<meta property="og:description" content="Build beautiful forms, collect responses, and export data. No coding required. Perfect for feedback, surveys, contact forms, and more." />
	<meta property="og:type" content="website" />
	<meta property="og:image" content="/Logo (1).png" />
	<meta name="twitter:card" content="summary" />
	<meta name="twitter:title" content="LidForm - Create Beautiful Forms in Seconds" />
	<meta name="twitter:description" content="Build beautiful forms, collect responses, and export data. No coding required." />
	<meta name="twitter:image" content="/Logo (1).png" />
</svelte:head>

<div class="min-h-screen bg-white">
	<!-- Header -->
	<header class="border-b border-gray-200 bg-white sticky top-0 z-50 backdrop-blur-sm bg-white/90">
		<nav class="container mx-auto px-4 py-4 flex items-center justify-between">
			<a href="/" class="flex items-center gap-3 group cursor-pointer">
				<img src="/Logo (1).png" alt="LidForm" class="w-11 h-11 transition-transform group-hover:scale-105" />
				<span class="text-2xl font-bold text-gray-900">LidForm</span>
			</a>
			<div class="flex items-center gap-3">
				{#if data.session}
					<a
						href="/dashboard"
						class="px-6 py-2.5 text-gray-900 font-semibold hover:text-black transition-all rounded-lg hover:bg-gray-50"
					>
						Dashboard
					</a>
				{:else}
					<a
						href="/auth/login"
						class="px-6 py-2.5 text-gray-600 font-semibold hover:text-gray-900 transition-all rounded-lg hover:bg-gray-50"
					>
						Sign in
					</a>
					<a
						href="/auth/signup"
						class="px-6 py-2.5 bg-black text-white font-semibold rounded-xl hover:bg-gray-800 transition-all shadow-lg hover:shadow-xl hover:-translate-y-0.5"
					>
						Start Free
					</a>
				{/if}
			</div>
		</nav>
	</header>

	<!-- Hero Section -->
	<main class="container mx-auto px-4 py-24">
		<div class="max-w-4xl mx-auto text-center">
			<div class="inline-block mb-6 px-4 py-2 bg-gray-100 rounded-full text-sm font-semibold text-gray-700 animate-fade-in">
				✨ 100% Free Forever
			</div>
			<h1 class="text-7xl font-extrabold text-gray-900 mb-6 leading-tight animate-fade-in-up">
				Create simple forms
				<span class="text-black underline decoration-4 decoration-gray-300">in seconds</span>
			</h1>
			<p class="text-xl text-gray-600 mb-12 max-w-2xl mx-auto animate-fade-in-up" style="animation-delay: 0.1s;">
				Build beautiful forms, collect responses, and export data. No coding required. Perfect for
				feedback, surveys, contact forms, and more.
			</p>
			<button
				onclick={handleGetStarted}
				class="px-12 py-4 bg-black text-white font-bold text-lg rounded-2xl hover:bg-gray-800 transition-all shadow-2xl hover:shadow-3xl hover:-translate-y-1 animate-fade-in-up"
				style="animation-delay: 0.2s;"
			>
				Get Started →
			</button>
			<p class="text-sm text-gray-500 mt-6 animate-fade-in" style="animation-delay: 0.3s;">
				Completely free • No credit card required • No limits
			</p>
		</div>

	</main>
</div>

<style>
	@keyframes fade-in {
		from {
			opacity: 0;
		}
		to {
			opacity: 1;
		}
	}

	@keyframes fade-in-up {
		from {
			opacity: 0;
			transform: translateY(30px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.animate-fade-in {
		animation: fade-in 0.6s ease-out;
	}

	.animate-fade-in-up {
		animation: fade-in-up 0.8s ease-out;
	}
</style>
