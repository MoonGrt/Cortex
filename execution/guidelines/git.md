---
type: [note]
tags: [git]
---

**常用命令**

```
git submodule update --init --recursive --remote
```


```
git init
git remote add origin https://github.com/xxx/xxx.git
```

# GitHub 使用指南

## 一、Git 下载与 SSH 配置

请参考官网或教程完成 Git 的安装与 SSH 配置。

---

## 二、Git 用户信息配置

```bash
git config user.name "MoonGrt"
git config user.email "1561145394@qq.com"
```

---

## 三、Git Bash 基本操作

### 教程参考：

[Git Bash 教程](https://blog.csdn.net/weixin_43629813/article/details/113824388)

### 基本命令：

1. 初始化 Git 仓库：

   ```bash
   git init
   ```

2. 添加文件到暂存区：

   ```bash
   git add README.md
   git add .
   ```

3. 提交文件到仓库：

   ```bash
   git commit -m "提交说明"
   ```

4. 关联远程仓库：

   ```bash
   git remote add origin https://github.com/xxx/xxx.git
   ```

5. 推送到远程仓库：

   ```bash
   git push -u origin master
   ```

   > 说明：首次推送需加 `-u`，后续可简化为：

   ```bash
   git push origin master
   ```

   > 强制推送（覆盖远程）：

   ```bash
   git push -f origin master
   ```

### 上传分支项目：

教程参考：[上传分支项目](https://blog.csdn.net/qq_27437967/article/details/71189571)

```bash
git init
git add .
git commit -m "test"
git branch test             # 创建分支
git checkout test           # 切换分支
git remote add origin https://github.com/xxx/xxx.git
git push origin test
```

---

## 四、常见问题与避坑指南

1. **远程仓库已初始化含 README 报错：**

   报错信息：

   ```
   failed to push some refs to https://github.com/…git
   ```

   解决方案：

   ```bash
   git pull --rebase origin master
   ```

2. **上传文件不能超过 100MB。**

3. **上传大批量文件超时处理建议：**

   将待上传内容集中复制至一个 `temp` 文件夹中，然后使用 Git Bash 逐步上传。注意：连续提交会覆盖前一次。

---

## 五、其他常用命令

```bash
# 删除本地分支
git branch -d <branch-name>

# 删除远程分支
git push origin --delete <branch-name>

# 查看用户名
git config user.name

# 查看邮箱
git config user.email

# 查看全局配置
git config --global --list

# 查看当前仓库配置
git config --local --list
```

---

## 六、Git 忽略文件设置（.gitignore）

1. 创建或编辑项目根目录下的 `.gitignore` 文件。
2. 添加需忽略的文件或文件夹规则。
3. 如果已经被跟踪，使用以下命令停止跟踪：

   ```bash
   git rm --cached <文件或文件夹>
   ```

---

## 七、Git 设置相关

### LF 与 CRLF 提示修复：

```bash
# 提交时转换为 LF，检出时转换为 CRLF
git config --global core.autocrlf true
```

---

## 八、仓库清理

```bash
# 查看 Git 对象大小
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sed -n 's/^blob //p' | sort -k2 -nr | head -n 20
# 删除指定路径下的所有文件及提交记录
python -m git_filter_repo --path "xx/xxx" --invert-paths --force
```

## 九、Git 上传失败处理

### 方法一：取消代理设置

```bash
git config --global --unset http.proxy
git config --global --unset https.proxy
```

---


# ✅ Git Commit 提交规范

```text
<type>(<scope>): <subject>
```

### 一、常见 `type` 类型说明：

| 类型       | 含义描述             |
| -------- | ---------------- |
| feat     | 新功能、新特性          |
| fix      | 修复 bug           |
| docs     | 文档变更             |
| style    | 代码格式（不影响功能，例如空格） |
| refactor | 代码重构（非功能修改）      |
| perf     | 性能优化             |
| test     | 添加或修改测试          |
| chore    | 构建过程或辅助工具的变动     |
| revert   | 回滚 commit        |
| build    | 打包相关，如修改构建配置     |
| ci       | 持续集成相关配置         |

---

### 二、字段说明

* `<type>`：提交类型（如 feat、fix 等）
* `<scope>`：可选，说明 commit 影响范围（如模块、页面、组件等）
* `<subject>`：简短精炼的描述，建议不超过 50 字符

---

### 三、示例

```bash
feat(login): 添加用户登录功能
fix(api): 修复获取用户信息接口错误
docs(readme): 更新项目说明文档
style: 调整缩进格式、删除多余空行
refactor(auth): 重构权限校验逻辑
test: 增加用户登录模块单元测试
chore: 更新依赖包版本
```
