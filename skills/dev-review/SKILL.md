---
name: dev-review
description: >-
  Review and verify software development artifacts including design documents,
  implementation code, and pull requests. Supports multiple review perspectives:
  design, implementation, security, performance, testing, accessibility,
  architecture, and best-practices. Use this skill when you need to perform
  code review, design review, security audit, or any development quality check.
  Trigger examples: "review this code", "check security", "review the design",
  "review my PR", "architecture review".
argument-hint: "[perspectives: design|implementation|security|performance|testing|accessibility|architecture|best-practices|all]"
---

## 起動方法

ユーザーからレビュー対象の説明を受け取ってください。
レビュー対象がまだ提供されていない場合は、何をレビューすべきか質問してください。

`git` コマンドを使用して変更箇所を特定できます（`git diff`, `git log` など）。

## レビュー観点の選択

引数 `$ARGUMENTS` からレビュー観点を解析してください。

**利用可能な観点:**

| 観点 | キーワード | ガイド |
|------|-----------|--------|
| 設計 | `design` | [references/design.md](references/design.md) |
| 実装 | `implementation` | [references/implementation.md](references/implementation.md) |
| セキュリティ | `security` | [references/security.md](references/security.md) |
| パフォーマンス | `performance` | [references/performance.md](references/performance.md) |
| テスト | `testing` | [references/testing.md](references/testing.md) |
| アクセシビリティ | `accessibility` | [references/accessibility.md](references/accessibility.md) |
| アーキテクチャ整合性 | `architecture` | [references/architecture.md](references/architecture.md) |
| ベストプラクティス準拠 | `best-practices` | [references/best-practices.md](references/best-practices.md) |

**選択ルール:**

- 引数にキーワードが含まれる場合、該当する観点のガイドを読み込む
- `all` が指定された場合、全観点のガイドを読み込む
- 引数なしの場合、レビュー対象の性質から適切な観点を判断し、ユーザーに提案してから進める
- 複数観点の指定可（例: `design security`）

**選択された観点のガイドのみを `references/` から読み込むこと。** 不要な観点のガイドは読み込まない。

## 作業ルール

**以下のルールは全観点で絶対に遵守してください:**

### 1. 事実ベースのレビュー（グラウンディング）

- **絶対に憶測でレビューしないこと**
- 全ての指摘は以下の信頼できる情報源に基づくこと:
  - 公式ドキュメント（言語仕様、フレームワーク公式サイト）
  - 実際のコード（推測ではなく、実際にファイルを読んで確認）
  - 実行ログ・エラーメッセージ
  - テスト結果
  - 業界標準の規格・ガイドライン（OWASP, W3C, RFC 等）
- 情報収集手段:
  - Web 検索で最新の公式ドキュメントを取得
  - `resolve-library-id` → `query-docs` で依存ライブラリの公式ドキュメントを参照
  - 実際のコードを読んで既存パターンを確認
- **指摘には必ず根拠を添えること**（公式ドキュメントの URL、コード内の該当箇所、規格の条項番号など）

### 2. 不明点の質問義務

- **分からないことがある場合、レビューを進める前に必ず質問か調査をすること**
- 質問すべき状況:
  - 仕様や要件が不明確な場合
  - 既存コードの意図が理解できない場合
  - ドキュメントとコードに矛盾がある場合
  - プロジェクト固有の設計判断の背景が分からない場合

### 3. 建設的なレビュー

- 問題の指摘だけでなく、必ず具体的な改善案を提示すること
- 改善案はコード例を含めて具体的に示すこと
- 既存の設計判断を尊重しつつ、改善点を提案すること
- Google のレビュー基準: 「コード全体の健全性を向上させる変更であれば、完璧でなくとも承認すべき」

## レビュー手順

1. **対象の把握**: レビュー対象のコード・設計を実際に読み、全体像を理解する
2. **コンテキスト収集**: 関連ファイル、依存関係、既存パターンを調査する
3. **ガイド読み込み**: 選択された観点のガイドを `references/` から読み込む
4. **観点別レビュー実施**: 各ガイドのチェックリストに基づきレビューする
5. **結果の統合出力**: 共通フォーマットで結果を出力する

## 出力フォーマット

```markdown
# レビュー結果

**対象**: [レビュー対象の説明]
**レビュー観点**: [選択された観点リスト]

---

## [観点名] レビュー

### 総合評価: [良好 / 改善推奨 / 要修正]

### 指摘事項

#### [重大度: Critical / Warning / Info] [指摘タイトル]
- **箇所**: `file:line`
- **指摘**: [具体的な問題の説明]
- **根拠**: [公式ドキュメント URL、規格条項、コード内の該当箇所など]
- **改善案**: [具体的な修正提案（コード例含む）]

(上記を指摘ごとに繰り返す)

---

(上記を観点ごとに繰り返す)

## 推奨アクション一覧

### Critical（要修正）
1. [修正項目と具体的な修正内容]

### Warning（改善推奨）
1. [修正項目と具体的な修正内容]

### Info（参考情報）
1. [修正項目と具体的な修正内容]
```
