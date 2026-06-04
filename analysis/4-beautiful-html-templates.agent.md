# beautiful-html-templates — Agent 分析

## 一句话定位

一个面向 coding agent 的**高质量 HTML 演示模板资源库**（34 套成品级 slide 模板 + 选型元数据 + 一份 agent 操作手册 `AGENTS.md`），核心价值在"素材 + 选型规则"，而不在运行时代码。GitHub: zarazhangrui/beautiful-html-templates，MIT 许可。

## 核心机制 / 它到底怎么工作

**判断：这是一个"模板资源库 + 轻量选型协议"，不是有自主 agent 逻辑的工作流引擎。**

- 它本身没有任何可执行的 agent loop、没有调度器、没有 LLM 调用代码。仓库构成是 82% HTML / 18% JS（JS 全在各模板内部做翻页导航），外加 `index.json`、`AGENTS.md`、`screenshots/`、`runtime/`、`scripts/`。
- 真正的"逻辑"是写给 agent 看的自然语言 SOP——`AGENTS.md`（本地副本 `templates/html-templates-agents.md`）。它规定了一条 6 步人机协作流程：
  1. 先问用户「场合(occasion)」+「氛围(mood)」，不准跳过、不准自行臆测；
  2. 读 `index.json`，按 `mood/tone/best_for/formality/density/scheme` 匹配，挑**3 个差异化候选**（要求一个本命、一个更暖的替代、一个 wildcard）；
  3. 对每个候选只取**首页（封面）**，把占位内容换成用户真实标题，生成独立可打开的 preview HTML；
  4. `open` 这 3 个预览发给用户对比，等用户选；
  5. 用户定板后克隆整套模板文件夹，按「保留/替换/扩展」规则填真内容，缺的版式要**用该模板的设计系统从零设计**（同字体、同调色板、同装饰语汇、同间距节奏），不准换模板、不准混搭、不准引入新视觉语言；
  6. 产物一律 `open` + 回传绝对路径。
- 设计哲学是 **tone-first matching**（按"感觉"匹配，不按行业）：明确写"a playful pastel deck can carry a finance review if the user is intentionally rejecting the formal-finance look——用户的品味优先"。`avoid_for` 是软警告不是硬否决。

所以：agent 智能完全外包给调用方（Claude / 任意 coding agent）。这个仓库提供的是**结构化素材 + 一套可被任何 agent 遵循的提示词协议**。

## 输入 → 输出

- **输入**：用户的演示主题/简报 + 口头表达的 occasion 与 mood/vibe。
- **中间产物**：3 个填了用户真实封面的 preview HTML（temp 目录，如 `previews/01-<slug>.html`）。
- **输出**：克隆并改写后的整套 deck（`template.html` + 同级 `styles.css`/`deck-stage.js` 等），全部用 `open` 打开并回传绝对路径，附一行选型理由 + 从零设计版式的 caveat。
- 关键约束：永远不能在 slide 上出现内部工作流文字（"preview"、"Option A/B/C"、文件名、模板 slug 等），slide 上只能是真实 deck 内容。

## 关键技术与可复用资产

**模板数量：34 套**（`index.json` 中 `template_count` 在原始 AGENTS.md 文案里写 28，实际索引 = 34，以 34 为准）。

本地已被索引并落盘为两套并行结构（slug 完全一致的 34 个）：
- `templates/slides/gallery/<slug>/`：`template.html`（完整 demo deck，~44–49KB）+ `design.md`（设计系统全文，28K–55K 字符）+ `template.json`（结构化元数据：palette/typography/scheme/navigation/slide_count）。
- `templates/slides/bold/<slug>/`：`design.md` + `preview.md`（轻量"预览卡"，只给封面预览用，明确写 "Do not read template.html for preview generation"）。
- `templates/slides/presets/STYLE_PRESETS.md`：另一套独立的 12 个"风格预设"（Bold Signal / Electric Studio / Creative Voltage / Dark Botanical / Notebook Tabs / Pastel Geometry / Split Pastel / Vintage Editorial / Neon Cyber / Terminal Green / Swiss Modern / Paper & Ink），带字体配对表 + "DO NOT USE 通用 AI slop"黑名单 + CSS 坑（如负 clamp 必须 `calc(-1*...)`）。这是面向"从零写"而非"克隆模板"的轻量参考。

**分类维度**（每个模板都有）：mood / occasion / tone / formality(low→high) / density / scheme(light/dark/mixed) / slide_count。

**slide_count 分布**（34 套）：8 页×8、9 页×3、10 页×14、11 页×2、12 页×3、13 页×1、18 页×2、20 页×1——多数是 10 页 demo，少数长模板（broadside 20、monochrome 18、signal 18）适合密集内容。

**风格谱系（挑代表）**：
- `8-bit-orbit`（dark/playful）：像素艺术街机美学，三字体栈 Tektur+Chakra Petch+Space Mono，一切尺寸吸附 4px 像素网格，硬偏移叠影 + CRT 扫描线 + 星空动画。
- `monochrome`（high formality, density high, 18 页）：纯黑墨水 ledger，Lora+Jost，无任何颜色——白皮书/研究综述。
- `signal`（navy+muted gold, institutional, 18 页）：投资/董事会/咨询交付的稳重之选。
- `broadside`（dark, 20 页）：火橙单色 + 中英双语字栈，社论大字报。
- `bold-poster`（density low）：巨号 Shrikhand + 单一火车头红，杂志封面式少字海报。
- `daisy-days` / `scatterbrain` / `retro-windows`：手绘雏菊、便利贴、Windows 95 chrome 等强个性低正式度风格。
- 编辑类家族很厚：`soft-editorial`/`editorial-forest`/`editorial-tri-tone`/`emerald-editorial`/`cobalt-grid`/`cartesian`/`vellum`/`grove` 等，覆盖 literary/considered 区间。

每个 `design.md` 是真正的可复用资产：含 colors（带 hex 与语义命名）、shadows（如 `pixel-stack-cyan-yellow` token 串）、typography（fontFamily/size/weight/lineHeight/letterSpacing 分级）、CJK 适配节、签名手法(signature move)清单。

**导航运行时**：无统一框架。每模板自带（inline keyboard handler + nav dots、`deck-stage.js`、scroll-snap 或无）。`AGENTS.md` 要求改写时原样保留模板自己的 navigation。

## 依赖与运行前提

- 纯前端：HTML + CSS + 少量原生 JS，浏览器直接打开即可，无构建步骤、无 npm 依赖。
- 字体走 Google Fonts（`<link>` 远程加载，如 Tektur/Chakra Petch/Space Mono）——需要联网；`STYLE_PRESETS` 个别用 Fontshare/JetBrains。**离线或字体加载失败时设计系统会塌**，手册明令"修 import，不准换字体"。
- 固定舞台模型：preview 按 1920×1080 固定 stage 出。
- 运行环境假设 macOS（手册用 `open <path>`）。
- 调用方必须是一个能读文件、写文件、跑 shell（open）的 coding agent——智能不在仓库里。

## 与"HTML + 飞书画板统一技能"的关系

**角色：它是统一技能里 HTML 引擎的"资源层 / 素材库"，被检索和克隆，而不是一个并列的执行技能。**

- 在统一技能中，HTML 生成引擎负责"理解需求 → 选风格 → 产出 HTML"，而本库正好提供两类可被引擎检索的素材：(1) 34 套成品 deck 模板（克隆改写路线），(2) `STYLE_PRESETS` 的 12 个轻量风格预设（从零生成路线）。产物 HTML 最终交给 `lark-apps`(妙搭) 部署成公网链接，或交给 `lark-whiteboard`/`lark-slides` 走飞书原生路线——本库不碰部署。
- 它的 `AGENTS.md` 选型协议（先问 occasion+mood → 3 候选 → 封面预览 → 定板 → 克隆扩展）可以直接被统一技能吸收为"HTML deck 子流程"。

**怎么组织这批模板让 HTML 引擎检索/复用（落地建议）**：
1. **以 `index.json` 为单一检索入口**：已经是结构化的 mood/tone/occasion/formality/density/scheme/slide_count，引擎按用户需求做加权匹配即可，不必先读 HTML。本地 `catalog/slides-gallery-original.json` 与 `slides-index.json` 已经把 34 套连同 `template_path` 索引好了——直接复用这个 catalog 作为引擎的检索表。
2. **两段式读取（省 token）**：选型阶段只读 `index.json` / `preview.md`（明确禁止读 `template.html`）；定板后再读 `gallery/<slug>/design.md` + `template.html` 做完整生成。这一"先元数据、后全文"的分层正是给 HTML 引擎做 RAG/分层检索的天然结构。
3. **gallery（成品 deck）走克隆路线，presets（12 风格）走从零路线**——两者面向不同生成策略，引擎应按"用户是否需要多页成品 deck"分流。
4. **保留 design.md 的 token 化设计系统**（colors/shadows/typography 分级 + signature moves），让引擎在"缺版式从零设计"时有机器可读的约束，而不是只靠看图。

## 局限与坑

- **没有 agent 逻辑**：一切智能靠调用方；脱离一个守规矩的 coding agent，这就只是一堆 HTML，无法"自动生成"。
- **文案与实际数量不一致**：`AGENTS.md` 正文写 `template_count: 28`，实际索引/仓库均为 34，迁移时以 34 为准，别照抄 28。
- **强依赖 Google Fonts + 联网**；字体即设计系统，离线会塌且手册禁止替换字体，飞书内网/受限环境需要预先把字体自托管。
- **每个模板是封闭视觉系统**：手册明令不准跨模板混搭版式、不准重新着色、不准换字体、不准"现代化"旧模板——复用灵活度低，定制空间被刻意收窄。
- **流程强制人机交互两次**（问 mood、选预览），适合交互式会话，**不适合一次性无人值守批处理**；统一技能若要无人值守生成，需要把这两步降级为可跳过的默认策略。
- **macOS 假设**（`open`）、固定 1920×1080 stage——移植到服务端/批量渲染或飞书画板场景需要替换打开方式与适配响应式。
- **gallery vs bold 两套并行结构 + presets 第三套**，三者命名/字段不完全统一（preview.md 里还残留 `bold-template-pack/...` 旧路径引用），整合进统一 catalog 时需要做一次路径与字段对齐。
