# Engineering Discipline

[English](README.md) | [한국어](README.ko.md)

面向 AI 编程代理的工程规范技能。支持 Claude Code、Gemini CLI、OpenCode、Codex 和 Cursor。

## 工作原理

技能以链式方式连接，从模糊的请求到经过验证的实现：

```
用户请求
    |
clarification ─── 解决歧义，探索代码库
    |
    |── 复杂度评估（自动路由）
    |       |
    |       |── 简单（评分 5-8）
    |       |       |
    |       |       plan-crafting ─── 创建可执行计划
    |       |           |
    |       |       run-plan ─── worker-validator 执行循环
    |       |           |
    |       |       review-work ─── 信息隔离验证
    |       |
    |       |── 复杂（评分 9-15）
    |               |
    |           milestone-planning ─── 5 个并行审查者 + 综合
    |               |
    |           long-run ─── 多日编排器
    |               |── M1: plan-crafting → run-plan → review-work → 检查点
    |               |── M2: plan-crafting → run-plan → review-work → 检查点
    |               |── ...
    |
    |── simplify ─── 实现后代码质量检查
    |── systematic-debugging ─── 复现优先的 bug 修复
    |── rob-pike ─── 基于度量的优化
```

无需记忆这些。每个技能会根据触发短语和上下文自动激活。

## 技能

### 工作流技能（链式连接）

#### Clarification（澄清）

通过迭代式问答 + 并行代码库探索，将模糊请求收窄为明确的工作范围。输出带有自动复杂度路由的 Context Brief。

**触发条件：** "我想要..."、"我需要..."、"让我们构建..."，或任何范围不立即清晰的请求。

#### Plan Crafting（计划制定）

从明确的范围创建可执行的多步骤实现计划。每一步都包含实际代码——不允许占位符。

**触发条件：** "制定计划"、"创建计划"，或 clarification 以简单（Simple）判定完成后。

#### Run Plan（执行计划）

使用 worker-validator 对执行计划。Worker 负责实现，Validator 在完全不了解 Worker 方法的情况下独立验证。

**触发条件：** "执行计划"、"运行计划"，或 plan-crafting 完成后。

#### Review Work（审查工作）

信息隔离的执行后验证。仅读取计划文档和代码库——不接收执行日志或 worker 输出。

**触发条件：** "审查工作"、"验证实现"，或 run-plan 完成后。

#### Simplify（简化）

通过三个并行代理（复用、质量、效率）审查更改的代码，然后修复发现的问题。

**触发条件：** "simplify"、"清理代码"、"审查更改"。

### 长期运行

用于跨越多天的复杂任务。

#### Milestone Planning（里程碑规划，Ultraplan）

并行生成 5 个独立的审查代理——可行性、架构、风险、依赖、用户价值——然后综合其发现，生成优化的里程碑依赖 DAG。

**触发条件：** "规划里程碑"、"分解为里程碑"、"ultraplan"，或 clarification 给出复杂（Complex）判定（评分 9-15）后。

**主要特性：**
- 信息隔离的 5 个并行审查者（无交叉污染）
- 带冲突解决日志的综合代理
- 综合后独立 DAG 验证
- 里程碑数量守卫（超过 7 个警告，超过 10 个需要批准）

#### Long Run Harness（长期运行治具）

编排多天执行。每个里程碑经过 plan-crafting、run-plan、review-work，支持检查点/恢复。

**触发条件：** "long run"、"开始长期运行"、"执行里程碑"。

**主要特性：**
- 每次阶段转换后状态持久化到磁盘（崩溃后可恢复）
- 重试升级：重新执行 → 重新规划 → 停止（带持久计数器）
- 通过 worktree 隔离实现并行里程碑
- 中断会话的恢复协议
- 与 Claude Code 内置重试对齐的速率限制处理
- 长对话的上下文窗口管理
- 执行中修正和里程碑添加程序

### 独立技能

#### Rob Pike's 5 Rules（Rob Pike 的 5 条规则）

防止过早优化并强制基于度量的开发的决策框架。

**触发条件：** "优化"、"慢"、"性能"、"瓶颈"、"加速"、"提速"、"太慢"

#### Systematic Debugging（系统化调试）

严格的调试工作流：复现优先、根因优先、失败测试优先。

**触发条件：** 任何 bug、测试失败或意外行为。

**参考指南：**
- [基于条件的等待](skills/systematic-debugging/condition-based-waiting.md) — 用可靠的条件轮询替代不稳定的超时
- [纵深防御验证](skills/systematic-debugging/defense-in-depth.md) — 在数据经过的每一层进行验证
- [根因追踪](skills/systematic-debugging/root-cause-tracing.md) — 通过调用链反向追踪找到原始触发器
- [污染者查找脚本](skills/systematic-debugging/find-polluter.sh) — 用二分法找到创建不需要的文件/状态的测试

## 快速开始

安装后，只需描述你想做什么：

- **"我想给 API 添加认证"** — 触发 clarification，根据复杂度路由到 plan-crafting 或 milestone-planning
- **"执行计划"** — 使用 worker-validator 验证执行计划
- **"这个测试不稳定"** — 触发 systematic-debugging
- **"API 很慢"** — 触发 rob-pike 度量优先工作流
- **"simplify"** — 审查最近更改的复用性、质量和效率
- **"long run"** — 启动带检查点的多日里程碑执行

## 安装

### Claude Code

```
/plugin marketplace add tmdgusya/engineering-discipline
/plugin install engineering-discipline
```

### Gemini CLI

```bash
gemini extensions install https://github.com/tmdgusya/engineering-discipline
```

### Cursor

从插件市场安装，或：

```text
/add-plugin engineering-discipline
```

### Codex

```bash
npx skills add tmdgusya/engineering-discipline
```

或全局安装（在所有项目中可用）：

```bash
npx skills add tmdgusya/engineering-discipline -g
```

详情参见 [Codex 安装指南](.codex/INSTALL.md)。

### OpenCode

添加到你的 `opencode.json`：

```json
{
  "plugin": ["engineering-discipline@git+https://github.com/tmdgusya/engineering-discipline.git"]
}
```

详情参见 [OpenCode 安装指南](.opencode/INSTALL.md)。

## 验证安装

启动新会话并提及性能问题或 bug。相关技能应自动激活。

## 市场

此插件已在 Claude Code 插件市场上架。

- **类别：** engineering
- **标签：** optimization, debugging, engineering, discipline, rob-pike, systematic, planning, long-running

### 从市场安装

```
/plugin marketplace add tmdgusya/engineering-discipline
/plugin install engineering-discipline
```

### 发布更新

更新 `.claude-plugin/marketplace.json` 中的版本并推送到仓库。市场条目从该文件拉取元数据。

## 许可证

MIT
