#!/bin/bash

set -e

echo "========================================="
echo "  OpenList + Cloudflared 一键部署脚本"
echo "========================================="

# ---------- 1. 下载并安装 Cloudflared ----------
echo "[1/5] 下载 Cloudflared ..."
wget https://github.com/cloudflare/cloudflared/releases/download/latest/cloudflared-linux-amd64
mv cloudflared-linux-amd64 /usr/bin/cloudflared
chmod +x /usr/bin/cloudflared
echo "  ✔ Cloudflared 安装完成"

# ---------- 2. 下载并安装 OpenList ----------
echo "[2/5] 下载 OpenList ..."
wget https://github.com/OpenListTeam/OpenList/releases/download/latest/openlist-linux-musl-amd64.tar.gz
tar -zxvf openlist-linux-musl-amd64.tar.gz
mv openlist /usr/bin/openlist
chmod +x /usr/bin/openlist
rm -f openlist-linux-musl-amd64.tar.gz
echo "  ✔ OpenList 安装完成"

# ---------- 3. 创建 OpenList 服务文件 ----------
echo "[3/5] 创建 OpenList 服务 ..."
cat > /etc/init.d/openlist << 'EOF'
#!/sbin/openrc-run

description="OpenList"

command="/usr/bin/openlist"
command_args="server"
pidfile="/run/openlist.pid"
command_background=true

depend() {
    need net
}
EOF
chmod +x /etc/init.d/openlist
echo "  ✔ OpenList 服务创建完成"

# ---------- 4. 创建 Cloudflared 服务文件 ----------
echo "[4/5] 创建 Cloudflared 服务 ..."
cat > /etc/init.d/cloudflared << 'EOF'
#!/sbin/openrc-run

description="Cloudflare Tunnel"

supervisor=supervise-daemon
command="/usr/bin/cloudflared"
command_args="tunnel run"
pidfile="/run/cloudflared.pid"

depend() {
    need net
}
EOF
chmod +x /etc/init.d/cloudflared
echo "  ✔ Cloudflared 服务创建完成"

# ---------- 5. 添加到开机启动 ----------
echo "[5/5] 添加服务到默认运行级别 ..."
rc-update add openlist default
rc-update add cloudflared default
echo "  ✔ 服务已添加到开机启动"

echo ""
echo "========================================="
echo "  部署完成！常用命令："
echo "-----------------------------------------"
echo "  启动服务："
echo "    rc-service openlist start"
echo "    rc-service cloudflared start"
echo ""
echo "  停止服务："
echo "    rc-service openlist stop"
echo "    rc-service cloudflared stop"
echo ""
echo "  查看状态："
echo "    rc-service openlist status"
echo "    rc-service cloudflared status"
echo "========================================="
