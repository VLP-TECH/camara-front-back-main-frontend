# 🚀 Configuración EasyPanel - Producción Optimizada

## ✅ Configuración Completa para EasyPanel

### 1. Información del Repositorio

```
URL: https://github.com/VLP-TECH/camara-front-back-main.git
Rama: main
```

### 2. Configuración de Build

**Tipo de App:**
```
Docker
```

**Dockerfile Path:**
```
frontend/Dockerfile
```

**Build Context:**
```
frontend/
```

**Build Command:**
```
(Dejar vacío - el Dockerfile maneja todo)
```

**Start Command:**
```
(Dejar vacío - Nginx se inicia automáticamente)
```

### 3. Configuración de Puerto

**Puerto Interno:**
```
80
```

**Puerto Externo (mapeo):**
```
4173
```

**Health Check Path:**
```
/health
```

**Health Check Command (opcional):**
```
wget -qO- http://localhost/health
```

### 4. Variables de Entorno

**Requeridas:**
```bash
NODE_ENV=production
```

**Opcionales (Supabase):**
```bash
VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
VITE_SUPABASE_ANON_KEY=tu-clave-publica-anon
VITE_API_BASE_URL=http://tu-backend:8000
```

**⚠️ IMPORTANTE:**
- Las variables `VITE_*` se inyectan en tiempo de BUILD
- Si cambias estas variables, debes REBUILD la aplicación
- No necesitas `PORT=4173` (Nginx usa puerto 80 internamente)

### 5. Configuración de Recursos

**Recomendado:**
```
CPU: 0.5 - 1 core
RAM: 512MB - 1GB
```

**Mínimo:**
```
CPU: 0.25 core
RAM: 256MB
```

### 6. Configuración de Dominio

**Custom Domain (opcional):**
```
tu-dominio.com
www.tu-dominio.com
```

**SSL/TLS:**
```
Automático (Let's Encrypt)
```

## 📋 Checklist de Despliegue

- [ ] Repositorio configurado correctamente
- [ ] Dockerfile path: `frontend/Dockerfile`
- [ ] Build context: `frontend/`
- [ ] Puerto interno: `80`
- [ ] Puerto externo: `4173` (o el que prefieras)
- [ ] Health check path: `/health`
- [ ] Variables de entorno configuradas
- [ ] `NODE_ENV=production` configurado
- [ ] Variables `VITE_*` configuradas (si usas Supabase)
- [ ] Build completado exitosamente
- [ ] Contenedor corriendo
- [ ] Health check pasando
- [ ] Aplicación accesible en el dominio

## 🔍 Verificación Post-Despliegue

### 1. Verificar Build
El build debe mostrar:
```
✓ built in X.XXs
Success
```

### 2. Verificar Contenedor
```bash
# En los logs de EasyPanel deberías ver:
# Nginx iniciado correctamente
# Health check pasando
```

### 3. Verificar Aplicación
- Abre la URL de tu aplicación
- Verifica que carga correctamente
- Revisa la consola del navegador (F12) para errores
- Prueba la navegación entre páginas (SPA routing)

### 4. Verificar Health Check
```bash
curl https://tu-dominio.com/health
# Debe responder: healthy
```

## 🐛 Troubleshooting

### Build falla
- Verifica que el Dockerfile path sea `frontend/Dockerfile`
- Verifica que el build context sea `frontend/`
- Revisa los logs de build en EasyPanel

### Health check falla
- Verifica que el puerto interno sea `80`
- Verifica que el health check path sea `/health`
- Revisa los logs del contenedor

### Variables de entorno no funcionan
- Recuerda que `VITE_*` se inyectan en BUILD time
- Si cambias `VITE_*`, debes hacer REBUILD
- Verifica que las variables estén en la sección correcta de EasyPanel

### Aplicación no carga
- Verifica que el puerto externo esté mapeado correctamente
- Revisa los logs del contenedor
- Verifica que Nginx esté corriendo: `docker exec <container> ps aux | grep nginx`

## 📊 Ventajas de esta Configuración

✅ **Imagen pequeña:** ~25MB vs ~150MB+  
✅ **Sin vulnerabilidades npm:** No hay Node.js en producción  
✅ **Mejor rendimiento:** Nginx optimizado para archivos estáticos  
✅ **Production-grade:** Configuración lista para producción  
✅ **SPA routing:** Configurado para React Router  
✅ **Compresión gzip:** Activa automáticamente  
✅ **Security headers:** Configurados automáticamente  
✅ **Cache optimizado:** Assets estáticos cacheados por 1 año  

## 🔗 Referencias

- Dockerfile: `frontend/Dockerfile`
- Documentación completa: `EASYPANEL.md`
- Quick start: `EASYPANEL_QUICK_START.md`
