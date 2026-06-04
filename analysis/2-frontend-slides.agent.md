# frontend-slides — Agent 分析

> 来源交叉核对：本地 5 个文件（original.md / animation-patterns.md / html-template.md / viewport-base.css / bold-templates-original.json）+ WebFetch `github.com/zarazhangrui/frontend-slides`（约 20.1k star，与本地内容一致）。

## 一句话定位

一个把"零依赖、动效丰富的 HTML 演示文稿"做到可交付的 Claude Skill：通过**先看后选（show, don't tell）**的视觉探索流程，从内容/PPTX 生成单文件 HTML 幻灯片，强制 **1920×1080 固定 16:9 舞台整体缩放**，并自带 Vercel 部署与 PDF 导出脚本。

## 核心机制 / 它到底怎么工作

它是一个**多阶段、渐进式披露（progressive disclosure）**的工作流，靠"先读轻量索引、最后才读重文档"控制上下文消耗。共 7 个阶段（Phase 0–6）：

- **Phase 0 — Detect Mode（判模式）**：三选一。Mode A 新建（→Phase 1）、Mode B PPT 转换（→Phase 4）、Mode C 增强已有 HTML。Mode C 有专门"修改规则"：改动前先数现有元素核对密度上限、加图先核对 1920×1080 是否已满、改完必须在 1280×720 + 一个手机视口截图验证不溢出/不重叠，溢出就主动拆页。
- **Phase 1 — Content Discovery（内容发现，仅新建）**：4 个问题一次性问完——Purpose（Pitch/Teaching/Conference/Internal）、Length（5-10 / 10-20 / 20+）、Content（齐全/草稿/仅主题）、**Density（low 演讲导向 vs high 阅读导向）**。明确规定"Phase 1 不问内联编辑"。Step 1.2 处理用户图片：扫描→逐图理解→评估 USABLE/NOT USABLE→围绕图文共同设计大纲。
- **Phase 2 — Style Discovery（风格发现，核心卖点）**："show, don't tell"。直接生成 **3 个单页 HTML 预览**对比，不问用户要不要选项。混合规则：1 个来自 `STYLE_PRESETS.md` 的安全预设 + ≥1 个来自 `bold-template-pack/selection-index.json` 的 bold 模板 + 1 个 wildcard（第二个 bold 或自创 custom）。一套强约束的**预览真实性规则（NON-NEGOTIABLE）**：预览页面绝不能出现 `preview` / `template` / `Option A/B/C` / 文件名 / "safe option" 等内部元数据，必须看起来像用户成片的第一页。预览存到 `.frontend-slides/slide-previews/`（style-a/b/c.html）。Step 2.1 让用户选 A/B/C 或 Mix。
- **Phase 3 — Generate（生成全篇）**：用 Phase 1 内容 + Phase 2 风格生成完整单文件 HTML。生成前必读三件套：`html-template.md`、`viewport-base.css`（全量内联）、`animation-patterns.md`。若选了 bold 模板，**此时才读那一个模板的 `design.md`**（不读 template.html，除非 design.md 缺关键实现）。关键约束：把 design.md 里的 viewport-fluid 数值翻译成 1920×1080 舞台坐标，**不保留 live reflow**。
- **Phase 4 — PPT Conversion**：`python scripts/extract-pptx.py <input.pptx> <output_dir>`（依赖 python-pptx）→ 跟用户确认提取结果 → 走 Phase 2 → 生成，保留文本/图片(assets/)/页序/演讲备注(作为 HTML 注释)。
- **Phase 5 — Delivery**：删预览目录、`open xxx.html`、告知文件位置/风格名/页数/导航键/如何改 `:root` 变量/内联编辑(悬停左上角或按 E)。
- **Phase 6 — Share & Export（可选）**：6A `bash scripts/deploy.sh <path>` 部署到 Vercel（含未登录用户的逐步引导）；6B `bash scripts/export-pdf.sh <path> [out.pdf] [--compact]` 用 Playwright headless 截图拼 PDF。

**渐进式披露的关键纪律**（也写进了 bold-templates JSON 的 `usage`）：先读 selection-index.json 元数据 → 入围后只读候选的 `preview.md` → 用户最终选定后才读那一个 `design.md` → 绝不批量读 `design.md`、不读 `template.html`。

## 输入 → 输出

- **输入**：(A) 文字内容/草稿/仅主题 + 可选图片文件夹；或 (B) 一个 .pptx 文件；或 (C) 一个已有 HTML 演示文件。外加 4 个结构化问答（用途/长度/内容齐全度/密度）和一次风格三选一。
- **输出**：**单个自包含 HTML 文件**，所有 CSS/JS 内联，零 npm/构建工具，字体走 Fontshare/Google Fonts（禁用系统字体）。图片用相对路径放 `assets/`（不用 base64，本地查看场景）。可选产物：Vercel 公网 URL、PDF。

## 关键技术与可复用资产

**1. 固定舞台 / 缩放方案（最硬核、最该复用）** — `viewport-base.css`：
- `.deck-stage` 固定 `width:1920px; height:1080px; transform-origin:0 0`；`.slide` 全部 `position:absolute; inset:0; 1920×1080`。
- 切页**只用** `.active`/`.visible` 切 `visibility/opacity/pointer-events`，**严禁用 `display:none/block`**（注释明确警告：后续 `.slide-content{display:flex}` 会覆盖它导致全部幻灯片同时可见）。
- 缩放 JS（html-template.md 内）：`factor = Math.min(innerWidth/1920, innerHeight/1080)`，再 `translate(x,y) scale(factor)` 居中，手机上 letterbox/pillarbox **绝不 reflow**。
- 自带 `@media print`（每页一张 1920×1080，`break-after:page`）和 `@media (prefers-reduced-motion)`（动画 0.01ms、过渡 0.2s）。
- 一条踩坑铁律：**绝不直接对 CSS 函数取负**（`-clamp()`/`-min()` 被静默忽略），要 `calc(-1 * clamp(...))`。

**2. 动效模式（animation-patterns.md）** — 一张"感受→动效"映射表（Dramatic/Techy/Playful/Professional/Calm/Editorial），配真实数值：
- 入场：`.reveal` fade+slide-up `translateY(30px)→0`，`transition 0.6s var(--ease-out-expo)`；`--ease-out-expo: cubic-bezier(0.16,1,0.3,1)`；还有 reveal-scale(0.9)、reveal-left(-50px)、reveal-blur(10px)。
- 错位揭示：`.reveal:nth-child(n)` 用 `transition-delay 0.1s/0.2s/0.3s/0.4s` 递增。
- 背景：gradient-mesh（多层 radial-gradient）、noise（内联 SVG）、grid（`background-size:50px 50px`）。
- 交互：`TiltEffect` 类（鼠标 3D 倾斜 ±10deg）；强调"一次编排好的页面载入 staggered reveal > 一堆零散微交互"。

**3. HTML 模板结构（html-template.md）**：`<div class="deck-viewport"> → <main class="deck-stage" id="deckStage"> → <section class="slide title-slide active">`；`SlidePresentation` 控制器类（键盘/触摸/滚轮导航 + setupStageScale + showSlide）。`:root` 变量样例：`--title-size:112px / --subtitle-size:34px / --body-size:28px / --slide-padding:72px`（**均按 1920×1080 设计尺寸写死，非 clamp**）。
- **内联编辑**：默认开启的 post-draft 能力。明确警告**不要用 CSS `~` 兄弟选择器**做悬停显隐（`pointer-events:none` 会断开 hover 链），必须用 **JS + 400ms 延迟 timeout**；左上角 80×80 hotzone、E 键、按钮点击三入口；localStorage 自动保存。
- 图片管线：Pillow `crop_circle()` / `resize_max(max_dim=1200)`，>1MB 压缩，`_processed` 后缀不覆盖原图。

**4. bold pack 预设（bold-templates-original.json）**：来自 `zarazhangrui/beautiful-html-templates`，`template_count:34`。每条含 `slug/name/tagline/mood[]/tone[]/formality/density/scheme/best_for/avoid_for/preview_md/design_md`。JSON 顶部内嵌 `frontend_slides_policy`：`layout_model:"fixed-stage", canvas 1920×1080, scaling:"scale-stage-to-viewport", mobile:"letterbox/pillarbox 不 reflow"`。代表性模板：Studio（黑底电黄）、Signal（藏青+暗金 institutional）、Monochrome（纯墨水 ledger）、8-Bit Orbit（像素霓虹）、Bold Poster（Shrikhand 大字+消防红）、Broadside（暗底火橙+中英双语字栈）、Vellum（藏青+暖黄 Cormorant 学术风）等。另有 `STYLE_PRESETS.md` 12 个安全预设（Dark Botanical / Notebook Tabs / Neon Cyber 等）。

## 依赖与运行前提

- **生成阶段零运行依赖**：成片是纯浏览器单文件，无 npm/构建。
- **字体**：依赖 Fontshare / Google Fonts 在线加载（离线/内网会掉字体）。
- **PPT 转换**：Python + `python-pptx`。
- **图片处理**：Python + `Pillow`。
- **部署（6A）**：Node.js + Vercel CLI（`npx vercel`），需 Vercel 账号登录；CSS `background-image` 引用的本地图可能被部署脚本漏打包。
- **PDF 导出（6B）**：Playwright + Chromium（首次下载 ~150MB，30-60s）；脚本靠 `.slide` 类名找页、起本地 HTTP 服务（要求**相对路径**图片，绝对 `/Users/...` 路径会失效）；18 页可达 ~20MB，`--compact` 降到 1280×720。

## 与"HTML + 飞书画板统一技能"的关系

它显然是统一技能的 **HTML 输出引擎首选候选**——成熟、零依赖、单文件、自带固定舞台缩放与动效库，正好补齐飞书 lark-apps（妙搭部署 HTML）的"内容生成"前半段，且部署目标可从 Vercel 换成飞书妙搭。

**该原样保留：**
- 整套 **fixed-stage / viewport-base.css**（1920×1080 + transform scale + `.active/.visible` 切页禁 display + print + reduced-motion）——这是它最值钱、最难踩对的部分，原样搬。
- **动效套件**（`--ease-out-expo`、reveal 系列、nth-child stagger delay、TiltEffect）。
- **渐进式披露纪律**（先 index、再 preview.md、最后单个 design.md），对省 token 直接有效。
- **预览真实性规则**（不在幻灯片上渲染内部元数据）。
- bold pack 的元数据 schema 与 34 模板资产。

**该改造：**
- **Phase 6 部署**：把 Vercel `deploy.sh` 改造/替换为飞书妙搭（lark-apps）部署路径；PDF 导出可保留但应接入飞书云盘/文档上传。
- **HTML ↔ 飞书画板分流**：本技能只产 HTML 演示；当需求是"架构/流程/时间线等结构化图"时应路由到飞书画板（lark-whiteboard），统一技能需在前置判一层"这是要做幻灯片还是要做画板"。
- **字体在线依赖**：飞书内网/离线场景需考虑字体回退或内嵌方案，不能硬依赖 Fontshare。
- **图片策略**：本技能为本地查看用相对路径；若产物要进飞书妙搭/云端分享，需切回 base64 内嵌或随包上传（与部署 gotcha 一致）。
- **结构化问答 UI**：可对接飞书侧的结构化提问 / 交互卡片，替代纯文本编号问答。

## 局限与坑

- **强约束于 16:9 固定舞台**：刻意不做响应式 reflow，手机上只是缩小整页 letterbox——文字在小屏可能偏小，这是设计取舍而非 bug。
- **`display:none/block` 切页陷阱**：后续布局类（`.slide-content{display:flex}`）会覆盖可见性导致全部幻灯片叠显，必须严格用 `.active/.visible`。
- **CSS 函数取负被静默忽略**（`-clamp()`），易写错且无报错。
- **内联编辑 hover 链断裂坑**：CSS `~` 选择器 + `pointer-events:none` 不可用，只能 JS + 400ms 延迟。
- **截图验证不可省**：`scrollHeight` 检查不够，grid 面板会**视觉重叠**却不报溢出，必须真实浏览器截图核对。
- **部署/导出多处隐性依赖**：Vercel 账号、Playwright/Chromium 大下载、绝对路径图片失效、background-image 图被漏打包、空格文件名 `%20`、大 PDF 体积——迁移到飞书时这些脚本基本要重写。
- **风格发现成本**：每次生成 3 个预览页是真实 token/时间开销，且强约束"不许问用户要不要选项"，对只想快出一版的用户偏重。
