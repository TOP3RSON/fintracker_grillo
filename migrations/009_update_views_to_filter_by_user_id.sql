-- Migration to update views to filter by user_id for multi-tenant support

-- Drop and recreate vw_entradas_saidas_mensal with user_id filtering
DROP VIEW IF EXISTS public.vw_entradas_saidas_mensal;

CREATE OR REPLACE VIEW public.vw_entradas_saidas_mensal AS
WITH e AS (
  SELECT date_trunc('month', data) AS mes, SUM(valor) AS total_entradas
  FROM public.entradas 
  WHERE user_id = auth.uid()
  GROUP BY 1
),
s AS (
  SELECT date_trunc('month', data) AS mes, SUM(valor) AS total_saidas
  FROM public.saidas 
  WHERE user_id = auth.uid()
  GROUP BY 1
)
SELECT
  COALESCE(e.mes, s.mes) AS mes,
  COALESCE(e.total_entradas, 0) AS total_entradas,
  COALESCE(s.total_saidas, 0)   AS total_saidas
FROM e FULL OUTER JOIN s ON e.mes = s.mes
ORDER BY mes;

-- Drop and recreate vw_saidas_por_categoria with user_id filtering
DROP VIEW IF EXISTS public.vw_saidas_por_categoria;

CREATE OR REPLACE VIEW public.vw_saidas_por_categoria AS
SELECT
  c.id AS categoria_id,
  COALESCE(c.nome, 'Sem categoria') AS categoria,
  SUM(s.valor) AS total_saidas
FROM public.saidas s
LEFT JOIN public.categorias c ON c.id = s.categoria_id AND c.user_id = auth.uid()
WHERE s.user_id = auth.uid()
GROUP BY c.id, c.nome
ORDER BY total_saidas DESC;

-- Drop and recreate vw_saldo_diario with user_id filtering
DROP VIEW IF EXISTS public.vw_saldo_diario;

CREATE OR REPLACE VIEW public.vw_saldo_diario AS
WITH dias AS (
  SELECT GENERATE_SERIES(
    LEAST(
      COALESCE((SELECT MIN(data) FROM public.entradas WHERE user_id = auth.uid()), CURRENT_DATE),
      COALESCE((SELECT MIN(data) FROM public.saidas WHERE user_id = auth.uid()),   CURRENT_DATE)
    ),
    GREATEST(
      COALESCE((SELECT MAX(data) FROM public.entradas WHERE user_id = auth.uid()), CURRENT_DATE),
      COALESCE((SELECT MAX(data) FROM public.saidas WHERE user_id = auth.uid()),   CURRENT_DATE)
    ),
    INTERVAL '1 day'
  )::date AS dia
),
e AS (
  SELECT data AS dia, SUM(valor) AS entradas_dia 
  FROM public.entradas 
  WHERE user_id = auth.uid() 
  GROUP BY 1
),
s AS (
  SELECT data AS dia, SUM(valor) AS saidas_dia   
  FROM public.saidas   
  WHERE user_id = auth.uid() 
  GROUP BY 1
),
base AS (
  SELECT
    d.dia,
    COALESCE(e.entradas_dia, 0) AS entradas_dia,
    COALESCE(s.saidas_dia,  0) AS saidas_dia,
    COALESCE(e.entradas_dia, 0) - COALESCE(s.saidas_dia, 0) AS saldo_dia
  FROM dias d
  LEFT JOIN e ON e.dia = d.dia
  LEFT JOIN s ON s.dia = d.dia
)
SELECT
  dia,
  entradas_dia,
  saidas_dia,
  SUM(saldo_dia) OVER (ORDER BY dia) AS saldo_acumulado
FROM base
ORDER BY dia;

-- Drop and recreate vw_contas_vencer with user_id filtering
DROP VIEW IF EXISTS public.vw_contas_vencer;

CREATE OR REPLACE VIEW public.vw_contas_vencer AS
SELECT
  id,
  descricao,
  valor,
  data_vencimento,
  tipo,
  status,
  categoria_id,
  whatsapp,
  created_at,
  grupo_parcelamento_id
FROM public.contas
WHERE data_vencimento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
  AND status = 'pendente'
  AND user_id = auth.uid()
ORDER BY data_vencimento;

-- Drop and recreate vw_contas_vencidas with user_id filtering
DROP VIEW IF EXISTS public.vw_contas_vencidas;

CREATE OR REPLACE VIEW public.vw_contas_vencidas AS
SELECT
  id,
  descricao,
  valor,
  data_vencimento,
  tipo,
  status,
  categoria_id,
  whatsapp,
  created_at,
  grupo_parcelamento_id
FROM public.contas
WHERE data_vencimento < CURRENT_DATE
  AND status = 'pendente'
  AND user_id = auth.uid()
ORDER BY data_vencimento;