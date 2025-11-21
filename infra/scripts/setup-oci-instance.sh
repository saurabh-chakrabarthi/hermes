#!/bin/bash

echo "Setting up OCI instance with simple Ruby server"

# Update system
sudo apt update && sudo apt upgrade -y

# Install Ruby and basic tools (no complex dependencies)
sudo apt install -y ruby ruby-dev git curl

# Ensure app directory exists
sudo mkdir -p /home/ubuntu/payment-portal
sudo chown ubuntu:ubuntu /home/ubuntu/payment-portal

# Clone repo
cd /home/ubuntu
rm -rf payment-portal
git clone https://github.com/saurabh-chakrabarthi/hermes.git payment-portal
cd payment-portal/server

# Create a simple Ruby server (no gem dependencies)
cat > start.rb << 'EOF'
#!/usr/bin/env ruby

require 'webrick'
require 'json'

# Simple in-memory storage
@bookings = []

server = WEBrick::HTTPServer.new(
  Port: 9292,
  BindAddress: '0.0.0.0'
)

# Health endpoint
server.mount_proc '/health' do |req, res|
  res.status = 200
  res['Content-Type'] = 'application/json'
  res.body = '{"status":"ok"}'
end

# API endpoints
server.mount_proc '/api/bookings' do |req, res|
  res['Access-Control-Allow-Origin'] = '*'
  res['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
  res['Access-Control-Allow-Headers'] = 'Content-Type'
  
  if req.request_method == 'OPTIONS'
    res.status = 200
    return
  end
  
  if req.request_method == 'GET'
    res.status = 200
    res['Content-Type'] = 'application/json'
    res.body = JSON.generate(@bookings)
  elsif req.request_method == 'POST'
    begin
      data = JSON.parse(req.body)
      booking = {
        id: @bookings.length + 1,
        name: data['name'],
        email: data['email'],
        amount: data['amount'],
        created_at: Time.now.iso8601
      }
      @bookings << booking
      res.status = 201
      res['Content-Type'] = 'application/json'
      res.body = JSON.generate(booking)
    rescue => e
      res.status = 400
      res.body = "Error: #{e.message}"
    end
  end
end

# Serve static files
server.mount '/', WEBrick::HTTPServlet::FileHandler, 'public'

trap('INT') { server.shutdown }

puts "Server starting on http://129.213.125.13:9292"
server.start
EOF

chmod +x start.rb

# Create systemd service
sudo tee /etc/systemd/system/payment-server.service > /dev/null <<EOF
[Unit]
Description=Simple Payment Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/payment-portal/server
ExecStart=/usr/bin/ruby start.rb
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable payment-server
sudo systemctl restart payment-server

# Open firewall port
sudo ufw allow 9292

echo "Ruby: $(ruby -v)"

sleep 3
if sudo systemctl is-active --quiet payment-server; then
    echo "✅ Simple server running at http://129.213.125.13:9292"
    echo "Test: curl http://129.213.125.13:9292/health"
else
    echo "❌ Server failed:"
    sudo journalctl -u payment-server --no-pager -l
fi

echo ""
echo "Next steps:"
echo "1. Add your SSH private key to GitHub repository secrets as ORACLE_SSH_KEY"
echo "2. Push your code to trigger GitHub Actions deployment"