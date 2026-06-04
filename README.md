# sota-present

> AI 演示资料创作 Claude Code Skill

一个 Claude Code Skill，通过自然语言描述内容，即可生成两种风格协调的输出：

- 🎞️ **HTML 演示文稿** — 单文件、零依赖、1920×1080 舞台模型
- 🖼️ **飞书画板 SVG** — 符合飞书渲染器约束、可编辑白板对象

## ✨ 核心创新

**统一风格系统** — 描述一次内容，HTML 与飞书画板两种输出风格协调一致。

## 📦 整合的项目

| 项目 | 贡献 |
|------|------|
| [taste-skill](https://github.com/Leonxlnx/taste-skill) | 反 AI 审美框架、设计质量规则（横切两条路径） |
| [frontend-slides](https://github.com/zarazhangrui/frontend-slides) | HTML 幻灯片 7 阶段工作流、固定舞台 |
| [beautiful-html-templates](https://github.com/zarazhangrui/beautiful-html-templates) | 34 套 HTML 模板、deck-stage 组件 |
| [beautiful-feishu-whiteboard](https://github.com/zarazhangrui/beautiful-feishu-whiteboard) | 35 色调色板、飞书 SVG 规则 |

> 注：原 `codebase-to-course`（代码课程）模式已在精简中移除，本 skill 聚焦 HTML 演示与飞书画板两条路径。

## 🚀 安装

```bash
npx skills add Leonxlnx/sota-present
```

## 💡 使用示例

### 生成演示文稿

```
用户: "为我们的 B 轮融资做一个 15 页的演示文稿"

Claude:
  1. 检测模式: slides
  2. 运行预检
  3. 展示 3 个风格预览
  4. 用户选择风格
  5. 生成完整 HTML 幻灯片
  6. 在浏览器中打开预览
```

### 生成飞书画板

```
用户: "画一个我们系统架构的飞书画板图"

Claude:
  1. 检测模式: whiteboard
  2. 运行预检
  3. 选择匹配的调色板
  4. 生成符合飞书规则的 SVG
  5. 验证 + 导出 PNG
  6. (可选) 内嵌进飞书文档（lark-doc <whiteboard type="svg">）
```

### 双模式（幻灯片 + 画板）

```
用户: "做一个技术分享的演示，加上架构图的飞书画板"

Claude:
  1. 检测模式: dual
  2. 选择 verified_dual 风格（HTML 模板 + 画板调色板协调）
  3. 生成 HTML 幻灯片
  4. 生成匹配的飞书画板 SVG
  5. 验证两种输出的风格一致性
```

## 🎨 模板统计

（数字以 `catalog/` 实测为准）

- **HTML 幻灯片模板**: 46 个已索引（34 gallery + 12 presets），另有 34 个 bold pack 在 `catalog/_source/` 原始导入文件中（未并入主索引）
- **画板调色板**: 35 个（克制 → 均衡 → 大胆）
- **验证的双模式配对**: 12 个（`verified_dual`，幻灯片 + 画板保证匹配）

## 🛠️ 环境要求

**必需**:
- Node.js ≥ 20
- Python 3

**可选**:
- `lark-cli` — 飞书 API 客户端（用于把画板写入飞书文档）
- `@larksuite/whiteboard-cli` — 画板 CLI（SVG→PNG→飞书 JSON）
- `librsvg` 或 `cairosvg` — SVG→PNG 转换

运行预检脚本检查环境：

```bash
bash scripts/preflight.sh
```

## 📁 项目结构

```
sota-present/
├── SKILL.md              # 入口点（模式检测 + 路由）
├── skill.json            # Skill 元数据
├── skills/               # 子技能文件（渐进式披露）
│   ├── TASTE.md          # 设计质量规则
│   ├── SLIDES.md         # HTML 幻灯片工作流
│   ├── WHITEBOARD.md     # 飞书 SVG 规则
│   └── STYLE-SYSTEM.md   # 设计令牌架构
├── catalog/              # 风格索引（JSON）
├── templates/            # 模板源文件
├── assets/               # 共享资源（CSS/JS）
├── scripts/              # 工具脚本
└── output/               # 生成产物
```

## 📄 许可证

MIT
