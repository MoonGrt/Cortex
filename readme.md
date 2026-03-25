# Cortex

Cortex 是一个基于 Git 的个人知识与执行系统，用于统一管理：

* 知识(你理解了什么)
* 思考(你在想什么)
* 实践(你做过什么)
* 环境(你如何复现)

它不是传统笔记工具，而是一个**工程化的知识仓库**，强调可链接、可执行、可复现。

---

## 核心理念

Cortex 的设计基于一个简单但严格的原则：

> 知识必须可连接，经验必须可复现

系统将你的内容分为两个核心域：

```
knowledge  ←→  execution
```

* Knowledge：长期有效的认知资产
* Execution：具体实践与可执行内容

二者通过链接形成闭环。

---

## 目录结构

```
cortex/
├── knowledge/        # 认知层(概念、课程、论文、想法)
│   ├── thoughts/
│   ├── concepts/
│   ├── courses/
│   ├── papers/
│   ├── notes/
│   └── maps/
│   └── knowledge.md
├── execution/        # 执行层(项目、脚本、环境)
│   ├── experiments/
│   ├── projects/
│   ├── sources/
│   │   ├── setup/
│   │   └── run/
│   └── execution.md
├── meta/             # 系统规则(schema / tags / template)
│   └── meta.md
├── inbox/            # 输入缓冲(快速记录)
│   └── inbox.md
└── README.md         # Cortex 系统说明
```

---

## 核心机制

### 1. 原子化知识

每个知识点一个文件：

```
knowledge/concepts/sta-setup-analysis.md
```

---

### 2. 双向链接

使用统一语法：

```
[[note-id]]
```

示例：

```
- [[sta-setup-analysis]]
- [[clock-skew]]
```

---

### 3. 知识与实践闭环

* 项目必须引用知识
* 知识可以回链实践

```
knowledge → execution → knowledge
```

---

### 4. 可执行优先

所有操作性内容应转化为脚本：

```
execution/scripts/install/install_openroad.sh
```

而不是仅写文档。

---

## 使用方式

### 记录知识

放入：

```
knowledge/concepts/
knowledge/papers/
knowledge/courses/
```

---

### 记录想法

放入：

```
knowledge/ideas/
```

---

### 做项目与实验

放入：

```
execution/projects/
execution/experiments/
```

---

### 编写脚本

放入：

```
execution/scripts/
```

---

### 快速记录(低成本输入)

放入：

```
inbox/
```

之后再整理到对应域。

---

## 工作流

```
inbox
  ↓
knowledge / execution
  ↓
scripts / projects
  ↓
沉淀回 knowledge
```

---

## 设计原则

1. 原子化
   一条知识一个文件

2. 去工具依赖
   使用 Markdown + Git

3. 可复现
   所有环境可以重建

4. 强连接
   知识之间必须有链接

5. 逐步演进
   从简单开始，逐步增强

---

## 适用人群

* 工程师(尤其是系统/芯片/软件工程)
* 需要长期积累技术知识的人
* 希望构建“可复现经验体系”的用户

---

## 最小开始方式

```bash
git clone <your-repo>
cd cortex
```

然后：

1. 写 1 条 concept
2. 写 1 条 idea
3. 跑 1 个项目
4. 写 1 个 install 脚本

---

## 长期目标

Cortex 最终应具备：

* 知识图谱(graph)
* 全文搜索
* 脚本化操作(CLI)
* 环境一键复现
* 可扩展到 AI(RAG / 本地问答)

---

## 总结

Cortex 的目标不是记录信息，而是构建：

> 一个可持续演进的认知与执行系统
