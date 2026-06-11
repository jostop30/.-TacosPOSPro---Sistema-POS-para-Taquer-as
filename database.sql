-- 0. Limpieza previa para evitar errores de duplicados al reinstalar
DROP POLICY IF EXISTS "Allow public read on productos" ON public.productos;
DROP POLICY IF EXISTS "Allow public insert on productos" ON public.productos;
DROP POLICY IF EXISTS "Allow public update on productos" ON public.productos;
DROP POLICY IF EXISTS "Allow public delete on productos" ON public.productos;

DROP POLICY IF EXISTS "Allow public read on mesas" ON public.mesas;
DROP POLICY IF EXISTS "Allow public insert on mesas" ON public.mesas;
DROP POLICY IF EXISTS "Allow public update on mesas" ON public.mesas;
DROP POLICY IF EXISTS "Allow public delete on mesas" ON public.mesas;

DROP POLICY IF EXISTS "Allow public read on pedidos" ON public.pedidos;
DROP POLICY IF EXISTS "Allow public insert on pedidos" ON public.pedidos;
DROP POLICY IF EXISTS "Allow public update on pedidos" ON public.pedidos;

DROP POLICY IF EXISTS "Allow public read on configuracion" ON public.configuracion;
DROP POLICY IF EXISTS "Allow public insert on configuracion" ON public.configuracion;
DROP POLICY IF EXISTS "Allow public update on configuracion" ON public.configuracion;

-- Habilitar la extensión para generar UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. CREACIÓN DE TABLAS

CREATE TABLE IF NOT EXISTS public.productos (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nombre TEXT NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    categoria TEXT,
    imagen TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.mesas (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    numero_mesa TEXT NOT NULL UNIQUE,
    estado TEXT DEFAULT 'disponible' CHECK (estado IN ('disponible', 'ocupada', 'preparando')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.pedidos (
    id TEXT PRIMARY KEY,
    tipo_servicio TEXT NOT NULL CHECK (tipo_servicio IN ('mesa', 'barra', 'delivery')),
    identificador_servicio TEXT NOT NULL,
    cliente TEXT,
    productos JSONB NOT NULL DEFAULT '[]',
    total NUMERIC(10,2) NOT NULL,
    estado TEXT DEFAULT 'pendiente_cocina' CHECK (estado IN ('pendiente', 'pendiente_cocina', 'preparando', 'listo', 'cobrado')),
    metodo_pago TEXT CHECK (metodo_pago IN ('efectivo', 'transferencia', 'point')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.configuracion (
    user_id UUID PRIMARY KEY,
    nombre_negocio TEXT DEFAULT 'Mi Taquería',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.licencias (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id UUID NOT NULL UNIQUE,
    activa BOOLEAN DEFAULT TRUE,
    tipo TEXT CHECK (tipo IN ('mensual', 'permanente')),
    fecha_expiracion TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. CREACIÓN DE ÍNDICES

CREATE INDEX IF NOT EXISTS idx_pedidos_estado ON public.pedidos(estado);
CREATE INDEX IF NOT EXISTS idx_pedidos_created_at ON public.pedidos(created_at);
CREATE INDEX IF NOT EXISTS idx_pedidos_tipo_servicio ON public.pedidos(tipo_servicio);
CREATE INDEX IF NOT EXISTS idx_mesas_estado ON public.mesas(estado);

-- 3. HABILITAR SEGURIDAD DE FILA (RLS)

ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracion ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.licencias ENABLE ROW LEVEL SECURITY;

-- 4. CREACIÓN DE POLÍTICAS (POLICIES)

-- Políticas para Productos
CREATE POLICY "Allow public read on productos" ON public.productos FOR SELECT USING (true);
CREATE POLICY "Allow public insert on productos" ON public.productos FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on productos" ON public.productos FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on productos" ON public.productos FOR DELETE USING (true);

-- Políticas para Mesas
CREATE POLICY "Allow public read on mesas" ON public.mesas FOR SELECT USING (true);
CREATE POLICY "Allow public insert on mesas" ON public.mesas FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on mesas" ON public.mesas FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on mesas" ON public.mesas FOR DELETE USING (true);

-- Políticas para Pedidos
CREATE POLICY "Allow public read on pedidos" ON public.pedidos FOR SELECT USING (true);
CREATE POLICY "Allow public insert on pedidos" ON public.pedidos FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on pedidos" ON public.pedidos FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on pedidos" ON public.pedidos FOR DELETE USING (true);
-- Políticas para Configuración
CREATE POLICY "Allow public read on configuracion" ON public.configuracion FOR SELECT USING (true);
CREATE POLICY "Allow public insert on configuracion" ON public.configuracion FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on configuracion" ON public.configuracion FOR UPDATE USING (true);

-- 5. INSERCIÓN DE DATOS INICIALES

-- Insertar Productos base
INSERT INTO public.productos (nombre, precio, categoria, imagen) VALUES
('Tacos al Pastor', 8.50, 'Tacos', NULL),
('Tacos de Carnitas', 7.50, 'Tacos', NULL),
('Torta Cubana', 12.00, 'Tortas', NULL),
('Agua Fresca', 2.50, 'Agua', NULL),
('Refresco', 3.00, 'Refrescos', NULL),
('Flan', 4.50, 'Postres', NULL)
ON CONFLICT DO NOTHING;

-- Insertar Mesas iniciales
INSERT INTO public.mesas (numero_mesa, estado) VALUES
('1', 'disponible'),
('2', 'disponible'),
('3', 'disponible'),
('4', 'disponible'),
('5', 'disponible')
ON CONFLICT (numero_mesa) DO NOTHING;

-- Insertar Configuración inicial con un UUID válido en lugar de 'default'
INSERT INTO public.configuracion (user_id, nombre_negocio) VALUES
('00000000-0000-0000-0000-000000000000', 'Mi Taquería')
ON CONFLICT (user_id) DO UPDATE SET nombre_negocio = 'Mi Taquería';