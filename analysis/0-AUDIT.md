# sota-present 审计报告

> 日期：2026-06-03 · 依据：本目录下 5 份 `*.agent.md` 深度分析 + catalog 实测
> 结论：现有 sota-present 架构正确（分层：TASTE/STYLE 脊梁 + SLIDES/WHITEBOARD 双引擎 + COURSE 独立），
> 但存在一批"文档声称 ≠ 实际"的事实漂移和死引用。本轮已修硬 bug，软问题列出待决。

## 一、架构判定（与 5 份分析对照）

5 个源项目不是同级，正确角色：

| 源项目 | 角色 | 在 sota-present 的落点 | 判定 |
|--------|------|----------------------|------|
| taste-skill | 横切审美规则层 | `skills/TASTE.md`（已蒸馏为单文件） | ✅ 正确 |
| frontend-slides | HTML 输出引擎 | `skills/SLIDES.md` + viewport/动效 | ✅ 正确 |
| beautiful-html-templates | HTML 引擎的资源层 | `catalog/slides-*.json` + `templates/slides/` | ✅ 正确 |
| beautiful-feishu-whiteboard | 飞书 SVG 输出引擎 | `skills/WHITEBOARD.md` + 35 palette | ✅ 正确 |
| codebase-to-course | 第三种输出（课程） | `skills/COURSE.md` | ⚠️ 与"画板+HTML"目标几乎零交集，建议降级为可选 |

**关键结论**：sota-present 上一轮已经收敛到正确的分层架构，**不需要从零重做新技能**。问题在执行细节，不在架构。

## 二、已修复（本轮）

| # | 文件:行 | 问题 | 修复 |
|---|---------|------|------|
| 1 | SKILL.md:76 | 引用 `scripts/deploy.sh`（不存在）部署到 Vercel | 改为 `serve.sh` 本地预览 + lark-apps（飞书妙搭）发布 |
| 2 | SKILL.md | styles 声称 `~80+` | 改为实测 **69** |
| 3 | SKILL.md | slide 模板声称 `~55 unique` | 改为 **46** 索引（34 gallery+12 presets），并注明 34 bold pack 未并入主索引 |
| 4 | SKILL.md | course themes 声称 `20+` | 改为 **7** |
| 5 | SKILL.md | dual 配对声称 `20+` | 改为 **12**（verified_dual），并列出全部 12 个 id |
| 6 | WHITEBOARD.md | `<polygon>` 白名单自相矛盾（line 26 允许"minor accent triangles" vs line 121 仅限 marker） | 统一为：polygon 仅限 `<marker>` 内 |
| 7 | WHITEBOARD.md | 字体规则矛盾（"Only system-ui" vs "Never set font-family"，且默认字体写错） | 统一为：绝不设 `font-family`，飞书回退 Noto Sans SC |
| 8 | scripts/whiteboard-cli.sh | **校验器把所有 `<polygon>` 判为禁用**，连 `<marker>` 内的箭头 polygon 也拒——导致 WHITEBOARD.md 自己的官方模板都通不过自己的校验器（端到端测试中暴露） | 加 parent-map，仅放行 `<marker>` 内的 polygon |

## 三、待决（软问题 / 需你拍板）

| # | 问题 | 来源 | 建议 |
|---|------|------|------|
| ~~A~~ | ~~从未跑通端到端~~ → ✅ **已验证（2026-06-03）**：dual 模式跑通「LLM 学习」主题，同时产出 `output/slides/index.html`（8 页）+ `output/whiteboard/llm-training.svg`，共用 editorial-forest 配色，双端美学协调成立。过程中暴露并修掉校验器 bug（见已修 #8）。PNG 预览经 Quick Look / headless Chrome 渲染确认。 | 实测 | 完成 |
| B | **course 模式是否剥离** —— 现在它是核心 4 大模式之一，但偏离"画板+HTML"目标 | agent #3 裁决 optional | 建议从核心路由降级为可选附加，或独立子技能 |
| C | **bold pack 34 模板未并入主索引** —— 资源在 catalog 里但 slides-index 检索不到 | 实测 | 要么并入 slides-index（→80），要么明确弃用 |
| D | **palette 35 vs 上游 37** —— 导入时少了 2 个 | agent #5 | 确认是否补回那 2 个 |
| E | **taste 旁系 skill 冲突源仍在** —— `templates/taste-{minimalist,brutalist,...}-skill.md` 内部互相打架（minimalist 推 serif、brutalist 用 Inter 违反主规则） | agent #1 | 它们只是参考素材、未被 TASTE.md 引用，无运行时风险；建议加 README 注明"仅参考，规则以 TASTE.md 为准" |
| F | **未版本化** —— 无 `.git`，未提交/未发布 | 实测 | 验证通过后 `git init` + 按惯例发布 |

## 四、下一步推荐

按风险优先级：**A（端到端验证）→ B/C/D（按验证结果决定）→ F（发布）**。
A 是关键：架构判对了，但"对的架构 + 没验证过的实现"仍可能处处是坑。
