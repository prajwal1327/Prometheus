#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Variables
PROMETHEUS_VERSION="2.44.0"

# Install Prometheus
echo "Installing Prometheus..."
wget https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
tar -xvf prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo mv prometheus-$PROMETHEUS_VERSION.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-$PROMETHEUS_VERSION.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-$PROMETHEUS_VERSION.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-$PROMETHEUS_VERSION.linux-amd64/console_libraries /etc/prometheus
sudo cp prometheus-$PROMETHEUS_VERSION.linux-amd64/prometheus.yml /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

# Create Prometheus service file
echo "Creating Prometheus service file..."
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file /etc/prometheus/prometheus.yml \\
    --storage.tsdb.path /var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Start and enable Prometheus service
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Clean up
rm -rf prometheus-$PROMETHEUS_VERSION.linux-amd64*
echo "Prometheus installation completed."

# Install Grafana
echo "Installing Grafana..."
sudo apt-get install -y software-properties-common
sudo apt-get update

# Add Grafana GPG key
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://packages.grafana.com/gpg.key | sudo tee /usr/share/keyrings/grafana-archive-keyring.gpg

# Add Grafana repository
echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt-get update
sudo apt-get install -y grafana

# Start and enable Grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

echo "Grafana installation completed."

# Display completion message
echo "Installation of Prometheus and Grafana is complete."
echo "Access Prometheus at http://<your_server_ip>:9090"
echo "Access Grafana at http://<your_server_ip>:3000"
echo "Default Grafana login: admin/admin"
