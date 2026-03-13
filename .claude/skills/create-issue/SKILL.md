---
name: create-issue
description: >
  GitHub Issueを構造化されたフォーマットで作成するスキル。
  生成したIssueは code-review スキルの「Issue要件チェック」と連携して使われることを前提とする。
  次のような場面で必ず使うこと：
  - 「Issueを作って」「Issueを立てて」「チケットを作って」と言われたとき
  - バグ報告や機能要望をIssue化してほしいと言われたとき
  - 「#150のIssueを作って」のようにIssue番号なしで作成を依頼されたとき
  - 会話の中で「これIssueにしておこう」と言われたとき
---

# Create Issue Skill

GitHub Issueを構造化されたフォーマットで作成する。
生成したIssueは code-review スキルの「Issue要件チェック」と連携して使われることを前提とする。

---

## Step 1: 情報収集

ユーザーの入力（会話・バグ報告・Slackの文章等）から以下を把握する。
不足している情報はレビュー前に確認する（一度にまとめて聞く）。

| 項目 | 説明 | 不足時の対応 |
|------|------|-------------|
| 概要 | 何のIssueか（1〜2行） | 入力から推測して確認 |
| 背景 | なぜ必要か | 入力から推測して確認 |
| 対応内容 | 実装方針の概要 | 任意。なければ省略 |
| AC | 検証可能な完了条件 | `references/ac-guide.md` に沿って生成 |

Issue の種別はリポジトリのラベル（Step 3 で取得）から判断する。
種別ごとの書き方ポイント → `references/issue-types.md` を参照

---

## Step 2: Issueの生成

`references/issue-template.md` のテンプレートと出力の原則に従って Issue 本文を生成する。
ACの書き方 → `references/ac-guide.md` を必ず参照して生成する。

---

## Step 3: ラベルの取得と選定

Issue種別に関わらず、常にリポジトリのラベル一覧を取得して選定する。

```bash
gh label list --json name,description --limit 100
```

取得したラベル一覧から、Issueの内容に合うものを選ぶ:

- 名前・description がIssueの種別や内容と合致するものをすべて選定する
- 複数ラベルを付与してよい（例: `bug` + `high-priority`）
- 合致するラベルが見当たらない場合はラベルなしで投稿し、その旨をユーザーに伝える
- `gh label list` が失敗する場合はラベルなしで続行し、エラー内容をユーザーに伝える

---

## Step 4: プレビューと確認

以下の形式でユーザーに提示する:

- **タイトル**: Issue のタイトル
- **ラベル**: 選定したラベル（なければ「なし」）
- **本文**: Step 2 で生成した Issue 本文（コードブロックで表示）

提示後、「この内容で GitHub に Issue を作成しますか？」とユーザーに確認する。

- **ユーザーが承認した場合** → GitHub に投稿する:
  ```bash
  gh issue create \
    --title "<タイトル>" \
    --body "<生成したIssue本文>" \
    --label "<ラベル1>" \
    --label "<ラベル2>"
  ```
  ラベルが複数ある場合は `--label` を繰り返す。ラベルなしの場合は `--label` を省略する。
  投稿後は Issue URL をユーザーに提示する。
- **ユーザーが修正を求めた場合** → フィードバックを反映して再度確認する
- **ユーザーが拒否した場合** → 投稿せずに終了する

---

## 参考

- `references/issue-template.md` — Issue本文テンプレート・出力の原則
- `references/issue-types.md` — 種別ごとの書き方ガイド
- `references/ac-guide.md` — 検証可能なACの書き方
