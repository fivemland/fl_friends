import { writable, readable, get } from 'svelte/store';

export const visible = writable(true);

export const PAGES = readable([
  {
    name: 'all',
    label: 'All Friends',
  },
  {
    name: 'pendings',
    label: 'Pending Friends',
  },
]);

export const activePage = writable('all');

export const players = writable(get(PAGES).reduce((acc, curr) => ((acc[curr.name] = []), acc), {}));

window.addEventListener('message', ({ data }) => {
  if (data.visible !== undefined) visible.set(data.visible);

  if (data.updatePlayers !== undefined) {
    let newPlayers = { all: [], pendings: [] };

    data.updatePlayers.forEach((player) => {
      if (player.pending === 1) {
        newPlayers.pendings = [...newPlayers.pendings, player];
      } else {
        newPlayers.all = [...newPlayers.all, player];
      }

      players.set(newPlayers);
    });
  }
});
