#!/bin/bash

# Chemin vers votre dossier de fonds d'écran
WALLPAPER_DIR="$HOME/Nextcloud/Images/walls"

# Vérifiez si le dossier existe et contient des images
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \))" ]; then
  echo "Le dossier de fonds d'écran n'existe pas ou ne contient aucune image."
  exit 1
fi

# Choix d'une image aléatoire (PNG, JPG, JPEG)
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) -print0 | shuf -z -n 1)

if [ -z "$RANDOM_WALLPAPER" ]; then
  echo "Aucun fond d'écran trouvé."
  exit 1
fi

# Options pour swww (vous pouvez les personnaliser)
SWWW_PARAMS=(
    "--transition-type" "random"  # Ou "wipe", "grow", "center", "any", "simple", "left", "right", "top", "bottom", "outer" etc.
    "--transition-fps" "60"
    "--transition-duration" "1.0" # Durée de la transition en secondes
    # "--transition-step" "255" # Pour certaines transitions comme wipe, grow
    # "--outputs" "eDP-1,DP-1" # Spécifiez les écrans si besoin, sinon s'applique à tous
)

# Initialiser swww daemon s'il n'est pas déjà lancé
if ! pgrep -x swww-daemon > /dev/null; then
    swww init
    # Attendre un court instant que le daemon soit prêt
    sleep 1
fi

# Changer le fond d'écran avec swww
swww img "${SWWW_PARAMS[@]}" "$RANDOM_WALLPAPER"

echo "Fond d'écran changé en : $RANDOM_WALLPAPER avec la transition ${SWWW_PARAMS[1]}"