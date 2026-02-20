-- 1. EXPANDINDO A INFRAESTRUTURA (Novos Campi e Áreas)
INSERT INTO public.comum_campus (id, tipo, sigla, nome) VALUES 
(4, 'Sede', 'SRV', 'Campus São Vicente'), (5, 'Sede', 'ROO', 'Campus Rondonópolis'), (6, 'Sede', 'CAS', 'Campus Cáceres');

INSERT INTO public.comum_areacurso (id, nome) VALUES (4, 'Engenharia'), (5, 'Educação'), (6, 'Agronomia');

-- 2. NOVO EDITAL (Para mostrar versionamento e múltiplos serviços)
INSERT INTO public.base_edital (id, exibir_edital_menu, nome, descricao, numero, ano, semestre, data_encerramento, chave_hash, hash, observacao, remanescentes, casas_decimais_escore, boleto_taxa, email_from, email_assinatura, aberto_ao_publico, usar_upload, lei_cotas, processou_isencao, processou_recurso_isencao, is_sisu, descricao_formulario_cota_generica, help_text_formulario_cota_generica, grupo_id) VALUES 
(2, true, 'Edital 02/2026', 'Processo Seletivo Segundo Semestre', '02/2026', 2026, 2, '2026-11-30', 'h2', 's2', 'TCC Expansão', false, 2, 75.00, 'contato@ifmt.br', 'Comissão Central', true, true, true, false, false, false, 'Cota Especial', 'Info', 1);

-- 3. NOVAS OFERTAS DE VAGAS
INSERT INTO public.base_ofertavaga (id, quantidade, boleto_taxa, dispensa_prova, curso_campus_id, edital_id, turno_id, semestre) VALUES 
(3, 60, 75.00, false, 1, 2, 3, '20262'), (4, 30, 75.00, false, 2, 2, 1, '20262');

-- 4. CARGA MASSIVA DIVERSIFICADA (Candidatos 201 a 500)
DO $$
DECLARE 
    sexos TEXT[] := ARRAY['M', 'F'];
    estados TEXT[] := ARRAY['Solteiro(a)', 'Casado(a)', 'Divorciado(a)', 'Viúvo(a)'];
    ufs TEXT[] := ARRAY['MT', 'SP', 'RJ', 'MG', 'MS', 'GO', 'PR'];
    paises TEXT[] := ARRAY['BR', 'AR', 'US', 'PT'];
    zonas TEXT[] := ARRAY['Urbana', 'Rural'];
BEGIN
    FOR i IN 201..500 LOOP
        INSERT INTO public.base_candidato (id, nome, nome_registro, nome_social, sexo, estado_civil, nascimento_data, nascimento_municipio, nascimento_pais, nome_mae, cpf, doc_identificacao, doc_orgao_expedidor, doc_data_emissao, telefone_contato1, email, endereco_logradouro, endereco_numero, endereco_bairro, endereco_municipio, endereco_zona_residencial, endereco_uf, endereco_cep, password, data_criacao, ativo, confirmado, cadastro_importado_sisu)
        VALUES (
            i, 
            'Candidato Extra '||i, 'Registro '||i, '', 
            sexos[1 + (i % 2)], 
            estados[1 + (i % 4)], 
            '1990-01-01'::date + (i || ' days')::interval, 
            'Cuiabá', 
            paises[1 + (i % 4)], 
            'Mãe '||i, 
            '222.222.'||LPAD(i::text, 3, '0')||'-99', 
            'RG'||i, 'SSP', '2012-05-10', '65888', 
            'extra'||i||'@tcc.com', 'Av. Teste', '100', 'Centro', 'Cuiabá', 
            zonas[1 + (i % 2)], 
            ufs[1 + (i % 7)], 
            '78000', 'pbkdf2_sha256$', now(), true, true, false
        );
    END LOOP;
END $$;

-- 5. NOVAS INSCRIÇÕES (600 registros: IDs 401 a 1000)
DO $$
BEGIN
    FOR i IN 401..1000 LOOP
        INSERT INTO public.base_inscricao (id, nome, cpf, doc_identificacao, doc_orgao_expedidor, numero, confirmada, isenta, paga, gratuita, cancelada, cancelamento_origem, motivo_eliminacao, observacao, criterio_escola_publica, criterio_renda_familiar, criterio_etnia, criterio_necessidade_especial, criterio_generico, criterio_quilombola, frase_pura, frase_pura_com_chave, frase_hash, controle_65_anos, status, candidato_id, oferta_vaga_id)
        VALUES (
            i, 'Inscrito Extra '||i, '000', 'DOC'||i, 'SSP', 
            '2026'||LPAD(i::text, 4, '0'), 
            (i % 5 != 0), -- Algumas não confirmadas para o gráfico de qualidade
            false, true, false, false, '', '', '', 
            (i % 2 = 0), (i % 3 = 0), (i % 4 = 0), false, false, false, 
            'frase nova', 'chave nova', 'hash nova', 0, 'Inscrito', 
            201 + (i % 300), -- Vincula aos novos candidatos
            3 + (i % 2)     -- Vincula às novas ofertas (edital 2)
        );
    END LOOP;
END $$;

-- 6. QUESTIONÁRIOS COM RENDA VARIADA (Para o Profiler brilhar)
INSERT INTO public.questionario_caracterizacao (id, inscricao_id, raca_id, renda_bruta_familiar, qtd_pessoas_domicilio, possui_necessidade_especial, precisa_atendimento_necessidade_especial, cursou_ensino_fundamental_integralmente_escola_publica, cursou_ensino_medio_integralmente_escola_publica, quilombola, formulario_generico, confirma_9_ano, tempo_sem_estudar)
SELECT 
    i + 400, i, (1 + (i % 3)), 
    (1412.00 + (random() * 8000))::numeric(10,2), -- Renda aleatória entre 1.4k e 9.4k
    (1 + (i % 6)), false, false, (i % 2 = 0), (i % 2 != 0), false, false, true, 0 
FROM generate_series(401, 1000) as i;

-- 7. SINCRONIZAR SEQUÊNCIAS
SELECT setval('comum_campus_id_seq', (SELECT max(id) FROM comum_campus));
SELECT setval('base_candidato_id_seq', (SELECT max(id) FROM base_candidato));
SELECT setval('base_inscricao_id_seq', (SELECT max(id) FROM base_inscricao));
SELECT setval('base_ofertavaga_id_seq', (SELECT max(id) FROM base_ofertavaga));
SELECT setval('base_edital_id_seq', (SELECT max(id) FROM base_edital));
