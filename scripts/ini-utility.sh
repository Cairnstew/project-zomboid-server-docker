#!/usr/bin/env bash

INI_FILE="${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
SPAWNREGIONS_FILE="${HOMEDIR}/Zomboid/Server/${SERVERNAME}_spawnregions.lua"

set_config() {
    local key="$1"
    local value="$2"
    if [[ -n "$value" ]]; then
        echo "DEBUG: Setting ${key}=${value} in INI file"
        sed -i "s|^${key}=.*|${key}=${value}|" "$INI_FILE"
    else
        echo "DEBUG: Skipping ${key} because value is empty"
    fi
}

escape_sed() {
    local input="$1"
    printf '%s' "$input" | sed -e 's/[\/&]/\\&/g'
}

fix_windows_eol() {
    echo "DEBUG: Fixing Windows EOL characters in search_folder.sh"
    sed -i 's/\r$//' /server/scripts/search_folder.sh
}

update_mods() {
    if [ -n "$MOD_IDS" ]; then
        echo "DEBUG: Found Mods including $MOD_IDS"
        sed -i "s|^Mods=.*|Mods=${MOD_IDS}|" "$INI_FILE"
    else
        echo "DEBUG: No MOD_IDS found, skipping Mods update"
    fi
}

update_workshop_ids() {
    if [ -n "$WORKSHOP_IDS" ]; then
        echo "DEBUG: Found Workshop IDs including $WORKSHOP_IDS"
        sed -i "s|^WorkshopItems=.*|WorkshopItems=${WORKSHOP_IDS}|" "$INI_FILE"
    else
        echo "DEBUG: No WORKSHOP_IDS found, skipping WorkshopItems update"
    fi
}

apply_maps_from_workshop() {
    echo "DEBUG: Applying maps from workshop"
    fix_windows_eol

    local workshop_path="${HOMEDIR}/pz-dedicated/steamapps/workshop/content/108600"
    if [ -d "$workshop_path" ]; then
        echo "DEBUG: Workshop directory exists at $workshop_path"
        source /server/scripts/search_folder.sh "$workshop_path"

        if [ -f "${HOMEDIR}/maps.txt" ]; then
            local map_list
            map_list=$(<"${HOMEDIR}/maps.txt")
            rm -f "${HOMEDIR}/maps.txt"

            if [ -n "$map_list" ]; then
                echo "DEBUG: Added maps including: $map_list"
                sed -i "s|^Map=.*|Map=${map_list}Muldraugh, KY|" "$INI_FILE"

                IFS=";" read -ra maps <<< "$map_list"
                for map in "${maps[@]}"; do
                    if ! grep -q "$map" "$SPAWNREGIONS_FILE"; then
                        local path="media/maps/$map/spawnpoints.lua"
                        if [ -e "${HOMEDIR}/pz-dedicated/$path" ]; then
                            local result="{ name = \"$map\", file = \"$path\" },"
                            echo "DEBUG: Adding spawn region for map: $map"
                            sed -i "/function SpawnRegions()/,/return {/ { /return {/ a\\\\t\\t$result}" "$SPAWNREGIONS_FILE"
                        else
                            echo "DEBUG: Spawnpoints file does not exist: ${HOMEDIR}/pz-dedicated/$path"
                        fi
                    else
                        echo "DEBUG: Spawn region for map $map already exists in $SPAWNREGIONS_FILE"
                    fi
                done
            else
                echo "DEBUG: No maps found in maps.txt"
            fi
        else
            echo "DEBUG: maps.txt file not found, skipping map application"
        fi
    else
        echo "DEBUG: Workshop directory does not exist at $workshop_path"
    fi
}
