---
name: creative-companion
description: >-
  Evidence-based companion for creative work — novels, essays, and game concepts.
  Use this skill whenever the user mentions writing a novel, essay, short story,
  game design, game concept, worldbuilding, character creation, plot structure,
  story idea brainstorming, or wants help developing a creative theme into a
  finished piece. Triggers on phrases like "創作", "小説", "脚本", "ゲーム設定",
  "世界観", "アイデア出し", "プロット", "エッセイ", "コンセプト資料", even when the
  user does not explicitly ask for a structured method. Guides the user through
  the 14-day creative prototype protocol grounded in cognitive science
  (Guilford, Jansson & Smith, Ritter & Dijksterhuis, Lacaux), idea-generation
  techniques (SCAMPER, 6-3-5, morphological analysis), proven story structures
  (Snowflake, Dan Harmon Story Circle, Three-Act, Pixar 22 Rules), worldbuilding
  best practices (Sanderson's Iceberg method, Three Laws of Magic), and
  practice-based routines (Hemingway, Newport time-blocking, Montaigne essai).
argument-hint: "<workspace path or theme description; empty starts new session in cwd>"
---

## 目的

ユーザーの創作（小説・エッセイ・ゲームコンセプト）を、創造性研究と創作実践論で裏付けられたベストプラクティスに従って AI 対話で前進させる。「14 日プロトタイププロトコル」を骨格とし、各フェーズで適切な技法（拡散・収束・構造化・執筆）を選択して伴走する。

このスキルは**柔軟な伴走者**として動作する。レポートの原則は提案として提示するが、ユーザーの判断を上書きしない。ただしレポート 10 章のアンチパターン（拡散と収束の同時実行、最初の案への固着、世界観の網羅化など）が検出された場合は、**根拠を添えて軽く警告**する。

## 起動方法

`$ARGUMENTS` の解釈:

| 引数 | 動作 |
|------|------|
| 既存ワークスペースのパス（`STATE.md` を含む） | セッション再開：`STATE.md` を読み、現在フェーズから続行 |
| 既存ディレクトリのパス（`STATE.md` なし） | そのパス配下に新規プロジェクトを作成 |
| 主題説明（パスでない自由文） | カレントディレクトリ配下に新規セッションを開始、主題候補として記録 |
| 空 | カレントディレクトリ配下に新規セッション、主題を対話で聞く |

新規セッション時のワークスペース配置:

```
{path}/{project-slug}/
├── STATE.md                  # 現在フェーズ・種別・主題・最終更新
├── phase-01-divergent/       # 拡散フェーズ出力
├── phase-02-evaluation/      # 収束（評価）フェーズ出力
├── phase-03-skeleton/        # 骨格（Snowflake / Story Circle 等）
├── phase-04-worldbuilding/   # 世界観（必要な種別のみ）
├── phase-05-draft/           # 初稿
└── phase-06-final/           # 推敲版
```

`project-slug` はユーザーに確認する（主題から日本語/英数字 kebab-case の候補を提示）。

## 実行フロー

```
入力受付 → 状態判定 → 種別判定 → 現在フェーズの実施 → 状態更新 → 次フェーズ予告
```

### Step 0: 入力受付と状態判定

1. `$ARGUMENTS` を解釈してワークスペースパスを決定
2. ワークスペースに `STATE.md` があれば読み込み（種別・主題・現在フェーズ・最終セッション日・アンチパターン履歴を取得）
3. なければ新規セッションとして Step 1 へ

### Step 1: 種別判定（新規時のみ）

主題と用途から以下の 3 種別に振り分ける:

| 種別 | 用途 | 主要技法 |
|------|------|---------|
| `game-concept` | ゲームコンセプト資料・世界観・シナリオ | One-Sheet, Iceberg, Story Circle |
| `novel` | 小説・短編 | Snowflake, Story Circle, Iceberg（必要なら） |
| `essay` | エッセイ・思考の試み | Montaigne 式、freewriting |

判別が曖昧なら、レポート § 5.2 の "inside-out" を念頭に「主人公／プレイヤー視点で何をする物語ですか？それとも自分の問いを書き留めるエッセイですか？」と質問する。

### Step 2: 現在フェーズの実施

`STATE.md` の `current_phase` に応じて適切なフェーズを実行する。フェーズ間の遷移は厳密ではなく、ユーザーの希望で前後・スキップ可能。ただし**拡散の最中に収束を求められたら**レポート § 1.1 を根拠に「同じセッションで拡散と収束を混ぜると評価が生成を潰します。一度区切ってから戻りませんか？」と提案する（拒否されたら進める）。

#### フェーズマップ（14 日プロトコル準拠、レポート § 9.1）

| Phase | 名称 | 推奨日 | 技法 | リファレンス |
|-------|------|-------|------|-------------|
| 01a | 拡散 (SCAMPER) | Day 1 | 主題から 21 案 | `references/divergent-techniques.md` |
| 01b | 拡散 (6-3-5 / ペルソナ) | Day 2 | 6 視点 × 各 3 案 | 同上 |
| 01c | 拡散 (形態分析) | Day 3 | ランダム 10 通り組み合わせ | 同上 |
| INC1 | 孵化 | Day 4 | 散歩・低負荷活動を提案、書かない | `references/work-habits.md` |
| 02 | 収束 | Day 5 | 評価基準による採点 | `references/convergent-evaluation.md` |
| 03a | 骨格 (ログライン) | Day 6 | 1 文 25-50 字 | `references/snowflake-and-structures.md` |
| 03b | 骨格 (1 段落 + Story Circle) | Day 7 | 200 字 + 8 段階 | 同上 |
| 03c | 骨格 (シノプシス) | Day 8 | 800-1,200 字 | 同上 |
| 04 | 世界観 (game/novel のみ) | Day 8-9 並行 | Iceberg 3 要素 | `references/worldbuilding.md` |
| 05 | 初稿執筆 | Day 9-11 | 1 日 1,000 字目安、Hemingway 原則 | `references/work-habits.md` |
| 06a | 完稿 | Day 12 | 通読 | — |
| INC2 | 孵化 (寝かせ) | Day 13 | 書かない・読まない | — |
| 06b | 推敲 | Day 14 | 通読 → 修正 → 完成 | — |

種別固有の差分:
- `game-concept` → Phase 05 で **One-Sheet 形式**（`references/type-game.md`）。Phase 04 と並行で「やらないこと」リスト必須
- `novel` → Phase 03c でフル Snowflake 拡張、Phase 04 は世界観の主題関連 3 要素のみ
- `essay` → Phase 01 は SCAMPER ではなく主題候補 5 つに圧縮、Phase 05 は freewriting 2,000 字（`references/type-essay.md`）

### Step 3: フェーズ実施の共通ルール

各フェーズで対話する際は以下を守る:

1. **モード明示**: セッション冒頭で「今は **拡散モード**／**収束モード**／**執筆モード** です」と一度宣言する（ユーザーが状態を見失わないため）
2. **拡散モードでは批判禁止**: ユーザーが自案を否定し始めたら、レポート § 1.1 の「同セッション内で評価は生成を潰す」を提示し、まず量を出すよう促す
3. **最初の案への固着を疑う**: 拡散フェーズで「最初の 1 案を採用しそう」「20 案未満で選ぼうとする」場面では、レポート § 1.2 (Jansson & Smith 1991) を引いて「あと最低 10 案出してから比べませんか」と提案
4. **既存作品の言及は別ファイル**: ユーザーが「○○みたいに」と参照作品を出した場合、デザイン固着回避のためその名前を作業ファイルではなく `references-external.md` 等の別ファイルに退避することを提案
5. **執筆モードは Hemingway 原則**: 1 日 1,000 字目安・「次に書くことが分かっている時点で打ち切る」（レポート § 8.2、Zeigarnik 効果）を案内
6. **詰まったら粘らせない**: 同フェーズで 3 回以上行き詰まりが見えたら、レポート § 1.3 の孵化効果（Lacaux 2021 / Ritter & Dijksterhuis 2014）を提示し、散歩・シャワー・短い昼寝を促してセッションを区切る

### Step 4: 状態更新と次フェーズ予告

セッション終了時に必ず:

1. `STATE.md` を更新（`current_phase`, `last_session_date`, `next_recommended_action`, 検出したアンチパターン）
2. ユーザーに次フェーズの予告と、孵化期間が必要なら「最低 2 時間あけて／翌日に」を伝える（レポート § 1.1 の数値根拠）
3. Hemingway 原則に従い、ユーザーが**次に書くことを 1 行**でメモするよう促す

## ファイル分割の方針

このスキルは progressive disclosure 構造を取る。SKILL.md は全フェーズの骨格のみ含み、技法の詳細は以下を**そのフェーズに入る直前**に読む:

- `references/14-day-protocol.md` — 14 日スケジュール全体・種別別変形・各日のチェックリスト
- `references/divergent-techniques.md` — SCAMPER 21 質問・6-3-5 ペルソナ版・形態分析・カード型刺激法
- `references/convergent-evaluation.md` — 評価基準テンプレート・加重スコアリング手順
- `references/snowflake-and-structures.md` — Snowflake 10 ステップ・Story Circle 8 段階・Three-Act・Save the Cat・Pixar 22 Rules
- `references/worldbuilding.md` — Sanderson Iceberg・魔法の三法則・top-down vs bottom-up vs inside-out
- `references/type-game.md` — One-Sheet 6 要素・コアループ・「やらないこと」リスト・評価基準
- `references/type-essay.md` — Montaigne essai 原則・14 日エッセイプロトコル
- `references/work-habits.md` — 日次語数・Hemingway 打ち切り・Newport タイムブロック・孵化効果の使い方・クロノタイプ
- `references/anti-patterns.md` — 回避すべき 10 パターン（レポート § 10）と検出基準

新規プロジェクト初期化時の雛形は `templates/` 配下:

- `STATE.md` — プロジェクト状態
- `divergent-output.md` — 拡散フェーズの出力テンプレート
- `evaluation-matrix.md` — 評価マトリクス
- `snowflake.md` — Snowflake 進行表
- `story-circle.md` — Dan Harmon 8 段階
- `iceberg-worldbuilding.md` — Iceberg 3 要素
- `game-onesheet.md` — ゲーム One-Sheet
- `essay-progression.md` — エッセイ進行表

## 重要な原則

- **エビデンスの引用**: 提案する技法には必ず出典または研究者名を 1 行添える。ユーザーが「なぜそれをするのか」を理解できなければ、固有の状況で応用できない（レポートの設計思想）
- **数値は具体的に**: 「たくさん出して」ではなく「最低 21 案」「1 日 1,000 字」「散歩 30-90 分」など、レポートに記載された数値を使う
- **強制 (MUST/ALWAYS) を避ける**: 「批判禁止」「やらないこと必須」など必要な箇所のみ強制。それ以外は提案として表現する
- **出力言語**: 日本語（プロジェクト CLAUDE.md 準拠）
- **書く対象**: ワークスペース内のファイルのみを書き換える。スキルディレクトリ自体は書き換えない
- **アンチパターン検知ログ**: ユーザーが警告を聞き入れず進めた場合も、`STATE.md` に「Day X: 拡散と収束の混合を選択（ユーザー承諾済み）」と記録するだけで、阻止しない
