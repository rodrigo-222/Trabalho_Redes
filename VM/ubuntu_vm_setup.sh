#!/bin/bash
# Setup para Ubuntu VMs (execute em CADA VM)

echo "🖥️ Configurando Ubuntu VM para gerar tráfego..."

# Atualiza sistema
sudo apt update

# Instala serviços básicos
echo "📦 Instalando serviços web..."
sudo apt install -y apache2 vsftpd openssh-server curl wget net-tools

# Configura Apache
echo "🌐 Configurando Apache..."
VM_IP=$(hostname -I | cut -d' ' -f1)
sudo systemctl start apache2
sudo systemctl enable apache2

# Cria página personalizada
sudo tee /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>VM $VM_IP</title></head>
<body>
  <h1>🖥️ Ubuntu VM</h1>
  <h2>IP: $VM_IP</h2>
  <p>Timestamp: $(date)</p>
  <p>Hostname: $(hostname)</p>
  <ul>
    <li><a href="/test.html">Página de Teste</a></li>
    <li><a href="/data.json">API Mock</a></li>
  </ul>
</body>
</html>
EOF

# Cria páginas de teste
sudo tee /var/www/html/test.html << EOF
<html><body>
<h1>Teste de Tráfego - $VM_IP</h1>
<p>Data: $(date)</p>
<p>Dados para gerar tráfego: $(seq 1 100 | tr '\n' ' ')</p>
</body></html>
EOF

sudo tee /var/www/html/data.json << EOF
{
  "vm_ip": "$VM_IP",
  "timestamp": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "status": "online",
  "test_data": [1,2,3,4,5,6,7,8,9,10]
}
EOF

# Configura FTP
echo "📁 Configurando FTP..."
sudo tee /etc/vsftpd.conf << EOF
listen=YES
local_enable=YES
write_enable=NO
anonymous_enable=YES
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_root=/var/ftp
no_anon_password=YES
EOF

# Cria diretório FTP
sudo mkdir -p /var/ftp
sudo tee /var/ftp/README.txt << EOF
FTP Server - VM $VM_IP
Data: $(date)
Arquivo de teste para monitoramento de tráfego
EOF

sudo chown -R ftp:ftp /var/ftp
sudo chmod -R 755 /var/ftp

# Inicia serviços
sudo systemctl restart vsftpd apache2 ssh
sudo systemctl enable vsftpd apache2 ssh

# Testa serviços
echo ""
echo "🧪 Testando serviços..."
echo -n "HTTP: "
curl -s -o /dev/null -w "%{http_code}" http://localhost && echo "✅ OK" || echo "❌ ERRO"

echo -n "FTP: "
timeout 3 nc -z localhost 21 && echo "✅ OK" || echo "❌ ERRO"

echo -n "SSH: "
timeout 3 nc -z localhost 22 && echo "✅ OK" || echo "❌ ERRO"

echo ""
echo "✅ VM $VM_IP configurada!"
echo "🌐 Serviços ativos:"
echo "   - HTTP: http://$VM_IP"
echo "   - FTP:  ftp://$VM_IP"
echo "   - SSH:  ssh user@$VM_IP"
