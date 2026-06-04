# beautiful-feishu-whiteboard — Agent 分析

## 一句话定位
一个面向飞书/Lark 画板（Feishu Whiteboard）的「设计系统型」技能：提供 35-37 套精选调色板 + 飞书 SVG 渲染器的硬性约束（RULES.md），让 Agent 自己排版、用纯原生 SVG 生成**可编辑**（非截图）的飞书画板，并回链 + 回图。它**不是**自动布局图表生成器——布局由 Agent 手写，模板只给「配色 + 气质」。

## 核心机制 / 它到底怎么工作
飞书画板把 SVG 当作「矢量原生图形」导入：符合白名单的元素会变成**真正可编辑的画板对象**（矩形、圆、连接线、文本框），不符合的会被**拍平成静态图片**或直接渲染失败。技能的全部价值就在于把这条「哪些 SVG 能变成原生对象」的边界用经验验证下来（RULES.md 称之为 "hard won, on board verified knowledge"）。

链路（走 lark-cli + whiteboard-cli，不是 DSL/PlantUML/Mermaid）：
1. Agent 手写一段逻辑坐标 SVG（约 1600–1700 宽，viewBox 不写固定 width/height）。
2. 本地渲染校验：`npx -y @larksuite/whiteboard-cli@^0.2.11 -i diagram.svg -o diagram.png -f svg`，再 `--check` 自动检测 text-overflow / node-overlap。**关键步骤是「render → 肉眼看 PNG → 改 → 重渲」迭代**，linter 仅辅助。
3. 转 OpenAPI 节点格式并写入飞书画板块：
   `npx -y @larksuite/whiteboard-cli@^0.2.11 -i diagram.svg --to openapi --format json | lark-cli whiteboard +update --whiteboard-token <tok> --source - --input_format raw --idempotent-token <unique> --overwrite --as user`
4. 回查真实画板图：`lark-cli whiteboard +query --whiteboard-token <tok> --output_as image`，再修残余布局问题。
5. 若无目标画板，先 `lark-cli docs +create --api-version v2 --content '<title>..</title><whiteboard type="blank"></whiteboard>'` 建一个空画板块拿 block_token。

即：**SVG 是唯一输入语言，whiteboard-cli 负责 SVG→OpenAPI 节点转换，lark-cli 负责认证与写入**。沙盒上游 README 与本仓 RULES.md 都未提 PlantUML/Mermaid（那是另一个独立的 `lark-whiteboard` skill 的能力）。

## 输入 → 输出
- 输入：用户的内容意图（"把 X 画成画板"）+ 风格偏好；Agent 选定模板 slug 后手写 SVG。
- 中间产物：`<dir>/diagram.svg`、`<dir>/diagram.png`（本地预览）。
- 输出：飞书文档内的**可编辑画板**（doc 链接）+ 渲染图。交付时必须**同时给 doc 链接和图片本身**，并主动提示用户可随时换风格（同内容换模板调色板重渲）。

## 关键技术与可复用资产

**调色板（最有价值的可复用资产）**
- 数量：上游 README/SKILL frontmatter 声称 **37 套**（9 Restrained / 16 Balanced / 12 Bold）；本仓快照实测 **35 套**（catalog/whiteboard-index.json + CATALOG.md 均为 35，分布 restrained 9 / balanced 15 / bold 11；formality medium 17 / low 11 / high 7）。存在 35 vs 37 的版本漂移（SKILL.md 文案写 37 但 CATALOG.md 标题写 "The 35 styles"），引用时以 index.json 为准。
- 命名（35 个 id）：avocado-press, grove, jade-lens, long-table, macchiato, monochrome, papier-bleu, reading-room, salmon-stamp, apricot-arc, berry-pop, bold-poster, checker-bloom, cobalt-bloom, coral, cut-bloom, editorial-forest, lime-slab, linen-cut, pin-and-paper, raw-grid, riptide-cobalt, soft-editorial, violet-marker, block-frame, burst-panel, confetti-wedge, court-press, crayon-stack, grove-block, mint-brut, neo-grid-bold, riso-brut, specimen-bold, stencil-tablet。默认安全选择：**Riso Brut**。
- 每个 palette 在 index.json 里是结构化设计令牌：7 个语义角色 `primary / secondary / accent / background / surface / text / text_muted` + `best_for` / `avoid_for` + `design_notes`(`shadow_style`, `border_width`, `corner_radius`)。真实色值示例：
  - Coral：coral `#E85D5D`、coral-dark `#D44A4A`、cream `#F5F0E8`、black `#1A1A1A`、gray `#6B6B6B`、white `#FFFFFF`；radius 0–12。
  - Crayon Stack（bold）：primary `#FF472B`、secondary `#D3FE79`、accent `#7E90FC`、text_muted `#8A2E43`；radius 0、border 0。
  - Grove（high）：primary `#192b1b`、secondary/accent `#c8524a`、background `#e8e4d6`、surface `#dedad0`。
- 每个 templates/<slug>/design.md 还有人类可读版（YAML frontmatter + 散文），明确「这只是 palette + mood，所有 medium 约束去读 ../../RULES.md」。

**飞书 SVG 严格规则（RULES.md，硬约束）**
- **唯一字体**：画板硬编码 Noto Sans SC（本仓蒸馏版 WHITEBOARD.md 写 system-ui，二者口径不同）。**永不设 font-family**，排版只靠 size/weight/casing/letter-spacing。
- **形状词汇全原生**：`<rect>`(含 rx)/`<circle>`/`<ellipse>`/直 `<line>`/`<polyline>`/`<text>`/`<tspan>`/`<g>`/`<defs>`/`<marker>`。
- **禁用（会失败或被拍平成图片）**：`<path>`（任何曲线/贝塞尔/弧）、`<polygon>`（仅允许在 `<marker>` 内做箭头）、gradient(linear/radial)、`<filter>`、`<pattern>`、`<clipPath>`、`<mask>`、`<foreignObject>`、`<image>`、`<use>`、`<style>` 块。无 freeform/有机形状（叶/花/波浪/彩带/涂鸦）。
- **箭头 = 原生连接器**：给 line/polyline 加 `marker-end`（双向再加 `marker-start`）指向 `<defs>` 中的 `<marker>`；画板转成 native connector，箭头取线的 stroke 色。**绝不画 polygon 三角头**。
- **opacity 被忽略**：opacity/fill/stroke-opacity 一律全不透明；要浅色用「更浅的实色 hex」，要叠透明就把重叠区画成独立的深色实块。
- **阴影只能硬偏移**：复制同一形状（同 rx、同尺寸、同 rotate 组）偏移到背后做实色阴影；禁 blur/filter。
- **颜色全实色 hex**：无 rgba()/hsl()。
- **transform 只用** translate/rotate/scale，禁 skewX/Y、matrix()。
- **画布**：无固定 16:9，逻辑坐标 ≈1600–1700 宽，用 viewBox 不写 root width/height；蒸馏版加了「四边 ≥80px margin、高 900–1200」的具体数字。
- **文字按字符 reflow**（CJK≈1em，Latin≈0.6em），SVG text 不自动换行，靠多个 `<tspan>` 手动换行，宁可换行不要缩字。
- **文本颜色导出不可靠**（PNG 常渲成黑）：判断文字色要用 `+query --output_as raw`（存储 hex）或看真实画板，**绝不信导出 PNG**。
- **never echo instructions**：画板上只放内容，绝不放 prompt/范围说明/来源引用/所选风格名/日期/token/文件路径等「作业头」元信息。

## 依赖与运行前提
- **强依赖 lark-cli**（npm `@larksuite/cli`），且必须已 `lark-cli config init`(扫码) + `lark-cli auth login` 认证；缺失则停止并告知安装步骤。
- `@larksuite/whiteboard-cli`（固定 `^0.2.11`）通过 npx 即用即下，无需安装。
- Node ≥ 20。
- 需要**飞书/Lark 账号**——画板写进用户自己的 tenant；所有写操作 `--as user`。
- 有 `scripts/preflight.sh` 做依赖与认证自检。

## 与「HTML + 飞书画板统一技能」的关系
本技能就是**飞书 SVG 输出引擎**：负责「内容 → 原生可编辑画板」这一条飞书专有链路。

**可与 HTML 引擎共享（设计层）**：
- 整套 35/37 调色板与设计令牌（catalog/whiteboard-index.json 的 7 角色 token 结构 + best_for/avoid_for + design_notes）是渲染中立的，HTML/CSS 引擎可直接复用同一份 token 表，实现「同一风格、双引擎一致输出」。
- 风格选择逻辑（Restrained/Balanced/Bold × Low/Medium/High formality × vibe，默认 Riso Brut）、叙事结构类型（pipeline/stages/comparison/system map/timeline/mind map/hierarchy）都与媒介无关，可共用。
- 「never echo instructions / 内容才上画布」这条信息卫生原则两引擎通用。

**必须隔离的飞书专有约束（HTML 无此限制，不能混用）**：
- SVG 元素白/黑名单（禁 path/gradient/filter/clipPath/mask/image/use/style）——HTML+CSS 恰恰能用渐变、阴影 blur、圆角曲线、字体。
- 单字体硬编码（Noto Sans SC，禁 font-family）——HTML 可自由配字体对（与 ui-ux-pro-max 的 57 套字体配对正好冲突）。
- opacity 被忽略、阴影只能硬偏移、颜色只能实色 hex——这些都是飞书渲染器特性，HTML 不应继承。
- 工具链 lark-cli + whiteboard-cli + OpenAPI 节点转换、`--output_as raw` 验色、画板 block_token 写入——纯飞书 API，须封在飞书分支里。
- 逻辑坐标系（viewBox、无固定画布、字符级 reflow、tspan 手动换行）是 SVG 思维；HTML 用流式/弹性布局，二者排版心智模型不同。

结论：**调色板/设计令牌/风格选择是共享层；SVG 元素约束、字体、opacity/阴影规则、lark 工具链是飞书专有层，必须隔离在引擎适配器后面**。

## 局限与坑
- **不是自动布局器**：坐标全靠 Agent 手算，必须靠「渲染→看 PNG→修」迭代，无人值守易出文字溢出/碰撞/裁切。
- **35 vs 37 版本漂移**：SKILL frontmatter 与上游 README 写 37，本仓 CATALOG.md/index.json 实为 35，引用数量要以 index.json 为准。
- **字体口径不一致**：RULES.md 说 Noto Sans SC，蒸馏版 WHITEBOARD.md 说 system-ui——以「永不设 font-family、让画板用默认字体」为准更稳。
- **导出 PNG 文字色不可信**，是反复踩的坑；判色必须走 raw 或真实画板。
- **强绑飞书 tenant**：无 lark-cli/无认证就完全不可用，不能产出独立可分享产物（要公网可访问得另走 lark-apps/妙搭）。
- **polygon/path 静默降级**：不报错但被拍平成「lumpy 图片」，破坏「可编辑」承诺，容易被忽视。
- whiteboard-cli 版本钉死 `^0.2.11`，上游若改 OpenAPI schema 可能 break。
