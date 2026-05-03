---
description: book.json または audio_prompts.json を修正した後、もう一方のファイルを同期し、変更した言語のテキストを他言語にも翻訳反映し、対応する audios/ 内の音声ファイルを削除する。
---

`book.json` または `audio_prompts.json` を Edit または Write で修正した直後に、確認なしで以下を自動実行すること。

---

## ファイル間の対応関係

```
book.json                          audio_prompts.json
pages[].texts[].audio: "pageX_textY"  entries[].audio: "pageX_textY_ja" (lang: "ja")
pages[].texts[].ja: "日本語テキスト"  entries[].text: "日本語テキスト"
pages[].texts[].en: "English text"    entries[].audio: "pageX_textY_en" (lang: "en")
                                       entries[].text: "English text"
```

---

## book.json を修正した場合

1. **他言語テキストを翻訳して補完する**
   - `ja` のみ変更した場合 → 新しい `ja` テキストを英訳して `en` フィールドも更新する
   - `en` のみ変更した場合 → 新しい `en` テキストを和訳して `ja` フィールドも更新する
   - `ja` と `en` 両方変更した場合 → そのまま使用する（翻訳不要）

2. **audio_prompts.json を同期する**
   - 変更した `texts[]` エントリの `audio` 値（例: `page2_text1`）を特定する
   - `audio_prompts.json` の `entries[]` から `audio: "page2_text1_ja"` と `audio: "page2_text1_en"` のエントリを探す
   - 更新後の `ja` テキストを `lang: "ja"` エントリの `text` に反映する
   - 更新後の `en` テキストを `lang: "en"` エントリの `text` に反映する

3. **音声ファイルを削除する**
   ```bash
   rm -f "<dir>/audios/page2_text1_ja.wav"
   rm -f "<dir>/audios/page2_text1_en.wav"
   ```

---

## audio_prompts.json を修正した場合

1. **他言語エントリを翻訳して補完する**
   - `lang: "ja"` のエントリを変更した場合 → 新しい `text` を英訳して、同じベースキーの `lang: "en"` エントリの `text` も更新する
   - `lang: "en"` のエントリを変更した場合 → 新しい `text` を和訳して、同じベースキーの `lang: "ja"` エントリの `text` も更新する

2. **book.json を同期する**
   - `audio` のサフィックス（`_ja` / `_en`）を除いたベースキー（例: `page2_text1`）を求める
   - `book.json` の `pages[].texts[]` から `audio: "page2_text1"` のエントリを探す
   - 更新後の `ja` テキストを `ja` フィールドに、`en` テキストを `en` フィールドに反映する

3. **音声ファイルを削除する**
   ```bash
   rm -f "<dir>/audios/page2_text1_ja.wav"
   rm -f "<dir>/audios/page2_text1_en.wav"
   ```

---

## 完了報告

- 同期したフィールドと削除したファイルの一覧を1〜2行で報告する
- 対象ファイルが存在しなかった場合もその旨を報告する
