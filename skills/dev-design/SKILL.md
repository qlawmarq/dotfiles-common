---
name: dev-design
description: >-
  Analyze development tasks and design implementation plans.
  Automatically triages task type (new feature, bug fix, refactoring, migration)
  and scale, then guides through the appropriate design phases
  (requirements, architecture, detailed design) with domain-specific guides
  (API, DB, security, performance, integration).
argument-hint: "<task description or development document>"
---

## 起動方法

`$ARGUMENTS` から開発タスクの説明またはドキュメントを受け取る。
引数が空の場合は、何を設計すべきか質問する。

## 実行フロー

```
入力受付 → 自動トリアージ → Phase別設計（対話） → ドキュメント出力
```

### Step 0: 入力受付

- `$ARGUMENTS` にタスク説明・開発ドキュメント・PRD等が渡される
- 引数なし → 何を設計すべきか質問し、回答を得てから Step 1 へ

### Step 1: 自動トリアージ

**Think harder** タスクの内容を分析し、以下の3つを判定する。

#### 1-1. タスク種別の判定

入力内容から、以下の6種別のいずれかに分類する:

| 種別 | 判定基準 |
|------|----------|
| `new-system` | 新規システム構築、大規模な新機能（複数コンポーネントにまたがる） |
| `new-feature` | 小〜中規模の機能追加（既存システムへの追加） |
| `enhancement` | 既存機能の拡張・改善（動作は変わるが構造は大きく変わらない） |
| `bug-fix` | バグ修正、障害対応、エラー修正 |
| `refactoring` | 外部動作を変えないコード構造の改善 |
| `migration` | 技術移行、フレームワーク変更、データ移行 |

#### 1-2. 複雑度スコアリング

以下の6次元を各1〜3点で評価し、合計スコア（6〜18点）を算出する:

| 次元 | 1 (Low) | 2 (Medium) | 3 (High) |
|------|---------|------------|----------|
| 変更スコープ | 単一ファイル/関数 | 複数ファイル・単一コンポーネント | 複数コンポーネント/システム |
| ドメイン新規性 | 既知のパターン | 一部未知 | 新ドメイン・前例なし |
| 技術的新規性 | 既存技術スタック | 小規模な新技術/ライブラリ | 新アーキテクチャパターン |
| 統合の複雑さ | 外部接点なし | 内部API変更 | 外部API・クロスシステム |
| リグレッションリスク | 影響範囲が限定的 | 中程度の影響 | 広範囲・クリティカルパス |
| 可逆性 | 容易に戻せる | やや困難 | データ移行・不可逆 |

#### 1-3. 設計Phaseと関連ガイドの決定

**スコアによる規模判定:**

| スコア | 規模 | 設計Phase |
|--------|------|-----------|
| 6-8 | Small | 要件確認のみ（簡易） |
| 9-13 | Medium | 要件定義 + 基本設計 |
| 14-18 | Large | 要件定義 + 基本設計 + 詳細設計 |

**タスク種別×規模の設計Phase選択:**

| タスク種別 | Small | Medium | Large |
|-----------|-------|--------|-------|
| new-system | requirements + architecture | req + arch + detailed | req + arch + detailed（全Phase） |
| new-feature | requirements（簡易） | req + architecture | req + arch + detailed |
| enhancement | requirements（差分のみ） | req + architecture（変更部分） | req + arch + detailed |
| bug-fix | `tasks/bug-fix.md` のみ | bug-fix + architecture（システム的問題時） | bug-fix + arch + detailed |
| refactoring | `tasks/refactoring.md` のみ | refactoring + architecture | refactoring + arch + detailed |
| migration | `tasks/migration.md` + req | migration + req + arch | migration + req + arch + detailed |

**専門ガイド（domains）の選択:**
タスク内容に応じて、関連する専門ガイドを推薦する:

| キーワード/コンテキスト | ガイド |
|------------------------|--------|
| API、エンドポイント、REST、GraphQL | `domains/api-design.md` |
| DB、テーブル、スキーマ、モデル | `domains/data-model.md` |
| 認証、認可、脆弱性、暗号化 | `domains/security.md` |
| 速度、レイテンシ、最適化、キャッシュ | `domains/performance.md` |
| 外部サービス、SDK、Webhook | `domains/integration.md` |

#### 1-4. トリアージ結果の提示

分析結果を以下の形式でユーザーに提示し、**合意を得てから**次のステップに進む:

```
## トリアージ結果

- **タスク種別**: [種別] - [判定理由]
- **複雑度スコア**: [合計点]/18（[規模判定]）
  - 変更スコープ: [点] - [理由]
  - ドメイン新規性: [点] - [理由]
  - 技術的新規性: [点] - [理由]
  - 統合の複雑さ: [点] - [理由]
  - リグレッションリスク: [点] - [理由]
  - 可逆性: [点] - [理由]
- **設計Phase**: [適用するPhase一覧]
- **専門ガイド**: [適用する専門ガイド一覧]
```

不明な次元がある場合はユーザーに質問して確定させる。

### Step 2: 設計の実行

トリアージで決定したPhaseを順番に実行する。
**各Phaseの開始時に対応するガイドをロードする。事前に全ガイドをロードしない。**

#### Phase 1: 要件定義（必要な場合）

`references/phases/requirements.md` をロードし、チェックリストに基づいて対話を行う。

- タスクの背景・目的・制約の明確化
- 機能要件・非機能要件の定義
- 受入条件の策定
- → ユーザーと合意してから次のPhaseへ

#### Phase 2: 基本設計（必要な場合）

`references/phases/architecture.md` + 関連する `domains/*.md` をロードする。

- アーキテクチャパターンの選定
- コンポーネント分割と責務定義
- 技術選定とトレードオフ分析
- → ユーザーと合意してから次のPhaseへ

#### Phase 3: 詳細設計（必要な場合）

`references/phases/detailed-design.md` + 関連する `domains/*.md` をロードする。

- モジュール/クラス設計
- インターフェース定義
- エラーハンドリング戦略
- → ユーザーと合意してから出力へ

#### タスク特化フロー（bug-fix / refactoring / migration）

該当する `references/tasks/*.md` をロードし、そのガイドのフローに従う。
必要に応じて `phases/*.md` や `domains/*.md` を補助的にロードする。

### Step 3: 設計ドキュメント出力

全Phaseの合意内容を統合し、実装者が必要な情報を全て含む設計ドキュメントを出力する。

## 共通ルール（全Phase・全ガイドに適用）

### 1. 事実ベースの設計（グラウンディング）

**絶対に憶測で設計しない。** 全ての設計判断は信頼できる情報源に基づくこと:

- 公式ドキュメント（`resolve-library-id` → `query-docs` で取得）
- 実際のコード（既存の実装パターン、依存関係）
- 実行ログ・エラーメッセージ
- テスト結果
- Web 検索による最新情報（ベストプラクティス、ライブラリ、アプローチ）

情報収集手段: Web 検索、`resolve-library-id` → `query-docs`、スクリプト作成による検証。
設計判断には必ず根拠を明記する（ドキュメント URL、コード参照、標準規格の引用）。

### 2. 不明点の質問義務

**分からないことがある場合、設計を進める前に必ず質問または調査する:**

- 仕様が不明確・曖昧な場合
- 複数の設計アプローチがあり優劣が判断できない場合
- 既存コードの設計意図が理解できない場合
- ドキュメントとコードに矛盾がある場合
- 非機能要件（性能、可用性、セキュリティ）の基準が不明な場合

### 3. 設計原則

1. **一貫性最優先**: 既存パターンを踏襲。新パターン導入時は明確な理由を記述
2. **YAGNI**: 現在の要件に最適な設計。将来の仮定で複雑化しない
3. **テスタビリティ**: 依存性注入とモック可能な設計
4. **トレードオフの明示**: 各選択肢の利点・欠点を定量的に評価
5. **受入条件からのテスト導出**: 各機能受入条件を満たすテストケースが明確

## ガイド一覧

### 設計Phase（phases/）

段階的に適用する設計フェーズのガイド。

| ファイル | 対象 |
|----------|------|
| `phases/requirements.md` | 要件定義・要件分析 |
| `phases/architecture.md` | アーキテクチャ設計（基本設計） |
| `phases/detailed-design.md` | 詳細設計（コンポーネント・モジュール） |

### 専門ガイド（domains/）

Phase内で必要に応じて適用する専門領域のガイド。

| ファイル | 対象 |
|----------|------|
| `domains/api-design.md` | API・インターフェース設計 |
| `domains/data-model.md` | データモデル・DB設計 |
| `domains/security.md` | セキュリティ設計 |
| `domains/performance.md` | パフォーマンス最適化 |
| `domains/integration.md` | 外部サービス統合 |

### タスク特化ガイド（tasks/）

特定のタスク種別で適用する専用フローのガイド。

| ファイル | 対象 |
|----------|------|
| `tasks/bug-fix.md` | バグ修正・障害対応 |
| `tasks/refactoring.md` | リファクタリング |
| `tasks/migration.md` | マイグレーション・移行 |
