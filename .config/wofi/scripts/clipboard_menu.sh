#!/bin/bash
# filepath: ~/.config/wofi/scripts/clipboard_menu.sh

# Script to display cliphist history with wofi and paste selection, using notifications

MAX_LENGTH=85
MAX_ENTRIES=30

# TABS_PREFIX="                        " # Moins utile si on ne l'utilise qu'une fois
DELETE_HISTORY_OPTION="                        --- DELETE/CLEAR HISTORY --- (clear, delete)" # Préfixe conservé pour l'alignement visuel

# Créez ce fichier CSS s'il n'existe pas, avec un contenu minimal pour désactiver les animations
# Voir le contenu suggéré pour clipboard_menu_wofi.css ci-dessous.

mapfile -t original_entries_array < <(cliphist list | head -n $MAX_ENTRIES)

display_options_list=()
idx=0
while [ $idx -lt ${#original_entries_array[@]} ]; do
    line="${original_entries_array[$idx]}"

    # Optimisation: Remplacer sed par une expression régulière Bash
    content_for_display="$line" # Valeur par défaut si le motif n'est pas trouvé
    if [[ "$line" =~ ^[0-9]+[[:space:]]+(.*)$ ]]; then
        content_for_display="${BASH_REMATCH[1]}"
    fi

    display_idx=$((idx + 1))
    truncated_line="$content_for_display"
    if [ "${#content_for_display}" -gt "$MAX_LENGTH" ]; then
        truncated_line="${content_for_display:0:$MAX_LENGTH}..."
    fi
    display_options_list+=("$display_idx     $truncated_line")
    ((idx++))
done

display_options_string=$(printf "%s\n" "${display_options_list[@]}")
options_for_wofi=$(printf "%s\n%s" "$display_options_string" "$DELETE_HISTORY_OPTION")

# Optimisation: Utiliser --style avec wofi
selection_from_wofi=$(echo -e "$options_for_wofi" | wofi --dmenu -p "📋 Clipboard History")
exit_code_wofi=$?

if [ $exit_code_wofi -eq 0 ] && [ -n "$selection_from_wofi" ]; then
    if [ "$selection_from_wofi" == "$DELETE_HISTORY_OPTION" ]; then
        # Utiliser wofi --style ici aussi pour la cohérence, si désiré
        confirm=$(echo -e "No\nYes" | wofi --dmenu -p "Are you sure you want to delete all clipboard history?")
        if [ "$confirm" == "Yes" ]; then
            cliphist wipe
            if [ $? -eq 0 ]; then
                notify-send "Clipboard History Deleted" "All entries have been removed."
            else
                notify-send "Error" "Failed to delete clipboard history."
                exit 1 # Quitter avec un code d'erreur
            fi
        else
            notify-send "Operation Cancelled" "Clipboard history was not deleted."
        fi
    else
        selected_display_idx=$(echo "$selection_from_wofi" | cut -d' ' -f1) # cut est généralement rapide
        selected_array_idx=$((selected_display_idx - 1))
        # Vérifier si l'index est valide pour éviter les erreurs
        if [ $selected_array_idx -ge 0 ] && [ $selected_array_idx -lt ${#original_entries_array[@]} ]; then
            original_selected_entry="${original_entries_array[$selected_array_idx]}"
            content=$(echo "$original_selected_entry" | cliphist decode) # cliphist decode est une opération externe nécessaire
            char_count=${#content}
            # Envoi de notification conditionnel (pas critique pour la perf, mais bon usage)
            if [ $char_count -gt 10 ]; then
                notify-send "Droped $char_count characters" "${content:0:50}..."
            elif [ $char_count -gt 0 ]; then # Pour ne pas notifier si le contenu est vide
                 notify-send "Droped $char_count characters" "$content"
            fi
            echo -n "$content" | wl-copy # wl-copy est une opération externe nécessaire
            if [ $? -eq 0 ]; then
                wtype -M ctrl -M shift v -m shift -m ctrl # wtype est externe
            else
                notify-send "Error" "Failed to copy to clipboard."
                exit 1 # Quitter avec un code d'erreur
            fi
        else
            notify-send "Error" "Invalid selection index."
            exit 1 # Quitter avec un code d'erreur
        fi
    fi
fi

exit $exit_code_wofi