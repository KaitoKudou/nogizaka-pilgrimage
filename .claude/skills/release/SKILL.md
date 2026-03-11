---
name: release
description: >
  iOS アプリのリリース作業を自動実行するスキル。リリースブランチの作成、タグの作成・プッシュ、
  GitHub Release の作成を一括で行う。ユーザーが「リリースして」「リリース作業」「リリースブランチを切って」
  「タグを打って」「GitHub Release を作って」などリリースに関する作業を依頼したとき、
  またはバージョン番号を指定して「v1.7.0 をリリース」のように言ったときに使用する。
---

# Release Skill

バージョン番号を受け取り、リリースに必要な一連の作業を全自動で実行する。

## 引数

バージョン番号（例: `v1.7.0` または `1.7.0`）。`v` プレフィックスはあってもなくてもよい。

ユーザーがバージョン番号を指定していない場合は、実行前に確認する。

## 命名規則

バージョン `1.7.0` の場合：

| 項目 | 値 |
|------|-----|
| ブランチ名 | `release/v1.7.0.0` |
| タグ名 | `v1.7.0` |
| Milestone 名 | `1.7.0` |
| Release タイトル | `v1.7.0` |

## 実行手順

以下の手順を確認なしで一気に実行する。

### 1. main ブランチの最新化

```bash
git checkout main
git pull origin main
```

### 2. リリースブランチの作成

```bash
git checkout -b release/v{version}.0
```

### 3. タグの作成

```bash
git tag v{version}
```

### 4. リモートへプッシュ

```bash
git push -u origin release/v{version}.0
git push origin v{version}
```

### 5. Milestone の issue 一覧を取得

```bash
gh issue list --milestone "{version}" --state all --json number,title,url --jq '.[] | "- \(.title) \(.url)"'
```

### 6. GitHub Release の作成

取得した issue 一覧をリリースノートに含めて Release を作成する。

```bash
gh release create v{version} --title "v{version}" --notes "## What's Changed
- {issue title} {issue url}
- {issue title} {issue url}
..."
```

## 完了後の出力

実行完了後、以下をユーザーに報告する：

- 作成したブランチ名
- 作成したタグ名
- GitHub Release の URL
