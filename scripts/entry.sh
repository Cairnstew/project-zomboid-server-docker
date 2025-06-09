#!/bin/bash

cd ${STEAMAPPDIR}

#####################################
#                                   #
# Force an update if the env is set #
#                                   #
#####################################

if [ "${FORCEUPDATE}" == "1" ]; then
  echo "FORCEUPDATE variable is set, so the server will be updated right now"
  bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" +login anonymous +app_update "${STEAMAPPID}" validate +quit
fi


######################################
#                                    #
# Process the arguments in variables #
#                                    #
######################################
#!/usr/bin/env bash

# Load helper functions
source /server/scripts/zomboid_args_functions.sh

# Build args using functions from sourced file
build_jvm_args

ARGS="${JVM_ARGS} --"

build_client_args
build_server_args
handle_server_preset

# Final debug output
echo "[DEBUG] Final ARGS: ${ARGS}"
echo "[DEBUG] JVM_ARGS: ${JVM_ARGS}"

# Use ARGS and JVM_ARGS as needed below...


# -------- INI ----------

source /server/scripts/config_functions.sh

# --- Core Settings ---
set_config "PVP" "$PVP"
set_config "PauseEmpty" "$PAUSE_EMPTY"
set_config "GlobalChat" "$GLOBAL_CHAT"
set_config "ChatStreams" "$CHAT_STREAMS"
set_config "Open" "$OPEN"
set_config "ServerWelcomeMessage" "$SERVER_WELCOME_MESSAGE"
set_config "AutoCreateUserInWhiteList" "$AUTO_CREATE_USER_IN_WHITELIST"
set_config "DisplayUserName" "$DISPLAY_USERNAME"
set_config "ShowFirstAndLastName" "$SHOW_FIRST_AND_LAST_NAME"
set_config "SpawnPoint" "$SPAWN_POINT"
set_config "SafetySystem" "$SAFETY_SYSTEM"
set_config "ShowSafety" "$SHOW_SAFETY"
set_config "SafetyToggleTimer" "$SAFETY_TOGGLE_TIMER"
set_config "SafetyCooldownTimer" "$SAFETY_COOLDOWN_TIMER"
set_config "SpawnItems" "$SPAWN_ITEMS"
set_config "DefaultPort" "$PORT"
set_config "UDPPort" "$UDPPORT"
set_config "ResetID" "$RESET_ID"
set_config "DoLuaChecksum" "$DO_LUA_CHECKSUM"
set_config "DenyLoginOnOverloadedServer" "$DENY_LOGIN_ON_OVERLOADED_SERVER"
set_config "Public" "$PUBLIC"
set_config "PublicName" "$SERVERNAME"
if [ -n "$PUBLIC_DESCRIPTION" ]; then
    set_config "PublicDescription" "$(escape_sed "$PUBLIC_DESCRIPTION")"
fi
set_config "MaxPlayers" "$MAX_PLAYERS"
set_config "PingLimit" "$PING_LIMIT"

# --- Mods and Workshop ---
update_mods
update_workshop_ids

# --- Maps and SpawnRegions ---
apply_maps_from_workshop

# --- Discord ---
if [ -n "$DISCORD_ENABLE" ]; then
    echo "DEBUG: Setting DiscordEnable=${DISCORD_ENABLE,,}"
    sed -i "s/^DiscordEnable=.*/DiscordEnable=${DISCORD_ENABLE,,}/" "$INI_FILE"
else
    echo "DEBUG: DISCORD_ENABLE not set, skipping DiscordEnable"
fi
set_config "DiscordToken" "$DISCORD_TOKEN"
set_config "DiscordChannel" "$DISCORD_CHANNEL"
set_config "DiscordChannelID" "$DISCORD_CHANNEL_ID"

# --- Anticheat ---
if [[ "${DISABLE_ANTICHEAT_ALL,,}" == "true" ]]; then
    echo "DEBUG: Disabling all anticheat protections"
    for i in {1..24}; do
        sed -i "s|^AntiCheatProtectionType${i}=.*|AntiCheatProtectionType${i}=false|" "$INI_FILE"
    done
elif [ -n "$DISABLE_ANTICHEAT" ]; then
    echo "DEBUG: Disabling anticheat protections: $DISABLE_ANTICHEAT"
    for i in $DISABLE_ANTICHEAT; do
        if [[ "$i" =~ ^[0-9]+$ ]] && [ "$i" -ge 1 ] && [ "$i" -le 24 ]; then
            sed -i "s|^AntiCheatProtectionType${i}=.*|AntiCheatProtectionType${i}=false|" "$INI_FILE"
        else
            echo "DEBUG: Invalid anticheat index: $i"
        fi
    done
else
    echo "DEBUG: No anticheat disabling requested"
fi

# --- Remaining config parameters ---
set_config "Password" "$PASSWORD"
set_config "MaxAccountsPerUser" "$MAX_ACCOUNTS_PER_USER"
set_config "AllowCoop" "$ALLOW_COOP"
set_config "SleepAllowed" "$SLEEP_ALLOWED"
set_config "SleepNeeded" "$SLEEP_NEEDED"
set_config "KnockedDownAllowed" "$KNOCKED_DOWN_ALLOWED"
set_config "SneakModeHideFromOtherPlayers" "$SNEAK_MODE_HIDE_FROM_PLAYERS"
set_config "SteamScoreboard" "$STEAM_SCOREBOARD"
set_config "SteamVAC" "$STEAMVAC"
set_config "UPnP" "$UPNP"
set_config "VoiceEnable" "$VOICE_ENABLE"
set_config "VoiceMinDistance" "$VOICE_MIN_DISTANCE"
set_config "VoiceMaxDistance" "$VOICE_MAX_DISTANCE"
set_config "Voice3D" "$VOICE_3D"
set_config "SpeedLimit" "$SPEED_LIMIT"
set_config "LoginQueueEnabled" "$LOGIN_QUEUE_ENABLED"
set_config "LoginQueueConnectTimeout" "$LOGIN_QUEUE_CONNECT_TIMEOUT"
set_config "server_browser_announced_ip" "$SERVER_BROWSER_ANNOUNCED_IP"
set_config "PlayerRespawnWithSelf" "$PLAYER_RESPAWN_WITH_SELF"
set_config "PlayerRespawnWithOther" "$PLAYER_RESPAWN_WITH_OTHER"
set_config "FastForwardMultiplier" "$FAST_FORWARD_MULTIPLIER"
set_config "DisableSafehouseWhenPlayerConnected" "$DISABLE_SAFEHOUSE_WHEN_PLAYER_CONNECTED"
set_config "Faction" "$FACTION"
set_config "FactionDaySurvivedToCreate" "$FACTION_DAY_SURVIVED_TO_CREATE"
set_config "FactionPlayersRequiredForTag" "$FACTION_PLAYERS_REQUIRED_FOR_TAG"
set_config "DisableRadioStaff" "$DISABLE_RADIO_STAFF"
set_config "DisableRadioAdmin" "$DISABLE_RADIO_ADMIN"
set_config "DisableRadioGM" "$DISABLE_RADIO_GM"
set_config "DisableRadioOverseer" "$DISABLE_RADIO_OVERSEER"
set_config "DisableRadioModerator" "$DISABLE_RADIO_MODERATOR"
set_config "DisableRadioInvisible" "$DISABLE_RADIO_INVISIBLE"
set_config "ClientCommandFilter" "$CLIENT_COMMAND_FILTER"
set_config "ClientActionLogs" "$CLIENT_ACTION_LOGS"
set_config "PerkLogs" "$PERK_LOGS"
set_config "ItemNumbersLimitPerContainer" "$ITEM_LIMIT_PER_CONTAINER"
set_config "BloodSplatLifespanDays" "$BLOOD_SPLAT_LIFESPAN_DAYS"
set_config "AllowNonAsciiUsername" "$ALLOW_NON_ASCII_USERNAME"
set_config "BanKickGlobalSound" "$BAN_KICK_GLOBAL_SOUND"
set_config "RemovePlayerCorpsesOnCorpseRemoval" "$REMOVE_PLAYER_CORPSES"
set_config "TrashDeleteAll" "$TRASH_DELETE_ALL"
set_config "PVPMeleeWhileHitReaction" "$PVP_MELEE_WHILE_HIT"
set_config "MouseOverToSeeDisplayName" "$MOUSEOVER_TO_SEE_NAME"
set_config "HidePlayersBehindYou" "$HIDE_PLAYERS_BEHIND"
set_config "PVPMeleeDamageModifier" "$PVP_MELEE_DAMAGE"
set_config "PVPFirearmDamageModifier" "$PVP_FIREARM_DAMAGE"
set_config "CarEngineAttractionModifier" "$CAR_ENGINE_ATTRACTION"
set_config "PlayerBumpPlayer" "$PLAYER_BUMP_PLAYER"
set_config "MapRemotePlayerVisibility" "$MAP_REMOTE_VISIBILITY"
set_config "BackupsCount" "$BACKUPS_COUNT"
set_config "BackupsOnStart" "$BACKUPS_ON_START"
set_config "BackupsOnVersionChange" "$BACKUPS_ON_VERSION_CHANGE"
set_config "BackupsPeriod" "$BACKUPS_PERIOD"
set_config "RCONPort" "$RCON_PORT"
set_config "RCONPassword" "$RCON_PASSWORD"
set_config "ServerPlayerID" "$SERVER_PLAYER_ID"


# Fix to a bug in start-server.sh that causes to no preload a library:
# ERROR: ld.so: object 'libjsig.so' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.
export LD_LIBRARY_PATH="${STEAMAPPDIR}/jre64/lib:${LD_LIBRARY_PATH}"

## Fix the permissions in the data and workshop folders
chown -R 1000:1000 /home/steam/pz-dedicated/steamapps/workshop /home/steam/Zomboid

# Run the debug script before starting the server
/server/scripts/debug_env.sh

su - steam -c "export LANG=${LANG} && export LD_LIBRARY_PATH=\"${STEAMAPPDIR}/jre64/lib:${LD_LIBRARY_PATH}\" && cd ${STEAMAPPDIR} && pwd && ./start-server.sh ${ARGS}"
#exec bash
