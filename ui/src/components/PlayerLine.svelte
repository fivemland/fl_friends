<script>
  import dayjs from 'dayjs';
  import relativeTime from 'dayjs/plugin/relativeTime';
  dayjs.extend(relativeTime);

  import { activePage } from '../stores';
  import Loading from './Loading.svelte';
  import CopyButton from './CopyButton.svelte';

  export let player;

  async function getUserInfo() {
    const response = await fetch(`https://${GetParentResourceName()}/requestPlayerInfo`, {
      method: 'POST',
      body: JSON.stringify({
        identifier: player.friend,
      }),
    });

    const { error, result } = await response.json();

    if (error) throw new Error(error);

    return result;
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
        <label for="playerInfoModal" class="btn btn-info btn-sm btn-circle"><i class="fa-solid fa-info" /></label>
      {/if}

      <label for="removeModal" class="btn btn-error btn-sm btn-circle">
        <i class="fa-solid fa-trash-can" />
      </label>
    </div>
  </div>

  <!-- Player informations modal -->
  <input type="checkbox" id="playerInfoModal" class="modal-toggle" />
  <div class="modal">
    <div class="modal-box relative">
      <label for="playerInfoModal" class="btn btn-sm btn-circle absolute right-2 top-2">
        <i class="fa-solid fa-xmark text-lg" />
      </label>
      <h3 class="text-lg font-bold">Friend Informations</h3>

      {#await getUserInfo()}
        <Loading />
      {:then data}
        <div class="overflow-x-auto mt-3 bg-base-200 p-3 rounded-md">
          <table class="table table-compact w-full">
            <tbody>
              <tr>
                <td>Character Name</td>
                <td class="text-right">{data.charName}</td>
              </tr>
              <tr>
                <td>Status</td>
                <td class={`text-right ${data.online ? 'text-success' : 'text-error'}`}>
                  {#if data.online}
                    <i class="fa-solid fa-circle" />
                    Online
                  {:else}
                    <i class="fa-solid fa-circle-dot" />
                    Offline
                  {/if}
                </td>
              </tr>
              <tr>
                <td>Friendship beginning date</td>
                <td class="text-right">{dayjs(data.add_date).fromNow()}</td>
              </tr>
              <tr>
                <td>
                  Discord Name
                  <CopyButton text={data.discordName} />
                </td>
                <td class="text-right">
                  {data.discordName}
                </td>
              </tr>
              <tr>
                <td>
                  Phone Number
                  <CopyButton text={data.phone_number} />
                </td>
                <td class="text-right">{data.phone_number}</td>
              </tr>
            </tbody>
          </table>
        </div>
      {:catch error}
        <div class="text-error text-center">
          <div class="text-xl">ERROR</div>
          {error.message}
        </div>
      {/await}
    </div>
  </div>
{/if}

<!-- Delete confirm modal -->
<input type="checkbox" id="removeModal" class="modal-toggle" />
<div class="modal">
  <div class="modal-box relative">
    <label for="removeModal" class="btn btn-sm btn-circle absolute right-2 top-2">
      <i class="fa-solid fa-xmark text-lg" />
    </label>
    <h3 class="text-lg font-bold">Friend Remove</h3>
    <div class="text-md">Are you sure you want to delete this friend?</div>

    <label on:click={() => friendInteraction('delete')} for="removeModal" class="btn btn-sm btn-error float-right">
      <i class="fa-solid fa-trash-can mr-1" /> Remove
    </label>
  </div>
</div>
