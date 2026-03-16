# Analytics イベント設計

## 目的

インセプションデッキの成功指標「3ヶ月継続率 60%以上」を計測するための基盤。
Firebase Analytics を使用し、Layer 2リリースと同時にイベント送信を開始する。

---

## 成功指標との対応

| 指標 | 計測方法 |
|---|---|
| 3ヶ月継続率 | Firebase Analytics の Retention レポート（自動収集） |
| Layer 2の利用深度 | 以下のカスタムイベントで計測 |

Firebase Analytics はアプリ起動・セッション数を自動収集するため、継続率自体は追加実装なしで計測できる。
カスタムイベントは「Layer 2の機能がどう使われているか」を把握するために定義する。

---

## カスタムイベント一覧

### チェックイン関連

| イベント名 | 発火タイミング | パラメータ |
|---|---|---|
| `checkin_completed` | チェックイン成功時（オンライン・オフライン問わず常に発火） | `spot_id`, `song_id`, `is_first_visit_to_spot`(Bool), `is_offline`(Bool), `cumulative_count`(Int) |
| `checkin_memo_entered` | 完了モーダルでメモを入力して保存時 | `spot_id`, `memo_length`(Int) |
| `checkin_memo_skipped` | 完了モーダルでメモ未入力のまま閉じた時 | `spot_id` |

### 巡礼手帳関連

| イベント名 | 発火タイミング | パラメータ |
|---|---|---|
| `notebook_viewed` | 巡礼手帳ビューを表示した時 | `record_count`(Int), `unique_spot_count`(Int) |
| `notebook_empty_cta_tapped` | 空状態のCTA「近くの聖地を探す」をタップした時 | なし |

### 記録編集関連

| イベント名 | 発火タイミング | パラメータ |
|---|---|---|
| `visit_date_edited` | 訪問日時を編集した時 | `spot_id` |
| `memo_edited` | メモを編集した時 | `spot_id` |
| `memo_deleted` | メモを削除した時 | `spot_id` |

### 認証関連

| イベント名 | 発火タイミング | パラメータ |
|---|---|---|
| `signin_prompt_shown` | サインイン促進画面が表示された時 | `trigger`("app_launch" / "checkin") |
| `signin_prompt_dismissed` | サインイン促進画面をスキップした時 | `trigger`("app_launch" / "checkin") |
| `signin_completed` | Sign in with Apple でサインイン成功時 | `is_migration`(Bool)（UUID移行を伴うか） |
| `account_deleted` | アカウント削除が完了した時 | なし |

---

## イベント命名規則

- スネークケースを使用する（Firebase Analytics の慣例に従う）
- `<機能>_<アクション>` の形式にする
- パラメータのBool値は `is_` プレフィックスを付ける

---

## 分析で確認したいこと

| 問い | 使うイベント |
|---|---|
| Layer 2はどれぐらい使われているか | `checkin_completed` の発火数・ユニークユーザー数 |
| メモ機能は使われているか | `checkin_memo_entered` / `checkin_memo_skipped` の比率 |
| 巡礼手帳は見返されているか | `notebook_viewed` の頻度（チェックイン日以外にも見ているか） |
| 空状態からの離脱率 | `notebook_empty_cta_tapped` / `notebook_viewed`（record_count=0）の比率 |
| サインイン移行は順調か | `signin_completed` / `signin_prompt_shown` の比率 |
| オフライン巡礼はどれぐらいあるか | `checkin_completed` で `is_offline = true` の比率 |
| 再訪問はあるか | `checkin_completed` で `is_first_visit_to_spot = false` のイベント数 |
