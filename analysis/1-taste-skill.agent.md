# taste-skill — Agent 分析

> 来源：本地 6 个 templates 文件全部读取（taste-skill-original.md 共 1207 行为主文档，另含 minimalist / brutalist / soft / redesign / taste 五个旁系 skill）。GitHub 仓库 https://github.com/Leonxlnx/taste-skill 通过 WebFetch 交叉核对成功（约 32.2k stars / 2.4k forks，MIT，`npx skills add` 安装，最新主线为 v2 即 `design-taste-frontend`，v1 保留为 legacy）。

## 一句话定位
一套面向 **落地页 / 作品集 / 改版**（明确不含 dashboard、数据表、多步表单）的「反 AI-slop」前端生成规则库——它不产出代码引擎，而是一份**横切的、上下文触发的、可机械自检的设计纪律宪法**，强行把 LLM 从它的默认审美里拽出来。

## 核心机制 / 它到底怎么工作
主文档 `design-taste-frontend` 的工作流是一条固定流水线：

1. **Brief Inference（§0）**——先「读空气」，从 page kind / vibe 词 / 参考链接 / 受众 / 既有品牌资产 / 隐性约束六个信号推断意图，**先于任何代码输出一行 "Design Read"**（如 *"Reading this as: B2B SaaS landing for technical buyers, with a Linear-style minimalist language, leaning toward Tailwind + Geist + restrained motion."*）。模糊时只问 **一个** 澄清问题，能推断就不问。
2. **三个拨盘（§1）**——`DESIGN_VARIANCE`(对称↔混乱)、`MOTION_INTENSITY`(静止↔电影级)、`VISUAL_DENSITY`(画廊↔驾驶舱)，baseline 固定 `8 / 6 / 4`。后续所有布局/动效/密度判断都 gate 在这三个变量上（如「`DESIGN_VARIANCE > 4` 时禁居中 hero」「`MOTION_INTENSITY > 3` 必须支持 reduced-motion」）。有 Dial Inference 表和 Use-Case 预设表把 Design Read 直接映射成数值。
3. **Brief → Design System Map（§2）**——「诚实规则」：若 brief 命中 Fluent / Material 3 / Carbon / Polaris / Atlaskit / Primer / GOV.UK / USWDS / Radix / shadcn / Bootstrap，就装**官方包**，不准手搓 CSS 复刻；若只是审美趋势（glassmorphism / bento / brutalism / aurora / Apple Liquid Glass）则坦白标注为「approximation」。
4. **执行指令（§3-8）+ AI Tells 黑名单（§9）+ 引用词汇表（§10）+ 改版协议（§11）+ Block Library 契约（§12）+ Out of Scope（§13）。**
5. **Final Pre-Flight Check（§14）**——约 **55 个 checkbox** 的机械自检矩阵，「任一项过不了就不算完成」。这是整个 skill 的强制收口。

关键设计哲学（文档原话）：**"Every rule below is contextual. None of it fires automatically."** —— 规则不是默认值，而是按 Design Read 取用的工具箱；同时大量规则又被标成 `(mandatory)` 形成硬约束。

## 输入 → 输出
- **输入**：自然语言 brief（页面类型 + vibe 词 + 可选参考 URL/截图/品牌资产），或一个待改版的既有代码库。
- **中间产物**：一行 Design Read + 三个拨盘数值 + 设计系统选择。
- **输出**：React / Next.js（默认 RSC）+ Tailwind v4 + Motion(`motion/react`) 的前端代码；改版模式下是「在原栈上做 targeted evolution」的差量改动。
- **不输出**：dashboard / 数据表 / 向导表单 / 代码编辑器 / 原生移动 / 实时协作 UI（§13 明确转交 Fluent/Carbon/TanStack 等）。

## 关键技术与可复用资产
**拨盘真实数值与映射：**
- baseline `8 / 6 / 4`；minimalist→`5-6/3-4/2-3`；agency→`9-10/8-10/3-4`；public-sector→`3-4/2-3/4-5`；redesign-overhaul→`+2/+2/match`。
- 拨盘技术定义：VARIANCE 8-10 = masonry/`grid-template-columns: 2fr 1fr 1fr`/`padding-left: 20vw`；DENSITY 8-10 = 无卡片、1px 线分隔、`font-mono` 强制数字。

**带真实数值的硬规则（可直接搬）：**
- **字体**：默认弃 `Inter`，首选 `Geist / Outfit / Cabinet Grotesk / Satoshi`；**衬线为「非常不推荐的默认」**，`Fraunces` 和 `Instrument_Serif` 被点名 BANNED；正确的强调做法是「同字体的 italic/bold」而非乱插一个 serif 词。display 默认 `text-4xl md:text-6xl tracking-tighter leading-none`，body `max-w-[65ch]`。
- **配色**：max 1 accent，饱和度 <80%；**THE LILA RULE** 禁 AI 紫/蓝 glow；**Premium-Consumer Palette Ban**——把 beige/cream 背景 `#f5f1ea #f7f5f1 #fbf8f1 #efeae0 #ece6db #faf7f1 #e8dfcb`、brass/clay accent `#b08947 #b6553a #9a2436 #9c6e2a #bc7c3a #7d5621`、espresso 文字 `#1a1714 #1a1814 #1b1814` 全列为禁用十六进制，并给 7 套替代调色板（Cold Luxury / Forest / Black-and-Tan 等），要求「不能连续两个项目用同一族」。
- **Hero 纪律**：必须落在首屏；标题 ≤2 行，副文案 ≤20 词且 ≤4 行；top padding 上限 `pt-24`；hero 文本元素 ≤4 个（eyebrow/brand-strip 二选一 + 标题 + 副文案 + ≤2 个 CTA），禁 trust 微条/定价 teaser/feature 列表塞进 hero。
- **Eyebrow 限额（号称 #1 被违反规则）**：每 3 个 section 最多 1 个 eyebrow，机械检查 = count(`uppercase tracking`) ≤ `ceil(sectionCount/3)`，hero 计 1。
- **布局去重**：Section-Layout-Repetition Ban（8 section 至少 4 种 layout family）、Zigzag 连续 ≤2、Marquee 每页 ≤1、Bento 单元格数 = 内容数（禁空格）、nav 单行且 ≤80px。
- **EM-DASH 全面禁用（§9.G）**：`—` 和作分隔的 `–` 在标题/eyebrow/正文/引用/按钮/alt 文本里一律零容忍，唯一允许的破折号是普通连字符 `-`。文档原话：phrasing 是 binary，零个。
- **§9.F 生产测试 Tells 黑名单**：版本号 eyebrow（`V0.6`/`BETA`）、`00/INDEX` 章节编号、`·` 中点限额每行 1 个、装饰性彩色状态点、`Quietly trusted by`、`Field notes` 式诗意标签、locale/天气条 `LIS 14:23 · 18°C`、scroll cue、div 假截图、假版本 footer `v1.4.2`——全部默认 banned。

**可复用代码资产（已写好的 canonical skeleton）：**
- §5.A GSAP Sticky-Stack、§5.B GSAP Horizontal-Pan、§5.C Motion `whileInView` Reveal-Stagger——均含 `useReducedMotion` 和 `start:"top top"`/`pin:true` 的正确参数。
- Appendix A 各设计系统真实 `npm install`/`npx shadcn` 命令；Appendix B 官方文档链接清单；Appendix C 带 `prefers-reduced-transparency` fallback 的 Apple Liquid Glass「诚实近似」CSS skeleton。

**Block Library 契约（§12，尚未填充）**：定义了 `skills/taste-skill/blocks/<category>/<name>.md` 目录结构、required frontmatter（`dial_compatibility` / `when_to_use` / `not_for` / `stack`）和 8 段 body schema。**仅有 schema，blocks 标注为「iteratively 填充」——是空壳。**

**五个旁系 skill（独立 frontmatter，风格更窄、更硬）：**
- `minimalist-ui`：暖单色 + 编辑风，明确允许 serif（`Lyon Text/Newsreader/Playfair`）、给精确十六进制（背景 `#F7F6F3`、边框 `#EAEAEA`、pastel `#FDEBEC` 等）。
- `industrial-brutalist-ui`：Swiss print（亮）/ tactical CRT（暗）二选一，`clamp(4rem,10vw,15rem)`、红 `#E61919`、零 border-radius、CRT scanline。
- `high-end-visual-design`(soft)：Awwwards-tier，Double-Bezel 嵌套架构、Button-in-Button、cubic-bezier `(0.32,0.72,0,1)`、Variance Engine。
- `redesign-existing-projects`：纯 audit 清单（Scan→Diagnose→Fix），不重写、修复优先级排序。
- 注意：旁系 skill 之间互相矛盾（minimalist 允许 serif、brutalist 用 Inter Black，与主文档「弃 Inter、弃 serif」冲突）——它们是**并列的独立风格 skill**，不是主文档的子模块。

## 依赖与运行前提
- **无运行时依赖**：本质是 Markdown 提示词（frontmatter `name/description` + 正文），靠 LLM 阅读执行，不含可执行代码（仓库的 `skill.sh` 只是安装脚本）。
- **目标技术栈假设**：React/Next.js（RSC 默认）、Tailwind v4（v4 需 `@tailwindcss/postcss`，禁 `tailwindcss` plugin）、Motion `motion/react`、`next/font`、图标限 Phosphor/HugeIcons/Radix/Tabler（弃 Lucide）。
- **要求环境具备图片生成工具**（§4.8 优先级 1：有 gen-tool 必须用，否则退 `picsum.photos/seed/...`，最后才留 TODO 占位）。
- **安装方式**：`npx skills add https://github.com/Leonxlnx/taste-skill`，安装名 `design-taste-frontend`。

## 与「HTML + 飞书画板统一技能」的关系
**定位：它应是统一技能的「横切设计规则层 / 质量闸门」，而不是输出引擎、也不是资源库。**

- **该原样保留（高价值、与渲染目标无关的纯规则）：**
  - §0 Brief Inference + Design Read 一行声明（任何生成前先读空气，普适）。
  - §9 全套 AI Tells 黑名单，尤其 **§9.G 零 em-dash**、§9.D「Jane Doe / Acme / 假精确数字」、§9.F 生产 Tells——这些是文本/内容层规则，对 HTML 和飞书画板里的文字标注**同样适用**。
  - §14 Pre-Flight Check 的「可机械验证」子集（em-dash 计数、eyebrow 计数、CTA intent 去重、配色锁、形状锁）——可改造成统一技能交付前的自动 lint。
  - §4.2 配色禁用十六进制表、§4.1 字体禁用名单：作为「不要这样配色/选字」的负向知识库直接复用。

- **该改造 / 收窄：**
  - 三个拨盘的**理念**保留（用数值描述 variance/motion/density），但**技术映射**（Tailwind class、`motion/react` hooks、`min-h-[100dvh]`）只在「输出 HTML」分支生效；**飞书画板路径要重写映射**——画板是结构化节点（架构/流程/时间线），没有 hover/scroll/dark-mode 概念，§3-§8 的绝大多数 web 工程指令对它无意义。
  - §4.7 布局去重、§4.9 内容密度等「页面级」规则需按目标载体拆分：HTML 落地页全套适用；画板只取「不要数据堆砌、一个 section 一个焦点、列表 >5 项换组件」这类信息架构层精神。

- **该丢弃 / 不纳入：**
  - §2 Design System Map、Appendix A/B 的官方包安装命令——若统一技能产物是**自包含 HTML（飞书妙搭/画板）**，引入 Fluent/Carbon/Atlaskit 这类 npm 框架既不可行也跑题。
  - §12 Block Library——**空契约，无实际 blocks**，没有可搬运的资产，只能作为「未来怎么组织代码片段」的参考。
  - §5 的 GSAP/Three.js 复杂 scroll-hijack skeleton——对飞书画板/轻量 HTML 过重，按需取 §5.C 的轻量 Motion reveal 即可。
  - 五个旁系风格 skill 互相冲突，**不要全量合并**；可作为「风格预设」供 Design Read 命中时选一个，但需消解它们与主文档的矛盾（serif/Inter 之争）。

## 局限与坑
- **规则量极大且自相矛盾的「contextual vs mandatory」张力**：文档开头声明「没有规则自动触发」，但正文密布 `(mandatory)` 硬约束 + 55 项 Pre-Flight。实操中 LLM 容易要么过度套用（把落地页规则硬塞进不适用场景），要么忽略——文档本身也承认「agent historically ignored em-dash limits」才不得不写成 binary。
- **Block Library 是空壳**：§12 只有 schema 和目录树，`blocks/` 下没有任何已实现 block，「可复用组件库」的承诺尚未兑现。
- **强绑定特定技术栈**：默认 React/Next + Tailwind v4 + Motion；vanilla HTML、Vue、其它框架虽被 README 宣称支持，但主文档的 class 名、hook、`'use client'` 隔离规则都是 React 语境，迁移到飞书画板/纯 HTML 需要大量翻译。
- **旁系 skill 与主 skill 冲突**：minimalist 允许并推荐 serif、brutalist 用 Inter Black 与 Playfair，直接违反主文档「serif 非常不推荐、弃 Inter」——同一仓库内规则不一致，合并时必须显式裁决。
- **禁用清单会过期/误伤**：大量黑名单是针对「当下 LLM 默认审美」的对抗，比如把所有 beige/brass 十六进制、所有 em-dash 一刀切；遇到品牌真的就是暖工艺调性或正常排版需要破折号时，需走 override 路径，否则规则本身会制造「为了反 slop 而失真」的新问题。
- **依赖外部图片生成工具**：§4.8 把「有 gen-tool 必须用」设为强制；环境无图像生成时只能退 picsum 占位，「even minimalist needs real images」的要求难以满足。
