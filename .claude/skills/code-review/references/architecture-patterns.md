# アーキテクチャレビュー観点

コードレビュー Step 3-3 で参照するプロジェクト固有のチェックリスト。

---

## レイヤー構成と依存方向

```
Feature（View + ViewModel） → Domain（Model + UseCase + RepositoryProtocol） → Data（Repository実装 + DataStore）
```

- 上位レイヤーが下位に依存し、逆方向の依存がないか
- `Feature/` 内のファイルが `Data/` を直接 import していないか
- `Domain/` が `Feature/` や `Data/` に依存していないか

---

## ViewModel パターン

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

- `@Observable` が付与されているか
- `@Dependency` プロパティに `@ObservationIgnored` が付いているか
- View にビジネスロジックが漏れていないか（View は ViewModel のメソッドを呼ぶだけ）
- `isLoading` の管理に `defer` を使っているか

---

## Dependency パターン

### インターフェース定義（`Domain/RepositoryProtocol/`）

```swift
@DependencyClient
struct SomeClient {
    var fetchItems: () async throws -> [Item]
}
```

- `@DependencyClient` struct で定義されているか
- `extension DependencyValues` は**使わない**（`@Dependency(SomeClient.self)` 構文を使う）

### 実装（`Data/Repository/`）

```swift
extension SomeClient: DependencyKey {
    static let liveValue: Self = {
        return .init(
            fetchItems: { /* Firebase 実装 */ }
        )
    }()
}
```

- `DependencyKey` の `liveValue` で実装を提供しているか
- 具体的な外部依存（Firestore 等）が `Data/` レイヤーに閉じているか

---

## UseCase の指針

- UseCase は `execute` メソッドのみを公開する
- **複数ステップのビジネスロジック**がある場合のみ UseCase を作る
- 単純な読み書きは ViewModel → Repository を直接呼ぶ（UseCase 不要）

---

## リソースアクセス

### ローカライズ文字列

```swift
// SwiftUI の Text — LocalizedStringResource を直接渡す
Text(.tabbarPilgrimage)

// String が必要な場面
.navigationTitle(String(localized: .tabbarCheckIn))
Button(String(localized: .alertOk)) { }

// フォーマット引数がある場合
String(format: String(localized: .menuAppVersion), version)
```

- `LocalizedStringResource+Keys.swift` の型安全キーを使っているか
- 生文字列（`"ログイン"`）が直書きされていないか

### カラー・画像

```swift
// SwiftUI
Color(.tabPrimary)
Image(.placeholder)

// UIKit
UIColor(resource: .tabPrimary)
UIImage(resource: .mapPin)
```

- Asset Catalog シンボルを使っているか
- 文字列指定（`UIImage(named: "mapPin")`）になっていないか

---

## Swift Concurrency / スレッド安全性

- `@MainActor` が UI 更新を行う ViewModel や関数に付与されているか
- `async/await` と `DispatchQueue` が混在していないか
- `Task { @MainActor in }` による main スレッドへのディスパッチが適切か
- `Sendable` 準拠が必要な型で準拠しているか

---

## ナビゲーション

- `NavigationStack` + `@State` を使用しているか
- `NavigationStack` が二重ネストになっていないか（各タブのルートに1つだけ）
- `NavigationLink(destination:)` で遷移先を指定しているか

---

## その他

### 重複・抽象化
- 同じロジックが複数箇所に重複していないか
- 共通化できる処理が関数・型として切り出されているか

### ハードコード
- マジックナンバー・マジック文字列が直書きされていないか
- 定数は `enum` や `static let` で名前付き定数として定義されているか

### iOS 固有
- `[weak self]` が必要な箇所（escaping closure, delegate）で使われているか
- バックグラウンドスレッドで UI 操作をしていないか
