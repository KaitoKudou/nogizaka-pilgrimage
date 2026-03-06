# nogizaka-pilgrimage CLAUDE.md

## プロジェクト概要

乃木坂46の聖地巡礼アプリ（iOS）。Firebaseをバックエンドに、地図・チェックイン・お気に入り機能を提供する。

## アーキテクチャ方針

### 採用するパターン

- **`@Observable` ViewModel + SwiftUI** — 状態管理の主体
- **swift-dependencies (`@Dependency`)** — 依存性注入
- **`@DependencyClient` (DependenciesMacros)** — struct ベースの Dependency 定義

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
struct SomeClient {
    var fetchItems: () async throws -> [Item]
}

extension SomeClient: DependencyKey {
    static let liveValue: Self = {
        return .init(
            fetchItems: { /* Firebase 実装 */ }
        )
    }()
}
```

### ナビゲーション

SwiftUI ネイティブの `NavigationStack` + `@State` を使用する。

### リソースアクセス

ローカライズ文字列は `Resource/LocalizedStringResource+Keys.swift` に定義した型安全キーを使う。

```swift
// SwiftUI の Text — LocalizedStringResource を直接渡す
Text(.tabbarPilgrimage)

// String が必要な場面（navigationTitle, Button, alert 等）
.navigationTitle(String(localized: .tabbarCheckIn))
Button(String(localized: .alertOk)) { }

// フォーマット引数がある場合
String(format: String(localized: .menuAppVersion), version)
```

カラー・画像は Asset Catalog シンボルを使う（`ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES`）。

```swift
// SwiftUI
Color(.tabPrimary)
Image(.placeholder)

// UIKit
UIColor(resource: .tabPrimary)
UIImage(resource: .mapPin)
```

## レイヤー構成

### ディレクトリ構造

```
Feature/          # Presentation層（View + ViewModel）
├── Initial/
│   ├── InitialView.swift
│   └── InitialViewModel.swift
├── PilgrimageList/
├── PilgrimageDetail/
├── CheckIn/
├── Favorite/
└── Menu/

Domain/           # Domain層（ビジネスエンティティ・ルール）
├── Model/
│   ├── PilgrimageInformation.swift
│   ├── AppUpdateInformation.swift
│   └── APIError.swift
├── UseCase/
│   └── CheckInUseCase.swift      # struct定義 + liveValue
└── RepositoryProtocol/            # @DependencyClient struct（インターフェース）
    ├── PilgrimageRepository.swift
    ├── CheckInRepository.swift
    ├── FavoriteRepository.swift
    └── AppConfigRepository.swift

Data/             # Data層（Repository実装・DataStore）
├── Repository/                   # extension + liveValue（Firestore実装）
│   ├── PilgrimageRepository+Live.swift
│   ├── CheckInRepository+Live.swift
│   ├── FavoriteRepository+Live.swift
│   └── AppConfigRepository+Live.swift
└── DataStore/
    ├── Remote/
    │   ├── PilgrimageRemoteDataStore.swift
    │   ├── CheckInRemoteDataStore.swift
    │   ├── FavoriteRemoteDataStore.swift
    │   └── AppConfigRemoteDataStore.swift
    └── Local/                    # ローカルキャッシュ（インメモリ → SwiftData予定）
        ├── FavoriteLocalDataStore.swift
        └── CheckInLocalDataStore.swift

Resource/         # リソース定義
├── Assets.xcassets/              # 画像リソース
├── Colors.xcassets/              # カラーリソース
├── ja.lproj/
│   └── Localizable.strings       # ローカライズ文字列
└── LocalizedStringResource+Keys.swift  # 型安全なローカライズキー定義

Utility/          # 既存のまま（LocationManager, Theme等）
```

### 依存方向

```
Feature → Domain → Data
```

上位レイヤーが下位レイヤーに依存し、逆方向の依存は発生しない。

### UseCaseの指針

- **UseCase.execute のみ**を公開する
- 複数ステップのビジネスロジックがある場合のみ UseCase を作る
- 現状は `CheckInUseCase`（位置検証 + Firestore書き込み）のみ
- 単純な読み書きは ViewModel から Repository を直接呼ぶ

### Repositoryの指針

- `Domain/RepositoryProtocol/` — `@DependencyClient` struct 定義（インターフェース）
- `Data/Repository/` — `extension + liveValue`（Firestore実装）
- 読み取りも書き込みも Repository が担う（UseCase 経由不要）

## 技術スタック

| 項目 | 内容 |
|------|------|
| 最低対応 OS | iOS 17.5 |
| UI フレームワーク | SwiftUI |
| バックエンド | Firebase (Firestore, Analytics) |
| 広告 | Google Mobile Ads |
| DI | swift-dependencies + DependenciesMacros |
| リソース管理 | Asset Catalog シンボル + `LocalizedStringResource` extension |

## パッケージ管理

Swift Package Manager を使用。TCA 廃止後は `Package.swift` に直接 `swift-dependencies` と `swift-dependency-macros` を追加する。