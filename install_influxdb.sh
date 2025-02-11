#!/bin/bash

# Definir cores para saída do terminal
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

echo -e "${GREEN}🔹 Atualizando pacotes do sistema...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${GREEN}🔹 Baixando e instalando o InfluxDB 2.0 Community Edition...${NC}"
wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.1-linux-amd64.tar.gz

echo -e "${GREEN}🔹 Extraindo arquivos...${NC}"
tar xvf influxdb2-2.7.1-linux-amd64.tar.gz

echo -e "${GREEN}🔹 Movendo arquivos para /usr/local/bin${NC}"
sudo mv influxdb2-2.7.1-linux-amd64/influx /usr/local/bin/
sudo mv influxdb2-2.7.1-linux-amd64/influxd /usr/local/bin/

echo -e "${GREEN}🔹 Criando usuário e diretórios para InfluxDB...${NC}"
sudo useradd --system --home /var/lib/influxdb2 --shell /bin/false influxdb
sudo mkdir -p /var/lib/influxdb2
sudo mkdir -p /etc/influxdb2
sudo chown -R influxdb:influxdb /var/lib/influxdb2
sudo chown -R influxdb:influxdb /etc/influxdb2

echo -e "${GREEN}🔹 Criando serviço systemd para InfluxDB...${NC}"
cat <<EOF | sudo tee /etc/systemd/system/influxdb.service
[Unit]
Description=InfluxDB 2.0 Service
After=network.target

[Service]
User=influxdb
Group=influxdb
ExecStart=/usr/local/bin/influxd --bolt-path=/var/lib/influxdb2/influxd.bolt --engine-path=/var/lib/influxdb2/engine --config-path=/etc/influxdb2/config.yml
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}🔹 Recarregando serviços e iniciando InfluxDB...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable influxdb
sudo systemctl start influxdb

echo -e "${GREEN}✅ InfluxDB instalado e rodando!${NC}"
echo -e "🔹 Para verificar o status: ${GREEN}sudo systemctl status influxdb${NC}"
echo -e "🔹 Para acessar a interface web: ${GREEN}http://localhost:8086${NC}"

echo -e "${GREEN}🔹 Criando um banco de dados para JMeter...${NC}"
influx setup --host http://localhost:8086 \
  --username admin \
  --password admin123 \
  --org jmeter-org \
  --bucket jmeter-bucket \
  --retention 30d \
  --force

echo -e "${GREEN}✅ Configuração do banco de dados finalizada!${NC}"
