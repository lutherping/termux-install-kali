#!/data/data/com.termux/files/usr/bin/bash
# 安装后环境配置脚本
# 修复: startkali -> kali, 使用 DESTINATION 变量消除硬编码路径
################################################################################

DESTINATION="${DESTINATION:-$HOME/kali-arm64}"
SETARCH="${SETARCH:-arm64}"

fix_profile() {
    local profile="${DESTINATION}/root/.bash_profile"
    if [ -f "$profile" ]; then
        sed -i '/if/,/fi/d' "$profile"
    fi
}

fix_sudo() {
    chmod +s "${DESTINATION}/usr/bin/sudo" 2>/dev/null || :
    chmod +s "${DESTINATION}/usr/bin/su" 2>/dev/null || :
    mkdir -p "${DESTINATION}/etc/sudoers.d"
    echo "kali    ALL=(ALL:ALL) ALL" > "${DESTINATION}/etc/sudoers.d/kali"
    echo "Set disable_coredump false" > "${DESTINATION}/etc/sudo.conf"
}

fix_uid() {
    GID=$(id -g)
    kali -r usermod -u "$UID" kali 2>/dev/null || :
    kali -r groupmod -g "$GID" kali 2>/dev/null || :
}

create_xsession_handler() {
    if [ "$SETARCH" = "arm64" ]; then
        LIBGCCPATH="/usr/lib/aarch64-linux-gnu"
    else
        LIBGCCPATH="/usr/lib/arm-linux-gnueabihf"
    fi

    local VNC_WRAPPER="${DESTINATION}/usr/bin/vnc"
    cat > "$VNC_WRAPPER" <<- 'EOF'
#!/bin/bash

vnc_start() {
    if [ ! -f ~/.vnc/passwd ]; then
        vnc_passwd
    fi
    USR=$(whoami)
    if [ "$USR" = "root" ]; then
        SCR=:1
    else
        SCR=:2
    fi
    export USER=$USR; LD_PRELOAD=LIBGCCPATH_PLACEHOLDER/libgcc_s.so.1 nohup vncserver $SCR >/dev/null 2>&1 </dev/null
}

vnc_stop() {
    vncserver -kill :1 2>/dev/null
    vncserver -kill :2 2>/dev/null
    return $?
}

vnc_passwd() {
    vncpasswd
    return $?
}

vnc_status() {
    session_list=$(vncserver -list 2>/dev/null)
    if echo "$session_list" | grep -q "590"; then
        echo "$session_list"
    else
        echo "没有运行中的 VNC 会话"
        echo "使用 'vnc start' 启动新会话"
    fi
}

vnc_kill() {
    pkill Xtigervnc 2>/dev/null || :
    return $?
}

case "$1" in
    start)  vnc_start ;;
    stop)   vnc_stop ;;
    status) vnc_status ;;
    kill)   vnc_kill ;;
    *)
        echo "用法: vnc {start|stop|status|kill}"
        ;;
esac
EOF
    # 替换占位符为实际的 LIBGCCPATH
    sed -i "s|LIBGCCPATH_PLACEHOLDER|${LIBGCCPATH}|g" "$VNC_WRAPPER"
    chmod +x "$VNC_WRAPPER"
}

## Main
fix_profile
fix_sudo
fix_uid
create_xsession_handler

echo "  Kali 环境配置完成。"
