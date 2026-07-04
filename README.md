# Termux 安装 Kali Nethunter (Rootless)

在 Android Termux 上一键安装 Kali Nethunter，无需 Root。

> 原始项目来自 [Hax4us/Nethunter-In-Termux](https://github.com/Hax4us/Nethunter-In-Termux)，本项目修复了若干兼容性和安全问题。

## 一键安装

```bash
pkg update && pkg upgrade -y && pkg install git -y && git clone https://github.com/lutherping/termux-install-kali.git && cd termux-install-kali/AutoInstallKali && chmod +x install-kali-for-termux env.sh && ./install-kali-for-termux
```

## 使用方法

```bash
kali        # 以 kali 用户登录
kali -r     # 以 root 用户登录
```

## 特性

- 支持 arm64 / armhf 架构
- 可选 full / minimal / nano 三种 Chroot 版本
- HTTPS 下载 + SHA256 完整性校验
- 自动配置 sudo、DNS、VNC

## 修复记录

| 版本 | 修复内容 |
|------|----------|
| 2026-07-04 | HTTP → HTTPS 下载 |
| 2026-07-04 | 修复 `/dev/shm` 挂载路径错误 |
| 2026-07-04 | 修复 `env.sh` 中 `startkali` → `kali` 命令名不匹配 |
| 2026-07-04 | SHA512 校验（404）→ SHA256SUMS |
| 2026-07-04 | axel 下载器 → wget 优先（兼容性更好） |
| 2026-07-04 | 消除硬编码路径，改用 `DESTINATION` 变量 |
