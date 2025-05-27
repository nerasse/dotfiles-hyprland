#!/bin/bash
# filepath: ~/.config/hypr/scripts/smart_toggle_borders.sh

# --- PARAMS - Configurez vos valeurs ici ---

# --- Configuration des bordures ---
# Taille de bordure constante que Hyprland utilisera.
# Le script la rendra visible ou transparente en changeant sa couleur.
EFFECTIVE_BORDER_SIZE="1"

# Couleur pour general:col.active_border quand plusieurs fenêtres sont présentes.
# Ceci est votre '$mauve_border_grad = $mauve $surface1 45deg'
VISIBLE_BORDER_COLOR_GRADIENT="rgb(cba6f7) rgb(45475a) 45deg"

# Couleur pour general:col.active_border quand une seule fenêtre ou en plein écran (totalement transparente).
TRANSPARENT_BORDER_COLOR="rgba(00000000)"

# Couleur pour general:col.inactive_border (fenêtres non focus).
# Ceci est votre '$inactive_border_col = $mantle'
# Cette couleur sera appliquée une fois au démarrage du script et après un reload Hyprland.
INACTIVE_WINDOW_BORDER_COLOR="rgb(181825)" # $mantle

# --- Configuration du script ---
LOG_FILE="$HOME/.cache/hypr/smart_toggle_borders.log"
# Délai en secondes avant de vérifier l'état des fenêtres après un événement.
# Utile pour laisser Hyprland stabiliser son état interne.
EVENT_PROCESSING_DELAY="0.05"
# Intervalle du Watchdog en secondes pour une vérification périodique.
WATCHDOG_INTERVAL="30"

# --- FIN PARAMS ---

# set -x # Décommentez pour un débogage très détaillé

# Variable globale pour stocker la dernière couleur appliquée à col.active_border
LAST_APPLIED_ACTIVE_BORDER_COLOR=""

log() {
    local log_dir
    log_dir=$(dirname "$LOG_FILE")
    if [ ! -d "$log_dir" ]; then mkdir -p "$log_dir"; fi
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Applique la couleur pour general:col.active_border
apply_active_border_color_setting() {
    local border_color_val="$1"
    local state_name="$2"

    if [ "$border_color_val" == "$LAST_APPLIED_ACTIVE_BORDER_COLOR" ]; then
        # log "INFO: Couleur de bordure active déjà à \"$border_color_val\". Pas de changement."
        return 0
    fi

    log "COMMANDE: hyprctl keyword general:col.active_border \"$border_color_val\" (État: $state_name)"
    hyprctl keyword general:col.active_border "$border_color_val" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        log "ERREUR: La commande hyprctl a échoué pour general:col.active_border=\"$border_color_val\""
    else
        LAST_APPLIED_ACTIVE_BORDER_COLOR="$border_color_val"
    fi
}

# Fonction principale pour mettre à jour les bordures en fonction de l'état du workspace
update_active_workspace_borders() {
    sleep "$EVENT_PROCESSING_DELAY" # Délai pour la stabilité

    local active_workspace_id_json
    active_workspace_id_json=$(hyprctl activeworkspace -j)
    local active_workspace_id
    active_workspace_id=$(echo "$active_workspace_id_json" | jq -r '.id')

    if [[ -z "$active_workspace_id" || "$active_workspace_id" == "null" ]]; then
        log "Erreur: Impossible d'obtenir l'ID de l'espace de travail actif. Raw JSON: $active_workspace_id_json"
        return 1
    fi

    local clients_json
    clients_json=$(hyprctl clients -j)

    local is_fullscreen_active
    is_fullscreen_active=$(echo "$clients_json" | jq --argjson ws_id_num "$active_workspace_id" \
        '[.[] | select(.workspace.id == $ws_id_num and .fullscreen == 1)] | length')
    is_fullscreen_active=${is_fullscreen_active:-0}

    if [ "$is_fullscreen_active" -gt 0 ]; then
        log "INFO: Plein écran détecté. Bordure active: TRANSPARENTE."
        apply_active_border_color_setting "$TRANSPARENT_BORDER_COLOR" "TRANSPARENTE (plein écran)"
        return 0
    fi

    local window_count_jq_result
    window_count_jq_result=$(echo "$clients_json" | jq --argjson ws_id_num "$active_workspace_id" \
        '[.[] | select(.workspace.id == $ws_id_num and .mapped == true and .fullscreen == 0)] | length')

    if ! [[ "$window_count_jq_result" =~ ^[0-9]+$ ]]; then
        log "ERREUR: jq n'a pas renvoyé un nombre valide pour window_count. Résultat: '$window_count_jq_result'"
        apply_active_border_color_setting "$TRANSPARENT_BORDER_COLOR" "TRANSPARENTE (erreur comptage jq)"
        return 1
    fi
    
    local window_count="$window_count_jq_result"

    if [ "$window_count" -le 1 ]; then
        log "INFO: Une seule fenêtre ou zéro (non plein écran). Bordure active: TRANSPARENTE."
        apply_active_border_color_setting "$TRANSPARENT_BORDER_COLOR" "TRANSPARENTE (une/zéro fenêtre)"
    else
        log "INFO: Plusieurs fenêtres ($window_count) (non plein écran). Bordure active: VISIBLE (gradient)."
        apply_active_border_color_setting "$VISIBLE_BORDER_COLOR_GRADIENT" "VISIBLE (gradient)"
    fi
}

# Applique les configurations de base des bordures à Hyprland
apply_base_hyprland_border_config() {
    log "Configuration Hyprland: border_size=$EFFECTIVE_BORDER_SIZE, col.inactive_border=$INACTIVE_WINDOW_BORDER_COLOR"
    hyprctl --batch \
        "keyword general:border_size $EFFECTIVE_BORDER_SIZE" \
        "keyword general:col.inactive_border \"$INACTIVE_WINDOW_BORDER_COLOR\"" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        log "ERREUR: Échec de la configuration de base des bordures Hyprland."
    fi
    # Forcer la réévaluation de la couleur de la bordure active au cas où elle aurait été modifiée par le reload
    LAST_APPLIED_ACTIVE_BORDER_COLOR=""
}


# --- Initialisation et Boucle Principale ---
if [ -f "$LOG_FILE" ]; then > "$LOG_FILE"; fi 
log "Démarrage du script smart_toggle_borders (mode couleur)."

# Configuration initiale des bordures dans Hyprland
apply_base_hyprland_border_config
# Initialiser la bordure active comme transparente
apply_active_border_color_setting "$TRANSPARENT_BORDER_COLOR" "INITIALISATION"


# Déterminer HYPRLAND_INSTANCE_SIGNATURE
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    HYPRLAND_INSTANCE_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance // empty')
    if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        HYPRLAND_INSTANCE_SIGNATURE=$(ls -td "$XDG_RUNTIME_DIR"/hypr/* | head -n 1 | xargs basename 2>/dev/null)
    fi
fi

if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    log "ERREUR CRITIQUE: HYPRLAND_INSTANCE_SIGNATURE manquant."; echo "ERREUR CRITIQUE: HYPRLAND_INSTANCE_SIGNATURE manquant." >&2; exit 1;
fi
log "HYPRLAND_INSTANCE_SIGNATURE: $HYPRLAND_INSTANCE_SIGNATURE"

SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

if [ ! -S "$SOCKET_PATH" ]; then
    log "Erreur: Socket Hyprland non trouvé: $SOCKET_PATH."
    SOCKET_PATH_ALT=$(find "$XDG_RUNTIME_DIR/hypr/" -name ".socket2.sock" -print -quit 2>/dev/null)
    if [ -S "$SOCKET_PATH_ALT" ]; then SOCKET_PATH="$SOCKET_PATH_ALT"; log "Socket alternatif trouvé: $SOCKET_PATH"; else
        log "ERREUR CRITIQUE: Socket Hyprland introuvable."; echo "ERREUR CRITIQUE: Socket Hyprland introuvable." >&2; exit 1;
    fi
fi
log "Utilisation du socket: $SOCKET_PATH"

update_active_workspace_borders # Appel initial pour définir l'état correct

# Boucle Watchdog en arrière-plan
( 
    while true; do 
        sleep "$WATCHDOG_INTERVAL"
        # log "[Watchdog] Vérification périodique." # Peut être activé pour le débogage du watchdog
        update_active_workspace_borders
    done 
) &
WATCHDOG_PID=$!
log "Watchdog démarré: PID $WATCHDOG_PID"

# Fonction de nettoyage pour l'arrêt du script
cleanup() {
    log "Arrêt du script. Terminaison du watchdog PID $WATCHDOG_PID."
    if kill -0 "$WATCHDOG_PID" 2>/dev/null; then
        kill "$WATCHDOG_PID"
    fi
    log "Script smart_toggle_borders terminé."
    exit 0
}
trap cleanup SIGINT SIGTERM

log "Écoute des événements socat..."
socat -u UNIX-CONNECT:"$SOCKET_PATH" - | while read -r line; do
    # log "[EVENT RAW] $line" # Décommentez pour voir tous les événements bruts
    if echo "$line" | grep -qE "^(configreloaded|reload)"; then
        log "[EVENT] $line - Rechargement config Hyprland détecté."
        sleep 0.5 # Délai pour que Hyprland finisse de recharger
        apply_base_hyprland_border_config # Réappliquer la config de base
        update_active_workspace_borders   # Mettre à jour l'état des bordures actives
    elif echo "$line" | grep -qE "^(workspace(v2)?|monitor(removed|added)|openwindow|closewindow|movewindow(v2)?|fullscreen|changefloatingmode|activewindow(v2)?)"; then
        # log "[EVENT] $line - Déclenchement de la mise à jour des bordures."
        update_active_workspace_borders
    fi
done

# Cette partie ne sera atteinte que si socat se termine pour une raison autre qu'un signal (rare)
log "Socat s'est terminé de manière inattendue."
cleanup