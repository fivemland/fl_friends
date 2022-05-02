<script>
  import Header from './components/Header.svelte';
  import PlayerLine from './components/PlayerLine.svelte';

  import { visible, activePage, PAGES, players } from './stores';

  let requestID = '';

  function sendRequest() {
    fetch(`https://${GetParentResourceName()}/sendRequest`, {
      method: 'POST',
      body: JSON.stringify({
        requestID,
      }),
    });

    requestID = '';
  }
</script>

{#if $visible}
  <main class="w-1/3 rounded-xl p-2 bg-slate-700">
    <Header />

    <div class="mt-2 w-full flex justify-center">
      {#each $PAGES as page}
        <button on:click={activePage.set(page.name)} class={`btn btn-sm w-1/2 mx-1 ${$activePage === page.name ? 'btn-info' : ''}`}>
          {page.label}
        </button>
      {/each}
    </div>

    <div class="mt-2 max-h-72 overflow-y-auto">
      {#if !$players[$activePage] || $players[$activePage].length <= 0}
        <div class="text-center text-warning text-lg italic mt-5">{$PAGES.find((page) => page.name === $activePage).no_text}</div>
      {:else}
        {#each $players[$activePage] as player}
          <PlayerLine {player} />
        {/each}
      {/if}
    </div>

    <div class="mt-5 flex justify-center">
      <input bind:value={requestID} type="text" placeholder="ID" class="input input-sm input-bordered input-accent mr-1" />
      <button on:click={sendRequest} disabled={requestID.length <= 0} class="btn btn-sm btn-accent ml-1"> Send Request </button>
    </div>
  </main>
{/if}
