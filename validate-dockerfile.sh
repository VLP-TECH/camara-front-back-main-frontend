#!/bin/bash

# Script de validación del Dockerfile
# Verifica que todos los archivos necesarios existan y la estructura sea correcta

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Validando Dockerfile...${NC}\n"

ERRORS=0

# Verificar que el Dockerfile existe
if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}✗ Dockerfile no encontrado${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Dockerfile existe${NC}"
fi

# Verificar directorio frontend
if [ ! -d "frontend" ]; then
    echo -e "${RED}✗ Directorio frontend no encontrado${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Directorio frontend existe${NC}"
fi

# Verificar package.json
if [ ! -f "frontend/package.json" ]; then
    echo -e "${RED}✗ frontend/package.json no encontrado${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ frontend/package.json existe${NC}"
    
    # Verificar script build
    if grep -q '"build"' frontend/package.json; then
        echo -e "${GREEN}✓ Script 'build' existe en package.json${NC}"
    else
        echo -e "${RED}✗ Script 'build' NO existe en package.json${NC}"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Verificar package-lock.json
if [ ! -f "frontend/package-lock.json" ]; then
    echo -e "${YELLOW}⚠ frontend/package-lock.json no encontrado (npm ci puede fallar)${NC}"
else
    echo -e "${GREEN}✓ frontend/package-lock.json existe${NC}"
fi

# Verificar vite.config.ts
if [ ! -f "frontend/vite.config.ts" ]; then
    echo -e "${YELLOW}⚠ frontend/vite.config.ts no encontrado${NC}"
else
    echo -e "${GREEN}✓ frontend/vite.config.ts existe${NC}"
fi

# Verificar estructura del Dockerfile
echo -e "\n${YELLOW}📋 Verificando estructura del Dockerfile...${NC}"

# Verificar que tiene FROM node
if grep -q "^FROM node" Dockerfile; then
    echo -e "${GREEN}✓ Stage builder (node) encontrado${NC}"
else
    echo -e "${RED}✗ Stage builder (node) NO encontrado${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Verificar que tiene FROM nginx
if grep -q "^FROM nginx" Dockerfile; then
    echo -e "${GREEN}✓ Stage runner (nginx) encontrado${NC}"
else
    echo -e "${RED}✗ Stage runner (nginx) NO encontrado${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Verificar COPY de package.json
if grep -q "COPY frontend/package" Dockerfile; then
    echo -e "${GREEN}✓ COPY de package.json encontrado${NC}"
else
    echo -e "${RED}✗ COPY de package.json NO encontrado${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Verificar COPY de dist
if grep -q "COPY --from=builder.*dist" Dockerfile; then
    echo -e "${GREEN}✓ COPY de dist encontrado${NC}"
else
    echo -e "${RED}✗ COPY de dist NO encontrado${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Verificar EXPOSE
if grep -q "^EXPOSE" Dockerfile; then
    echo -e "${GREEN}✓ EXPOSE encontrado${NC}"
else
    echo -e "${RED}✗ EXPOSE NO encontrado${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Verificar HEALTHCHECK
if grep -q "^HEALTHCHECK" Dockerfile; then
    echo -e "${GREEN}✓ HEALTHCHECK encontrado${NC}"
else
    echo -e "${YELLOW}⚠ HEALTHCHECK NO encontrado (opcional)${NC}"
fi

# Verificar instalación de wget
if grep -q "apk add.*wget" Dockerfile; then
    echo -e "${GREEN}✓ Instalación de wget encontrada${NC}"
else
    echo -e "${YELLOW}⚠ Instalación de wget NO encontrada (puede causar problemas en health check)${NC}"
fi

# Resumen
echo -e "\n${YELLOW}═══════════════════════════════════════${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Validación completada sin errores${NC}"
    echo -e "${GREEN}El Dockerfile parece estar correctamente configurado${NC}"
    exit 0
else
    echo -e "${RED}❌ Validación completada con $ERRORS error(es)${NC}"
    echo -e "${RED}Por favor corrige los errores antes de hacer build${NC}"
    exit 1
fi
