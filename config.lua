Config = {}

Config.Version = "1.1.0"
Config.Debug = false

Config.DefaultPlaySound = 'hey-dont-shut-arc-raiders.mp3'
Config.DefaultDeathSound = ''
Config.DefaultRangeLevel = 3
Config.DefaultVolumeLevel = 4
Config.PreviewVolume = 0.7
Config.MinDistance = 0.6
Config.FallbackVoiceRange = 8.0
Config.OpenHintDurationMs = 4000
Config.PlayCooldownMs = 1200
Config.VolumeTickMs = 120

Config.HandsUpAnimDict = 'missminuteman_1ig_2'
Config.HandsUpAnimName = 'handsup_base'
Config.HandsUpAnimFlags = 49

Config.RangePreviewColor = { r = 255, g = 213, b = 74, a = 80 }
Config.RangeMarkerType = 1
Config.RangeLevels = {
    { name = '超近距離 1m', mode = 'absolute', value = 1.0 },
    { name = '近距離 3m', mode = 'absolute', value = 3.0 },
    { name = '標準', mode = 'relative', value = 2.0 },
    { name = '広い', mode = 'relative', value = 2.75 },
    { name = 'かなり広い', mode = 'relative', value = 3.5 },
    { name = '最大', mode = 'relative', value = 5.0 },
}
Config.VolumeLevels = {
    { name = 'かなり小さい', value = 0.05 },
    { name = '小さい', value = 0.15 },
    { name = 'やや小さい', value = 0.35 },
    { name = '標準', value = 0.65 },
    { name = '大きい', value = 1.00 },
}

Config.PermissionEnabled = false
Config.UseItemRequirement = true
Config.RequiredItemName = 'meme_radio'
Config.ShopEnabled = true
Config.ShopPrice = 1000
Config.ShopPedModel = 's_m_y_ammucity_01'
Config.ShopPedScenario = 'WORLD_HUMAN_CLIPBOARD'
Config.ShopCoords = vector3(257.42, -1093.96, 46.91)
Config.ShopHeading = 180.0
Config.ShopInteractDistance = 2.0
Config.ShopBlipEnabled = false

Config.AllowLicenses = {
    -- 'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
}
Config.AllowDiscordIds = {
    -- 'discord:123456789012345678'
}
Config.UseAdminAce = true
Config.AdminAce = '3rd_meme_radio.admin'

Config.LegacySoundMap = {
    ['hey-dont-shut-arc-raiders .mp3'] = 'hey-dont-shut-arc-raiders.mp3',
    ['dont-shoot-arc-raiders特別.mp3'] = 'dont-shoot-arc-raiders-special.mp3'
}

Config.SoundEntries = {
    { file = "31_1.mp3", label = "31 その1" },
    { file = "3-2-1-go-green-screen-footage-2xoehcl8evq.mp3", label = "3・2・1・GO！" },
    { file = "acziyapanhakonohuo-dong-wozhi-yuan-shiteimasu.mp3", label = "ACジャパンはこの活動を支援しています" },
    { file = "discord-call-sound.mp3", label = "Discord 通話音" },
    { file = "edf4-mission-complete.mp3", label = "EDF4 ミッションクリア" },
    { file = "edf5-mission-complete.mp3", label = "EDF5 ミッションクリア" },
    { file = "gta-san-andreas-mission-complete-sound-hq.mp3", label = "GTA SA ミッションクリア" },
    { file = "gta-v-death-sound-effect-102.mp3", label = "GTA V 死亡音" },
    { file = "get-out.mp3", label = "Get Out" },
    { file = "hikakin-eele-shiinaaaa.mp3", label = "HIKAKIN えぇ、楽しいなぁぁぁ！" },
    { file = "hikakin-butsukui-su.mp3", label = "HIKAKIN ぶつ食いっす" },
    { file = "hikakinsu-cai-zhu-ketezhu-ketekuree.mp3", label = "HIKAKIN 助けて助けてくれ" },
    { file = "img_3728.mp3", label = "IMG 3728" },
    { file = "ny-video-online-audio-converter.mp3", label = "NY 音源" },
    { file = "paypay.mp3", label = "PayPay" },
    { file = "roblox-ooooof.mp3", label = "Roblox OOF" },
    { file = "skyrim-level-up.mp3", label = "Skyrim レベルアップ" },
    { file = "valorant-chamber-ult-jp.mp3", label = "VALORANT Chamber ULT" },
    { file = "what-bottom-text-meme-sanctuary-guardian-sound-effect-hd.mp3", label = "WHAT ボトムテキスト" },
    { file = "wtf-sound.mp3", label = "WTF" },
    { file = "expedientes-secretos-x-musica22.mp3", label = "Xファイル風BGM" },
    { file = "mariogemuoba.mp3", label = "mariogemuoba" },
    { file = "aa-gomikasu-tahine_imxtnpi.mp3", label = "ああ！ゴミカスー！タヒねー！" },
    { file = "ara-ara.mp3", label = "あらあら" },
    { file = "terimakasih-abangkuh-indonesia-man.mp3", label = "ありがとう兄貴" },
    { file = "opm-be-a-good-boy.mp3", label = "いい子にしろ" },
    { file = "ikuzo_e04ykqv.mp3", label = "いくぞ！" },
    { file = "u0ko.mp3", label = "うおこ" },
    { file = "uwaaaaaaaaa.mp3", label = "うわあああああ" },
    { file = "uwatsu-qian-karache-ga.mp3", label = "うわっ前から車が" },
    { file = "e-kuruyo-sore.mp3", label = "え、来るよそれ" },
    { file = "e-le-shiinaaaaaaaaaaa_npp6qml.mp3", label = "えーらしいなぁぁぁぁ" },
    { file = "okawariitadaketadarouka.mp3", label = "おかわりいただけただろうか" },
    { file = "oqian-hakoredesi-ne.mp3", label = "お前はこれで死ね" },
    { file = "shen-hayan-tsuteiru-kokodesi-nuding-medehanaito.mp3", label = "ここで死ぬ運命ではない" },
    { file = "konoxing-woxiao-su_8yxjmfo.mp3", label = "この星を消す" },
    { file = "sonnazhuang-bei-deda-zhang-fu-ka.mp3", label = "そんな装備で大丈夫か" },
    { file = "chiyotsuto-daijini-shitekudasai.mp3", label = "ちょっと大事にしてください" },
    { file = "naaniyatsutendaoqian-eeeee.mp3", label = "なぁにやってんだお前ぇぇぇぇぇ！" },
    { file = "nankaqi-mazukunai.mp3", label = "なんか気まずくない？" },
    { file = "nandayo-moooo-matakayoooo.mp3", label = "なんだよもぉぉ またかよぉ" },
    { file = "haishikoro.mp3", label = "はいしころ" },
    { file = "ha-ka-ta-no-yan-bo-fang-noyan.mp3", label = "は・か・た・の・塩" },
    { file = "hidoinaa.mp3", label = "ひどいなぁ" },
    { file = "hiroyukigou-wen-x1-3.mp3", label = "ひろゆき 拷問 x1.3" },
    { file = "huzakerunomoda-gai-nisayyo.mp3", label = "ふざけるのも大概にせぇよ" },
    { file = "butsukui-su.mp3", label = "ぶつ食いっす" },
    { file = "hee_svvwkix.mp3", label = "へぇ" },
    { file = "maesukenew.mp3", label = "まえすけ" },
    { file = "huamimada-hao-ki.mp3", label = "まだ早期" },
    { file = "misae_od6owrq.mp3", label = "みさえ" },
    { file = "moshimoshi-donaldodesu.mp3", label = "もしもしドナルドです" },
    { file = "yatsutaze.mp3", label = "やったぜ" },
    { file = "yarimasune.mp3", label = "やりますね" },
    { file = "i-eeeeeaaaaa-xiao-guo-yin.mp3", label = "イエーーーーイ 効果音" },
    { file = "ion-waon.mp3", label = "イオン WAON" },
    { file = "ikagemu2-zhi-mareeeeeee.mp3", label = "イカゲーム 止まれぇぇぇ" },
    { file = "wewe.mp3", label = "ウェウェ" },
    { file = "umagon-chinchin.mp3", label = "ウマゴン ちんちん" },
    { file = "erro.mp3", label = "エラー" },
    { file = "endaiya.mp3", label = "エンダァ" },
    { file = "meme-de-creditos-finales.mp3", label = "エンディングクレジット ミーム" },
    { file = "ororontiyotiyoha-a-duan.mp3", label = "オロロンちょちょはぁ" },
    { file = "gaigai-ondo.mp3", label = "ガイガイ音頭" },
    { file = "kuizuchu-ti.mp3", label = "クイズ出題" },
    { file = "gukii-xiao-guo-yin.mp3", label = "グキッ 効果音" },
    { file = "ketsuno-ana-ga-uwaitsu.mp3", label = "ケツの穴がウワイッ" },
    { file = "konan-hiramekiyin.mp3", label = "コナン ひらめき音" },
    { file = "gorori-nanikore.mp3", label = "ゴロリ なにこれ？" },
    { file = "jagura-button.mp3", label = "ジャグラーボタン" },
    { file = "jurassic-park.mp3", label = "ジュラシック・パーク" },
    { file = "skairim.mp3", label = "スカイリム" },
    { file = "spongebob-2000-years-later-2019-download-link.mp3", label = "スポンジ・ボブ 2000年後" },
    { file = "a-few-moments-later-sponge-bob-sfx-fun.mp3", label = "スポンジ・ボブ 数分後" },
    { file = "cirno.mp3", label = "チルノ" },
    { file = "chin-xiao-guo-yin_s5phjia.mp3", label = "チーン 効果音" },
    { file = "technoloyia-technologia-tecnologia.mp3", label = "テクノロジア" },
    { file = "teretsutere.mp3", label = "テレッテレー" },
    { file = "deja-vu-fade.mp3", label = "デジャヴ" },
    { file = "l-theme-a-death-note.mp3", label = "デスノート Lのテーマ" },
    { file = "shimasu-tomuburaun.mp3", label = "トム・ブラウン します" },
    { file = "doagabi-marimasu.mp3", label = "ドアが閉まります" },
    { file = "doraemon1.mp3", label = "ドラえもん" },
    { file = "donki-hote.mp3", label = "ドン・キホーテ" },
    { file = "hatsupisetsuto.mp3", label = "ハッピーセット" },
    { file = "panpanpanpanpanpan-panpan_kasekmb.mp3", label = "パンパンパンパンパンパン" },
    { file = "hu-biip-mijun.mp3", label = "ビープ未準" },
    { file = "bun_aluw5lp.mp3", label = "ブン" },
    { file = "hey-dont-shut-arc-raiders.mp3", label = "ヘイ、閉めるな（ARC RAIDERS）" },
    { file = "bezita-moudameda-oshimaidaa.mp3", label = "ベジータ もうだめだぁ おしまいだぁ" },
    { file = "pokemon-hui-fu-yin.mp3", label = "ポケモン 回復音" },
    { file = "maikerugei.mp3", label = "マイケル・ゲイ" },
    { file = "makudonarudodonarudo-ranranru_pthoidf.mp3", label = "マクドナルド ランランルー" },
    { file = "mama-mamamamaa_r2z6zzi.mp3", label = "ママ ママママァ" },
    { file = "mario-1up.mp3", label = "マリオ 1UP" },
    { file = "musuka-3fen.mp3", label = "ムスカ 3分間待ってやる" },
    { file = "musuka-ojing-kani.mp3", label = "ムスカ お静かに" },
    { file = "musuka-du-meruzo.mp3", label = "ムスカ どぅめるぞ" },
    { file = "musuka-dokohexing-ku.mp3", label = "ムスカ どこへ行く" },
    { file = "musuka-gui-gotsuko.mp3", label = "ムスカ グイグッと来い" },
    { file = "musuka-rapiyutawang-noqian.mp3", label = "ムスカ ラピュタは滅びぬ" },
    { file = "musuka-ren-gomi.mp3", label = "ムスカ 人がゴミのようだ" },
    { file = "musuka-he-wosuru.mp3", label = "ムスカ 何をする" },
    { file = "musuka-sheng-fu.mp3", label = "ムスカ 勝負" },
    { file = "musuka-ming-qi-i.mp3", label = "ムスカ 名器ぃ" },
    { file = "musuka-shao-kifu-tsuteyaru.mp3", label = "ムスカ 少し気をつけてやる" },
    { file = "musuka-shi-jian-da.mp3", label = "ムスカ 時間だ" },
    { file = "musuka-nu-rasenaihougaliang-izo-1.mp3", label = "ムスカ 濡らせない方が良いぞ 2" },
    { file = "metal-gear-alert-sound-effect_xkohrez.mp3", label = "メタルギア 警戒音" },
    { file = "moskau.mp3", label = "モスカウ" },
    { file = "unicoooorn_1.mp3", label = "ユニコーン" },
    { file = "yunikon-banshiixiong-jiao-bi.mp3", label = "ユニコーン バンシィ 咆哮" },
    { file = "la-grande-combinacion.mp3", label = "ラ・グランデ・コンビナシオン" },
    { file = "rubiichiyan.mp3", label = "ルビーちゃん" },
    { file = "dry-fart.mp3", label = "乾いたおなら音" },
    { file = "ren-noxin-tokanainka_jvptsaf.mp3", label = "人の心とかないんか？" },
    { file = "zhen-etemian-reya.mp3", label = "全員てめぇら" },
    { file = "y2mate-mp3cut_srzy6rh.mp3", label = "切り抜き音源" },
    { file = "xiao-guo-yin.mp3", label = "効果音" },
    { file = "heng-yao-re.mp3", label = "変や俺" },
    { file = "japanese-school-bell-clear-full.mp3", label = "学校のチャイム" },
    { file = "perfect-fart.mp3", label = "完璧なおなら" },
    { file = "shaolin-zhiyao.mp3", label = "少林寺" },
    { file = "kibodokuratsushiya.mp3", label = "希望ドクラッシュや" },
    { file = "ben-dang-nisuimasendeshita_sn2ttze.mp3", label = "弁当にすいませんでした" },
    { file = "10_scream-1.mp3", label = "悲鳴 1" },
    { file = "dont-shoot-arc-raiders-special.mp3", label = "撃つな、ARC RAIDERS" },
    { file = "4ne.mp3", label = "死ね" },
    { file = "si-ndanziyanaino_vawnx9p.mp3", label = "死んだんじゃないの" },
    { file = "shi-bu_pe6vqix.mp3", label = "死亡" },
    { file = "suiko-koumon-inrou.mp3", label = "水戸黄門 印籠" },
    { file = "ryusei-no-kyoku.mp3", label = "流星の曲" },
    { file = "kiyo-an-ii-wei-ziyanai.mp3", label = "清安いい味じゃない" },
    { file = "wu-xian-cheng.mp3", label = "無限城" },
    { file = "mu-tomu-gahe-ushun-jian.mp3", label = "無音が減る瞬間" },
    { file = "muda_muda_muda_sound_effect.mp3", label = "無駄無駄無駄" },
    { file = "huh-cat-meme.mp3", label = "猫の は？ ミーム" },
    { file = "shi-li-dana-chun-ai-dayo.mp3", label = "知りだな 純愛だよ" },
    { file = "tu-ji-iiiiiii.mp3", label = "突撃イイイイイ！" },
    { file = "laughing-dog-meme.mp3", label = "笑う犬 ミーム" },
    { file = "iku-there.mp3", label = "行くぜ" },
    { file = "akiramennayo-song-gang-xiu-zao.mp3", label = "諦めんなよ" },
    { file = "run-vine-sound-effect.mp3", label = "走るVine 効果音" },
    { file = "tao-zou-zhong-jian-tsukatsutaa.mp3", label = "逃走中 見つかったぁ" },
    { file = "you-xi-wang.mp3", label = "遊戯王" },
    { file = "you-xi-wang-naanikoree-biao-you-xi.mp3", label = "遊戯王 なにこれぇ" },
    { file = "hu-zhang-you-ren-hapu-gasha-shimasu.mp3", label = "部長より発表します" },
    { file = "dont-shut-arc-raiders1.mp3", label = "閉めるな（ARC RAIDERS）1" },
    { file = "dont-shut-arc-raiders2.mp3", label = "閉めるな（ARC RAIDERS）2" },
    { file = "kai-shi-dana.mp3", label = "開示だな" },
    { file = "dian-hua-ling-sheng.mp3", label = "電話の着信音" },
    { file = "ling-meng-konnichiha.mp3", label = "霊夢 こんにちは" },
    { file = "initial-d.mp3", label = "頭文字D" }
}

function Config.NormalizeSoundName(name)
    if type(name) ~= 'string' then
        return name
    end
    return Config.LegacySoundMap[name] or name
end

function Config.GetRangeLevel(level)
    level = tonumber(level) or Config.DefaultRangeLevel
    if level < 1 then level = 1 end
    if level > #Config.RangeLevels then level = #Config.RangeLevels end
    return level
end

function Config.GetVolumeLevel(level)
    level = tonumber(level) or Config.DefaultVolumeLevel
    if level < 1 then level = 1 end
    if level > #Config.VolumeLevels then level = #Config.VolumeLevels end
    return level
end

function Config.GetRangeConfig(level)
    return Config.RangeLevels[Config.GetRangeLevel(level)]
end

function Config.GetRangeName(level)
    return Config.GetRangeConfig(level).name
end

function Config.GetBaseVolume(level)
    return Config.VolumeLevels[Config.GetVolumeLevel(level)].value
end

function Config.GetVolumeName(level)
    return Config.VolumeLevels[Config.GetVolumeLevel(level)].name
end

function Config.IsValidSound(name)
    if type(name) ~= 'string' or name == '' then
        return false
    end
    name = Config.NormalizeSoundName(name)
    for _, entry in ipairs(Config.SoundEntries) do
        if entry.file == name then
            return true
        end
    end
    return false
end

function Config.GetSoundLabel(name)
    if type(name) ~= 'string' or name == '' then
        return '未選択'
    end
    name = Config.NormalizeSoundName(name)
    for _, entry in ipairs(Config.SoundEntries) do
        if entry.file == name then
            return entry.label or entry.file
        end
    end
    return name
end

function Config.GetSoundCatalog(hiddenMap)
    local out = {}
    hiddenMap = hiddenMap or {}
    for _, entry in ipairs(Config.SoundEntries) do
        if not hiddenMap[entry.file] then
            out[#out + 1] = {
                file = entry.file,
                label = entry.label or entry.file
            }
        end
    end
    return out
end

function Config.GetDeletedCatalog(hiddenMap)
    local out = {}
    hiddenMap = hiddenMap or {}
    for _, entry in ipairs(Config.SoundEntries) do
        if hiddenMap[entry.file] then
            out[#out + 1] = {
                file = entry.file,
                label = entry.label or entry.file
            }
        end
    end
    return out
end

--[[
========================================
3rd Meme Radio 設定メモ
========================================

■ MP3追加 / タイトル変更
1. html/audio に mp3 を入れる
2. Config.SoundEntries に 1行追加する

例:
{ file = 'my-sound.mp3', label = 'マイサウンド' }

■ 権限
- Config.PermissionEnabled = true にすると許可リスト制になります
- Config.AllowLicenses に FiveM license を追加
- Config.AllowDiscordIds に discord ID を追加
  例: 'discord:123456789012345678'
- Discordロールそのものの判定は、この単体リソースだけではできません
  （ロール情報を取得する外部Discord連携が必要です）

■ アイテム制限
- Config.UseItemRequirement = true なら RequiredItemName を所持中のみ使用可
- デフォルト: meme_radio

■ 管理者削除
- Config.UseAdminAce = true なら ACE 権限で管理者判定
- add_ace group.admin 3rd_meme_radio.admin allow
  もしくは
- add_principal identifier.license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx group.admin

========================================
コピペ用サンプル（環境で微調整してください）
========================================

[QBCore item sample - qb-core/shared/items.lua]
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

[OX Inventory item sample - data/items.lua]
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

[QS Inventory sample]
item name: meme_radio
image file: meme.png
label: Meme Radio
description: ミームラジオを使えるアイテム
weight: 100
unique: true

画像ファイル:
assets/meme.png
========================================
]]
