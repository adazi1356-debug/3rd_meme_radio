# 3rd Meme Radio

FiveM / QBCore 向けのミームラジオリソースです。  
`X` で手を上げて音を再生し、`R` で設定UIを開けます。

## 主な機能

- `X` で手上げトグル
  - 手を上げた瞬間に現在選択中の MP3 を周囲へ再生
  - もう一度 `X` で手を下げる
  - 連続再生時は前の音を止めてから新しい音を再生
- 距離減衰付き 3D 風再生
- 通常再生 MP3 設定
- 死亡時 MP3 設定
- お気に入り登録
- お気に入り 1〜9 スロット
- `0` はデフォルト音
- スロットごとの個別音量
- 近距離 1m / 3m を含む広さ設定
- 広さ変更中はリング表示
- 保存通知
- 管理者による MP3 非表示 / 復帰
- プレイヤーごとの設定保存
- meme_radio アイテム所持でのみ使用可能
- QBCore 現金購入ショップ付き
- QBCore / QB Inventory / QS Inventory / OX Inventory の所持判定に対応

## デフォルトキー

- `X` : 手上げ / 再生
- `R` : 設定UI
- `1〜9` : お気に入りスロット切替
- `0` : デフォルト音へ切替

## 導入

1. `3rd_meme_radio` フォルダを `resources` に入れる
2. `server.cfg` に追加

```cfg
ensure 3rd_meme_radio
```

3. `qb-core/shared/items.lua` などに `meme_radio` アイテムを追加
4. 画像 `assets/meme.png` を使うインベントリ画像フォルダへコピー

## 設定

すべて `config.lua` にあります。

- 音源一覧と表示名
- 権限
- 必須アイテム
- ショップ座標
- 管理者 ACE
- コピペ用の item snippet

## 権限

デフォルトでは `Config.PermissionEnabled = false` です。  
この状態では、**meme_radio アイテムを持っていれば使えます**。

権限制にしたい場合:

```lua
Config.PermissionEnabled = true
```

その上で、以下のどちらかを使ってください。

- `Config.AllowLicenses`
- `Config.AllowDiscordIds`

### 管理者

管理者削除を使う場合は ACE をおすすめします。

```cfg
add_ace group.admin 3rd_meme_radio.admin allow
```

## 管理者機能

管理者で UI を開くと、MP3 一覧にゴミ箱が表示されます。

- 削除 → 一般ユーザーには非表示
- 削除一覧 → 戻すと即時復帰
- リソース再起動不要

## ショップ

- 座標: `vector3(257.42, -1093.96, 46.91)`
- 価格: `$1000`
- 現金払い
- アイテム名: `meme_radio`

## MP3追加

1. `html/audio` に mp3 を追加
2. `config.lua` の `Config.SoundEntries` に 1行追加

```lua
{ file = 'my-sound.mp3', label = 'マイサウンド' }
```

## バージョン

- UI 表示: `v1.1.0`
- resource version: `1.1.0`
