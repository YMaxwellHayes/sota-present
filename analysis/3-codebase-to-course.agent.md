# codebase-to-course — Agent 分析

## 一句话定位
把任意 codebase 读懂后，自动生成一份**面向"vibe coder"（不懂代码的 AI 编程使用者）的交互式单页 HTML 教程**——带滚动分屏导航、代码↔大白话对照、组件群聊动画、数据流动画和测验，开箱即用、离线可跑。它本质是一个"教学型 HTML 生成器"，而不是通用展示工具。

## 核心机制 / 它到底怎么工作
一个固定的**多阶段流水线**（SKILL.md 称 4 阶段，实际含 Phase 2.5 共 5 步）：

- **Phase 1 代码分析**：先深读 README + 入口文件 + UI 代码，自己搞清楚"这个 app 干什么"，再提取：主要 actor（组件/服务/模块）及职责、核心用户旅程、API/数据流/通信模式、聪明的工程套路（缓存/懒加载/错误处理）、真实 bug 与坑、技术栈选型理由。强调"AI 别问用户产品是干嘛的，用户自己也可能不懂"。
- **Phase 2 课程设计**：把课程结构化成 **4–6 个 module**（最多 7–8，宁可少而精）。叙事弧线是"倒置 CS 教育"——从学习者已知的**用户可见行为**出发，逐层下钻到代码内部（`[用户行为] → [功能模块] → [核心抽象] → [基础设施]`）。每个 module 必须挂钩一项"实用技能"（更会指挥 AI / 更会 debug / 更会做架构决策），否则砍掉。提供一张 module 位置→用途的菜单表（不是清单）。**明确要求：不要把课程大纲拿给用户审批，直接开干。**
- **Phase 2.5 Module Briefs（仅复杂 codebase）**：为每个 module 写一份 brief，把代码片段（含文件路径行号）**预先抽取**进 brief。这是省 token 的关键步骤——让后续并行写作的 subagent 完全不必再读 codebase。
- **Phase 3 构建**：分**顺序路径**（简单 codebase，主上下文逐个写）和**并行路径**（复杂 codebase，按 brief 分发给 subagent，每批最多 3 个）。
- **Phase 4 复查并打开浏览器**。

**关键设计判断（两个版本不一致，见"局限与坑"）**：
- 原 SKILL.md 主张**目录化输出**：`styles.css` / `main.js` / `_base.html` / `_footer.html` / `build.sh` 全部**逐字复制**（绝不重新生成），AI 只写各 module 的 `<section>` 片段，最后 `build.sh` 拼装成 `index.html`。理由：boilerplate 不重复生成、module 独立写质量更高、产物离线零依赖。
- GitHub README 上写的却是**单个自包含 HTML 文件**。
- sota-present 蒸馏版 `COURSE.md` 跟随的是**单文件**路线（CSS/JS inline，存到 `output/course/index.html`）。

## 输入 → 输出
- **输入**：一个 codebase。三种入口——本地文件夹、GitHub 链接（先 `git clone <url> /tmp/<repo-name>`）、当前工作目录（"turn this into a course"）。
- **输出**：一份滚动分屏的交互式 HTML 教程，含固定顶部进度条、侧边 dot 导航、键盘方向键导航、4–6 个 module，每个 module 内 3–6 屏。
- **强制元素（每门课必含全部 5 类）**：① 组件群聊动画（iMessage 风）② 消息/数据流动画 ③ 代码↔大白话对照块（每 module 至少一处）④ 测验（每 module 至少一个）⑤ 术语 tooltip（每 module 首次出现的技术词都要挂）。其余（架构图、layer toggle、pattern card、spot-the-bug 等）为可选。

## 关键技术与可复用资产
- **`templates/course/base/` 下的成套基建（最有价值的可复用资产）**：
  - `styles.css`（~34KB）、`main.js`（~19KB）——一个**通用交互引擎**，IIFE 自包含，靠扫描 class 名 + `data-*` 属性**自动初始化**所有交互元素（导航/进度条/滚动揭示/键盘/tooltip/测验/拖拽匹配/群聊/数据流/架构图/spot-the-bug/layer toggle）。HTML 端只写标记，零内联 JS。
  - `interactive-elements.md`（~32KB）——17 种交互元素的完整 HTML+CSS 实现模式与 `data-*` 契约。
  - `design-system.md`（~12KB）——完整设计 token：暖色"开发者笔记本"调色板（暖米白底、单一大胆 accent 如朱红/珊瑚/teal、Catppuccin 风深靛炭代码块 #1E1E2E）、字体（Bricolage Grotesque / DM Sans / JetBrains Mono，明确禁用 Inter/Roboto/Arial）、间距、阴影、动画、响应式断点。
  - `content-philosophy.md`（~9KB）、`gotchas.md`（~3KB）。
- **`catalog/course-index.json`**：sota-present 自加的 **7 套主题预设**（professional-light / developer-dark / literary-light / hacker-dark / academic-light / editorial-light / friendly-light），各带 mood、best_for、字体三元组、推荐交互元素、密度——比原 skill 单一暖色调更灵活，可作主题选择层。
- **内容方法论**（可迁移到任何教学产物）：倒置教育弧线、"先 why should I care 再 how"、禁止复用隐喻（尤其禁"餐厅"隐喻）、测验测"做"不测"背"、只用真实代码不用简化示例。
- **省 token 工程**：brief 预抽代码片段 + 并行 subagent + 逐字复制 boilerplate，是处理大 codebase 的可借鉴模式。

## 依赖与运行前提
- **运行时零依赖**：产物纯 HTML/CSS/JS，离线可跑；唯一外部依赖是 **Google Fonts CDN**（断网时字体退化但功能不受影响）。
- **生成时依赖**：能读 codebase（本地或 `git clone`，需 git）；目录化路线需 `bash build.sh` 做拼装；并行路线需 subagent/Task 能力。
- 不依赖任何后端、构建工具链或包管理。

## 与"HTML + 飞书画板统一技能"的关系
**关键判断：course 模式应作为统一技能的"可选附加模式"，倾向于剥离为独立技能，不应进入核心。**

理由：
1. **产物形态高度专一**：它产出的不是"一张图/一页展示"，而是一份**带学习路径、测验、进度条的多 module 长教程**。用户目标是"既能生成飞书画板 SVG 又能生成 HTML"——指向的是**可视化/演示**这一层；course 是**教育课程**，是另一个品类，二者只在"都吐 HTML"这点上重叠。
2. **与飞书画板 SVG 几乎不交集**：飞书画板擅长表达架构/流程/时间线等**单张结构化图**（PlantUML/Mermaid/DSL → 画板节点）。course 的核心价值（群聊动画、滚动分屏、测验、tooltip、键盘导航）依赖一整套运行时 JS 引擎，**无法降级成静态 SVG 画板**。强行把 course 塞进统一技能，会让画板分支和 course 分支共享面极小却互相拖累指令复杂度。
3. **触发语义不同**：course 的触发词非常窄且明确（"turn this into a course / teach this code / interactive tutorial from code"），天然适合独立 skill 的 description 路由，不必和"画个架构图/做个 HTML 落地页"挤在同一决策树里。
4. **但有高价值可复用件应被统一技能吸收**：`design-system.md` 的设计 token、`content-philosophy.md` 的反 AI-slop 审美规则、`catalog/course-index.json` 的主题预设、以及"交互元素靠 class+data-* 自动初始化"的引擎架构思路——这些是通用 HTML 生成的优质素材，可抽进统一技能的共享 HTML 资产库。

结论：**核心模式 = HTML 展示 + 飞书画板 SVG；course 作为可选的、独立挂载的子技能（或附加模式）存在，复用其设计/内容资产，但不把整条 4–6 module 教学流水线塞进核心路由。**

## 局限与坑
- **输出形态文档自相矛盾**：SKILL.md 说"目录 + build.sh 拼装"，GitHub README 说"单个自包含 HTML 文件"，sota-present 的 `COURSE.md` 又走单文件 inline 路线。三处不一致，落地前**必须先定一种**，否则 `build.sh`/目录结构与"单文件"指令会打架。
- **强约束多**：每门课强制含全部 5 类交互元素 + 每 module ≥1 测验 + ≥1 代码对照 + 术语 tooltip。对小型/简单 codebase 容易**过度生产**，硬凑群聊/数据流动画会显得牵强（skill 自己也承认"creatively frame… even if you have to"）。
- **强依赖 main.js 的 class/data-* 契约**：module HTML 必须严格匹配引擎约定（chat 容器要 `id`、flow 动画要 `data-steps='[...]'` JSON、scroll-snap 用 `proximity` 不用 `mandatory`、`.module` 用 `min-height:100dvh`）。任何偏差都会静默失效，调试成本高。
- **受众极窄**：明确只服务"vibe coder / 零技术背景"，要求全程白话、禁 jargon。若实际受众是工程师，则语气和深度都不匹配。
- **不向用户审批大纲**：直接开干的设定省事，但对复杂 codebase 若分析方向偏了，要到 Phase 4 看成品才发现，返工成本大。
- **codebase 体量风险**：超大 repo 的 Phase 1 深读 + Phase 2.5 抽片段会很耗 token；并行 subagent 缓解了写作阶段，但分析阶段仍是瓶颈。
- **GitHub 页面 best-effort 抓取成功**，但其描述（references 仅含 design-system.md / interactive-elements.md、单文件输出）比本地 `templates/course/base/`（含 6 个文件、目录化）**更旧/更简**，说明本地副本是更完整的快照，应以本地为准。
