# 🚀 Guía de Configuración Box en Easypanel

## 📋 Diferencia entre Box y Web-App

En Easypanel, un **Box** es un tipo de servicio que te da más control sobre la configuración, incluyendo la posibilidad de configurar procesos personalizados. A diferencia de Web-App, Box permite:

- Configurar procesos/scripts personalizados
- Mayor flexibilidad en la configuración
- Control directo sobre el contenedor Docker

## ✅ Configuración Completa para Box

### Opción A: Con Dockerfile (Recomendado)

Esta es la opción recomendada porque es más eficiente y optimizada.

### Opción B: Sin Dockerfile (Usando Deployment Script)

Si prefieres ejecutar sin Dockerfile, usando directamente el Deployment Script y Processes.

---

## 📦 Opción A: Configuración con Dockerfile

### 1. Crear el Box

1. En Easypanel, ve a tu proyecto
2. Haz clic en **"+ Service"** o **"Templates"**
3. Selecciona **"Box"** como tipo de servicio
4. Asigna un nombre (ej: `camara-front-back-main-frontend-box`)

### 2. Configuración del Repositorio (Source)

En la sección **"Source"**:

- **Owner:** `VLP-TECH`
- **Repository:** `camara-front-back-main-frontend`
- **Branch:** `main`
- **Build Path:** `/` (raíz del proyecto)

### 3. Configuración del Build

En la sección **"Build"**:

- **Método:** `Dockerfile`
- **File:** `Dockerfile` (sin ruta adicional, solo "Dockerfile")
- **Build Context:** `.` (punto, raíz del proyecto)

**⚠️ IMPORTANTE:**
- NO uses URLs de GitHub para el Dockerfile
- NO uses `frontend/Dockerfile` (el Dockerfile está en la raíz)
- El build context debe ser la raíz (`.`) porque el Dockerfile copia desde `frontend/`

### 4. Configuración de Puerto

En la sección **"Ports"** o **"Network"**:

- **Puerto interno:** `80` (Nginx)
- **Puerto externo:** `80` (o el que Easypanel asigne automáticamente)
- **Health Check Path:** `/health`

### 5. Variables de Entorno

En la sección **"Environment"**:

**Requeridas:**
```
NODE_ENV=production
```

**Opcionales (si usas Supabase):**
```
VITE_SUPABASE_URL=tu-url-de-supabase
VITE_SUPABASE_ANON_KEY=tu-clave-anon
VITE_API_BASE_URL=http://tu-backend:8000
```

**⚠️ IMPORTANTE:**
- Las variables `VITE_*` deben estar configuradas ANTES del build (se inyectan en tiempo de compilación)
- NO necesitas `PORT=80` porque Nginx usa el puerto 80 internamente

### 6. Configuración de Processes (Opcional)

**Nota:** Normalmente NO es necesario configurar procesos porque el Dockerfile ya tiene un CMD explícito que inicia Nginx. Sin embargo, si Easypanel lo requiere o si quieres tener control adicional:

1. Ve a la sección **"Processes"**
2. Si aparece un proceso por defecto (ej: `nodejs-server`), puedes:
   - **Opción A:** Eliminarlo (el Dockerfile maneja el inicio)
   - **Opción B:** Deshabilitarlo (toggle "Enabled" a OFF)

**Si necesitas crear un proceso personalizado:**
- **Name:** `nginx-server` (o el que prefieras)
- **Command:** `nginx -g 'daemon off;'`
- **Directory:** `/` (raíz del contenedor)
- **Enabled:** `ON`

**⚠️ IMPORTante:** El Dockerfile ya tiene el CMD configurado, así que normalmente no necesitas configurar procesos.

### 7. Configuración de Start Command

En la sección **"Start Command"** o **"Run Command"**:

- **Dejar vacío** (el Dockerfile tiene CMD configurado)

El Dockerfile ya incluye:
```dockerfile
CMD ["sh", "-c", "nginx -t && nginx -g 'daemon off;'"]
```

Esto valida la configuración de Nginx antes de iniciarlo.

---

## 📦 Opción B: Configuración SIN Dockerfile (Deployment Script)

Esta opción ejecuta el build y el servidor directamente sin usar Dockerfile.

### 1. Crear el Box

1. En Easypanel, ve a tu proyecto
2. Haz clic en **"+ Service"** o **"Templates"**
3. Selecciona **"Box"** como tipo de servicio
4. Asigna un nombre (ej: `camara-front-back-main-frontend-box`)

### 2. Configuración del Repositorio (Source)

En la sección **"Source"**:

- **Owner:** `VLP-TECH`
- **Repository:** `camara-front-back-main-frontend`
- **Branch:** `main`
- **Build Path:** `/` (raíz del proyecto)

### 3. Configuración del Build

En la sección **"Build"**:

- **Método:** `Nixpacks` o `Buildpacks` (NO Dockerfile)
- O dejar sin especificar Dockerfile

### 4. Deployment Script

En la sección **"Deployment Script"**, usa:

```bash
cd /code/frontend
npm install
npm run build
supervisorctl restart vite-server
```

**Explicación:**
- `cd /code/frontend` - Va al directorio del frontend
- `npm install` - Instala las dependencias
- `npm run build` - Construye la aplicación (genera `dist/`)
- `supervisorctl restart vite-server` - Reinicia el proceso del servidor

### 5. Configuración de Processes

En la sección **"Processes"**, crea o actualiza el proceso:

**Name:** `vite-server`

**Command:**
```bash
npm start
```

**Directory:**
```
/code/frontend
```

**Enabled:** `ON`

**Explicación:**
- El comando `npm start` ejecuta `vite preview` que sirve los archivos estáticos desde `dist/`
- El puerto por defecto es `4173` (o el definido en la variable `PORT`)

### 6. Configuración de Puerto

En la sección **"Ports"** o **"Network"**:

- **Puerto interno:** `4173` (puerto de Vite preview)
- **Puerto externo:** `4173` (o el que Easypanel asigne)
- **Health Check Path:** `/` (Vite preview no tiene endpoint `/health` por defecto)

### 7. Variables de Entorno

En la sección **"Environment"**:

**Requeridas:**
```
NODE_ENV=production
PORT=4173
```

**Opcionales (si usas Supabase):**
```
VITE_SUPABASE_URL=tu-url-de-supabase
VITE_SUPABASE_ANON_KEY=tu-clave-anon
VITE_API_BASE_URL=http://tu-backend:8000
```

**⚠️ IMPORTANTE:**
- Las variables `VITE_*` deben estar configuradas ANTES del build
- `PORT=4173` define el puerto para `vite preview`

### 8. Alternativa sin supervisorctl

Si no usas supervisorctl, puedes iniciar directamente en el proceso:

**Deployment Script:**
```bash
cd /code/frontend
npm install
npm run build
```

**Process (vite-server):**
- **Name:** `vite-server`
- **Command:** `npm start`
- **Directory:** `/code/frontend`
- **Enabled:** `ON`

El proceso se iniciará automáticamente después del build.

## 📋 Checklist de Configuración (Opción B: Sin Dockerfile)

Antes de hacer deploy, verifica:

- [ ] Tipo de servicio: **Box** (no Web-App)
- [ ] Repositorio: `VLP-TECH/camara-front-back-main-frontend`
- [ ] Rama: `main`
- [ ] Build Path: `/`
- [ ] Build Method: **NO Dockerfile** (Nixpacks/Buildpacks o vacío)
- [ ] Deployment Script configurado con `cd /code/frontend`, `npm install`, `npm run build`
- [ ] Process `vite-server` configurado con `npm start` en `/code/frontend`
- [ ] Puerto interno: `4173`
- [ ] Variables de entorno configuradas (`NODE_ENV=production`, `PORT=4173`)

## 📋 Checklist de Configuración (Opción A: Con Dockerfile)

Antes de hacer deploy, verifica:

- [ ] Tipo de servicio: **Box** (no Web-App)
- [ ] Repositorio: `VLP-TECH/camara-front-back-main-frontend`
- [ ] Rama: `main`
- [ ] Build Path: `/`
- [ ] Dockerfile Path: `Dockerfile` (en la raíz)
- [ ] Build Context: `.` (raíz)
- [ ] Puerto interno: `80`
- [ ] Health Check: `/health`
- [ ] Variables de entorno configuradas (especialmente `NODE_ENV=production`)
- [ ] Procesos: Deshabilitados o eliminados (el Dockerfile maneja el inicio)

## 🚀 Deploy

### Con Dockerfile (Opción A)

1. **Guardar** toda la configuración
2. Hacer clic en **"Deploy"** o **"Deploy service"**
3. Esperar a que el build de Docker complete
4. Verificar que el contenedor esté corriendo

### Sin Dockerfile (Opción B)

1. **Guardar** toda la configuración (especialmente Deployment Script y Process)
2. Hacer clic en **"Deploy"** o **"Deploy service"**
3. El Deployment Script ejecutará `npm install` y `npm run build`
4. El Process `vite-server` iniciará automáticamente con `npm start`
5. Verificar que el proceso esté corriendo en la sección "Processes"

## ✅ Verificación Post-Deploy

### Opción A: Con Dockerfile

#### 1. Verificar Build

El build debería mostrar:
```
Step 1/XX : FROM node:18-alpine AS builder
Step 2/XX : WORKDIR /app
Step 3/XX : COPY frontend/package*.json ./
Step 4/XX : RUN npm install --no-audit && npm cache clean --force
...
Step XX/XX : FROM nginx:1.27-alpine AS runner
Step XX/XX : COPY nginx/default.conf /etc/nginx/conf.d/default.conf
Step XX/XX : RUN nginx -t
```

#### 2. Verificar Contenedor

- El contenedor debe estar en estado **"Running"**
- Los logs deben mostrar: `nginx: configuration file /etc/nginx/nginx.conf test is successful`

#### 3. Verificar Health Check

```bash
curl http://tu-servidor/health
# Debe responder: "healthy"
```

#### 4. Verificar Aplicación

- Abre la URL del box en el navegador
- Verifica que la aplicación carga correctamente
- Verifica que no haya errores en la consola (F12)

### Opción B: Sin Dockerfile

#### 1. Verificar Deployment Script

- Revisa los logs del Deployment Script
- Debe mostrar: `npm install` completado y `npm run build` exitoso
- Debe mostrar: `supervisorctl restart vite-server` ejecutado

#### 2. Verificar Process

- En la sección **"Processes"**, el proceso `vite-server` debe estar en estado **"Running"**
- Los logs del proceso deben mostrar que Vite está sirviendo en el puerto 4173

#### 3. Verificar Aplicación

- Abre la URL del box en el navegador (puerto 4173)
- Verifica que la aplicación carga correctamente
- Verifica que no haya errores en la consola (F12)
- Verifica que los archivos JS/CSS se cargan desde `/dist/`

## 🐛 Troubleshooting

### Error: "Dockerfile not found"

**Solución:**
- Verifica que el Dockerfile esté en la raíz del repositorio
- Verifica que el Dockerfile Path sea exactamente `Dockerfile` (sin `/` al inicio)
- Verifica que el Build Context sea `.` (raíz)

### Error: "Build failed - no space left on device"

**Solución:**
- El `.dockerignore` ya está configurado para excluir archivos innecesarios
- Si persiste, contacta al soporte de Easypanel para liberar espacio

### Error: "nginx: configuration file test failed"

**Solución:**
- Verifica que el archivo `nginx/default.conf` esté en el repositorio
- Verifica que el Dockerfile copie correctamente: `COPY nginx/default.conf /etc/nginx/conf.d/default.conf`
- Revisa los logs del build para ver el error específico de Nginx

### Error: "Container exits immediately"

**Solución:**
- Verifica que el CMD esté configurado en el Dockerfile
- Verifica que no haya procesos conflictivos en la sección "Processes"
- Revisa los logs del contenedor para ver el error específico

### Error: "Health check failed"

**Solución:**
- Verifica que el health check path sea `/health`
- Verifica que Nginx esté corriendo: `docker exec <container> ps aux | grep nginx`
- Verifica la configuración de Nginx: `docker exec <container> nginx -t`

### Error: "502 Bad Gateway"

**Solución:**
- Verifica que Nginx esté corriendo
- Verifica que los archivos estén en `/usr/share/nginx/html`
- Revisa los logs de Nginx: `docker exec <container> cat /var/log/nginx/error.log`

## 📝 Notas Importantes

### Arquitectura del Dockerfile

El Dockerfile usa multi-stage build:

1. **Stage 1 (builder):** Node.js 18 Alpine
   - Instala dependencias con `npm install`
   - Construye la aplicación con `npm run build`
   - Limpia node_modules y cache

2. **Stage 2 (runner):** Nginx 1.27 Alpine
   - Instala wget para health check
   - Copia archivos construidos a `/usr/share/nginx/html`
   - Copia configuración de Nginx desde `nginx/default.conf`
   - Valida configuración con `nginx -t`
   - Inicia Nginx con validación en runtime

### Archivos Importantes

- **Dockerfile** - En la raíz del proyecto
- **nginx/default.conf** - Configuración de Nginx
- **.dockerignore** - Excluye archivos innecesarios del build
- **frontend/package.json** - Dependencias del frontend

### Diferencias entre Opciones

| Aspecto | Con Dockerfile (Opción A) | Sin Dockerfile (Opción B) |
|---------|---------------------------|---------------------------|
| Build | En imagen Docker | En Deployment Script |
| Servidor | Nginx (optimizado) | Vite preview |
| Tamaño | ~25MB (imagen pequeña) | Mayor (Node.js completo) |
| Performance | Mejor (Nginx) | Buena (Vite preview) |
| Configuración | Más simple | Más flexible |
| Procesos | No necesario | Requerido (vite-server) |
| Health Check | `/health` endpoint | No disponible por defecto |

### Diferencias con Web-App

| Aspecto | Web-App | Box |
|---------|---------|-----|
| Tipo de servicio | Web-App | Box |
| Configuración | Más simple | Más flexible |
| Procesos | Automático | Configurable |
| Dockerfile | Requerido | Opcional |
| CMD | Opcional | Recomendado explícito |

### Optimizaciones Incluidas

- ✅ Imagen final pequeña (~25MB vs ~150MB+ con Node.js completo)
- ✅ Gzip compression habilitado
- ✅ Cache de assets estáticos (1 año)
- ✅ Security headers configurados
- ✅ SPA routing configurado
- ✅ Health check endpoint
- ✅ Validación de configuración en build y runtime

## 🔗 Referencias

- [Dockerfile](./Dockerfile) - Configuración de build
- [nginx/default.conf](./nginx/default.conf) - Configuración de Nginx
- [EASYPANEL.md](./EASYPANEL.md) - Guía para Web-App (referencia)
- [DEPLOY.md](./DEPLOY.md) - Guía general de despliegue
