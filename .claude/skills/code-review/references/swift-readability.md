# Swift 可読性チェックリスト

コードレビュー Step 3-2 で参照する詳細チェックリスト。

---

## 命名

### 型名
- 名詞または名詞句を使う（`UserProfile`, `CheckInResult`）
- プロトコルは「能力」→ `-able`/`-ible`（`Codable`, `Sendable`）、「何であるか」→ 名詞（`Collection`, `View`）

### 関数名
- 副作用あり → 動詞で始める（`fetchItems()`, `toggleFavorite()`）
- 副作用なし → 名詞句またはプロパティ（`distance(to:)`, `var isEmpty: Bool`）
- mutating → 命令形（`sort()`）、non-mutating → `-ed`/`-ing`（`sorted()`）
- Bool を返す → `is`/`has`/`should`/`can` プレフィックス

### 引数ラベル
- 第一引数が文の一部として自然に読めるか
- 前置詞ラベル（`at:`, `for:`, `with:`）が適切か
- 型情報と重複するラベルを避ける（`func add(_ item: Item)` ✅ / `func addItem(item: Item)` ❌）

### 変数名
- 略語を避け意図が明確（`idx` → `index`, `btn` → `button`）
- 1文字変数はクロージャの短い引数（`$0`）やループカウンタ（`i`）のみ
- Bool 変数は `is`/`has`/`should` プレフィックス

---

## 構造・複雑度

### 関数の長さと責務
- 1関数30行以下を目安
- 1関数1責務（複数段階がある場合は分割を検討）
- 早期リターン（`guard`）でハッピーパスのネストを浅く保つ

### ネスト
- 3段階以上は分割を検討
- `guard let` + 早期 `return` でネストを削減
- 複雑な条件分岐は関数に切り出して名前をつける

### View の構造（SwiftUI）
- `body` が長すぎる場合はサブビューや `@ViewBuilder` メソッドに分割
- 同ファイル内で再利用 → `@ViewBuilder` private メソッド
- 他ファイルからも利用 → 独立した `View` struct

---

## コメント

### 良いコメント
- **WHY**: なぜこの実装を選んだか
- **HACK/WORKAROUND**: OS バグやライブラリの制約への回避策
- **MARK**: セクション分割（`// MARK: - Private Methods`）

### 避けるべきコメント
- **WHAT**: コードを読めば分かること
- **変更履歴**: git log が担う
- **コメントアウトされたコード**: 削除する

---

## Swift イディオム

### Optional ハンドリング
- `guard let` で早期リターン（関数冒頭の前提条件チェック）
- `if let` はスコープ内でのみ使う場合に限定
- `!` 強制アンラップは避ける（`guard let` または `??`）
- Optional チェーン（`user?.name`）の活用

### パターンマッチング
- `switch` は全ケースを網羅（`default` は最後の手段）
- `where` 句で条件を絞る

### コレクション操作
- `for` ループより `map`/`filter`/`compactMap`/`reduce` を優先
- ただし可読性が下がるチェーンは `for` の方が良い場合もある
- `first(where:)` / `contains(where:)` の活用

### defer
- リソースのクリーンアップに活用（`isLoading = true` → `defer { isLoading = false }`）

### アクセス制御
- 公開する必要がないものは `private` / `fileprivate`
- テスト対象にする場合は `@testable import` 前提で `internal`
