
const app = document.getElementById('app');
const viewRoot = document.getElementById('viewRoot');
const topbar = document.getElementById('topbar');
const closeBtn = document.getElementById('closeBtn');
const versionBadge = document.getElementById('versionBadge');

const state = {
  open: false,
  isAdmin: false,
  settings: {
    defaultPlaySound: '',
    deathSound: '',
    rangeLevel: 1,
    volumeLevel: 1,
    favorites: {},
    favoriteSlots: {},
    favoriteSlotVolumes: {}
  },
  soundCatalog: [],
  deletedCatalog: [],
  hotbar: { visible: false, slots: [], currentLabel: '', version: '' },
  rangeLevels: [],
  volumeLevels: [],
  activeAudio: new Map(),
  currentView: 'main',
  workingTarget: 'default',
  search: '',
  scroll: { list: 0, favorites: 0, deleted: 0 },
  editingSlot: 1
};

function resourceFetch(name, data = {}) {
  const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : '3rd_meme_radio';
  return fetch(`https://${resource}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data)
  }).then((res) => res.json().catch(() => ({}))).catch(() => ({}));
}

function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function setState(data) {
  if (data.settings) state.settings = data.settings;
  if (Array.isArray(data.soundCatalog)) state.soundCatalog = data.soundCatalog;
  if (Array.isArray(data.deletedCatalog)) state.deletedCatalog = data.deletedCatalog;
  if (data.hotbar) state.hotbar = data.hotbar;
  if (Array.isArray(data.rangeLevels)) state.rangeLevels = data.rangeLevels;
  if (Array.isArray(data.volumeLevels)) state.volumeLevels = data.volumeLevels;
  if (typeof data.isAdmin === 'boolean') state.isAdmin = data.isAdmin;
  if (data.version) state.hotbar.version = data.version;
  versionBadge.textContent = `v${data.version || state.hotbar.version || '1.0.0'}`;
}

function show(open) {
  state.open = open;
  app.classList.toggle('hidden', !open);
}

function saveScroll(key, selector) {
  const node = document.querySelector(selector);
  if (node) state.scroll[key] = node.scrollTop;
}

function restoreScroll(key, selector) {
  const node = document.querySelector(selector);
  if (node) node.scrollTop = state.scroll[key] || 0;
}

function getLabel(file) {
  const entry = state.soundCatalog.find((row) => row.file === file) || state.deletedCatalog.find((row) => row.file === file);
  return entry ? entry.label : file;
}

function filteredCatalog(source) {
  const q = (state.search || '').trim().toLowerCase();
  const arr = source === 'deleted' ? state.deletedCatalog : state.soundCatalog;
  if (!q) return arr;
  return arr.filter((row) => row.file.toLowerCase().includes(q) || String(row.label || '').toLowerCase().includes(q));
}

function renderTopbar() {
  if (!state.hotbar?.visible) {
    topbar.classList.add('hidden');
    topbar.innerHTML = '';
    return;
  }

  const cards = (state.hotbar.slots || []).map((slot) => `
    <div class="topbar-card ${slot.isSelected ? 'active' : ''}">
      <div class="slot-k">${slot.slot === 0 ? '0 / DEFAULT' : `${slot.slot}`}</div>
      <div class="slot-v">${escapeHtml(slot.label || '未設定')}</div>
      <div class="badge">音量: ${escapeHtml(slot.volumeName || '')}</div>
    </div>
  `).join('');

  topbar.innerHTML = `
    <div class="topbar-title">
      <span>現在: ${escapeHtml(state.hotbar.currentLabel || '')}</span>
      <span>v${escapeHtml(state.hotbar.version || '1.0.0')}</span>
      <span>R: 設定 / 1-9: お気に入り / 0: デフォルト</span>
    </div>
    ${cards}
  `;
  topbar.classList.remove('hidden');
}

function renderMain() {
  state.currentView = 'main';
  viewRoot.innerHTML = `
    <div class="grid">
      <div class="card">
        <h3>通常再生 MP3</h3>
        <p>Xで手を上げた瞬間に再生される音です。</p>
        <div class="current">現在: ${escapeHtml(getLabel(state.settings.defaultPlaySound || ''))}</div>
        <button class="action-btn" data-action="open-list" data-target="default">MP3変更</button>
      </div>
      <div class="card">
        <h3>死亡時の音</h3>
        <p>設定すると死亡時にも同じように周囲へ流れます。</p>
        <div class="current">現在: ${escapeHtml(state.settings.deathSound ? getLabel(state.settings.deathSound) : '未選択')}</div>
        <button class="action-btn" data-action="open-list" data-target="death">死亡時の音設定</button>
      </div>
      <div class="card">
        <h3>音の広さ</h3>
        <p>近距離 1m / 3m と、通常レンジ拡張を選べます。</p>
        <div class="current">現在: ${escapeHtml(state.rangeLevels[(state.settings.rangeLevel || 1) - 1]?.name || '')}</div>
        <button class="action-btn" data-action="open-range">広さ設定</button>
      </div>
      <div class="card">
        <h3>デフォルト音量</h3>
        <p>デフォルト音と、スロット 0 の音量です。</p>
        <div class="current">現在: ${escapeHtml(state.volumeLevels[(state.settings.volumeLevel || 1) - 1]?.name || '')}</div>
        <button class="action-btn" data-action="open-volume">音量設定</button>
      </div>
      <div class="card">
        <h3>お気に入り設定</h3>
        <p>お気に入り登録した音源を 1〜9 のスロットに入れます。各スロットごとに音量も変えられます。</p>
        <button class="action-btn" data-action="open-favorites">お気に入り設定</button>
      </div>
      ${state.isAdmin ? `
      <div class="card">
        <h3>削除一覧</h3>
        <p>一般ユーザーには見せたくない音源を非表示にできます。戻すと即時復帰します。</p>
        <button class="action-btn" data-action="open-deleted">削除一覧</button>
      </div>` : ''}
    </div>
    <div class="footer-actions">
      <button class="action-btn save" data-action="save">保存</button>
      <button class="action-btn close" data-action="close">閉じる</button>
    </div>
  `;
}

function renderList(target) {
  state.currentView = 'list';
  state.workingTarget = target;

  const current = target === 'death' ? state.settings.deathSound : state.settings.defaultPlaySound;
  const title = target === 'death' ? '死亡時の音設定' : 'MP3変更';
  const desc = target === 'death' ? '未選択にすると死亡時は無音です。' : '再生は自分だけ、選択でデフォルト音に設定されます。';

  const items = filteredCatalog('catalog').map((row) => {
    const file = row.file;
    const label = row.label || row.file;
    const isSelected = current === file;
    const isFav = !!state.settings.favorites[file];
    return `
      <div class="list-item ${isSelected ? 'selected' : ''}">
        <div class="list-meta">
          <div class="list-title-row">
            <button class="favorite-star ${isFav ? 'on' : 'off'}" data-action="toggle-favorite" data-file="${escapeHtml(file)}">${isFav ? '★' : '☆'}</button>
            <div>
              <h4>${escapeHtml(label)}</h4>
              <div class="filename">${escapeHtml(file)}</div>
            </div>
          </div>
        </div>
        <div class="item-actions">
          ${state.isAdmin ? `<button class="trash-btn" title="削除" data-action="delete-sound" data-file="${escapeHtml(file)}">🗑</button>` : ''}
          <button class="sub-btn blue" data-action="preview" data-file="${escapeHtml(file)}">再生</button>
          <button class="sub-btn gold" data-action="${target === 'death' ? 'select-death' : 'select-default'}" data-file="${escapeHtml(file)}">選択</button>
        </div>
      </div>
    `;
  }).join('');

  viewRoot.innerHTML = `
    <div class="list-header">
      <div>
        <h2>${escapeHtml(title)}</h2>
        <p>${escapeHtml(desc)}</p>
      </div>
      <div class="list-tools">
        <input id="searchInput" class="search-input" placeholder="タイトル / ファイル名で検索" value="${escapeHtml(state.search)}">
        <button class="sub-btn" data-action="back">戻る</button>
      </div>
    </div>
    ${target === 'death' ? `<div class="footer-actions" style="margin:0 0 14px 0"><button class="sub-btn red" data-action="clear-death">未選択にする</button></div>` : ''}
    <div class="list-wrap">${items || '<div class="empty-note">表示できる音源がありません。</div>'}</div>
  `;
  document.getElementById('searchInput')?.addEventListener('input', (e) => {
    saveScroll('list', '.list-wrap');
    state.search = e.target.value || '';
    renderList(target);
  });
  restoreScroll('list', '.list-wrap');
}

function renderRange() {
  state.currentView = 'range';
  resourceFetch('setRangePreview', { enabled: true });
  const buttons = state.rangeLevels.map((row, idx) => `
    <button class="level-btn ${(state.settings.rangeLevel === idx + 1) ? 'active' : ''}" data-action="set-range" data-level="${idx + 1}">
      <span class="big">Lv.${idx + 1}</span>
      <span class="small">${escapeHtml(row.name || '')}</span>
      <span class="small">${row.mode === 'absolute' ? `${row.value}m` : `ボイス x${row.value}`}</span>
    </button>
  `).join('');

  viewRoot.innerHTML = `
    <div class="list-header">
      <div>
        <h2>音の広さ設定</h2>
        <p>変更中は地面にリングを表示します。</p>
      </div>
      <button class="sub-btn" data-action="back">戻る</button>
    </div>
    <div class="card">
      <div class="current">現在: ${escapeHtml(state.rangeLevels[(state.settings.rangeLevel || 1) - 1]?.name || '')}</div>
      <div class="level-grid">${buttons}</div>
    </div>
    <div class="footer-actions">
      <button class="action-btn save" data-action="save">保存</button>
      <button class="action-btn close" data-action="close">閉じる</button>
    </div>
  `;
}

function renderVolume() {
  state.currentView = 'volume';
  const buttons = state.volumeLevels.map((row, idx) => `
    <button class="level-btn ${(state.settings.volumeLevel === idx + 1) ? 'active' : ''}" data-action="set-volume" data-level="${idx + 1}">
      <span class="big">Lv.${idx + 1}</span>
      <span class="small">${escapeHtml(row.name || '')}</span>
      <span class="small">${Math.round((row.value || 0) * 100)}%</span>
    </button>
  `).join('');

  viewRoot.innerHTML = `
    <div class="list-header">
      <div>
        <h2>デフォルト音量</h2>
        <p>スロット 0 と通常再生に使う音量です。</p>
      </div>
      <button class="sub-btn" data-action="back">戻る</button>
    </div>
    <div class="card">
      <div class="current">現在: ${escapeHtml(state.volumeLevels[(state.settings.volumeLevel || 1) - 1]?.name || '')}</div>
      <div class="level-grid">${buttons}</div>
    </div>
    <div class="footer-actions">
      <button class="action-btn save" data-action="save">保存</button>
      <button class="action-btn close" data-action="close">閉じる</button>
    </div>
  `;
}

function favoriteRows() {
  return state.soundCatalog.filter((row) => state.settings.favorites[row.file]);
}

function renderFavorites() {
  state.currentView = 'favorites';
  const slotCards = Array.from({ length: 9 }, (_, idx) => {
    const slot = idx + 1;
    const key = String(slot);
    const file = state.settings.favoriteSlots[key] || '';
    const label = file ? getLabel(file) : '未設定';
    const level = state.settings.favoriteSlotVolumes[key] || state.settings.volumeLevel || 1;
    return `
      <button class="slot-btn ${state.editingSlot === slot ? 'active' : ''}" data-action="pick-slot" data-slot="${slot}">
        <div class="slot-number">スロット ${slot}</div>
        <div class="slot-label">${escapeHtml(label)}</div>
        <div class="slot-empty">${file ? escapeHtml(file) : '空きスロット'}</div>
        <div class="slot-volume-row">
          <button data-action="slot-volume-down" data-slot="${slot}">-</button>
          <span>${escapeHtml(state.volumeLevels[(level || 1) - 1]?.name || '')}</span>
          <button data-action="slot-volume-up" data-slot="${slot}">+</button>
        </div>
      </button>
    `;
  }).join('');

  const items = favoriteRows().map((row) => `
    <div class="favorite-item">
      <div>
        <div class="slot-label">${escapeHtml(row.label || row.file)}</div>
        <div class="filename">${escapeHtml(row.file)}</div>
      </div>
      <div class="item-actions">
        <button class="sub-btn blue" data-action="preview" data-file="${escapeHtml(row.file)}">再生</button>
        <button class="sub-btn gold" data-action="assign-slot" data-slot="${state.editingSlot}" data-file="${escapeHtml(row.file)}">スロット${state.editingSlot}に入れる</button>
      </div>
    </div>
  `).join('');

  viewRoot.innerHTML = `
    <div class="list-header">
      <div>
        <h2>お気に入り設定</h2>
        <p>左でスロットを選び、右の音源を入れてください。各スロットの音量は左で変更できます。</p>
      </div>
      <button class="sub-btn" data-action="back">戻る</button>
    </div>
    <div class="favorite-layout">
      <div class="card">
        <h3>1〜9 スロット</h3>
        <p>手を上げている間に 1〜9 で切り替えます。0 はデフォルト音です。</p>
        <div class="slot-grid">${slotCards}</div>
        <div class="footer-actions">
          <button class="action-btn" data-action="clear-slot" data-slot="${state.editingSlot}">選択中スロットを解除</button>
        </div>
      </div>
      <div class="card">
        <h3>お気に入り一覧</h3>
        <p>MP3一覧の ☆ で登録した音源だけ表示されます。</p>
        <div class="favorite-list">${items || '<div class="empty-note">お気に入りがありません。MP3一覧の☆で追加してください。</div>'}</div>
      </div>
    </div>
    <div class="footer-actions">
      <button class="action-btn save" data-action="save">保存</button>
      <button class="action-btn close" data-action="close">閉じる</button>
    </div>
  `;
  restoreScroll('favorites', '.favorite-list');
}

function renderDeleted() {
  state.currentView = 'deleted';
  const items = filteredCatalog('deleted').map((row) => `
    <div class="list-item">
      <div class="list-meta">
        <div class="list-title-row">
          <button class="restore-btn" title="戻す" data-action="restore-sound" data-file="${escapeHtml(row.file)}">↺</button>
          <div>
            <h4>${escapeHtml(row.label || row.file)}</h4>
            <div class="filename">${escapeHtml(row.file)}</div>
          </div>
        </div>
      </div>
      <div class="item-actions">
        <button class="sub-btn green" data-action="restore-sound" data-file="${escapeHtml(row.file)}">戻す</button>
      </div>
    </div>
  `).join('');

  viewRoot.innerHTML = `
    <div class="list-header">
      <div>
        <h2>削除一覧</h2>
        <p>戻すと一般ユーザーにもすぐ表示されます。</p>
      </div>
      <div class="list-tools">
        <input id="searchInput" class="search-input" placeholder="タイトル / ファイル名で検索" value="${escapeHtml(state.search)}">
        <button class="sub-btn" data-action="back">戻る</button>
      </div>
    </div>
    <div class="list-wrap">${items || '<div class="empty-note">削除された音源はありません。</div>'}</div>
  `;
  document.getElementById('searchInput')?.addEventListener('input', (e) => {
    saveScroll('deleted', '.list-wrap');
    state.search = e.target.value || '';
    renderDeleted();
  });
  restoreScroll('deleted', '.list-wrap');
}

function render() {
  if (state.currentView === 'list') return renderList(state.workingTarget);
  if (state.currentView === 'range') return renderRange();
  if (state.currentView === 'volume') return renderVolume();
  if (state.currentView === 'favorites') return renderFavorites();
  if (state.currentView === 'deleted') return renderDeleted();
  return renderMain();
}

function stopAndRemoveAudio(id) {
  const audio = state.activeAudio.get(id);
  if (!audio) return;
  audio.pause();
  audio.removeAttribute('src');
  state.activeAudio.delete(id);
}

function buildAudioSrc(file) {
  const encoded = encodeURIComponent(file);
  const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : '3rd_meme_radio';
  return `https://cfx-nui-${resource}/html/audio/${encoded}`;
}

function ensureAudio(id, file) {
  let audio = state.activeAudio.get(id);
  if (!audio) {
    audio = new Audio();
    audio.preload = 'auto';
    audio.addEventListener('ended', () => stopAndRemoveAudio(id));
    state.activeAudio.set(id, audio);
  }
  const src = buildAudioSrc(file);
  if (audio.src !== src) {
    audio.src = src;
    audio.load();
  }
  return audio;
}

function playAudio(id, file, volume) {
  stopAndRemoveAudio(id);
  const audio = ensureAudio(id, file);
  audio.currentTime = 0;
  audio.volume = Math.max(0, Math.min(1, Number(volume) || 0));
  audio.play().catch((err) => console.error('meme radio play failed', file, err));
}

function setVolume(id, volume) {
  const audio = state.activeAudio.get(id);
  if (!audio) return;
  audio.volume = Math.max(0, Math.min(1, Number(volume) || 0));
}

function stopAudio(id) {
  stopAndRemoveAudio(id);
}

window.addEventListener('message', (event) => {
  const data = event.data || {};
  if (data.action === 'open') {
    setState(data);
    state.currentView = 'main';
    render();
    show(true);
    renderTopbar();
    return;
  }
  if (data.action === 'close') {
    resourceFetch('stopPreview');
    setState(data);
    show(false);
    renderTopbar();
    return;
  }
  if (data.action === 'hydrate') {
    setState(data);
    render();
    renderTopbar();
    return;
  }
  if (data.action === 'setHotbar') {
    state.hotbar = data;
    renderTopbar();
    return;
  }
  if (data.action === 'play3d' || data.action === 'playPreview') {
    playAudio(data.id, data.file, data.volume);
    return;
  }
  if (data.action === 'setVolume') {
    setVolume(data.id, data.volume);
    return;
  }
  if (data.action === 'stopSound') {
    stopAudio(data.id);
  }
});

closeBtn.addEventListener('click', () => resourceFetch('closeUi'));

document.addEventListener('click', async (event) => {
  const target = event.target.closest('[data-action]');
  if (!target) return;
  const action = target.dataset.action;
  const file = target.dataset.file;
  const slot = Number(target.dataset.slot || 0);
  const level = Number(target.dataset.level || 0);

  if (action === 'close') {
    resourceFetch('closeUi');
    return;
  }
  if (action === 'save') {
    await resourceFetch('saveSettings', state.settings);
    return;
  }
  if (action === 'back') {
    state.search = '';
    resourceFetch('setRangePreview', { enabled: false });
    state.currentView = 'main';
    render();
    return;
  }
  if (action === 'open-list') {
    state.search = '';
    state.workingTarget = target.dataset.target || 'default';
    renderList(state.workingTarget);
    return;
  }
  if (action === 'open-range') {
    renderRange();
    return;
  }
  if (action === 'open-volume') {
    renderVolume();
    return;
  }
  if (action === 'open-favorites') {
    renderFavorites();
    return;
  }
  if (action === 'open-deleted') {
    state.search = '';
    renderDeleted();
    return;
  }
  if (action === 'preview') {
    await resourceFetch('previewSound', { file });
    return;
  }
  if (action === 'toggle-favorite') {
    saveScroll('list', '.list-wrap');
    await resourceFetch('toggleFavorite', { file });
    return;
  }
  if (action === 'select-default') {
    saveScroll('list', '.list-wrap');
    await resourceFetch('selectDefaultSound', { file });
    return;
  }
  if (action === 'select-death') {
    saveScroll('list', '.list-wrap');
    await resourceFetch('selectDeathSound', { file });
    return;
  }
  if (action === 'clear-death') {
    await resourceFetch('selectDeathSound', { file: '' });
    return;
  }
  if (action === 'delete-sound') {
    if (confirm(`削除しますか？\n${getLabel(file)}`)) {
      saveScroll('list', '.list-wrap');
      await resourceFetch('deleteSound', { file });
    }
    return;
  }
  if (action === 'restore-sound') {
    saveScroll('deleted', '.list-wrap');
    await resourceFetch('restoreSound', { file });
    return;
  }
  if (action === 'set-range') {
    await resourceFetch('setRangeLevel', { level });
    return;
  }
  if (action === 'set-volume') {
    await resourceFetch('setVolumeLevel', { level });
    return;
  }
  if (action === 'pick-slot') {
    state.editingSlot = slot;
    renderFavorites();
    return;
  }
  if (action === 'assign-slot') {
    saveScroll('favorites', '.favorite-list');
    await resourceFetch('assignSlot', { slot, file });
    return;
  }
  if (action === 'clear-slot') {
    await resourceFetch('clearSlot', { slot });
    return;
  }
  if (action === 'slot-volume-down' || action === 'slot-volume-up') {
    const current = Number(state.settings.favoriteSlotVolumes[String(slot)] || state.settings.volumeLevel || 1);
    const next = action === 'slot-volume-down' ? Math.max(1, current - 1) : Math.min(state.volumeLevels.length, current + 1);
    await resourceFetch('setSlotVolume', { slot, level: next });
    return;
  }
});

document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' && state.open) {
    resourceFetch('closeUi');
  }
});
