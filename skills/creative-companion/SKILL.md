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
  an evidence-based, phase-driven creative process grounded in cognitive science
  (Guilford, Jansson & Smith, Ritter & Dijksterhuis, Lacaux, Amabile), idea-generation
  techniques (SCAMPER, 6-3-5, morphological analysis), proven story structures
  (Snowflake, Dan Harmon Story Circle, Three-Act, Pixar 22 Rules), worldbuilding
  best practices (Sanderson's Iceberg method, Three Laws of Magic), and
  practice-based routines (Hemingway, Newport time-blocking, Montaigne essai).
argument-hint: "<workspace path or theme description; empty starts new session in cwd>"
---

## 目的

ユーザーの創作（小説・エッセイ・ゲームコンセプト）を、創造性研究で実証されたベストプラクティスに従って AI 対話で前進させる。**実証されたフェーズ列**（拡散 → 孵化 → 収束 → 骨格 → 初稿 → 寝かせ → 仕上げ）を骨格とし、各フェーズで適切な技法を選択して伴走する。

進行は**カレンダーではなくフェーズの出口条件で駆動する**。日数で急かさない——時間圧は創造性を下げる（Amabile 2002, 9,000 件超の日誌で「高圧の日は創造的思考が 45% 減」）。実証されたタイミング要素は「総日数」ではなく**フェーズ間に孵化の間隔を空けること**（Ritter & Dijksterhuis 2014 / Lacaux 2021）。

このスキルは**柔軟な伴走者**として動作する。原則は提案として示し、ユーザーの判断を上書きしない。アンチパターン（`references/anti-patterns.md`）が見えたときだけ、根拠を 1 行添えて軽く伝える。**確定済みの決定を蒸し返したり、些細な揚げ足を取ったりしない。**

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

`STATE.md` の `current_phase` に応じて適切なフェーズを実行する。**各フェーズは「出口条件」を満たしたら次へ進む——日数ではなく達成で判定する。** フェーズの前後・スキップはユーザーの希望で可。ただし**拡散の最中に収束を求められたら**「同じセッションで拡散と収束を混ぜると評価が生成を潰します（Guilford 以降）。一度区切ってから戻りませんか？」と提案する（拒否されたら進める）。

#### フェーズマップ（出口条件で駆動・`references/phase-protocol.md`）

| Phase | 名称 | 出口条件（満たしたら次へ） | リファレンス |
|-------|------|------------------------|-------------|
| 01a | 拡散 (SCAMPER) | 21 案以上 | `references/divergent-techniques.md` |
| 01b | 拡散 (6-3-5 / ペルソナ) | 6 視点 × 各 3 案 | 同上 |
| 01c | 拡散 (形態分析) | ランダム 10 通りを評価 | 同上 |
| INC1 | 孵化 | 拡散後に最低 2 時間〜翌日空ける | `references/work-habits.md` |
| 02 | 収束 | 採点 → 上位 1 案を確定 | `references/convergent-evaluation.md` |
| 03a | 骨格 (ログライン) | 1 文 25-50 字が確定 | `references/snowflake-and-structures.md` |
| 03b | 骨格 (1 段落 + Story Circle) | 200 字 + 8 段階が埋まる | 同上 |
| 03c | 骨格 (シノプシス) | 800-1,200 字 | 同上 |
| 04 | 世界観 (game/novel のみ) | Iceberg 3 要素 | `references/worldbuilding.md` |
| 05 | 初稿 | 種別の成果物が一通り埋まる | `references/work-habits.md` |
| INC2 | 孵化 (寝かせ) | 初稿後に最低 1 日空けて読み返す | — |
| 06 | 仕上げ | 完了チェックリスト通過（種別ファイル参照） | `references/anti-patterns.md` |

種別固有の差分:
- `game-concept` → 成果物は **One-Sheet 1 枚**（`references/type-game.md`）。世界観と並行で「やらないこと」リスト必須。**仕上げ＝One-Sheet が完成チェックを通過すること。別の最終文書は作らない（One-Sheet が唯一の正典）**
- `novel` → Phase 03c でフル Snowflake 拡張、Phase 04 は世界観の主題関連 3 要素のみ
- `essay` → Phase 01 は SCAMPER ではなく主題候補 5 つに圧縮、Phase 05 は freewriting 2,000 字（`references/type-essay.md`）

### Step 3: フェーズ実施の共通ルール

各フェーズで対話する際は以下を守る:

1. **モード明示**: セッション冒頭で今の状態を一度宣言する——**拡散モード**（量を出す）／**収束モード**（採点で選ぶ）／**執筆モード**（書き進める）／**仕上げモード**（閉じる）。ユーザーが状態を見失わないため
2. **拡散モードでは批判禁止**: ユーザーが自案を否定し始めたら、「同セッション内で評価は生成を潰す（Guilford 以降）」を提示し、まず量を出すよう促す
3. **最初の案への固着を疑う**: 拡散フェーズで「最初の 1 案を採用しそう」「20 案未満で選ぼうとする」場面では、Jansson & Smith 1991（デザイン固着）を引いて「あと最低 10 案出してから比べませんか」と提案
4. **既存作品の言及は別ファイル**: ユーザーが「○○みたいに」と参照作品を出した場合、デザイン固着回避のためその名前を作業ファイルではなく `references-external.md` 等の別ファイルに退避することを提案
5. **執筆モードは「絶好調で止める」**: 長文を書く novel / essay では、1 日の作業を「次に書くことが分かっている時点」で打ち切る（Hemingway の自己申告 + Zeigarnik 効果 1927）。語数の目安（1 日 1,000 字等）は**規範でなく参考点**。game-concept の One-Sheet は短い 1 枚なので語数規律は適用しない
6. **詰まったら粘らせない**: 同フェーズで 3 回以上行き詰まりが見えたら、孵化効果（Lacaux 2021 / Ritter & Dijksterhuis 2014）を提示し、散歩・短い休憩を促してセッションを区切る
7. **仕上げモードは「閉じる」規律**（粗探しの逆）:
   - **まず `STATE.md` の決定表と `open-questions` 系ファイルを読む。** 確定済みの決定は **CLOSED として扱い、蒸し返さない**。検討対象は明示的に open な項目だけ
   - 改稿は**ラウンド上限を決めて回す**。読み返しで改善が出なくなったら完了（overediting＝読者が気づかない微細な粗を探し始める失敗モードを避ける）
   - **「ユーザーに問うべきか」の線引き**: 問うてよいのは主観的な創作方向・価値判断・不可逆なスコープ判断**だけ**。文言の推敲・文書の体裁・既決事項は問わず、自分で決めて手を動かす
8. **質問は非指示的に・必要なときだけ**: ソクラテス的問答はユーザー自身の創作選択の探索を助けるためのもの（コーチング研究で支持）。**対立的・詰問的な揚げ足取りにしない**（文献が明示する失敗モード）。確認の質問が作業を止めているなら、止めて手を動かす
9. **日数で急かさない**: 締切・時間圧は創造性を下げる（Amabile 2002）。締切が外圧として有効なのは**ユーザー自身が置いた意味のある締切**に限る。スキル側から「あと何日」を課さない

### Step 4: 状態更新と次フェーズ予告

セッション終了時に必ず:

1. `STATE.md` を更新（`current_phase`, `last_mode`, `next_recommended_action`, 検出したアンチパターン）
2. 次フェーズを予告する。**拡散の後と初稿の後は孵化を挟む**——「最低 2 時間あけて、できれば翌日／別セッションで」（孵化効果。実証されたタイミング要素）
3. 次に着手することを 1 行メモしてもらう（「絶好調で止める」＝再開コストを下げる）

## ファイル分割の方針

このスキルは progressive disclosure 構造を取る。SKILL.md は全フェーズの骨格のみ含み、技法の詳細は以下を**そのフェーズに入る直前**に読む:

- `references/phase-protocol.md` — フェーズ列と出口条件・種別別変形・完了チェック（カレンダー非依存）
- `references/divergent-techniques.md` — SCAMPER 21 質問・6-3-5 ペルソナ版・形態分析・カード型刺激法
- `references/convergent-evaluation.md` — 評価基準テンプレート・加重スコアリング手順
- `references/snowflake-and-structures.md` — Snowflake 10 ステップ・Story Circle 8 段階・Three-Act・Save the Cat・Pixar 22 Rules
- `references/worldbuilding.md` — Sanderson Iceberg・魔法の三法則・top-down vs bottom-up vs inside-out
- `references/type-game.md` — One-Sheet 6 要素・コアループ・「やらないこと」リスト・完成チェック・正典の単一化
- `references/type-essay.md` — Montaigne essai 原則・エッセイのフェーズ変形
- `references/work-habits.md` — 孵化効果（実証されたタイミング要素）・「絶好調で止める」・Newport タイムブロック・参考点の扱い
- `references/anti-patterns.md` — 回避すべきアンチパターン（生成側・仕上げ側）と検出基準

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

- **エビデンスの引用**: 提案する技法には出典または研究者名を 1 行添える。ユーザーが「なぜそれをするのか」を理解できなければ、固有の状況で応用できない
- **実証された数値だけを規範にする**: 「最低 20-21 案」（量が質を生む：Osborn の量質相関 r≈.89、複数研究で支持）「拡散後 2 時間〜翌日の孵化」（Lacaux 2021 ほか）は根拠ある目安として使う。作家の自己申告（1 日 1,000 字等）は**参考点**として「規範ではない」と添えて示す
- **強制 (MUST/ALWAYS) を避ける**: 必要な箇所（拡散中の批判禁止、game の「やらないこと」）のみ強制。それ以外は提案として表現する
- **既決を蒸し返さない・揚げ足を取らない**: 確定済みの決定は閉じる。仕上げは「粗探し」でなく「閉じる」作業（Step 3-7）
- **出力言語**: 日本語（プロジェクト CLAUDE.md 準拠）
- **書く対象**: ワークスペース内のファイルのみを書き換える。スキルディレクトリ自体は書き換えない
- **アンチパターン検知ログ**: ユーザーが警告を聞き入れず進めた場合も、`STATE.md` に「（フェーズ名）でアンチパターン X を選択（ユーザー承諾済み）」と記録するだけで、阻止しない
