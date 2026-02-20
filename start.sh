#!/bin/bash

echo "🚀 Iniciando ambiente do TCC (Versão Docker Nativo)..."

# 1. Configurações de Sistema e Memória
# Para o Postgres local do Ubuntu para liberar a porta 5432
sudo systemctl stop postgresql 2>/dev/null || true
sudo sysctl -w vm.max_map_count=262144
sudo chown $USER /var/run/docker.sock

# 2. Garantir que a rede tcc-network existe
if [ ! "$(sudo docker network ls -q -f name=tcc-network)" ]; then
    echo "🌐 Criando rede tcc-network..."
    sudo docker network create tcc-network
fi

# 3. Iniciar ou Criar o banco de estudo (postgres-tcc)
# Se o container não existir, ele faz o 'run' usando o volume persistente
if [ ! "$(sudo docker ps -a -q -f name=postgres-tcc)" ]; then
    echo "🆕 Container postgres-tcc não encontrado. Criando com volume pgdata_tcc..."
    sudo docker run -d \
      --name postgres-tcc \
      --network tcc-network \
      -e POSTGRES_USER=admin \
      -e POSTGRES_PASSWORD=tcc_pass \
      -e POSTGRES_DB=db_projeto \
      -p 5432:5432 \
      -v pgdata_tcc:/var/lib/postgresql/data \
      postgres:16
else
    echo "📦 Iniciando container existente postgres-tcc..."
    sudo docker start postgres-tcc
fi

# 4. Sobe a infra do OpenMetadata via Compose
cd ~/openmetadata-docker
echo "🐘 Subindo infraestrutura do OpenMetadata..."
sudo docker compose -f docker-compose-postgres.yml up -d postgresql elasticsearch

# LOOP DE ESPERA pelo banco interno
for i in {1..30}; do
  STATUS=$(sudo docker inspect --format='{{.State.Health.Status}}' openmetadata_postgresql 2>/dev/null)
  if [ "$STATUS" == "healthy" ]; then
    echo "✅ Banco interno está saudável!"
    break
  fi
  echo "⏳ Aguardando banco interno ficar 'healthy'... ($i/30)"
  sleep 3
done

# 5. Sobe o restante dos serviços
echo "🐳 Subindo OpenMetadata e Ingestão..."
sudo docker compose -f docker-compose-postgres.yml up -d

# 6. Conecta o banco de estudo à rede do OpenMetadata
# Isso permite que o OpenMetadata 'enxergue' o seu postgres-tcc
sudo docker network connect openmetadata-docker_app_net postgres-tcc 2>/dev/null || true

echo "---"
echo "✅ Ambiente pronto! Seus dados foram preservados no volume pgdata_tcc."
echo "🔗 Acesse: http://localhost:8585"
