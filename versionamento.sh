#!/bin/bash

echo "Executando alteração estrutural para causar mudança Major..."

# Comando que adiciona a coluna de observação conforme descrito no TCC
sudo docker exec -it postgres-tcc psql -U admin -d db_projeto -c "ALTER TABLE public.base_candidato ADD COLUMN observacao_tcc VARCHAR(255);"

echo "Coluna adicionada. Mudança Major concluída!"
