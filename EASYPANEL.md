# 🚀 Guía de Configuración en Easypanel

## ⚠️ Error Común: Dockerfile Path

Si ves este error:
```
ERROR: resolve : lstat /etc/easypanel/projects/.../code/https:: no such file or directory
```

**Problema:** Easypanel está configurado con una URL de GitHub en lugar de la ruta del archivo.

## ✅ Configuración Correcta en Easypanel

### 1. Configuración del Repositorio

**URL del Repositorio:**
```
https://github.com/VLP-TECH/camara-front-back-main.git
```

**Rama:**
```
main
```

### 2. Configuración del Dockerfile

**Ruta del Dockerfile:**
```
frontend/Dockerfile
```

**Build Context:**
```
frontend/
```

**❌ NO usar:**
- `https://github.com/VLP-TECH/camara-front-back-main/blob/main/frontend/Dockerfile`
- `https:/github.com/...` (URLs web)
- `Dockerfile` (sin especificar el contexto)

**✅ Usar:**
- `frontend/Dockerfile` (ruta relativa desde la raíz del repositorio)
- Build Context: `frontend/`

### 3. Configuración del Build

**Build Command:**
```
(Dejar vacío - el Dockerfile maneja el build)
```

**O si necesitas especificar:**
```bash
docker build -t app .
```

### 4. Configuración del Start

**Start Command:**
```
(Dejar vacío - el Dockerfile tiene CMD configurado)
```

**O si necesitas especificar:**
```bash
npm run start
```

### 5. Variables de Entorno

Configurar las siguientes variables en Easypanel:

```
NODE_ENV=production
```

**⚠️ IMPORTANTE:** Ya NO necesitas `PORT=4173` porque Nginx usa el puerto 80 internamente.

**Opcionales (si usas Supabase):**
```
VITE_SUPABASE_URL=tu-url-de-supabase
VITE_SUPABASE_ANON_KEY=tu-clave-anon
VITE_API_BASE_URL=http://tu-backend:8000
```

**Nota:** Las variables `VITE_*` deben estar configuradas ANTES del build, ya que se inyectan en tiempo de compilación.

### 6. Puerto

**Puerto interno del contenedor:**
```
80
```

**Puerto externo (mapeo):**
```
80
```

**Health Check Path:**
```
/health
```

## 🔧 Pasos para Corregir el Error

1. **Ir a la configuración del proyecto en Easypanel**
2. **Buscar la sección "Dockerfile" o "Build Settings"**
3. **En el campo "Dockerfile Path":**
   - Eliminar cualquier URL de GitHub
   - Escribir solo: `Dockerfile`
   - O dejar el campo vacío
4. **Guardar los cambios**
5. **Redesplegar el proyecto**

## 📋 Verificación

Después de configurar, el build debería mostrar:
```
Step 1/XX : FROM node:18-alpine AS builder
...
```

En lugar de:
```
ERROR: resolve : lstat .../https:: no such file or directory
```

## 🐛 Troubleshooting

### Error: "Dockerfile not found"
- Verifica que el Dockerfile esté en la raíz del repositorio
- Verifica que el repositorio esté clonado correctamente
- Asegúrate de que la ruta sea `Dockerfile` (sin `/` al inicio)

### Error: "Build failed"
- Verifica que todas las dependencias estén en `package.json`
- Revisa los logs de build en Easypanel
- Verifica que Node.js 18 esté disponible

### Error: "Port already in use"
- Verifica que el puerto externo (ej: 4173) esté configurado correctamente
- El puerto interno siempre es 80 (Nginx)
- Asegúrate de que no haya otro servicio usando el puerto externo

### Error: "Health check failed"
- Verifica que el health check path sea `/health`
- El health check usa `wget` para verificar el endpoint
- Asegúrate de que Nginx esté corriendo correctamente

## 📝 Notas Importantes

- El Dockerfile está en `frontend/Dockerfile`
- Build Context debe ser `frontend/`
- No uses URLs de GitHub para el Dockerfile
- El Dockerfile usa multi-stage build con Nginx Alpine
- **Puerto interno:** 80 (Nginx estándar)
- **Puerto externo:** 4173 (o el que configures en EasyPanel)
- **Health check:** `/health`
- La imagen final es ~25MB (vs ~150MB+ con Node.js)
- Sin vulnerabilidades de npm en producción


