#!/bin/bash

echo "Iniciando alimentação de dados para gerar linhagem..."

# 1. Inserção de Inscrição Real
# Mapeia o fluxo: Candidato -> Inscrição
sudo docker exec -it postgres-tcc psql -U admin -d db_projeto -c "INSERT INTO public.base_inscricao (nome, cpf, doc_identificacao, doc_orgao_expedidor, numero, confirmada, isenta, paga, gratuita, cancelada, cancelamento_origem, motivo_eliminacao, observacao, criterio_escola_publica, criterio_renda_familiar, criterio_etnia, criterio_necessidade_especial, criterio_generico, frase_pura, frase_pura_com_chave, frase_hash, controle_65_anos, status, candidato_id, oferta_vaga_id, criterio_quilombola) SELECT nome, cpf, doc_identificacao, doc_orgao_expedidor, 'INS-001', true, false, true, false, false, '', '', 'Inscricao via processo de linhagem', false, false, false, false, false, '', '', '', 0, 'Ativo', id, 1, false FROM public.base_candidato LIMIT 10;"

# 2. Inserção de Token de Acesso
# Mapeia o fluxo: Candidato -> Token
sudo docker exec -it postgres-tcc psql -U admin -d db_projeto -c "INSERT INTO public.base_token (hash, expiracao, tipo, candidato_id) SELECT MD5(cpf), NOW() + INTERVAL '1 day', 'ACESSO-SISTEMA', id FROM public.base_candidato LIMIT 10;"

# 3. Inserção no SISU
# Mapeia o fluxo: Candidato -> Inscrição SISU
sudo docker exec -it postgres-tcc psql -U admin -d db_projeto -c "INSERT INTO public.base_inscricaosisu (numero, status, descricao_cota, candidato_id, oferta_vaga_id, quilombola, estudou_escola_publica, renda_inferior, etnia) SELECT 'SISU-' || id, 'Importado', 'Ampla Concorrencia', id, 1, false, false, false, false FROM public.base_candidato LIMIT 10;"

# 4. Inserção no Downstream final: Boleto 
# Mapeia o fluxo final: Inscrição -> Boleto
sudo docker exec -it postgres-tcc psql -U admin -d db_projeto -c "INSERT INTO public.boleto_boleto (convenio_banco, convenio_convenio, convenio_atualizado_em, convenio_especie_documento, convenio_carteira, convenio_cedente, convenio_cedente_documento, convenio_cedente_endereco, convenio_agencia_cedente, convenio_conta_cedente, convenio_demonstrativo, convenio_instrucoes, nosso_numero, valor_documento, data_geracao, data_vencimento, data_documento, data_processamento, sacado_nome, sacado_documento, sacado_cidade, sacado_uf, sacado_endereco, sacado_bairro, sacado_cep, confirmacao_suap_boletos, convenio_id, inscricao_id) SELECT '001', 'CONV-123', NOW(), 'DM', '17', 'UFMT', '00.000.000/0001-00', 'Av. Fernando Correa', '1234', '12345-6', 'Taxa de Inscricao', 'Pagar no banco', 'NOSSO-' || id, 150.00, NOW(), NOW() + INTERVAL '7 days', CURRENT_DATE, CURRENT_DATE, nome, cpf, 'Cuiaba', 'MT', 'Endereco Teste', 'Bairro Teste', '78000-000', true, 1, id FROM public.base_inscricao LIMIT 10;"

echo "Fluxo de linhagem concluído!"
