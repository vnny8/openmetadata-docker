 #!/bin/bash

echo "🛑 Encerrando ambiente do TCC..."

# 1. Desconecta o banco de estudo da rede tcc-network
sudo docker network disconnect -f tcc-network postgres-tcc 2>/dev/null || true


# 2. Para e remove o container do banco individual
sudo docker rm -f postgres-tcc 2>/dev/null || true

# 3. Desce os containers do OpenMetadata (ES, Server, Ingestion)
cd ~/openmetadata-docker
sudo docker compose -f docker-compose-postgres.yml down

# 4. Limpeza de redes órfãs 
sudo docker network prune -f

echo "✅ Ambiente do OpenMetadata e Banco Postgres-TCC desligados." 



