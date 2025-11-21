# Quick Start Guide

## Issue Resolution

The branding has been updated in all source files. If you're still seeing "Enterprise Payment Portal":

### 1. Clear Browser Cache
- **Chrome/Edge**: Ctrl+Shift+Delete (Windows) or Cmd+Shift+Delete (Mac)
- **Firefox**: Ctrl+Shift+Delete (Windows) or Cmd+Shift+Delete (Mac)
- Or use **Incognito/Private** mode

### 2. Hard Refresh
- **Windows**: Ctrl+F5 or Ctrl+Shift+R
- **Mac**: Cmd+Shift+R

### 3. Start Fresh Server
```bash
# Kill any running servers
pkill -f ruby
pkill -f java

# Start server (simple HTTP server)
cd server
ruby -run -e httpd . -p 3000 &

# Start client
cd ../client
mvn spring-boot:run
```

### 4. Verify Files Updated
All these files now show "Hermes Remittance Portal":
- ✅ `server/app/views/booking.html`
- ✅ `server/app/views/confirmation.html`
- ✅ `client/src/main/resources/templates/dashboard.html`
- ✅ `client/src/main/resources/static/index.html`

### 5. URLs to Test
- **Server**: http://localhost:3000/app/views/booking.html
- **Client**: http://localhost:8080

## If Still Not Working
1. Check browser developer tools (F12) for cached resources
2. Disable browser cache in developer tools
3. Use different browser
4. Restart your computer to clear all caches