<div align="center">

# sota-present

**一次内容描述，产出有设计品味、风格一致的 HTML 演示文稿与飞书画板。**

一个面向「高水准演示资料」的 [Claude Code](https://docs.claude.com/zh-CN/docs/claude-code) Skill。

[English](./README.md) · 简体中文

</div>

---

## 这是什么

`sota-present` 是一个 Claude Code Skill。你只描述一次内容，Claude 就能沿**两条路径**产出演示资料：

- 🎞️ **HTML 演示文稿** — 单文件、零依赖、固定 1920×1080 舞台，支持键盘 / 触屏 / 滚轮翻页。
- 🖼️ **飞书画板 SVG** — 严格符合飞书渲染器约束，生成的是**可编辑**的画板对象，可直接嵌入飞书云文档。

选 `dual`（双模式）就能从同一份内容**同时**产出两者，共用一套配色，看起来像一家人。

## 为什么用它

让 AI 直接「做个 PPT」，结果往往一眼能看出是 AI 做的：indigo 配色、满屏 Inter 字体、居中卡片网格、紫粉渐变、em-dash 满天飞。`sota-present` 就是为了一次解决三个问题：

| 问题 | `sota-present` 的解法 |
|---|---|
| **AI 设计千篇一律** | 一层不可妥协的反-slop 规则（`TASTE`）：禁用这些「AI 味」（Inter/Roboto 当标题、generic indigo、全居中、em-dash、假截图……），并在交付前过一遍检查清单。 |
| **多端重复劳动 + 风格漂移** | 同一份内容，从一套共享设计令牌**同时**编译出 HTML 和飞书画板。选 `verified_dual` 风格，两端保证协调一致。 |
| **平台约束难搞** | 飞书画板渲染器规矩很硬（禁 `<path>`、禁渐变、禁透明度、单字体）。`sota-present` 把这些约束沉淀成规则 + 校验器，你不用懂渲染器也能产出可上传、可编辑的画板。 |

它是一套**「品味 + 素材 + 平台适配」的脚手架**，不是黑盒。内容的深度与准确性仍然来自你和 Claude；技能保证的是**更高的质量下限**和**跨端一致性**。

## 快速开始

```bash
npx skills add YMaxwellHayes/sota-present
```

然后用自然语言对 Claude Code 说：

```
「为我们 Q3 战略做一个 12 页的演示文稿。」
「画一张我们系统架构的飞书画板。」
「做一个技术分享演示，再配一张架构的飞书画板。」
```

**环境要求：** Node.js ≥ 20、Python 3。可选：`lark-cli` + `@larksuite/whiteboard-cli`（把画板写入飞书）、`librsvg`/`cairosvg`（SVG→PNG）。运行 `bash scripts/preflight.sh` 自检。

## 用法

### HTML 幻灯片
Claude 识别为 `slides` 模式 → 用你的真实内容生成 3 个不同风格的预览 → 你挑一个 → 生成完整 deck 到 `output/slides/`。

### 飞书画板
Claude 识别为 `whiteboard` 模式 → 选匹配的调色板 → 写出符合约束的 SVG → 用 `scripts/whiteboard-cli.sh` 校验 → 可经 `lark-doc` / `lark-whiteboard` 技能嵌入飞书云文档成为可编辑画板。

### 双模式（两者协调）
两个都要时，Claude 优先选 `verified_dual` 风格，让 HTML deck 和画板共用一套配色，成为协调的一套。

## 工作原理

分层架构让两个输出引擎彼此独立、又保持一致：

```
        TASTE（反-slop 规则）  +  STYLE-SYSTEM（共享设计令牌）
                              │  共用脊梁
              ┌───────────────┴───────────────┐
        HTML 引擎                          飞书画板引擎
        (SLIDES.md)                       (WHITEBOARD.md)
              │                                   │
        gallery / preset 模板              调色板目录 + SVG 规则
```

- `skills/TASTE.md` — 反 AI-slop 设计规则（两条路径都适用）。
- `skills/SLIDES.md` — 7 阶段 HTML 幻灯片工作流，固定 1920×1080 舞台。
- `skills/WHITEBOARD.md` — 在飞书渲染器硬规则下生成 SVG。
- `skills/STYLE-SYSTEM.md` — 让两端保持同步的设计令牌桥梁。
- `catalog/` — 精选的风格 / 模板 / 调色板索引。

## 内含素材

| 素材 | 数量 |
|---|---|
| 精选风格（`styles.json`） | **69** |
| HTML 幻灯片模板（已索引） | **46**（34 gallery + 12 presets） |
| 飞书画板调色板 | **35** |
| 验证过的双模式配对 | **12**（HTML + 画板保证匹配） |

## 质量与测试

`scripts/stress-test.py` 是一个可复现的代码路径压测脚本，覆盖：catalog 完整性、35 个调色板全部过 SVG 校验器、校验器精度（合法 SVG 通过、9 类非法 SVG 被拒）、34 个 gallery 模板全部非空渲染、脚本冒烟。当前状态：**26/26 检查通过，34/34 模板渲染通过。**

```bash
python3 scripts/stress-test.py            # 全量（含模板渲染）
python3 scripts/stress-test.py --no-render # 快速（跳过 Chrome 渲染）
```

## 致敬

`sota-present` 站在这些优秀开源项目的肩膀上，向作者们致以诚挚感谢：

| 项目 | 作者 | 贡献 |
|---|---|---|
| [taste-skill](https://github.com/Leonxlnx/taste-skill) | [@Leonxlnx](https://github.com/Leonxlnx) | 反 AI-slop 设计哲学与质量规则层，是 `TASTE` 的核心。 |
| [frontend-slides](https://github.com/zarazhangrui/frontend-slides) | [@zarazhangrui](https://github.com/zarazhangrui) | HTML 幻灯片工作流、固定舞台缩放模型与动效模式。 |
| [beautiful-html-templates](https://github.com/zarazhangrui/beautiful-html-templates) | [@zarazhangrui](https://github.com/zarazhangrui) | 34 套 gallery 幻灯片模板与 `deck-stage` 组件。 |
| [beautiful-feishu-whiteboard](https://github.com/zarazhangrui/beautiful-feishu-whiteboard) | [@zarazhangrui](https://github.com/zarazhangrui) | 画板调色板与经实测验证的飞书 SVG 规则集。 |

## 许可证

[MIT](./LICENSE)。整合代码采用 MIT；内含的上游素材保留其原始署名（见「致敬」）。
