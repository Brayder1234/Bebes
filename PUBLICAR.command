#!/bin/bash
# ================================================================
#  Publicar la landing "MegaKit Adiós Pantallas" en GitHub Pages
#  Doble clic en este archivo. Solo tienes que autorizar una vez.
# ================================================================
cd "$(dirname "$0")" || exit 1

REPO="megakit-adios-pantallas"

echo ""
echo "======================================================"
echo "  Publicando: MegaKit Adiós Pantallas"
echo "======================================================"
echo ""

# 1) Asegurar GitHub CLI
if ! command -v gh >/dev/null 2>&1; then
  echo "→ Instalando GitHub CLI (gh)..."
  if command -v brew >/dev/null 2>&1; then brew install gh; else
    echo "✗ No encontré Homebrew. Instálalo desde https://brew.sh y vuelve a intentar."
    read -r -p "Enter para cerrar..."; exit 1
  fi
fi

# 2) Autenticación (solo la primera vez abre el navegador)
if ! gh auth status >/dev/null 2>&1; then
  echo "→ Necesitas conectar tu cuenta de GitHub (se abrirá el navegador)."
  echo "  Elige:  GitHub.com  →  HTTPS  →  Login with a web browser"
  echo ""
  gh auth login || { echo "✗ No se completó el login."; read -r -p "Enter para cerrar..."; exit 1; }
fi

OWNER=$(gh api user -q .login 2>/dev/null)
echo "→ Cuenta: $OWNER"

# 3) Crear el repositorio y subir (o solo subir si ya existe)
if git remote get-url origin >/dev/null 2>&1; then
  echo "→ El repositorio ya estaba conectado. Subiendo cambios..."
  git add -A && git commit -m "Actualizar landing" >/dev/null 2>&1
  git push -u origin main
else
  echo "→ Creando repositorio público '$REPO' y subiendo la landing..."
  gh repo create "$REPO" --public --source=. --remote=origin --push \
    --description "Landing MegaKit Adiós Pantallas" || {
      echo "✗ No se pudo crear el repo (¿ya existe uno con ese nombre?)."; read -r -p "Enter para cerrar..."; exit 1; }
fi

# 4) Activar GitHub Pages (hosting gratis)
echo "→ Activando el hosting (GitHub Pages)..."
gh api --method POST "/repos/$OWNER/$REPO/pages" \
  -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 \
  && echo "  ✔ Hosting activado." \
  || echo "  (El hosting ya estaba activo o se activará en un momento.)"

URL="https://$OWNER.github.io/$REPO/"
echo ""
echo "======================================================"
echo "  ✅ LISTO. Tu landing estará en vivo en ~1-2 minutos:"
echo ""
echo "     $URL"
echo ""
echo "======================================================"
echo ""
sleep 2
open "$URL" 2>/dev/null
read -r -p "Enter para cerrar esta ventana..."
