---
name: create-pr
description: >
  GitHub の PR 作成フローを自動実行するスキル。ブランチ作成・プッシュ・PR 作成を一括で行う。
  ユーザーが「PRを作って」「PRを出して」「プルリクエストを作成して」と依頼したとき、
  または issue 番号を指定して「#150のPRを出して」のように言ったときに使用する。
  コミット後に「PRに進めますか？」と聞かれて承認した場合にも使用する。
---

# Create PR Skill

issue 番号を元に、PR 作成に必要な一連の作業を自動実行する。

## 引数

issue 番号（例: `#150` または `150`）。`#` プレフィックスはあってもなくてもよい。

issue 番号が指定されていない場合は、現在のブランチ名（`feature/{番号}`）から推測する。
それでも特定できない場合はユーザーに確認する。

## ブランチ命名規則

issue 番号 `150` の場合：

| 項目 | 値 |
|------|-----|
| ブランチ名 | `feature/150` |
| ベースブランチ | `main` |

## 実行手順

### 1. ブランチの準備

現在のブランチが `feature/{issue番号}` でない場合、main の最新から作成する。

```bash
git checkout main
git pull origin main
git checkout -b feature/{issue番号}
```

既に `feature/{issue番号}` ブランチにいる場合はこのステップをスキップする。

### 2. 変更の確認

`git status` と `git diff` で変更内容を確認する。
未コミットの変更がある場合は、適切なメッセージでコミットする。

### 3. リモートへプッシュ

```bash
git push -u origin feature/{issue番号}
```

### 4. issue 情報の取得

```bash
gh issue view {issue番号} --json title,body
```

### 5. PR の作成

issue のタイトルを参考に PR を作成する。本文は以下のフォーマットに従う。

```bash
gh pr create --title "{PRタイトル}" --body "## Summary
- {変更内容の要約を箇条書き}

## Test plan
- [ ] {テスト項目}

close #{issue番号}

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

### フォーマットのポイント

- **タイトル**: issue のタイトルに準拠。70文字以内に収める
- **Summary**: 変更内容を1〜3行の箇条書きで簡潔に
- **Test plan**: 動作確認のチェックリスト
- **close #{issue番号}**: マージ時に issue を自動クローズするためのリンク

## 完了後の出力

実行完了後、PR の URL をユーザーに報告する。
