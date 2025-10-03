<script lang="ts">
	import { goto } from '$app/navigation';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	let email = $state('');
	let password = $state('');
	let confirmPassword = $state('');
	let error = $state('');
	let success = $state('');
	let loading = $state(false);

	async function handleSignup() {
		if (loading) return;
		error = '';
		success = '';
		loading = true;

		if (password !== confirmPassword) {
			error = 'Passwords do not match';
			loading = false;
			return;
		}

		if (password.length < 6) {
			error = 'Password must be at least 6 characters';
			loading = false;
			return;
		}

		const { error: signUpError } = await data.supabase.auth.signUp({
			email,
			password
		});

		if (signUpError) {
			error = signUpError.message;
			loading = false;
		} else {
			success = 'Account created successfully! Redirecting...';
			setTimeout(() => {
				goto('/dashboard');
			}, 1500);
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>Sign Up - LidForm</title>
	<meta name="description" content="Create your free LidForm account to start building beautiful forms in seconds." />
</svelte:head>

<div class="min-h-screen flex items-center justify-center bg-gray-50 px-4">
	<div class="max-w-md w-full">
		<div class="bg-white rounded-3xl border-2 border-gray-200 shadow-2xl p-10 animate-fade-in">
			<div class="text-center mb-10">
				<img src="/Logo (1).png" alt="LidForm" class="w-16 h-16 mx-auto mb-4" />
				<h1 class="text-4xl font-extrabold text-gray-900 mb-2">Create your account</h1>
				<p class="text-gray-600">Start creating forms in seconds</p>
			</div>

			{#if error}
				<div class="bg-red-50 border border-red-200 text-red-800 rounded-lg p-4 mb-6">
					{error}
				</div>
			{/if}

			{#if success}
				<div class="bg-green-50 border border-green-200 text-green-800 rounded-lg p-4 mb-6">
					{success}
				</div>
			{/if}

			<form onsubmit={(e) => { e.preventDefault(); handleSignup(); }} class="space-y-4">
				<div>
					<label for="email" class="block text-sm font-medium text-gray-700 mb-2">
						Email address
					</label>
					<input
						id="email"
						type="email"
						bind:value={email}
						required
						class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
						placeholder="you@example.com"
					/>
				</div>

				<div>
					<label for="password" class="block text-sm font-medium text-gray-700 mb-2">
						Password
					</label>
					<input
						id="password"
						type="password"
						bind:value={password}
						required
						class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
						placeholder="••••••••"
					/>
				</div>

				<div>
					<label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">
						Confirm Password
					</label>
					<input
						id="confirmPassword"
						type="password"
						bind:value={confirmPassword}
						required
						class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
						placeholder="••••••••"
					/>
				</div>

				<button
					type="submit"
					disabled={loading}
					class="w-full bg-black text-white font-semibold py-3 px-4 rounded-xl hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all hover:-translate-y-0.5 shadow-lg"
				>
					{loading ? 'Creating account...' : 'Sign up'}
				</button>
			</form>


			<p class="text-center mt-6 text-sm text-gray-600">
				Already have an account?
				<a href="/auth/login" class="text-black hover:underline font-semibold">
					Sign in
				</a>
			</p>
		</div>
	</div>
</div>

<style>
	@keyframes fade-in {
		from {
			opacity: 0;
			transform: scale(0.95);
		}
		to {
			opacity: 1;
			transform: scale(1);
		}
	}

	.animate-fade-in {
		animation: fade-in 0.4s ease-out;
	}
</style>

