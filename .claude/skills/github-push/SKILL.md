---
name: github-push
description: 把本地提交推送到 GitHub 远程仓库（或拉取更新）。当用户说"push"、"推送"、"提交并推送"、"发布到 GitHub"、"拉取更新"、"pull" 时触发。自动选择 SSH 或 HTTPS 凭据通道，全程不暴露 token。
---

# GitHub 推送 / 拉取助手

把本地提交安全推送到 `github.com/kaipingyang/CDISC_training`（或拉取远程更新）。

## 安全铁律（必须遵守）

1. **绝不读取 token 明文**：不得 `cat ~/.Renviron`、`echo $GITHUB_TOKEN` 或任何
   输出 token 值的命令。token 只通过**变量引用**（`${GITHUB_TOKEN}`）使用。
2. **命令文本不得包含 token**：所有命令写 `https://kaipingyang:${GITHUB_TOKEN}@...`
   形式（变量引用），不展开真实值。
3. **输出打码**：git/curl 的报错可能回显带凭据的 URL，必须用 sed 打码：
   `sed -E 's#(https://)[^@]*@#\1***@#g'`
4. **凭据存放位置**（本环境约定）：
   - SSH key：`~/.ssh/id_ed25519`（已注册到 GitHub，优先使用）
   - HTTPS token：`~/.Renviron` 的 `GITHUB_TOKEN`（**只做存在性检查**，不读值）
5. skill 文件与对话记录中不得出现任何真实凭据。

## 使用流程

### Step 1 — 前置检查

```bash
git status --short                 # 工作区干净？（有未提交改动先问用户是否提交）
git log --oneline origin/main..HEAD   # 是否有未推送提交（空 = 无需推送）
git remote -v                      # 确认远程地址
```

### Step 2 — 选择推送通道

**优先 SSH**（本环境 remote 已配置为 `ssh://git@ssh.github.com:443/...`）：

```bash
git push origin main
```

**HTTPS 备选**（SSH 失败时，token 从 `~/.Renviron` 加载，全程不暴露）：

```bash
set -a; source ~/.Renviron 2>/dev/null; set +a
[ -z "$GITHUB_TOKEN" ] && { echo "GITHUB_TOKEN 未找到"; exit 1; }
echo "token 已加载（值不显示，长度 ${#GITHUB_TOKEN} 字符）"   # 只报长度，不报值
git push "https://kaipingyang:${GITHUB_TOKEN}@github.com/kaipingyang/CDISC_training.git" main 2>&1 \
  | sed -E 's#(https://)[^@]*@#\1***@#g'
```

### Step 3 — 验证

```bash
git fetch origin
git log --oneline origin/main..HEAD   # 空 = 推送完整
```

## 故障排查

| 症状 | 原因 | 处理 |
|------|------|------|
| `Failed to connect to github.com port 443` | github.com 直连被干扰（本环境常见） | 确认 remote 是 SSH over 443（`ssh://git@ssh.github.com:443/...`），或临时用显式 SSH URL push |
| `Host key verification failed` | known_hosts 缺失 | `ssh-keyscan -p 443 ssh.github.com >> ~/.ssh/known_hosts` |
| `Permission denied (publickey)` | SSH key 未注册 | 用 token 调 API 注册：`POST /user/keys`（同样变量引用 + 打码） |
| 认证成功但推送被拒 | 分支保护/权限 | 检查仓库分支保护规则 |

## 输出规范

- 全程不得出现 token、密码、SSH 私钥内容
- 报告时只描述结果（"推送成功，x 个提交"），不含任何凭据细节
