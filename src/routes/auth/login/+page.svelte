<script lang="ts">
	import { goto } from '$app/navigation';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	let email = $state('');
	let password = $state('');
	let error = $state('');
	let loading = $state(false);

	async function handleLogin() {
		if (loading) return;
		error = '';
		loading = true;

		const { error: signInError } = await data.supabase.auth.signInWithPassword({
			email,
			password
		});

		if (signInError) {
			error = signInError.message;
			loading = false;
		} else {
			goto('/dashboard');
		}
	}
</script>

<svelte:head>
	<title>Sign In - LidForm</title>
	<meta name="description" content="Sign in to your LidForm account to create and manage forms." />
</svelte:head>

<div class="min-h-screen flex items-center justify-center bg-gray-50 px-4">
	<div class="max-w-md w-full">
		<div class="bg-white rounded-3xl border-2 border-gray-200 shadow-2xl p-10 animate-fade-in">
			<div class="text-center mb-10">
				<img src="/Logo (1).png" alt="LidForm" class="w-16 h-16 mx-auto mb-4" />
				<h1 class="text-4xl font-extrabold text-gray-900 mb-2">Welcome back</h1>
				<p class="text-gray-600">Sign in to your LidForm account</p>
			</div>

			{#if error}
				<div class="bg-red-50 border border-red-200 text-red-800 rounded-lg p-4 mb-6">
					{error}
				</div>
			{/if}

			<form onsubmit={(e) => { e.preventDefault(); handleLogin(); }} class="space-y-4">
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

				<button
					type="submit"
					disabled={loading}
					class="w-full bg-black text-white font-semibold py-3 px-4 rounded-xl hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all hover:-translate-y-0.5 shadow-lg"
				>
					{loading ? 'Signing in...' : 'Sign in'}
				</button>
			</form>


			<p class="text-center mt-6 text-sm text-gray-600">
				Don't have an account?
				<a href="/auth/signup" class="text-black hover:underline font-semibold">
					Sign up
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

