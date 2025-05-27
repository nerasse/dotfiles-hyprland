#!/bin/bash

# --- Configuration ---
# Chemin vers votre dossier de fonds d'écran
WALLPAPER_DIR="$HOME/Nextcloud/Images/walls"
# Chemin vers le lien symbolique que hyprlock utilisera
SYMLINK_PATH="$HOME/.cache/current_hyprlock_bg.png"
# --- Fin de la Configuration ---

# Fonction pour afficher les erreurs et quitter
error_exit() {
    echo "Erreur (hyprlock-custom.sh): $1" >&2
    # On ne quitte pas forcément, car hyprlock pourrait encore se lancer
    # avec l'ancien fond d'écran ou un fallback si le lien existe déjà.
    # Si vous voulez absolument empêcher le lancement de hyprlock en cas d'erreur ici,
    # décommentez la ligne 'exit 1' ci-dessous.
    # exit 1
}

# 1. Vérifier si le dossier de fonds d'écran existe
if [ ! -d "$WALLPAPER_DIR" ]; then
    error_exit "Le dossier de fonds d'écran '$WALLPAPER_DIR' n'a pas été trouvé."
    # Si le dossier n'existe pas, on ne peut pas choisir de fond,
    # hyprlock utilisera ce qui est configuré ou son fallback.
else
    # 2. Choisir un fond d'écran aléatoire
    #    Trouver tous les fichiers image (png, jpg, jpeg, gif) et en choisir un au hasard
    CHOSEN_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" \) | shuf -n 1)

    # Vérifier si un fond d'écran a été trouvé
    if [ -z "$CHOSEN_WALLPAPER" ]; then
        error_exit "Aucun fichier image trouvé dans '$WALLPAPER_DIR'."
    else
        # 3. Créer/mettre à jour le lien symbolique
        #    Assurez-vous que le répertoire pour le lien symbolique existe
        if ! mkdir -p "$(dirname "$SYMLINK_PATH")"; then
            error_exit "Impossible de créer le répertoire pour le lien symbolique ($(dirname "$SYMLINK_PATH"))."
        else
            #    Créer le lien symbolique forcé (-f)
            if ! ln -sf "$CHOSEN_WALLPAPER" "$SYMLINK_PATH"; then
                error_exit "Impossible de créer/mettre à jour le lien symbolique '$SYMLINK_PATH' vers '$CHOSEN_WALLPAPER'."
            else
                 # Optionnel: Afficher le fond d'écran choisi (pour débogage, peut être commenté)
                 # echo "Hyprlock utilisera: $CHOSEN_WALLPAPER (via $SYMLINK_PATH)"
                 : # Commande vide pour que le 'else' ait quelque chose
            fi
        fi
    fi
fi

hyprlock

exit 0