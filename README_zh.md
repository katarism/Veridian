# 市场分析工作台

基于 Claude Code 的 human-in-the-loop 市场分析系统。六个专职 subagent 协作完成完整分析链：材料收集 → 质量评级 → 市场分析 → 证据审计 → 报告输出。

只需修改一个配置文件（`market_config.md`），即可将整套流程切换到任意市场，无需改动任何 agent 文件。

> **English documentation** → [README.md](README.md)

> [!IMPORTANT]
> **前置条件：** 本系统需要 `pdftotext` 将 PDF 转为文本后才能进行分析。
> clone 后运行 `./setup.sh`，自动检测并安装所需依赖。
> 手动安装：`brew install poppler`（macOS）· `sudo apt install poppler-utils`（Linux）

---

## 系统架构

```
人类提问
  └─→ orchestrator（路由 + 任务分解）
        ├─→ materials-strategist（制定搜索策略 + 材料评级）
        │     └─→ web-researcher（执行抓取 + PDF文本提取）
        │
        ├─→ [人类确认材料质量] ←── 必须停下来等待
        │
        ├─→ analyst（分析 + 假设构建 + 投资人问答）
        ├─→ evidence-auditor（证据质量审计）
        └─→ writer（最终报告）
```

**核心设计原则：**
- 每个推断必须标注证据质量（★1–5）
- 本地视角 vs 全球视角必须显式区分，不能混用
- 材料空白不能被掩盖，必须呈现给人类
- 人类决策节点不能被跳过——agent team 无权自行推进

---

## 快速开始

### 前置条件
- 安装 [Claude Code](https://claude.ai/code) CLI
- `pdftotext` — 下方 setup 步骤会自动检测并安装

### 1. 克隆项目
```bash
git clone https://github.com/katarism/Veridian.git
cd Veridian
```

### 2. 运行 setup
```bash
chmod +x setup.sh && ./setup.sh
```
自动检测 `pdftotext` 是否已安装，缺失时按系统类型自动安装，完成后自动启动 Claude。

### 3. 配置 + 开始分析——Claude 引导你完成配置
Claude 启动后会以对话方式逐项引导你填写配置：
- 你想分析哪个市场？
- 目标公司是哪些？
- 最关心哪些分析角度？

你回答后，Claude 自动将内容写入 `market_config.md`。配置完成后，直接提出你的第一个研究问题：
> 「请对NEC与富士通的云转型战略进行比较分析」

orchestrator 会首先向你确认分析角度，再开始材料收集。

---

## 文件结构

```
.
├── CLAUDE.md                        # 系统规则（Claude Code 项目指令）
├── market_config.md                 # ← 每次切换市场只需改这一个文件
├── README.md                        # 英文文档
├── README_zh.md                     # 中文文档（本文件）
├── .gitignore
├── .claude/
│   └── agents/
│       ├── orchestrator.md          # 协调者：路由 + 任务分解
│       ├── materials-strategist.md  # 材料策略 + 质量评级
│       ├── web-researcher.md        # 纯执行层：抓取 + PDF转换
│       ├── analyst.md               # 市场分析：insight + 假设 + 投资人问答
│       ├── evidence-auditor.md      # 证据审计
│       └── writer.md                # 结构化报告输出
│
├── raw_materials/                   # [gitignored] 原始PDF和提取文本
│   └── {公司}/
│       ├── pdfs/                    # 下载的PDF文件
│       └── md/                      # pdftotext转换后的文本（analyst唯一读取源）
│
├── material_status.md               # [gitignored] 运行时状态（自动维护）
└── output/                          # [gitignored] 分析报告输出
    ├── analyst_report_v1.md
    ├── audit_report_v1.md
    ├── final_report.md
    └── qa_1.md                      # Q&A追问输出
```

---

## Agent 职责一览

| Agent | 模型 | 职责 | 可用工具 |
|-------|------|------|---------|
| orchestrator | sonnet | 接收问题、分解任务、路由、维护状态表 | Read, Write, Bash, Agent |
| materials-strategist | sonnet | 制定搜索策略、对材料质量评级（★1–5） | Read, Write, Bash |
| web-researcher | haiku | 执行搜索和抓取、PDF转文本 | WebFetch, WebSearch, Write, Read |
| analyst | opus | 三段式分析（insight → 假设 → 投资人问答） | Read, Write |
| evidence-auditor | sonnet | 验证每条推断的材料支撑 | Read, Write |
| writer | sonnet | 生成最终可读报告 | Read, Write |

---

## 材料质量评级标准

| 等级 | 来源类型 | 是否可用于推断 |
|------|---------|--------------|
| ★★★★★ | 官方财报原文、Q&A PDF、SEC filings | ✓ 最高置信度 |
| ★★★★☆ | 官方决算短信、官方新闻稿 | ✓ |
| ★★★☆☆ | 专业媒体、分析师报告 | ✓（需标注"非客户原声"）|
| ★★☆☆☆ | 普通新闻报道 | 仅用于背景参考 |
| ★☆☆☆☆ | 匿名评价、招聘网站 | ✗ 不可用于推断 |

analyst 只使用 ★★★ 及以上的材料做推断。

---

## 分析报告结构

每份 `analyst_report_v{N}.md` 包含三个部分：

1. **Unspoken Insight** — 市场里每个成功玩家都明白、但客户从不大声说出来的隐性逻辑
2. **三个核心假设 + 证伪条件** — 每个假设标注支撑材料来源，并说明被证伪所需的条件
3. **投资人5问** — 挑战者投资人评估新进入者能否在此市场胜出的五个问题，以及基于现有材料能回答到的程度

所有推断使用统一证据标注格式：
```
[文件名, p.XX, ★N JP]    ← 本地视角材料
[文件名, p.XX, ★N GL]    ← 全球视角材料
[推断，无直接证据]         ← 无材料支撑时必须标注
```

---

## 报告交付后的追问流程

`final_report.md` 存在时，追问进入轻量 Q&A 流程，不重启完整分析链：

| 追问类型 | 路由 | 输出 |
|---------|------|------|
| 概念解释 | orchestrator 直接回答 | 对话回复 |
| 证据溯源（"这个数字从哪里来？"）| evidence-auditor | `output/qa_{N}.md` |
| 深度追问（"有更具体的竞争案例吗？"）| analyst（Q&A模式）| `output/qa_{N}.md` |
| 需要新材料 | 询问用户确认后 → web-researcher | 补充抓取 |
| 格式调整 | writer | 更新报告 |

---

## 切换市场示例

只改 `market_config.md`，其余所有 agent 自动适应：

```yaml
# 从日本SIer切换到中国新能源
market_name: "中国新能源"
local_perspective_label: "CN"
target_companies:
  - 比亚迪
  - 宁德时代
  - 理想汽车
primary_sources:
  - "上市公司年报/半年报（A股/港股官方披露）"
  - "投资者说明会纪要（PDF）"
secondary_sources:
  - "财新、36kr等专业媒体"
  - "中金、高盛研究报告"
non_listed_companies: []
structural_data_gaps: []
```

---

## License

MIT
