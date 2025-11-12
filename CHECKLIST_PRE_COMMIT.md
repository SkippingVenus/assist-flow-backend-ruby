# ✅ Checklist Pre-Commit

Antes de hacer commit y subir tu código, verifica:

## 🔐 Seguridad

- [ ] El archivo `.env` NO está siendo trackeado por git
- [ ] NO hay credenciales hardcodeadas en el código
- [ ] NO hay tokens o API keys en el código
- [ ] Las contraseñas de ejemplo en la documentación son genéricas
- [ ] El archivo `.env.example` está actualizado (sin valores reales)

## 📝 Código

- [ ] El código compila sin errores: `rails server` (Ctrl+C para detener)
- [ ] Los tests pasan (si los tienes): `rspec`
- [ ] No hay código comentado innecesario
- [ ] No hay `binding.pry` o `byebug` olvidados
- [ ] No hay `console.log` o `puts` de debugging
- [ ] Los nombres de variables son descriptivos
- [ ] El código sigue las convenciones del proyecto

## 📚 Documentación

- [ ] README.md está actualizado
- [ ] API_DOCUMENTATION.md refleja los endpoints actuales
- [ ] Comentarios importantes están en el código
- [ ] Nuevas funcionalidades están documentadas

## 🗂️ Archivos

- [ ] Solo archivos necesarios están siendo agregados
- [ ] No se están subiendo archivos temporales
- [ ] No se están subiendo logs
- [ ] Los archivos binarios grandes no están incluidos

## 🧪 Testing

- [ ] Probaste las funcionalidades nuevas manualmente
- [ ] Los endpoints funcionan correctamente
- [ ] La autenticación JWT funciona
- [ ] Las validaciones funcionan como esperado

## 📦 Dependencias

- [ ] Si agregaste gems, actualizaste el `Gemfile`
- [ ] Ejecutaste `bundle install`
- [ ] El `Gemfile.lock` está actualizado

## 🔍 Revisión Final

```bash
# Ver qué archivos se van a subir
git status

# Ver cambios específicos
git diff

# Ver archivos ignorados (para confirmar que .env está ahí)
git status --ignored
```

## ⚠️ IMPORTANTE: Verificar .env

Ejecuta este comando para confirmar que `.env` está ignorado:

```bash
git check-ignore .env
```

Si retorna `.env`, está bien ignorado ✅
Si no retorna nada, ¡PELIGRO! ❌ El archivo podría subirse.

## 📋 Comandos de Verificación Rápida

```powershell
# En PowerShell (Windows)
cd "c:\Users\Omen\Documents\PrograMovil_Front\assist-flow-backend-ruby"

# Verificar que .env está ignorado
git check-ignore .env

# Ver qué se va a subir
git status

# Ver archivos grandes
git ls-files | ForEach-Object { Get-Item $_ } | Where-Object { $_.Length -gt 1MB } | Select-Object Name, Length
```

## ✅ Todo Listo? Procede con:

```bash
git add .
git commit -m "Tu mensaje descriptivo aquí"
git push
```

## 🚨 Si Accidentalmente Subiste .env

```bash
# Eliminar del repositorio pero mantener local
git rm --cached .env

# Commit del cambio
git commit -m "Remove .env from repository"

# Subir
git push

# Agregar .env al .gitignore si no está
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Add .env to gitignore"
git push
```

## 📊 Información del Proyecto Actual

**Archivos que serán ignorados:**
- `/log/*` - Logs de la aplicación
- `/tmp/*` - Archivos temporales
- `.env` - Variables de entorno
- `/coverage/*` - Reportes de cobertura
- `/storage/*` - Archivos subidos
- `.byebug_history` - Historial de debugging
- `/node_modules` - Dependencias JS

**Archivos importantes que SÍ se suben:**
- `app/**/*` - Todo el código fuente
- `config/**/*` - Configuración (excepto secrets)
- `db/migrate/*` - Migraciones
- `Gemfile` y `Gemfile.lock` - Dependencias
- `.env.example` - Template de variables
- `*.md` - Toda la documentación
- `.gitignore` - Este archivo mismo

## 💡 Tips

- **Commits frecuentes**: Mejor muchos commits pequeños que uno grande
- **Mensajes claros**: Describe qué y por qué, no cómo
- **Ramas para features**: Usa ramas para nuevas funcionalidades
- **Pull antes de Push**: Siempre haz `git pull` antes de `git push`

---

**Último check antes de subir:**
```bash
# ¿El .env está ignorado?
git check-ignore .env

# ¿Hay algo raro en el status?
git status

# ¿Los cambios son correctos?
git diff --staged
```

Si todo está ✅, ¡adelante con el push! 🚀
