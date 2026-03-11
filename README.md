# 3rd Meme Radio

FiveM / QBCore 向けのミームラジオリソースです。  
`X` で手上げトグル、`R` で設定UIを開き、距離減衰付きでMP3を周囲へ再生できます。

## 主な機能

- `X` で手上げトグル
  - 手を上げた瞬間に現在選択中の MP3 を周囲へ再生
  - もう一度 `X` で手を下げる
  - 連続再生時は前の音を止めてから新しい音を再生
- 距離減衰付き 3D 風再生
- 通常再生 MP3 設定
- 死亡時 MP3 設定
- お気に入り登録
- お気に入り 0〜9 スロット
- 音量設定
  - 全体音量
  - お気に入りごとの個別音量
- 近距離 1m / 3m を含む広さ設定
- 広さ変更中はリング表示
- 保存通知
- 管理者による MP3 非表示 / 復帰
- プレイヤーごとの設定保存
- QBCore 現金購入ショップ付き
- インベントリ所持判定対応
  - qb-inventory
  - qs-inventory
  - ox_inventory
  - ls-inventoryhud

## デフォルトキー

- `X` : 手上げ / 再生
- `R` : 設定UI
- `0〜9` : お気に入りスロット切替

## 導入

1. `3rd_meme_radio` フォルダを `resources` に入れる
2. `server.cfg` に追加

```cfg
ensure 3rd_meme_radio
```

3. 必要に応じて `qb-core/shared/items.lua` などへ `meme_radio` アイテムを追加
4. 必要に応じて `assets/meme.png` を各インベントリ画像フォルダへコピー

## 設定

すべて `config.lua` にあります。

### 基本設定

- `Config.DefaultPlaySound`
  - デフォルト再生音
- `Config.DefaultDeathSound`
  - 死亡時のデフォルト音。空文字なら無音
- `Config.DefaultRangeLevel`
  - デフォルト広さレベル
- `Config.DefaultVolumeLevel`
  - デフォルト音量レベル
- `Config.PreviewVolume`
  - UI内で自分だけ再生する試聴音量
- `Config.PlayCooldownMs`
  - X連打時の再生クールダウン

### 広さ設定

- `Config.RangeLevels`
  - 1m / 3m の近距離と、ボイスレンジ倍率ベースの広さを設定
- `Config.RangePreviewColor`
  - リングマーカー色
- `Config.RangeMarkerType`
  - リングマーカー種類

### 音量設定

- `Config.VolumeLevels`
  - UIで選べる音量一覧
- ここで変更した音量は、自分だけでなく周りのプレイヤーに聞こえる大きさにも反映されます

### 権限設定

- `Config.PermissionEnabled = true`
  - 許可リスト制を有効化
- `Config.AllowLicenses`
  - FiveM license を追加
- `Config.AllowDiscordIds`
  - discord identifier を追加  
  例: `discord:123456789012345678`

> Discordロールそのものの判定は、この単体リソースだけではできません。  
> ロール情報を取得する外部Discord連携が必要です。

### アイテム制限

- `Config.UseItemRequirement`
  - `true` でアイテム所持中のみ使用可能
  - `false` でアイテム無しでも使用可能
- 現在のデフォルトは `true`
- `Config.RequiredItemName`
  - 必須アイテム名。デフォルトは `meme_radio`

## 使用制限の設定例

### 1. 誰でも `X` で使えるようにする

アイテム不要、権限不要にしたい場合は、`config.lua` を次のようにしてください。

```lua
Config.UseItemRequirement = false
Config.PermissionEnabled = false
```

この設定では、全プレイヤーが `X` でミームラジオを使えます。

### 2. アイテムを持っている人だけ使えるようにする

```lua
Config.UseItemRequirement = true
Config.RequiredItemName = 'meme_radio'
Config.PermissionEnabled = false
```

この設定では、`meme_radio` アイテムを持っている人だけが使えます。  
権限チェックは行いません。

### 3. 特定の人だけ使えるようにする

権限リストで許可した人だけ使えるようにしたい場合は、`config.lua` を次のようにしてください。

```lua
Config.PermissionEnabled = true
Config.UseItemRequirement = false

Config.AllowLicenses = {
    'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    'license:yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'
}

Config.AllowDiscordIds = {
    'discord:123456789012345678',
    'discord:987654321098765432'
}
```

この設定では、`AllowLicenses` または `AllowDiscordIds` に入っている人だけが使えます。  
アイテムは不要です。

### 4. 特定の人だけ、さらにアイテム所持時のみ使えるようにする

```lua
Config.PermissionEnabled = true
Config.UseItemRequirement = true
Config.RequiredItemName = 'meme_radio'

Config.AllowLicenses = {
    'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
}

Config.AllowDiscordIds = {
    'discord:123456789012345678'
}
```

この設定では、以下の両方を満たした時だけ使えます。

- 許可リストに入っている
- `meme_radio` アイテムを持っている

つまり、**一番厳しい制限**です。

### 5. ライセンスだけで制限したい場合

```lua
Config.PermissionEnabled = true
Config.UseItemRequirement = false

Config.AllowLicenses = {
    'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
}

Config.AllowDiscordIds = {}
```

### 6. Discord ID だけで制限したい場合

```lua
Config.PermissionEnabled = true
Config.UseItemRequirement = false

Config.AllowLicenses = {}

Config.AllowDiscordIds = {
    'discord:123456789012345678'
}
```

## FiveM license / discord id の確認方法

サーバー側でプレイヤー識別子を確認したい場合は、接続ログや識別子取得用の既存管理スクリプトで確認してください。  
このリソースでは `license:` と `discord:` identifier をそのまま `config.lua` に記載します。

例:

```text
license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
discord:123456789012345678
```

## ショップ設定

- `Config.ShopEnabled`
  - 購入ショップを有効化
- `Config.ShopPrice`
  - 価格
- `Config.ShopCoords`
  - 設置座標
- `Config.ShopPedModel`
  - PEDモデル
- `Config.ShopPedScenario`
  - PEDの待機モーション
- `Config.ShopHeading`
  - PEDの向き

### 管理者設定

- `Config.UseAdminAce = true`
  - ACE権限で管理者判定
- `Config.AdminAce = '3rd_meme_radio.admin'`

```cfg
add_ace group.admin 3rd_meme_radio.admin allow
```

または

```cfg
add_principal identifier.license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx group.admin
```

## 3rd Meme Radio 設定メモ

### MP3追加 / タイトル変更

1. `html/audio` に mp3 を入れる
2. `Config.SoundEntries` に1行追加する

```lua
{ file = 'my-sound.mp3', label = 'マイサウンド' }
```

### 権限

- `Config.PermissionEnabled = true` にすると許可リスト制になります
- `Config.AllowLicenses` に FiveM license を追加
- `Config.AllowDiscordIds` に discord ID を追加
- Discordロール判定は外部連携が必要です

### アイテム制限

- `Config.UseItemRequirement = true` なら `RequiredItemName` 所持中のみ使用可
- `Config.UseItemRequirement = false` ならアイテム無しでも使用可
- 現在のデフォルトは `true`
- アイテム名デフォルトは `meme_radio`

### 管理者削除

- 管理者で UI を開くと MP3 一覧にゴミ箱が表示されます
- 削除 → 一般ユーザーには非表示
- 削除一覧 → 戻すと即時復帰
- リソース再起動不要

## コピペ用サンプル

### QBCore item sample - qb-core/shared/items.lua

```lua
['meme_radio'] = {
    ['name'] = 'meme_radio',
    ['label'] = 'Meme Radio',
    ['weight'] = 100,
    ['type'] = 'item',
    ['image'] = 'meme.png',
    ['unique'] = true,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['description'] = 'ミームラジオを使えるアイテム'
},
```

### OX Inventory item sample - data/items.lua

```lua
['meme_radio'] = {
    label = 'Meme Radio',
    weight = 100,
    stack = false,
    close = true,
    description = 'ミームラジオを使えるアイテム',
    client = {
        image = 'meme.png'
    }
}
```

### QS Inventory sample

```text
item name: meme_radio
image file: meme.png
label: Meme Radio
description: ミームラジオを使えるアイテム
weight: 100
unique: true
```

### 画像ファイル

```text
assets/meme.png
```

## MP3追加

1. `html/audio` に mp3 を追加
2. `config.lua` の `Config.SoundEntries` に 1行追加

```lua
{ file = 'my-sound.mp3', label = 'マイサウンド' }
```

## ショップ

- 座標: `vector3(257.42, -1093.96, 46.91)`
- 価格: `$1000`
- 現金払い
- アイテム名: `meme_radio`

## バージョン

- UI 表示: `v1.2.10`
- resource version: `1.2.10`

## キー切替

- `0〜9キー`: お気に入りスロット切替

## Hotfix 1.2.10

- NUI audio playback path changed to relative file loading
- Added safer delayed playback retry for Audio.play() DOMException
