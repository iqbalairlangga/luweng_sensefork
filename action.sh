#!/system/bin/sh
# LuwengSense Pro - WebUI Launcher

MODDIR=${0%/*}
PORT=8080

# Kill existing server
pkill -f "busybox httpd" 2>/dev/null
pkill -f "python.*http.server" 2>/dev/null
sleep 1

# Check for busybox httpd
if command -v busybox >/dev/null 2>&1; then
    busybox httpd -p $PORT -h "$MODDIR/webroot" &
    echo "Server started on port $PORT (busybox)"
elif command -v python3 >/dev/null 2>&1; then
    cd "$MODDIR/webroot" && python3 -m http.server $PORT &
    echo "Server started on port $PORT (python)"
elif command -v python >/dev/null 2>&1; then
    cd "$MODDIR/webroot" && python -m SimpleHTTPServer $PORT &
    echo "Server started on port $PORT (python2)"
else
    echo "No HTTP server available"
    exit 1
fi

sleep 1

# Open in browser
am start -a android.intent.action.VIEW -d "http://127.0.0.1:$PORT" 2>/dev/null

echo "WebUI: http://127.0.0.1:$PORT"
