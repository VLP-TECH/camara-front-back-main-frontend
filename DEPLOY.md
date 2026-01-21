# 🚀 Guía de Despliegue en Producción

## 📋 Opción 1: Scripts Automatizados (Recomendado)

### Scripts Disponibles

El proyecto incluye scripts automatizados para facilitar el deploy:

#### 1. Deploy Principal (`deploy.sh`)

```bash
# Hacer ejecutable
chmod +x deploy.sh

# Deploy con puerto por defecto (4173)
./deploy.sh

# Deploy con puerto personalizado
./deploy.sh 3000
```

**Funcionalidades:**
- ✅ Verifica que Docker esté corriendo
- ✅ Detiene y elimina contenedores existentes
- ✅ Construye la imagen Docker
- ✅ Inicia el contenedor con configuración optimizada
- ✅ Verifica health check automáticamente
- ✅ Muestra información de acceso

#### 2. Verificación (`check-deploy.sh`)

```bash
# Hacer ejecutable
chmod +x check-deploy.sh

# Verificar estado
./check-deploy.sh
./check-deploy.sh 3000  # Puerto personalizado
```

**Verifica:**
- Estado del contenedor
- Health check endpoint
- Respuesta HTTP de la aplicación
- Últimas líneas de logs

#### 3. Limpieza (`clean-deploy.sh`)

```bash
# Hacer ejecutable
chmod +x clean-deploy.sh

# Limpiar deploy
./clean-deploy.sh
```

**Elimina:**
- Contenedor en ejecución
- Contenedor detenido
- Opcionalmente la imagen Docker
- Limpia docker-compose

#### 4. Actualización (`update-deploy.sh`)

```bash
# Hacer ejecutable
chmod +x update-deploy.sh

# Actualizar (pull + rebuild)
./update-deploy.sh
./update-deploy.sh 3000  # Puerto personalizado
```

**Realiza:**
- Pull de cambios desde Git
- Rebuild y redeploy automático

---

## 📋 Opción 2: Docker Compose (Recomendado para Producción)

### Configuración Actual

El proyecto usa un **Dockerfile en la raíz** que:
- Construye el frontend con Node.js 18
- Genera archivos estáticos optimizados
- Sirve con Nginx Alpine (imagen ligera ~25MB)
- Incluye configuración SPA routing
- Health check endpoint en `/health`

### Pasos de Deploy

```bash
# 1. Clonar el repositorio
git clone https://github.com/VLP-TECH/camara-front-back-main-frontend.git
cd camara-front-back-main-frontend

# 2. Construir y levantar con docker-compose
docker-compose up --build -d

# 3. Verificar que está corriendo
docker ps
docker logs ecosistema-valencia-view

# 4. Verificar health check
curl http://localhost:4173/health
# Debe responder: "healthy"

# 5. Acceder a la aplicación
# URL: http://localhost:4173
```

### Configuración de Puerto

El puerto se puede configurar con variable de entorno:

```bash
# Puerto personalizado
PORT=3000 docker-compose up --build -d
```

**Configuración por defecto:**
- Puerto interno: `80` (Nginx)
- Puerto externo: `4173`
- Health check: `/health`

---

## 📋 Opción 3: Docker Directo

### Pasos:

```bash
# 1. Construir la imagen
docker build -t frontend-app .

# 2. Ejecutar el contenedor
docker run -d \
  --name ecosistema-valencia-view \
  -p 4173:80 \
  -e NODE_ENV=production \
  --restart unless-stopped \
  frontend-app

# 3. Ver logs
docker logs -f ecosistema-valencia-view

# 4. Verificar health check
curl http://localhost:4173/health
```

### Comandos Útiles

```bash
# Ver estado del contenedor
docker ps | grep ecosistema-valencia-view

# Ver logs en tiempo real
docker logs -f ecosistema-valencia-view

# Detener contenedor
docker stop ecosistema-valencia-view

# Reiniciar contenedor
docker restart ecosistema-valencia-view

# Eliminar contenedor
docker rm ecosistema-valencia-view

# Eliminar imagen
docker rmi frontend-app
```

---

## 📋 Opción 4: Easypanel (Plataforma de Hosting)

### Configuración en Easypanel

1. **Repositorio:**
   - URL: `https://github.com/VLP-TECH/camara-front-back-main-frontend.git`
   - Rama: `main`

2. **Dockerfile:**
   - Dockerfile Path: `Dockerfile` (en la raíz)
   - Build Context: `.` (raíz del proyecto)

3. **Variables de Entorno:**
   ```
   NODE_ENV=production
   ```
   
   **Opcionales (si usas Supabase):**
   ```
   VITE_SUPABASE_URL=tu-url-de-supabase
   VITE_SUPABASE_ANON_KEY=tu-clave-anon
   ```
   
   ⚠️ **IMPORTANTE:** Las variables `VITE_*` deben configurarse ANTES del build (se inyectan en tiempo de compilación).

4. **Puerto:**
   - Puerto interno: `80`
   - Puerto externo: `4173` (o el que prefieras)
   - Health check path: `/health`

5. **Deploy:**
   - Guardar configuración
   - Hacer deploy

---

## 📋 Opción 5: Desarrollo Local (sin Docker)

### Pasos:

```bash
# 1. Ir al directorio frontend
cd frontend

# 2. Instalar dependencias
npm install

# 3. Iniciar servidor de desarrollo
npm run dev

# La aplicación estará disponible en:
# http://localhost:5173 (o el siguiente puerto disponible)
```

### Build para Producción Local

```bash
# 1. Construir el proyecto
cd frontend
npm run build

# 2. Preview de producción
npm run start
# o directamente:
vite preview --host 0.0.0.0 --port 4173
```

---

## 🔧 Variables de Entorno

### Producción (Docker)

```bash
NODE_ENV=production
```

### Desarrollo

Las variables `VITE_*` se configuran en un archivo `.env` en el directorio `frontend/`:

```bash
# frontend/.env
VITE_SUPABASE_URL=tu-url-de-supabase
VITE_SUPABASE_ANON_KEY=tu-clave-anon
VITE_API_BASE_URL=http://tu-backend:8000
```

⚠️ **Nota:** Las variables `VITE_*` se inyectan en tiempo de build, no en runtime.

---

## ✅ Verificación Post-Despliegue

### 1. Verificar Contenedor

```bash
docker ps | grep ecosistema-valencia-view
```

### 2. Verificar Health Check

```bash
curl http://localhost:4173/health
# Debe responder: "healthy"
```

### 3. Verificar Aplicación

```bash
# Verificar que responde
curl -I http://localhost:4173
# Debe devolver HTTP 200

# Verificar en navegador
# Abre: http://localhost:4173
```

### 4. Verificar Logs

```bash
docker logs ecosistema-valencia-view
```

---

## 🐛 Troubleshooting

### Error: "Port already in use"

```bash
# Encontrar proceso usando el puerto
lsof -ti:4173

# Matar proceso
kill -9 $(lsof -ti:4173)

# O matar múltiples puertos
for port in 8080 8081 8082 8083; do
  lsof -ti:$port | xargs kill -9 2>/dev/null
done
```

### Error: "Docker daemon not running"

```bash
# Iniciar Docker Desktop (macOS/Windows)
# O en Linux:
sudo systemctl start docker
```

### Error: "Build failed"

```bash
# Limpiar y reconstruir
docker-compose down
docker system prune -f
docker-compose up --build
```

### Error: "Health check failed"

```bash
# Verificar logs
docker logs ecosistema-valencia-view

# Verificar que Nginx esté corriendo
docker exec ecosistema-valencia-view ps aux | grep nginx

# Verificar configuración de Nginx
docker exec ecosistema-valencia-view cat /etc/nginx/conf.d/default.conf
```

### Error: "Cannot find module" (en desarrollo)

```bash
# Reinstalar dependencias
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### Error: "Dockerfile not found"

Verifica que el Dockerfile esté en la raíz del proyecto:
```bash
ls -la Dockerfile
```

---

## 📝 Notas Importantes

### Arquitectura del Deploy

1. **Dockerfile Multi-Stage:**
   - Stage 1 (builder): Node.js 18 Alpine - construye la aplicación
   - Stage 2 (runner): Nginx 1.27 Alpine - sirve archivos estáticos

2. **Optimizaciones:**
   - Imagen final: ~25MB (vs ~150MB+ con Node.js completo)
   - Gzip compression habilitado
   - Cache de assets estáticos (1 año)
   - Security headers configurados

3. **SPA Routing:**
   - Todas las rutas sirven `index.html`
   - Configurado en Nginx con `try_files`

4. **Health Check:**
   - Endpoint: `/health`
   - Retorna: `"healthy\n"`
   - Verificado cada 30 segundos

### Puertos

- **Puerto interno:** `80` (Nginx estándar)
- **Puerto externo:** `4173` (configurable)
- **Health check:** `/health`

### Archivos Importantes

- `Dockerfile` - En la raíz del proyecto
- `docker-compose.yml` - Configuración de servicios
- `frontend/package.json` - Dependencias y scripts
- `frontend/dist/` - Archivos construidos (generados)

### Comandos Rápidos

```bash
# Deploy completo
./deploy.sh

# Verificar estado
./check-deploy.sh

# Ver logs
docker logs -f ecosistema-valencia-view

# Detener
docker stop ecosistema-valencia-view

# Limpiar todo
./clean-deploy.sh
```

---

## 🔗 Referencias

- [Dockerfile](./Dockerfile) - Configuración de build
- [docker-compose.yml](./docker-compose.yml) - Configuración de servicios
- [EASYPANEL.md](./EASYPANEL.md) - Guía específica para Easypanel
- [DOCKER.md](./DOCKER.md) - Documentación detallada de Docker
