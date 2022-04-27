<script>
  import { activePage } from '../stores';
  import Loading from './Loading.svelte';

  export let player;

  let userInfo = false;

  async function openInfo() {
    userInfo = false;

    const response = await fetch(`https://${GetParentResourceName()}/requestPlayerInfo`, {
      method: 'POST',
      body: JSON.stringify({
        identifier: player.friend,
      }),
    });

    const responseJson = await response.json();

    if (responseJson.error) return (userInfo = responseJson.error);

    userInfo = responseJson.result;
  }

  function friendInteraction(method = 'delete') {
    fetch(`https://${GetParentResourceName()}/friendInteraction`, {
      method: 'POST',
      body: JSON.stringify({
        method,
        player,
      }),
    });
  }
</script>

{#if typeof player === 'object'}
  <div class="grid grid-flow-col gap-1 px-2 text-center items-center bg-slate-800 border-b border-gray-900 rounded-md p-2">
    <div class="w-50 text-left">{player.charName}</div>
    <div class="w-50 text-right">
      {#if $activePage === 'pendings'}
        <button on:click={() => friendInteraction('accept')} class="btn btn-success btn-sm btn-circle">
          <i class="fa-solid fa-check" />
        </button>
      {:else}
        <label on:click={openInfo} for="playerInfoModal" class="btn btn-info btn-sm btn-circle"><i class="fa-solid fa-info" /></label>
      {/if}
      <button on:click={() => friendInteraction('delete')} class="btn btn-error btn-sm btn-circle">
        <i class="fa-solid fa-trash-can" />
      </button>
    </div>
  </div>

  <input type="checkbox" id="playerInfoModal" class="modal-toggle" />
  <div class="modal">
    <div class="modal-box relative">
      <label on:click={(userInfo = false)} for="playerInfoModal" class="btn btn-sm btn-circle absolute right-2 top-2">
        <i class="fa-solid fa-xmark text-lg" />
      </label>
      <h3 class="text-lg font-bold">Friend Informations</h3>

      {#if userInfo === false || userInfo === undefined}
        <Loading />
      {:else if typeof userInfo === 'string'}
        {userInfo}
      {:else}
        <div class="overflow-x-auto mt-3 bg-base-200 p-3 rounded-md">
          <table class="table table-compact w-full">
            <tbody>
              <tr>
                <td>Character Name</td>
                <td class="text-right">{userInfo.charName}</td>
              </tr>
              <tr>
                <td>Discord Name</td>
                <td class="text-right">{userInfo.discordName}</td>
              </tr>
              <tr>
                <td>Status</td>
                <td class={`text-right ${userInfo.online ? 'text-success' : 'text-error'}`}>
                  {#if userInfo.online}
                    <i class="fa-solid fa-circle" />
                    Online
                  {:else}
                    <i class="fa-solid fa-circle-dot" />
                    Offline
                  {/if}
                </td>
              </tr>
              <tr>
                <td>Phone Number</td>
                <td class="text-right">{userInfo.phone_number}</td>
              </tr>
            </tbody>
          </table>
        </div>
      {/if}
    </div>
  </div>
{/if}
