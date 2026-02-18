# nogizaka-pilgrimage CLAUDE.md

## プロジェクト概要

乃木坂46の聖地巡礼アプリ（iOS）。Firebaseをバックエンドに、地図・チェックイン・お気に入り機能を提供する。

## アーキテクチャ方針

### 採用するパターン

- **`@Observable` ViewModel + SwiftUI** — 状態管理の主体
- **swift-dependencies (`@Dependency`)** — 依存性注入
- **`@DependencyClient` (DependenciesMacros)** — struct ベースの Dependency 定義

### 廃止するもの

- **The Composable Architecture (TCA)** — `@Reducer`, `Store`, `Action`, `Effect` は全廃
  - 理由: TCA のアップデート追従コストがメンテナンスの負担になるため
  - swift-dependencies と DependenciesMacros は TCA から切り離して継続使用する

### ViewModel の書き方

```swift
@Observable
final class SomeViewModel {
    @ObservationIgnored
    @Dependency(SomeClient.self) var someClient

    var items: [Item] = []
    var isLoading = false

    func fetchItems() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await someClient.fetchItems()
        } catch {
            // エラーハンドリング
        }
    }
}
```

### Dependency の書き方

`extension DependencyValues` は書かない。`@Dependency(SomeClient.self)` 構文を使う。

```swift
@DependencyClient
struct SomeClient: DependencyKey {
    static var liveValue = Self(
        fetchItems: { /* Firebase 実装 */ }
    )

    var fetchItems: () async throws -> [Item]
}
```

### ナビゲーション

SwiftUI ネイティブの `NavigationStack` + `@State` を使用する。

## 技術スタック

| 項目 | 内容 |
|------|------|
| 最低対応 OS | iOS 17.5 |
| UI フレームワーク | SwiftUI |
| バックエンド | Firebase (Firestore, Analytics) |
| 広告 | Google Mobile Ads |
| DI | swift-dependencies + DependenciesMacros |
| リソース管理 | R.swift |

## パッケージ管理

Swift Package Manager を使用。TCA 廃止後は `Package.swift` に直接 `swift-dependencies` と `swift-dependency-macros` を追加する。

## Firebase キャッシュ方針

（TCA 剥がし完了後に決定・追記する）
