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
				<!-- Navigation Links -->
				<div class="hidden md:flex items-center gap-2">
					<a 
						href="#features" 
						class="px-4 py-2.5 font-semibold transition-all rounded-lg scroll-smooth text-gray-600 hover:text-gray-900 hover:bg-slate-100 flex items-center gap-2"
					>
						<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
						</svg>
						Features
					</a>
					<a 
						href="#pricing" 
						class="px-4 py-2.5 font-semibold transition-all rounded-lg scroll-smooth text-gray-600 hover:text-gray-900 hover:bg-slate-100 flex items-center gap-2"
					>
						<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
						</svg>
						Pricing
					</a>
					<a 
						href="#faq" 
						class="px-4 py-2.5 font-semibold transition-all rounded-lg scroll-smooth text-gray-600 hover:text-gray-900 hover:bg-slate-100 flex items-center gap-2"
					>
						<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
						</svg>
						FAQ
					</a>
				</div>
				
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
	<section class="container mx-auto px-4 py-24">
		<div class="max-w-4xl mx-auto text-center">
			<div class="inline-block mb-6 px-4 py-2 bg-gray-100 rounded-full text-sm font-semibold text-gray-700 animate-fade-in">
				✨ 100% Free Forever
			</div>
			<h1 class="text-5xl md:text-7xl font-extrabold text-gray-900 mb-6 leading-tight animate-fade-in-up">
				Create simple forms
				<span class="text-black underline decoration-4 decoration-gray-300">in seconds</span>
			</h1>
			<p class="text-lg md:text-xl text-gray-600 mb-12 max-w-2xl mx-auto animate-fade-in-up" style="animation-delay: 0.1s;">
				Build beautiful forms, collect responses, and export data. No coding required. Perfect for
				feedback & contact forms.
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
	</section>

	<!-- Trusted By Section -->
	<section class="py-16 md:py-20 bg-white border-b border-gray-100">
		<div class="container mx-auto px-4">
			<div class="text-center mb-12">
				<p class="text-gray-500 text-sm font-semibold uppercase tracking-wider mb-8">Trusted by developers worldwide</p>
				<h2 class="text-2xl md:text-3xl font-bold text-gray-900 mb-2">Built with the best tools</h2>
				<p class="text-gray-600 max-w-2xl mx-auto">
					LidForm is powered by industry-leading technologies that ensure reliability, performance, and security.
				</p>
			</div>

			<div class="grid grid-cols-2 md:grid-cols-4 gap-8 md:gap-12 items-center justify-items-center max-w-4xl mx-auto">
				<!-- Svelte -->
				<div class="group flex items-center justify-center p-4 rounded-xl hover:bg-gray-50 transition-all duration-300">
					<img src="/trustedby/svelte.webp" alt="Svelte" class="h-8 md:h-10 w-auto object-contain grayscale group-hover:grayscale-0 transition-all duration-300" />
				</div>

				<!-- Supabase -->
				<div class="group flex items-center justify-center p-4 rounded-xl hover:bg-gray-50 transition-all duration-300">
					<img src="/trustedby/supabase.jpg" alt="Supabase" class="h-8 md:h-10 w-auto object-contain grayscale group-hover:grayscale-0 transition-all duration-300" />
				</div>

				<!-- Vercel -->
				<div class="group flex items-center justify-center p-4 rounded-xl hover:bg-gray-50 transition-all duration-300">
					<img src="/trustedby/vercel.webp" alt="Vercel" class="h-8 md:h-10 w-auto object-contain grayscale group-hover:grayscale-0 transition-all duration-300" />
				</div>

				<!-- PD -->
				<div class="group flex items-center justify-center p-4 rounded-xl hover:bg-gray-50 transition-all duration-300">
					<img src="/trustedby/pd.png" alt="PD" class="h-8 md:h-10 w-auto object-contain grayscale group-hover:grayscale-0 transition-all duration-300" />
				</div>
			</div>

			<!-- <div class="text-center mt-8">
				<p class="text-gray-400 text-sm">
					Trusted by thousands of developers building the future of web applications
				</p>
			</div> -->
		</div>
	</section>

	<!-- Features Section -->
	<section id="features" class="bg-gray-50 py-20 md:py-32">
		<div class="container mx-auto px-4">
			<div class="text-center mb-16">
				<h2 class="text-4xl md:text-5xl font-extrabold text-gray-900 mb-4">
					Everything you need to create forms
				</h2>
				<p class="text-lg md:text-xl text-gray-600 max-w-2xl mx-auto">
					Powerful features that make form building a breeze
				</p>
			</div>

			<div class="grid md:grid-cols-2 gap-8 max-w-6xl mx-auto">
				<!-- Feature 1: Easy Form Builder -->
				<div class="group bg-white rounded-3xl border-2 border-gray-200 overflow-hidden hover:border-black transition-all hover:-translate-y-2 hover:shadow-2xl">
					<div class="aspect-video bg-gradient-to-br from-blue-50 to-indigo-50 p-8 flex items-center justify-center overflow-hidden">
						<img src="/1.png" alt="Easy Form Builder" class="w-full h-full object-contain max-w-md transition-transform group-hover:scale-110 duration-500" />
					</div>
					<div class="p-8">
						<h3 class="text-2xl font-bold text-gray-900 mb-3">Clean Interface</h3>
						<p class="text-gray-600 leading-relaxed text-lg">
							Create forms with our intuitive interface. Add fields, customize design, and publish in minutes. No coding required.
						</p>
					</div>
				</div>

				<!-- Feature 2: Collect Responses -->
				<div class="group bg-white rounded-3xl border-2 border-gray-200 overflow-hidden hover:border-black transition-all hover:-translate-y-2 hover:shadow-2xl">
					<div class="aspect-video bg-gradient-to-br from-green-50 to-emerald-50 p-8 flex items-center justify-center overflow-hidden">
						<img src="/2.png" alt="Collect Responses" class="w-full h-full object-contain max-w-md transition-transform group-hover:scale-110 duration-500" />
					</div>
					<div class="p-8">
						<h3 class="text-2xl font-bold text-gray-900 mb-3">Easily Customizable</h3>
						<p class="text-gray-600 leading-relaxed text-lg">
							Customize your form to your liking. Add fields, customize design, and publish in minutes. No coding required.
						</p>
					</div>
				</div>

				<!-- Feature 3: View Submissions -->
				<div class="group bg-white rounded-3xl border-2 border-gray-200 overflow-hidden hover:border-black transition-all hover:-translate-y-2 hover:shadow-2xl">
					<div class="aspect-video bg-gradient-to-br from-purple-50 to-pink-50 p-8 flex items-center justify-center overflow-hidden">
						<img src="/3.png" alt="View Submissions" class="w-full h-full object-contain max-w-md transition-transform group-hover:scale-110 duration-500" />
					</div>
					<div class="p-8">
						<h3 class="text-2xl font-bold text-gray-900 mb-3">Add fields</h3>
						<p class="text-gray-600 leading-relaxed text-lg">
							Add fields to your form. Add text, email, phone, dropdown, and file upload fields.
						</p>
					</div>
				</div>

				<!-- Feature 4: Export Data -->
				<div class="group bg-white rounded-3xl border-2 border-gray-200 overflow-hidden hover:border-black transition-all hover:-translate-y-2 hover:shadow-2xl">
					<div class="aspect-video bg-gradient-to-br from-orange-50 to-amber-50 p-8 flex items-center justify-center overflow-hidden">
						<img src="/4.png" alt="Export to CSV" class="w-full h-full object-contain max-w-md transition-transform group-hover:scale-110 duration-500" />
					</div>
					<div class="p-8">
						<h3 class="text-2xl font-bold text-gray-900 mb-3">Share your form</h3>
						<p class="text-gray-600 leading-relaxed text-lg">
							Easily share your form via link or embed. Collect unlimited responses from anyone, anywhere in the world.
						</p>
					</div>
				</div>
			</div>
		</div>
	</section>

	<!-- Pricing Section -->
	<section id="pricing" class="py-20 md:py-32">
		<div class="container mx-auto px-4">
			<div class="text-center mb-16">
				<h2 class="text-4xl md:text-5xl font-extrabold text-gray-900 mb-4">
					Simple, Transparent Pricing
				</h2>
				<p class="text-lg md:text-xl text-gray-600 max-w-2xl mx-auto">
					No hidden fees. No credit card required. Free forever.
				</p>
			</div>

			<div class="max-w-xl mx-auto">
				<div class="bg-white rounded-3xl border-4 border-black p-10 md:p-12 shadow-2xl relative overflow-hidden">
					<!-- Free Forever Badge -->
					<!-- <div class="absolute -top-3 -right-3 bg-green-500 text-white px-6 py-2 rounded-full font-bold text-sm rotate-12 shadow-lg">
						100% FREE
					</div> -->

					<div class="text-center mb-8">
						<h3 class="text-3xl font-extrabold text-gray-900 mb-2">Free Forever</h3>
						<div class="text-6xl font-extrabold text-black mb-4">$0</div>
						<p class="text-gray-600 text-lg">Everything. Forever. Free.</p>
					</div>

					<ul class="space-y-4 mb-10">
						<li class="flex items-start gap-3">
							<svg class="w-6 h-6 text-green-600 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
							</svg>
							<span class="text-gray-900 text-lg"><strong>Unlimited forms</strong> - Create as many forms as you need</span>
						</li>
						<li class="flex items-start gap-3">
							<svg class="w-6 h-6 text-green-600 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
							</svg>
							<span class="text-gray-900 text-lg"><strong>Unlimited responses</strong> - No limits on submissions</span>
						</li>
						<li class="flex items-start gap-3">
							<svg class="w-6 h-6 text-green-600 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
							</svg>
							<span class="text-gray-900 text-lg"><strong>All form field types</strong> - Text, email, phone, dropdown</span>
						</li>
						<li class="flex items-start gap-3">
							<svg class="w-6 h-6 text-green-600 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
							</svg>
							<span class="text-gray-900 text-lg"><strong>CSV export</strong> - Download your data anytime</span>
						</li>
						<li class="flex items-start gap-3">
							<svg class="w-6 h-6 text-green-600 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
							</svg>
							<span class="text-gray-900 text-lg"><strong>Embed anywhere</strong> - Share via link or iframe</span>
						</li>
						<li class="flex items-start gap-3">
							<svg class="w-6 h-6 text-green-600 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
							</svg>
							<span class="text-gray-900 text-lg"><strong>Custom thank you message</strong> - Personalize your forms</span>
						</li>
					</ul>

					<button
						onclick={handleGetStarted}
						class="w-full px-8 py-5 bg-black text-white font-bold text-xl rounded-2xl hover:bg-gray-800 transition-all shadow-2xl hover:shadow-3xl hover:-translate-y-1"
					>
						Get Started Now →
					</button>
					<p class="text-center text-gray-500 text-sm mt-4">
						No credit card required • Sign up in 30 seconds
					</p>
				</div>
			</div>
		</div>
	</section>

	<!-- FAQ Section -->
	<section id="faq" class="bg-gray-50 py-20 md:py-32">
		<div class="container mx-auto px-4">
			<div class="text-center mb-16">
				<h2 class="text-4xl md:text-5xl font-extrabold text-gray-900 mb-4">
					Frequently Asked Questions
				</h2>
				<p class="text-lg md:text-xl text-gray-600 max-w-2xl mx-auto">
					Everything you need to know about LidForm
				</p>
			</div>

			<div class="max-w-3xl mx-auto space-y-6">
				<!-- FAQ 1 -->
				<details class="bg-white rounded-2xl border-2 border-gray-200 p-6 hover:border-black transition-all group">
					<summary class="font-bold text-xl text-gray-900 cursor-pointer flex items-center justify-between">
						<span>Is LidForm really free forever?</span>
						<svg class="w-6 h-6 text-gray-400 group-open:rotate-180 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
						</svg>
					</summary>
					<p class="mt-4 text-gray-600 leading-relaxed text-lg">
						Yes! LidForm is 100% free forever. No hidden fees, no premium plans, no limits. We believe form building should be accessible to everyone.
					</p>
				</details>

				<!-- FAQ 2 -->
				<details class="bg-white rounded-2xl border-2 border-gray-200 p-6 hover:border-black transition-all group">
					<summary class="font-bold text-xl text-gray-900 cursor-pointer flex items-center justify-between">
						<span>How many forms can I create?</span>
						<svg class="w-6 h-6 text-gray-400 group-open:rotate-180 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
						</svg>
					</summary>
					<p class="mt-4 text-gray-600 leading-relaxed text-lg">
						Create unlimited forms! There are no restrictions on the number of forms you can build or the number of responses you can collect.
					</p>
				</details>

				<!-- FAQ 3 -->
				<details class="bg-white rounded-2xl border-2 border-gray-200 p-6 hover:border-black transition-all group">
					<summary class="font-bold text-xl text-gray-900 cursor-pointer flex items-center justify-between">
						<span>Can I export my form data?</span>
						<svg class="w-6 h-6 text-gray-400 group-open:rotate-180 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
						</svg>
					</summary>
					<p class="mt-4 text-gray-600 leading-relaxed text-lg">
						Absolutely! You can export all your form submissions to CSV format anytime. Perfect for analysis in Excel, Google Sheets, or any other tool.
					</p>
				</details>

				<!-- FAQ 4 -->
				<details class="bg-white rounded-2xl border-2 border-gray-200 p-6 hover:border-black transition-all group">
					<summary class="font-bold text-xl text-gray-900 cursor-pointer flex items-center justify-between">
						<span>Do I need to know how to code?</span>
						<svg class="w-6 h-6 text-gray-400 group-open:rotate-180 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
						</svg>
					</summary>
					<p class="mt-4 text-gray-600 leading-relaxed text-lg">
						Not at all! LidForm is designed to be simple and intuitive. Just sign up, create your form, and share it. No coding knowledge required.
					</p>
				</details>

				<!-- FAQ 5 -->
				<details class="bg-white rounded-2xl border-2 border-gray-200 p-6 hover:border-black transition-all group">
					<summary class="font-bold text-xl text-gray-900 cursor-pointer flex items-center justify-between">
						<span>Can I embed forms on my website?</span>
						<svg class="w-6 h-6 text-gray-400 group-open:rotate-180 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
						</svg>
					</summary>
					<p class="mt-4 text-gray-600 leading-relaxed text-lg">
						Yes! You can share your forms via a direct link or embed them on any website using our iframe code. It's super easy!
					</p>
				</details>

				<!-- FAQ 6 -->
				<details class="bg-white rounded-2xl border-2 border-gray-200 p-6 hover:border-black transition-all group">
					<summary class="font-bold text-xl text-gray-900 cursor-pointer flex items-center justify-between">
						<span>Is my data secure?</span>
						<svg class="w-6 h-6 text-gray-400 group-open:rotate-180 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
						</svg>
					</summary>
					<p class="mt-4 text-gray-600 leading-relaxed text-lg">
						Your data security is our priority. We use Supabase for secure data storage with row-level security policies to ensure only you can access your forms and submissions.
					</p>
				</details>
			</div>
		</div>
	</section>

	<!-- Footer -->
	<footer class="bg-white border-t-2 border-gray-200 py-12">
		<div class="container mx-auto px-4">
			<div class="grid md:grid-cols-4 gap-12 mb-12">
				<!-- Brand -->
				<div class="md:col-span-2">
					<a href="/" class="flex items-center gap-3 mb-4 group">
						<img src="/Logo (1).png" alt="LidForm" class="w-12 h-12 transition-transform group-hover:scale-105" />
						<span class="text-2xl font-bold text-gray-900">LidForm</span>
					</a>
					<p class="text-gray-600 leading-relaxed mb-4">
						Create beautiful forms in seconds. Collect responses, analyze data, and grow your business. Completely free, forever.
					</p>
					<div class="text-sm text-gray-500">
						© 2025 LidForm. All rights reserved.
					</div>
				</div>

				<!-- Product -->
				<div>
					<h3 class="font-bold text-gray-900 mb-4 text-lg">Product</h3>
					<ul class="space-y-3">
						<li>
							<a href="/auth/signup" class="text-gray-600 hover:text-black transition-colors">Get Started</a>
						</li>
						<li>
							<a href="/auth/login" class="text-gray-600 hover:text-black transition-colors">Sign In</a>
						</li>
						<li>
							<a href="#features" class="text-gray-600 hover:text-black transition-colors">Features</a>
						</li>
						<li>
							<a href="#pricing" class="text-gray-600 hover:text-black transition-colors">Pricing</a>
						</li>
					</ul>
				</div>

				<!-- Support -->
				<div>
					<h3 class="font-bold text-gray-900 mb-4 text-lg">Support</h3>
					<ul class="space-y-3">
						<li>
							<a href="#faq" class="text-gray-600 hover:text-black transition-colors">FAQ</a>
						</li>
						<li>
							<a href="mailto:support@softodesign.com" class="text-gray-600 hover:text-black transition-colors">Contact Us</a>
						</li>
						<li>
							<a href="/privacy" class="text-gray-600 hover:text-black transition-colors">Privacy Policy</a>
						</li>
						<li>
							<a href="/terms" class="text-gray-600 hover:text-black transition-colors">Terms of Service</a>
						</li>
					</ul>
				</div>
			</div>

			<div class="border-t border-gray-200 pt-8">
				<div class="text-center text-gray-600">
					<p class="mb-2">Made with ❤️ for form builders everywhere</p>
					<p class="text-sm">Powered by SvelteKit & Supabase</p>
				</div>
			</div>
		</div>
	</footer>
</div>

<style>
	:global(html) {
		scroll-behavior: smooth;
	}

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
