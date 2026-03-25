# Meta Domain

## 定义

Meta 是 Cortex 的“系统层”，用于定义**规则、结构和约束**，而不是存储具体知识或项目内容。

它的作用是：
- 维持系统一致性
- 降低混乱
- 支持自动化（脚本 / 校验 / 生成）

---

## 包含内容

### 1. schema
定义数据结构规范

例如：
- note 的字段结构
- project 的组织方式

---

### 2. tags
标签系统定义

示例：

timing:
  domain: digital-ic

eda:
  domain: tools

---

### 3. conventions
命名与写作规范

包括：
- 文件命名规则
- link 规范
- 目录约定

---

### 4. templates
模板文件

示例：
- note 模板
- project 模板
- script 模板

---

## 设计原则

1. 不存业务内容  
   ❌ 不写知识  
   ❌ 不写项目记录  

2. 只定义规则  
   ✅ 结构  
   ✅ 约束  
   ✅ 标准  

3. 可被程序读取  
   - YAML / JSON 优先  
   - 避免随意格式  

---

## 示例

一个标准 note 结构：

---
type: concept
tags: [timing]
---

---

## 核心价值

Meta 决定 Cortex 是否：

- 可扩展
- 可维护
- 可自动化

---

## 典型误用（必须避免）

❌ 在 meta 中写笔记  
❌ 把 meta 当作文档仓库  
❌ 不维护 schema 导致结构漂移  

---

## 总结

Meta 是 Cortex 的“操作系统”，而不是数据本身。
