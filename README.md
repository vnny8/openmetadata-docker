# Governança e Rastreabilidade de Dados com OpenMetadata

Repositório do Trabalho de Conclusão de Curso (TCC) em Ciência da Computação/UFMT focado em governança, versionamento e linhagem de dados utilizando OpenMetadata e um banco operacional realista baseado em PostgreSQL.

## 🎯 Objetivos do Projeto
- **Data lineage ponta a ponta**: reconstruir o caminho do dado da origem (`base_candidato`) até o consumo financeiro (`boleto_boleto`).
- **Versionamento de metadados**: registrar mudanças estruturais relevantes (DDL) e seu impacto.
- **Observabilidade passiva**: monitorar saúde dos ativos sem intervir diretamente nas cargas transacionais.

## 🧱 Arquitetura e Componentes
- **OpenMetadata 1.11.6** (catálogo, governança, workflows de ingestão).
- **PostgreSQL 16** interno e externo (`postgres-tcc`) como banco de estudo.
- **Elasticsearch** para busca avançada.
- **Airflow/Ingestion Framework** embarcado no stack do OpenMetadata.
- **Scripts Bash e SQL** para provisionar dados, gerar linhagem e simular mudanças de esquema.

## 📦 Pré-requisitos
- Linux com Bash e privilégios `sudo` (os scripts gerenciam serviços locais).
- Docker Engine 24+ e Docker Compose v2 habilitado via `docker compose`.
- >= 4 CPUs e 8 GB RAM disponíveis para containers de banco + OpenMetadata.
- Porta `8585` livre para a UI do OpenMetadata e `5432` para o Postgres de estudo.

## 📁 Estrutura Principal
```
.
├── docker-compose-postgres.yml   # Stack OpenMetadata + dependências
├── start.sh / stop.sh            # Boot/teardown completo
├── gerarLinhagem.sh              # Carga de dados para evidenciar lineage
├── versionamento.sh              # Exemplo de mudança estrutural (DDL)
├── popular_banco.sql             # Dataset base (200 candidatos)
├── mais_dados.sql                # Dataset estendido (500+ candidatos)
├── mais arquivos *.sql           # Suporte a casos extras
└── docker-volume/db-data-postgres# Persistência dos volumes
```

## 🚀 Passo a Passo de Execução
1. Clone e entre no diretório:
   ```bash
   git clone https://github.com/vnny8/openmetadata-docker.git
   cd openmetadata-docker
   chmod +x *.sh
   ```
2. Suba todo o ambiente:
   ```bash
   ./start.sh
   ```
   O script:
   - Libera a porta `5432`, ajusta `vm.max_map_count` e garante acesso ao Docker socket.
   - Cria a rede `tcc-network`.
   - Provisiona (ou inicia) o container `postgres-tcc` com volume `pgdata_tcc`.
   - Sobe `postgresql` + `elasticsearch` do OpenMetadata e aguarda `healthy`.
   - Sobe o restante dos serviços (`openmetadata`, `ingestion`, etc.).
   - Conecta o `postgres-tcc` à rede do OpenMetadata para permitir ingestões.
3. Acesse a interface em `http://localhost:8585` e finalize o onboarding conforme necessário.

### Popular o Banco de Estudo
Após o ambiente estar pronto:
```bash
sudo docker exec -i postgres-tcc psql -U admin -d db_projeto < popular_banco.sql
sudo docker exec -i postgres-tcc psql -U admin -d db_projeto < mais_dados.sql
```
- `popular_banco.sql` cria campus, cursos, ofertas e 200 candidatos/inscrições.
- `mais_dados.sql` adiciona novos editais, candidatos (201-500) e +600 inscrições, reforçando cenários de versionamento.

### Demonstrar Linhagem Automatizada
```bash
./gerarLinhagem.sh
```
Esse script encadeia inserts em `base_inscricao`, `base_token`, `base_inscricaosisu` e `boleto_boleto`, reproduzindo o fluxo observado pelo OpenMetadata (Origem ➔ Processamento ➔ Financeiro). Execute um workflow de ingestão no OpenMetadata para visualizar o grafo resultante.

### Simular Mudança Estrutural (Versionamento)
```bash
./versionamento.sh
```
Adiciona a coluna `observacao_tcc` em `base_candidato`, permitindo acompanhar impactos de DDL nas entidades catalogadas.

### Encerrar o Ambiente
```bash
./stop.sh
```
O script desconecta/remover `postgres-tcc`, derruba o `docker compose` do OpenMetadata e limpa redes órfãs.

## 📊 Estudo de Caso
O TCC replica um processo seletivo com três etapas principais:
1. `base_candidato`: captura original do candidato.
2. `base_inscricao`: consolidação e regras de negócio.
3. `boleto_boleto`: cobrança financeira.

A ingestão realizada pelo OpenMetadata reconstitui a linhagem completa e habilita monitoramentos sobre qualidade de dados (questionários, critérios socioeconômicos, etc.).

## 👥 Autoria
- **Autor**: Vinícius Padilha Vieira
- **Orientador**: Prof. Dr. Josiel Maimone de Figueiredo
- **Instituição**: Instituto de Computação – UFMT
