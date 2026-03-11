
const app = document.getElementById('app');
const viewRoot = document.getElementById('viewRoot');
const topbar = document.getElementById('topbar');
const closeBtn = document.getElementById('closeBtn');
const versionBadge = document.getElementById('versionBadge');
const titleMascot = document.getElementById('titleMascot');

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
    favoriteVolumes: {}
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
  editingSlot: 1,
  favoriteVolumeOpen: ''
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
  if (data.settings) {
    state.settings = data.settings;
    state.settings.favorites = state.settings.favorites || {};
    state.settings.favoriteSlots = state.settings.favoriteSlots || {};
    state.settings.favoriteVolumes = state.settings.favoriteVolumes || {};
  }
  if (Array.isArray(data.soundCatalog)) state.soundCatalog = data.soundCatalog;
  if (Array.isArray(data.deletedCatalog)) state.deletedCatalog = data.deletedCatalog;
  if (data.hotbar) state.hotbar = data.hotbar;
  if (Array.isArray(data.rangeLevels)) state.rangeLevels = data.rangeLevels;
  if (Array.isArray(data.volumeLevels)) state.volumeLevels = data.volumeLevels;
  if (typeof data.isAdmin === 'boolean') state.isAdmin = data.isAdmin;
  if (data.version) state.hotbar.version = data.version;
  versionBadge.textContent = `v${data.version || state.hotbar.version || '1.0.0'}`;
  if (titleMascot) {
    const version = encodeURIComponent(data.version || state.hotbar.version || '1.0.0');
    const localAsset = `assets/meme.png?v=${version}`;
    const fallbackAsset = `./assets/meme.png?v=${version}`;
    if (!titleMascot.dataset.bound) {
      titleMascot.dataset.bound = '1';
      titleMascot.onerror = () => {
        titleMascot.src = fallbackAsset;
      };
    }
    if (!titleMascot.src || !titleMascot.src.includes('assets/meme.png')) {
      titleMascot.src = localAsset;
    }
  }
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
  const hotbar = state.hotbar || {};
  if (!hotbar.visible) {
    topbar.classList.add('hidden');
    topbar.innerHTML = '';
    return;
  }

  const defaultCard = `
    <div class="topbar-card ${Number(hotbar.selectedSlot || 0) === 0 ? 'active' : ''}">
      <div class="slot-k">0</div>
      <div class="slot-v">${escapeHtml(hotbar.defaultLabel || '未設定')}</div>
    </div>
  `;

  const cards = (hotbar.slots || []).map((slot) => `
    <div class="topbar-card ${slot.isSelected ? 'active' : ''}">
      <div class="slot-k">${slot.slot}</div>
      <div class="slot-v">${escapeHtml(slot.label || '未設定')}</div>
    </div>
  `).join('');

  topbar.innerHTML = `
    <div class="topbar-main">
      <div>現在: ${escapeHtml(hotbar.currentLabel || '')}</div>
      <div>R: 設定</div>
    </div>
    ${defaultCard}
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
        <h3>音量設定</h3>
        <p>再生した音が周りのプレイヤーに聞こえる大きさを変えます。</p>
        <div class="current">現在: ${escapeHtml(state.volumeLevels[(state.settings.volumeLevel || 1) - 1]?.name || '')}</div>
        <button class="action-btn" data-action="open-volume">音量設定</button>
      </div>
      <div class="card">
        <h3>お気に入り設定</h3>
        <p>お気に入り登録した音源を 1〜9 のスロットに入れます。各種お気に入りの音量は一覧の音量マークから変えられます。</p>
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
  const visibleCatalog = filteredCatalog('catalog');
  const totalCatalogCount = state.soundCatalog.length;
  const desc = target === 'death'
    ? '未選択にすると死亡時は無音です。'
    : `再生は自分だけ、選択でデフォルト音に設定されます。現在のMP3数: ${visibleCatalog.length}件 / 全体 ${totalCatalogCount}件`;

  const items = visibleCatalog.map((row) => {
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
        ${target === 'default' ? '<button class="sub-btn gold" data-action="open-favorites">お気に入り設定</button>' : ''}
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
        <h2>音量設定</h2>
        <p>ここで変更した音量は、自分だけでなく周りのプレイヤーに聞こえる大きさにも反映されます。</p>
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
  if (!Number.isInteger(state.editingSlot) || state.editingSlot < 1 || state.editingSlot > 9) state.editingSlot = 1;
  const slotCards = Array.from({ length: 9 }, (_, idx) => {
    const slot = idx + 1;
    const key = String(slot);
    const file = state.settings.favoriteSlots[key] || '';
    const label = file ? getLabel(file) : '未設定';
    return `
      <button class="slot-btn ${state.editingSlot === slot ? 'active' : ''}" data-action="pick-slot" data-slot="${slot}">
        <div class="slot-number">スロット ${slot}</div>
        <div class="slot-label">${escapeHtml(label)}</div>
        <div class="slot-empty">${file ? escapeHtml(file) : '空きスロット'}</div>
      </button>
    `;
  }).join('');

  const items = favoriteRows().map((row) => {
    const file = row.file;
    const level = Number(state.settings.favoriteVolumes?.[file] || state.settings.volumeLevel || 1);
    const currentVol = state.volumeLevels[(level || 1) - 1];
    const isOpen = state.favoriteVolumeOpen === file;
    return `
      <div class="favorite-item">
        <div>
          <div class="slot-label">${escapeHtml(row.label || row.file)}</div>
          <div class="filename">${escapeHtml(row.file)}</div>
          ${isOpen ? `
          <div class="favorite-volume-panel">
            <p>各種お気に入りの音の大きさを変えられます。変更した大きさは保存され、周りに聞こえる音にも反映されます。</p>
            <div class="favorite-volume-slider-row">
              <input class="favorite-volume-slider" type="range" min="1" max="${state.volumeLevels.length}" step="1" value="${level}" data-action="favorite-volume-slider" data-file="${escapeHtml(file)}">
              <div class="favorite-volume-current">${escapeHtml(currentVol?.name || '')} ${Math.round((currentVol?.value || 0) * 100)}%</div>
            </div>
          </div>` : ''}
        </div>
        <div class="item-actions">
          <button class="icon-mini-btn ${isOpen ? 'active' : ''}" title="お気に入り音量" data-action="toggle-favorite-volume" data-file="${escapeHtml(file)}">🔊</button>
          <button class="sub-btn blue" data-action="preview" data-file="${escapeHtml(file)}">再生</button>
          <button class="sub-btn gold" data-action="assign-slot" data-slot="${state.editingSlot}" data-file="${escapeHtml(file)}">スロット${state.editingSlot}に入れる</button>
        </div>
      </div>
    `;
  }).join('');

  viewRoot.innerHTML = `
    <div class="list-header">
      <div>
        <h2>お気に入り設定</h2>
        <p>上でスロットを選び、下のお気に入り音源を入れてください。再生の左にある音量マークで、各種お気に入りの音の大きさを変えられます。</p>
      </div>
      <button class="sub-btn" data-action="back">戻る</button>
    </div>
    <div class="favorite-layout">
      <div class="card">
        <h3>1〜9 スロット</h3>
        <p>手を上げている間、キーボード 1〜9 で切り替えられます。0キーはデフォルト音に戻します。</p>
        <div class="slot-grid">${slotCards}</div>
        <div class="footer-actions">
          <button class="action-btn" data-action="clear-slot" data-slot="${state.editingSlot}">選択中スロットを解除</button>
        </div>
      </div>
      <div class="card">
        <h3>お気に入り一覧</h3>
        <p>MP3一覧の星で登録した音源だけがここに出ます。</p>
        <div class="favorite-list">${items || '<div class="empty-note">お気に入りがありません。MP3一覧で☆を押してください。</div>'}</div>
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
  return `audio/${encoded}`;
}

function ensureAudio(id, file) {
  let audio = state.activeAudio.get(id);
  if (!audio) {
    audio = new Audio();
    audio.preload = 'auto';
    audio.autoplay = false;
    audio.addEventListener('ended', () => stopAndRemoveAudio(id));
    state.activeAudio.set(id, audio);
  }
  const src = buildAudioSrc(file);
  const currentSrc = audio.getAttribute('src') || '';
  if (currentSrc !== src) {
    audio.setAttribute('src', src);
  }
  return audio;
}

function tryPlayAudio(audio, file) {
  const playPromise = audio.play();
  if (playPromise && typeof playPromise.catch === 'function') {
    playPromise.catch((err) => {
      console.error('meme radio play failed', file, err);
      setTimeout(() => {
        const retryPromise = audio.play();
        if (retryPromise && typeof retryPromise.catch === 'function') {
          retryPromise.catch((retryErr) => console.error('meme radio retry failed', file, retryErr));
        }
      }, 75);
    });
  }
}

function playAudio(id, file, volume) {
  stopAndRemoveAudio(id);
  const audio = ensureAudio(id, file);
  audio.volume = Math.max(0, Math.min(1, Number(volume) || 0));

  const startPlayback = () => {
    try {
      audio.currentTime = 0;
    } catch (e) {
      // ignore seek errors before metadata is ready
    }
    tryPlayAudio(audio, file);
  };

  if (audio.readyState >= 2) {
    startPlayback();
    return;
  }

  audio.addEventListener('canplay', startPlayback, { once: true });
  audio.load();
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
  const slot = Number(target.dataset.slot || 1);
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
    state.editingSlot = 1;
    renderFavorites();
    return;
  }
  if (action === 'open-deleted') {
    state.search = '';
    renderDeleted();
    return;
  }
  if (action === 'preview') {
    const level = Number(state.settings.favoriteVolumes?.[file] || state.settings.volumeLevel || 1);
    await resourceFetch('previewSound', { file, level });
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
    state.editingSlot = Math.min(9, Math.max(1, slot || 1));
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
  if (action === 'toggle-favorite-volume') {
    saveScroll('favorites', '.favorite-list');
    state.favoriteVolumeOpen = state.favoriteVolumeOpen === file ? '' : file;
    renderFavorites();
    return;
  }
});


document.addEventListener('input', (event) => {
  const target = event.target;
  if (!target?.matches?.('[data-action="favorite-volume-slider"]')) return;
  const file = target.dataset.file;
  const level = Number(target.value || 1);
  state.settings.favoriteVolumes = state.settings.favoriteVolumes || {};
  state.settings.favoriteVolumes[file] = level;
  const row = target.closest('.favorite-volume-panel');
  const info = state.volumeLevels[level - 1];
  const label = row?.querySelector('.favorite-volume-current');
  if (label) {
    label.textContent = `${info?.name || ''} ${Math.round((info?.value || 0) * 100)}%`;
  }
});

document.addEventListener('change', async (event) => {
  const target = event.target;
  if (!target?.matches?.('[data-action="favorite-volume-slider"]')) return;
  saveScroll('favorites', '.favorite-list');
  const file = target.dataset.file;
  const level = Number(target.value || 1);
  state.favoriteVolumeOpen = file;
  await resourceFetch('setFavoriteVolume', { file, level });
});

document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' && state.open) {
    resourceFetch('closeUi');
  }
});
