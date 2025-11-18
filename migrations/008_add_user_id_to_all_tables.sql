-- Migration to add user_id to all data tables for multi-tenant support
-- This assumes the Supabase auth system where auth.uid() returns the authenticated user's UUID

-- Add user_id column to categorias (using UUID to match Supabase auth system)
ALTER TABLE categorias ADD COLUMN IF NOT EXISTS user_id UUID;
CREATE INDEX IF NOT EXISTS categorias_user_id_idx ON categorias(user_id);

-- Add user_id column to entradas
ALTER TABLE entradas ADD COLUMN IF NOT EXISTS user_id UUID;
CREATE INDEX IF NOT EXISTS entradas_user_id_idx ON entradas(user_id);

-- Add user_id column to saidas
ALTER TABLE saidas ADD COLUMN IF NOT EXISTS user_id UUID;
CREATE INDEX IF NOT EXISTS saidas_user_id_idx ON saidas(user_id);

-- Add user_id column to contas
ALTER TABLE contas ADD COLUMN IF NOT EXISTS user_id UUID;
CREATE INDEX IF NOT EXISTS contas_user_id_idx ON contas(user_id);

-- Add user_id column to tarefas
ALTER TABLE tarefas ADD COLUMN IF NOT EXISTS user_id UUID;
CREATE INDEX IF NOT EXISTS tarefas_user_id_idx ON tarefas(user_id);

-- Add user_id column to contas_financeiras
ALTER TABLE contas_financeiras ADD COLUMN IF NOT EXISTS user_id UUID;
CREATE INDEX IF NOT EXISTS contas_financeiras_user_id_idx ON contas_financeiras(user_id);

-- Add user_id column to whatsapp_conversas (if needed for per-user conversations)
ALTER TABLE whatsapp_conversas ADD COLUMN IF NOT EXISTS user_id UUID;
CREATE INDEX IF NOT EXISTS whatsapp_conversas_user_id_idx ON whatsapp_conversas(user_id);

-- Enable Row Level Security on all tables
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE entradas ENABLE ROW LEVEL SECURITY;
ALTER TABLE saidas ENABLE ROW LEVEL SECURITY;
ALTER TABLE contas ENABLE ROW LEVEL SECURITY;
ALTER TABLE tarefas ENABLE ROW LEVEL SECURITY;
ALTER TABLE contas_financeiras ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_conversas ENABLE ROW LEVEL SECURITY;

-- Create RLS policies - users can only access their own data
CREATE POLICY categorias_user_policy ON categorias FOR ALL USING (auth.uid() = user_id);
CREATE POLICY entradas_user_policy ON entradas FOR ALL USING (auth.uid() = user_id);
CREATE POLICY saidas_user_policy ON saidas FOR ALL USING (auth.uid() = user_id);
CREATE POLICY contas_user_policy ON contas FOR ALL USING (auth.uid() = user_id);
CREATE POLICY tarefas_user_policy ON tarefas FOR ALL USING (auth.uid() = user_id);
CREATE POLICY contas_financeiras_user_policy ON contas_financeiras FOR ALL USING (auth.uid() = user_id);
CREATE POLICY whatsapp_conversas_user_policy ON whatsapp_conversas FOR ALL USING (auth.uid() = user_id);

-- Create function to automatically set user_id for new records
CREATE OR REPLACE FUNCTION set_user_id()
RETURNS TRIGGER AS $$
BEGIN
  NEW.user_id = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically set user_id on INSERT
CREATE TRIGGER trigger_set_user_id_categorias
  BEFORE INSERT ON categorias
  FOR EACH ROW
  EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_set_user_id_entradas
  BEFORE INSERT ON entradas
  FOR EACH ROW
  EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_set_user_id_saidas
  BEFORE INSERT ON saidas
  FOR EACH ROW
  EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_set_user_id_contas
  BEFORE INSERT ON contas
  FOR EACH ROW
  EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_set_user_id_tarefas
  BEFORE INSERT ON tarefas
  FOR EACH ROW
  EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_set_user_id_contas_financeiras
  BEFORE INSERT ON contas_financeiras
  FOR EACH ROW
  EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_set_user_id_whatsapp_conversas
  BEFORE INSERT ON whatsapp_conversas
  FOR EACH ROW
  EXECUTE FUNCTION set_user_id();