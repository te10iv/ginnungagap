#!/bin/bash
# ==========================================
# User Data Template for Web Servers
# ==========================================

set -e

# Variables from Terraform
SERVER_NUMBER="${server_number}"
PROJECT_NAME="${project_name}"
ENVIRONMENT="${environment}"

# Log output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "========================================="
echo "User Data Script Start: $(date)"
echo "Server Number: $SERVER_NUMBER"
echo "Project: $PROJECT_NAME"
echo "Environment: $ENVIRONMENT"
echo "========================================="

# System Update
echo "Updating system packages..."
yum update -y

# Install Apache
echo "Installing Apache..."
yum install -y httpd mod_ssl

# Enable and start Apache
systemctl enable httpd
systemctl start httpd

# Create index.html
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$PROJECT_NAME - Web Server $SERVER_NUMBER</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            max-width: 600px;
            text-align: center;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
        }
        .info {
            background: #f5f5f5;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
            text-align: left;
        }
        .info-item {
            margin: 10px 0;
            display: flex;
            justify-content: space-between;
        }
        .label {
            font-weight: bold;
            color: #555;
        }
        .value {
            color: #667eea;
        }
        .badge {
            display: inline-block;
            background: #4caf50;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Web Server $SERVER_NUMBER</h1>
        <div class="badge">✓ Apache Running</div>
        
        <div class="info">
            <div class="info-item">
                <span class="label">Project:</span>
                <span class="value">$PROJECT_NAME</span>
            </div>
            <div class="info-item">
                <span class="label">Environment:</span>
                <span class="value">$ENVIRONMENT</span>
            </div>
            <div class="info-item">
                <span class="label">Server:</span>
                <span class="value">#$SERVER_NUMBER</span>
            </div>
            <div class="info-item">
                <span class="label">Hostname:</span>
                <span class="value" id="hostname"></span>
            </div>
            <div class="info-item">
                <span class="label">Private IP:</span>
                <span class="value" id="ip"></span>
            </div>
            <div class="info-item">
                <span class="label">AZ:</span>
                <span class="value" id="az"></span>
            </div>
        </div>
        
        <p style="color: #666; margin-top: 20px;">
            Managed by Terraform
        </p>
    </div>
    
    <script>
        // Get hostname
        document.getElementById('hostname').textContent = window.location.hostname;
        
        // Fetch instance metadata (IMDSv2)
        async function fetchMetadata() {
            try {
                // Get token
                const token = await fetch('http://169.254.169.254/latest/api/token', {
                    method: 'PUT',
                    headers: {'X-aws-ec2-metadata-token-ttl-seconds': '21600'}
                }).then(r => r.text());
                
                const headers = {'X-aws-ec2-metadata-token': token};
                
                // Get metadata
                const ip = await fetch('http://169.254.169.254/latest/meta-data/local-ipv4', {headers}).then(r => r.text());
                const az = await fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone', {headers}).then(r => r.text());
                
                document.getElementById('ip').textContent = ip;
                document.getElementById('az').textContent = az;
            } catch (e) {
                console.error('Failed to fetch metadata:', e);
            }
        }
        
        fetchMetadata();
    </script>
</body>
</html>
EOF

# Create health check endpoint
echo "OK" > /var/www/html/health.html

# Firewall configuration
echo "Configuring firewall..."
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

echo "========================================="
echo "User Data Script Complete: $(date)"
echo "========================================="
