# sota-present

> 全能型 AI 视觉创作 Claude Code Skill

一个 Claude Code Skill，整合了 5 个优秀开源项目，通过自然语言描述内容，即可生成三种输出：

- 🎞️ **HTML 演示文稿** — 单文件、零依赖、1920×1080 舞台模型
- 🖼️ **飞书画板 SVG** — 符合飞书渲染器约束、可编辑白板对象
- 📚 **代码互动课程** — scroll-snap 模块、17 种交互元素

## ✨ 核心创新

**统一风格系统** — 描述一次内容，三种输出风格协调一致。

## 📦 整合的项目

| 项目 | Stars | 贡献 |
|------|-------|------|
| [taste-skill](https://github.com/Leonxlnx/taste-skill) | 32k⭐ | 反 AI 审美框架、设计质量规则 |
| [frontend-slides](https://github.com/zarazhangrui/frontend-slides) | 20k⭐ | HTML 幻灯片 7 阶段工作流 |
| [codebase-to-course](https://github.com/zarazhangrui/codebase-to-course) | 4.5k⭐ | 代码→课程转化、17 种交互元素 |
| [beautiful-html-templates](https://github.com/zarazhangrui/beautiful-html-templates) | — | 34 套 HTML 模板、deck-stage 组件 |
| [beautiful-feishu-whiteboard](https://github.com/zarazhangrui/beautiful-feishu-whiteboard) | — | 35 色调色板、飞书 SVG 规则 |

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
  6. (可选) 上传到飞书文档
```

### 生成代码课程

```
用户: "把这个 React 代码库转化成一个互动教程"

Claude:
  1. 检测模式: course
  2. 分析代码库结构
  3. 设计课程大纲 (4-6 模块)
  4. 生成带交互元素的 HTML 课程
  5. 组装并本地预览
```

### 双模式（幻灯片 + 画板）

```
用户: "做一个技术分享的演示，加上架构图的飞书画板"

Claude:
  1. 检测模式: dual
  2. 选择统一风格（HTML 模板 + 画板调色板协调）
  3. 生成 HTML 幻灯片
  4. 生成匹配的飞书画板 SVG
  5. 验证两种输出的风格一致性
```

## 🎨 模板统计

- **HTML 幻灯片模板**: ~55 个（34 gallery + 12 presets + 去重后的 bold pack）
- **画板调色板**: 35 个（从克制到大胆）
- **课程主题**: 20+ 个兼容配置
- **验证的双模式配对**: 20+ 个精选（幻灯片 + 画板保证匹配）

## 🛠️ 环境要求

**必需**:
- Node.js ≥ 20
- Python 3

**可选**:
- `lark-cli` — 飞书 API 客户端（用于上传画板到飞书文档）
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
│   ├── COURSE.md         # 代码课程工作流
│   └── STYLE-SYSTEM.md   # 设计令牌架构
├── catalog/              # 风格索引（JSON）
├── templates/            # 模板源文件
├── assets/               # 共享资源（CSS/JS）
├── scripts/              # 工具脚本
└── output/               # 生成产物
```

## 📄 许可证

MIT
