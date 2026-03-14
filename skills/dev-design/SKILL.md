---
name: dev-design
description: >-
  Design comprehensive implementation plans for software development tasks.
  Use this skill for any design phase: requirements analysis, architecture
  design, detailed component design, API design, data model design, bug fix
  planning, refactoring strategy, migration planning, performance optimization,
  security hardening, and third-party integration design. Invoke with
  perspective keywords to focus on specific design aspects.
argument-hint: "[perspectives: requirements|architecture|detailed-design|api-design|data-model|bug-fix|refactoring|migration|performance|security|integration|all]"
---

## 起動方法

ユーザーからタスクの説明を受け取る。
タスクの説明がまだ提供されていない場合は、何を設計すべきか質問する。

**Think harder** 設計への影響を深く考慮し、要件の背景と目的を理解するため対話を行う:

- どのような問題を解決したいか
- 期待される成果と成功基準
- 既存システムとの関係性

長期的な保守性と拡張性を考慮し、技術的な選択肢を洗い出し、評価し、最適なアプローチを提案する。
最終的な詳細設計の作成においては、全てのコンテキスト情報を作業者に伝えることが最も重要。

## 観点選択ロジック

`$ARGUMENTS` から設計観点を解析する:

- キーワードが含まれる場合 → 対応するガイドをロード
- `all` が指定された場合 → 全ガイドをロード
- 引数なし → タスク内容から適切な観点を判断し、ユーザーに提案してから進行

**重要: 選択された観点のガイドのみ読み込むこと。不要なガイドはロードしない。**

| キーワード | ガイドファイル | 対象 |
|---|---|---|
| `requirements` | references/requirements.md | 要件定義・要件分析 |
| `architecture` | references/architecture.md | アーキテクチャ設計（基本設計） |
| `detailed-design` | references/detailed-design.md | 詳細設計（コンポーネント・モジュール） |
| `api-design` | references/api-design.md | API・インターフェース設計 |
| `data-model` | references/data-model.md | データモデル・DB設計 |
| `bug-fix` | references/bug-fix.md | バグ修正・エラー修正設計 |
| `refactoring` | references/refactoring.md | リファクタリング設計 |
| `migration` | references/migration.md | マイグレーション・移行設計 |
| `performance` | references/performance.md | パフォーマンス最適化設計 |
| `security` | references/security.md | セキュリティ設計 |
| `integration` | references/integration.md | 外部サービス統合設計 |

複数の観点を同時に指定可能（例: `requirements architecture api-design`）。

## 主な責務

1. タスクの背景理解と要件の明確化
2. 技術的選択肢の洗い出しと評価
3. **機能受入条件の定義と検証可能性の確保**
4. トレードオフ分析と既存アーキテクチャとの整合性確認
5. **最新技術情報の調査と出典の明記**
6. 実装者に全コンテキストを伝える詳細設計ドキュメントの作成

## 共通ルール（全観点に適用）

**以下のルールは絶対に遵守すること:**

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

## 設計手順

1. **タスク理解**: タスクの背景・目的・制約を把握する
2. **コンテキスト収集**: 既存コード・アーキテクチャ・関連ライブラリの公式情報を調査
3. **ガイドロード**: 選択された観点の `references/*.md` を読み込む
4. **設計実行**: ガイドのチェックリストに基づき設計案を作成。複数案を検討
5. **対話・合意**: ユーザーと対話し最適案を確定
6. **ドキュメント出力**: 確定した設計を標準フォーマットで出力
