#!/bin/bash

echo "🛑 Encerrando ambiente do TCC com segurança..."

# 1. Desconecta o banco de estudo da rede tcc-network
# Usamos o nome que você criou manualmente para evitar travar a rede
sudo docker network disconnect -f tcc-network postgres-tcc 2>/dev/null || true

# 2. Para e remove o container do banco individual
# Como você usa volumes nomeados (pgdata_tcc), os dados NÃO serão apagados aqui
sudo docker rm -f postgres-tcc 2>/dev/null || true

# 3. Desce os containers do OpenMetadata (ES, Server, Ingestion)
cd ~/openmetadata-docker
sudo docker compose -f docker-compose-postgres.yml down

# 4. Limpeza de redes órfãs (O substituto moderno para o passo do Snap)
sudo docker network prune -f

echo "✅ Ambiente do OpenMetadata e banco Postgres-TCC desligados."
