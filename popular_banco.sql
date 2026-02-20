-- 1. CADASTROS BÁSICOS
INSERT INTO public.comum_campus (id, tipo, sigla, nome) VALUES 
(1, 'Sede', 'CBA', 'Campus Cuiabá Octayde'), (2, 'Sede', 'VGD', 'Campus Várzea Grande'), (3, 'Sede', 'BLM', 'Campus Campo Novo do Parecis');

INSERT INTO public.comum_areacurso (id, nome) VALUES (1, 'TI'), (2, 'Saúde'), (3, 'Gestão');
INSERT INTO public.comum_nivelensino (id, nome) VALUES (1, 'Técnico'), (2, 'Graduação');
INSERT INTO public.comum_turno (id, nome) VALUES (1, 'Matutino'), (2, 'Noturno'), (3, 'Vespertino'), (4, 'Integral');

-- 2. CURSOS E VÍNCULOS
INSERT INTO public.comum_curso (id, nome, ativo, area_id, nivel_ensino_id) VALUES 
(1, 'Computação', true, 1, 2), (2, 'Enfermagem', true, 2, 2);

INSERT INTO public.comum_cursocampus (id, resolucao, campus_id, curso_id) VALUES 
(1, 'RES 01/2025', 1, 1), (2, 'RES 02/2025', 2, 2);

-- 3. EDITAIS 
INSERT INTO public.comum_editalgrupo (id, nome, caracterizacao, cota_escola_publica, administracao) VALUES (1, 'Vestibular 2026', 'Prova', 'Sim', 'Reitoria');

INSERT INTO public.base_edital (id, exibir_edital_menu, nome, descricao, numero, ano, semestre, data_encerramento, chave_hash, hash, observacao, remanescentes, casas_decimais_escore, boleto_taxa, email_from, email_assinatura, aberto_ao_publico, usar_upload, lei_cotas, processou_isencao, processou_recurso_isencao, is_sisu, descricao_formulario_cota_generica, help_text_formulario_cota_generica, grupo_id) VALUES 
(1, true, 'Edital 01/2026', 'Geral', '01/2026', 2026, 1, '2026-12-31', 'h1', 's1', '', false, 2, 50.00, 'prosel@ifmt.br', 'Comissão', true, true, true, false, false, false, 'Cota', 'Help', 1);

-- 4. OFERTA DE VAGAS
INSERT INTO public.base_ofertavaga (id, quantidade, boleto_taxa, dispensa_prova, curso_campus_id, edital_id, turno_id, semestre) VALUES 
(1, 40, 50.00, false, 1, 1, 1, '20261'), (2, 40, 50.00, false, 2, 1, 2, '20261');

-- 5. CANDIDATOS 
DO $$
BEGIN
    FOR i IN 1..200 LOOP
        INSERT INTO public.base_candidato (id, nome, nome_registro, nome_social, sexo, estado_civil, nascimento_data, nascimento_municipio, nascimento_pais, nome_mae, cpf, doc_identificacao, doc_orgao_expedidor, doc_data_emissao, telefone_contato1, email, endereco_logradouro, endereco_numero, endereco_bairro, endereco_municipio, endereco_zona_residencial, endereco_uf, endereco_cep, password, data_criacao, ativo, confirmado, cadastro_importado_sisu)
        VALUES (i, 'Candidato '||i, 'Registro '||i, '', 'M', 'Solteiro', '2000-01-01', 'Cuiabá', 'BR', 'Mãe', '111.111.'||LPAD(i::text, 3, '0')||'-00', 'RG'||i, 'SSP', '2010-01-01', '659999', 'user'||i||'@tcc.com', 'Rua', 'S/N', 'Bairro', 'Cuiabá', 'Urbana', 'MT', '78000', 'pbkdf2_sha256$', now(), true, true, false);
    END LOOP;
END $$;

-- 6. INSCRIÇÕES (CORRIGIDO: criterio_quilombola)
DO $$
BEGIN
    FOR i IN 1..400 LOOP
        INSERT INTO public.base_inscricao (id, nome, cpf, doc_identificacao, doc_orgao_expedidor, numero, confirmada, isenta, paga, gratuita, cancelada, cancelamento_origem, motivo_eliminacao, observacao, criterio_escola_publica, criterio_renda_familiar, criterio_etnia, criterio_necessidade_especial, criterio_generico, criterio_quilombola, frase_pura, frase_pura_com_chave, frase_hash, controle_65_anos, status, candidato_id, oferta_vaga_id)
        VALUES (i, 'Inscrito '||i, '000', '123', 'SSP', '2026'||LPAD(i::text, 4, '0'), true, false, true, false, false, '', '', '', false, false, false, false, false, false, 'frase', 'chave', 'hash', 0, 'Inscrito', (i % 200) + 1, (i % 2) + 1);
    END LOOP;
END $$;

-- 7. QUESTIONÁRIOS
INSERT INTO public.questionario_raca (id, descricao, codigo_auxiliar, lei_cota) VALUES (1, 'Branca', '1', false), (2, 'Preta', '2', true), (3, 'Parda', '3', true);

INSERT INTO public.questionario_caracterizacao (id, inscricao_id, raca_id, renda_bruta_familiar, qtd_pessoas_domicilio, possui_necessidade_especial, precisa_atendimento_necessidade_especial, cursou_ensino_fundamental_integralmente_escola_publica, cursou_ensino_medio_integralmente_escola_publica, quilombola, formulario_generico, confirma_9_ano, tempo_sem_estudar)
SELECT i, i, (i % 3) + 1, 1500.00, 3, false, false, true, true, false, false, true, 0 FROM generate_series(1, 400) as i;

-- 8. SINCRONIZAR SEQUÊNCIAS
SELECT setval('comum_campus_id_seq', (SELECT max(id) FROM comum_campus));
SELECT setval('base_candidato_id_seq', (SELECT max(id) FROM base_candidato));
SELECT setval('base_inscricao_id_seq', (SELECT max(id) FROM base_inscricao));
