# Execution Domain

## 定义

Execution 是 Cortex 中的“执行层”，用于存储**所有实践、项目经验和可执行资产**。

这些内容强调：
- 可运行
- 可复现
- 与具体环境相关

---

## 子分类

### 1. projects
项目实践

结构：

project-name/
├── README.md
├── notes/
├── scripts/
├── configs/

内容包括：
- 项目理解
- 使用方法
- 问题记录

---

### 2. experiments
临时实验

特点：
- 短生命周期
- 可失败
- 可删除或归档

---

### 3. scripts
脚本库（核心资产）

分类建议：
- install/
- run/
- debug/

要求：
- 可直接执行
- 不依赖手动步骤

---

### 4. environments
环境复现

内容：
- 安装脚本
- Dockerfile
- 配置文件

目标：
“一键重建环境”

---

### 5. playbooks
操作流程（经验沉淀）

示例：
- 如何调试 timing
- 如何跑某个 flow

特点：
- 半结构化
- 强经验导向

---

## 与 Knowledge 的关系

Execution 必须引用 Knowledge：

示例：

- [[sta-setup-analysis]]

Knowledge 可以反向引用 Execution：

- [[openroad-timing-debug]]

---

## 核心原则

1. 可执行优先
   文档不如脚本

2. 可复现
   所有环境必须能重建

3. 项目隔离
   不同项目互不污染

4. 从实践中抽象知识
   Execution → Knowledge
