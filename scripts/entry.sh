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
ARGS=""

# Set the server memory. Units are accepted (1024m=1Gig, 2048m=2Gig, 4096m=4Gig): Example: 1024m
if [ -n "${MEMORY}" ]; then
  ARGS="${ARGS} -Xmx${MEMORY} -Xms${MEMORY}"
fi

if [ "${ZOMBOID_STEAM}" == "1" ] || [ "${ZOMBOID_STEAM,,}" == "true" ]; then
  JVM_ARGS="${JVM_ARGS} -Dzomboid.steam=1"
elif [ "${ZOMBOID_STEAM}" == "0" ] || [ "${ZOMBOID_STEAM,,}" == "false" ]; then
  JVM_ARGS="${JVM_ARGS} -Dzomboid.steam=0"
fi

if [ -n "${DEPLOYMENT_USER_CACHEDIR}" ]; then
  JVM_ARGS="${JVM_ARGS} -Ddeployment.user.cachedir=\"${DEPLOYMENT_USER_CACHEDIR}\""
fi

if [ "${SOFTRESET}" == "1" ] || [ "${SOFTRESET,,}" == "true" ]; then
  JVM_ARGS="${JVM_ARGS} -Dsoftreset"
fi

if [ "${DEBUG_JVM}" == "1" ] || [ "${DEBUG_JVM,,}" == "true" ]; then
  JVM_ARGS="${JVM_ARGS} -Ddebug"
fi

# End of Java arguments
ARGS="${ARGS} -- "

# ------------ CLIENT --------------

if [ "${SAFEMODE}" == "1" ] || [ "${SAFEMODE,,}" == "true" ]; then
  ARGS="${ARGS} -safemode"
fi

if [ "${NOSOUND}" == "1" ] || [ "${NOSOUND,,}" == "true" ]; then
  ARGS="${ARGS} -nosound"
fi

if [ "${AITEST}" == "1" ] || [ "${AITEST,,}" == "true" ]; then
  ARGS="${ARGS} -aitest"
fi

if [ "${NOVOIP}" == "1" ] || [ "${NOVOIP,,}" == "true" ]; then
  ARGS="${ARGS} -novoip"
fi

if [ "${DEBUG}" == "1" ] || [ "${DEBUG,,}" == "true" ]; then
  ARGS="${ARGS} -debug"
fi

if [ -n "${DEBUGLOG_CLIENT}" ]; then
  ARGS="${ARGS} -debuglog=${DEBUGLOG_CLIENT}"
fi

if [ -n "${CONNECT}" ]; then
  ARGS="${ARGS} +connect ${CONNECT}"
fi

if [ -n "${PASSWORD}" ]; then
  ARGS="${ARGS} +password ${PASSWORD}"
fi

if [ "${DEBUGTRANSLATION}" == "1" ] || [ "${DEBUGTRANSLATION,,}" == "true" ]; then
  ARGS="${ARGS} -debugtranslation"
fi

if [ -n "${MODFOLDERS}" ]; then
  ARGS="${ARGS} -modfolders ${MODFOLDERS}"
fi

if [ "${IMGUI}" == "1" ] || [ "${IMGUI,,}" == "true" ]; then
  ARGS="${ARGS} -imgui"
fi

if [ "${IMGUIDEBUGVIEWPORTS}" == "1" ] || [ "${IMGUIDEBUGVIEWPORTS,,}" == "true" ]; then
  ARGS="${ARGS} -imguidebugviewports"
fi

# ------------ CLIENT --------------

# ------------ SERVER --------------


if [ -n "${DISABLELOG}" ]; then
  ARGS="${ARGS} -disablelog=${DISABLELOG}"
fi

if [ -n "${DEBUGLOG}" ]; then
  ARGS="${ARGS} -debuglog=${DEBUGLOG}"
fi

if [ -n "${ADMINUSERNAME}" ]; then
  ARGS="${ARGS} -adminusername ${ADMINUSERNAME}"
fi

if [ -n "${ADMINPASSWORD}" ]; then
  ARGS="${ARGS} -adminpassword ${ADMINPASSWORD}"
fi


if [ -n "${STATISTIC}" ]; then
  ARGS="${ARGS} -statistic ${STATISTIC}"
fi

if [ -n "${PORT}" ]; then
  ARGS="${ARGS} -port ${PORT}"
fi

if [ -n "${UDPPORT}" ]; then
  ARGS="${ARGS} -udpport ${UDPPORT}"
fi

if [ "${STEAMVAC}" == "1" ] || [ "${STEAMVAC,,}" == "true" ]; then
  ARGS="${ARGS} -steamvac true"
elif [ "${STEAMVAC,,}" == "false" ]; then
  ARGS="${ARGS} -steamvac false"
fi

# You can choose a different servername by using this option when starting the server.
if [ -n "${SERVERNAME}" ]; then
  ARGS="${ARGS} -servername \"${SERVERNAME}\""
else
  # If not servername is set, use the default name in the next step
  SERVERNAME="servertest"
fi

# ------------ SERVER --------------


# If preset is set, then the config file is generated when it doesn't exists or SERVERPRESETREPLACE is set to True.
if [ -n "${SERVERPRESET}" ]; then
  # If preset file doesn't exists then show an error and exit
  if [ ! -f "${STEAMAPPDIR}/media/lua/shared/Sandbox/${SERVERPRESET}.lua" ]; then
    echo "*** ERROR: the preset ${SERVERPRESET} doesn't exists. Please fix the configuration before start the server ***"
    exit 1
  # If SandboxVars files doesn't exists or replace is true, copy the file
  elif [ ! -f "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua" ] || [ "${SERVERPRESETREPLACE,,}" == "true" ]; then
    echo "*** INFO: New server will be created using the preset ${SERVERPRESET} ***"
    echo "*** Copying preset file from \"${STEAMAPPDIR}/media/lua/shared/Sandbox/${SERVERPRESET}.lua\" to \"${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua\" ***"
    mkdir -p "${HOMEDIR}/Zomboid/Server/"
    cp -nf "${STEAMAPPDIR}/media/lua/shared/Sandbox/${SERVERPRESET}.lua" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
    sed -i "1s/return.*/SandboxVars = \{/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
    # Remove carriage return
    dos2unix "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
    # I have seen that the file is created in execution mode (755). Change the file mode for security reasons.
    chmod 644 "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
  fi
fi



# -------- INI ----------

if [ -n "${PVP}" ]; then
  sed -i "s|^PVP=.*|PVP=${PVP}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${PAUSE_EMPTY}" ]; then
  sed -i "s|^PauseEmpty=.*|PauseEmpty=${PAUSE_EMPTY}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${GLOBAL_CHAT}" ]; then
  sed -i "s|^GlobalChat=.*|GlobalChat=${GLOBAL_CHAT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${CHAT_STREAMS}" ]; then
  sed -i "s|^ChatStreams=.*|ChatStreams=${CHAT_STREAMS}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${OPEN}" ]; then
  sed -i "s|^Open=.*|Open=${OPEN}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SERVER_WELCOME_MESSAGE}" ]; then
  sed -i "s|^ServerWelcomeMessage=.*|ServerWelcomeMessage=${SERVER_WELCOME_MESSAGE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${AUTO_CREATE_USER_IN_WHITELIST}" ]; then
  sed -i "s|^AutoCreateUserInWhiteList=.*|AutoCreateUserInWhiteList=${AUTO_CREATE_USER_IN_WHITELIST}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DISPLAY_USERNAME}" ]; then
  sed -i "s|^DisplayUserName=.*|DisplayUserName=${DISPLAY_USERNAME}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SHOW_FIRST_AND_LAST_NAME}" ]; then
  sed -i "s|^ShowFirstAndLastName=.*|ShowFirstAndLastName=${SHOW_FIRST_AND_LAST_NAME}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SPAWN_POINT}" ]; then
  sed -i "s|^SpawnPoint=.*|SpawnPoint=${SPAWN_POINT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SAFETY_SYSTEM}" ]; then
  sed -i "s|^SafetySystem=.*|SafetySystem=${SAFETY_SYSTEM}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SHOW_SAFETY}" ]; then
  sed -i "s|^ShowSafety=.*|ShowSafety=${SHOW_SAFETY}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SAFETY_TOGGLE_TIMER}" ]; then
  sed -i "s|^SafetyToggleTimer=.*|SafetyToggleTimer=${SAFETY_TOGGLE_TIMER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SAFETY_COOLDOWN_TIMER}" ]; then
  sed -i "s|^SafetyCooldownTimer=.*|SafetyCooldownTimer=${SAFETY_COOLDOWN_TIMER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SPAWN_ITEMS}" ]; then
  sed -i "s|^SpawnItems=.*|SpawnItems=${SPAWN_ITEMS}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DEFAULT_PORT}" ]; then
  sed -i "s|^DefaultPort=.*|DefaultPort=${DEFAULT_PORT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${UDP_PORT}" ]; then
  sed -i "s|^UDPPort=.*|UDPPort=${UDP_PORT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${RESET_ID}" ]; then
  sed -i "s|^ResetID=.*|ResetID=${RESET_ID}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi


if [ -n "${MOD_IDS}" ]; then
 	echo "*** INFO: Found Mods including ${MOD_IDS} ***"
	sed -i "s/Mods=.*/Mods=${MOD_IDS}/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Fixes EOL in script file for good measure
sed -i 's/\r$//' /server/scripts/search_folder.sh
# Check 'search_folder.sh' script for details
if [ -e "${HOMEDIR}/pz-dedicated/steamapps/workshop/content/108600" ]; then

  map_list=""
  source /server/scripts/search_folder.sh "${HOMEDIR}/pz-dedicated/steamapps/workshop/content/108600"
  map_list=$(<"${HOMEDIR}/maps.txt")  
  rm "${HOMEDIR}/maps.txt"

  if [ -n "${map_list}" ]; then
    echo "*** INFO: Added maps including ${map_list} ***"
    sed -i "s/Map=.*/Map=${map_list}Muldraugh, KY/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"

    # Checks which added maps have spawnpoints.lua files and adds them to the spawnregions file if they aren't already added
    IFS=";" read -ra strings <<< "$map_list"
    for string in "${strings[@]}"; do
        if ! grep -q "$string" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_spawnregions.lua"; then
          if [ -e "${HOMEDIR}/pz-dedicated/media/maps/$string/spawnpoints.lua" ]; then
            result="{ name = \"$string\", file = \"media/maps/$string/spawnpoints.lua\" },"
            sed -i "/function SpawnRegions()/,/return {/ {    /return {/ a\
            \\\t\t$result
            }" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_spawnregions.lua"
          fi
        fi
    done
  fi 
fi

if [ -n "${DO_LUA_CHECKSUM}" ]; then
  sed -i "s|^DoLuaChecksum=.*|DoLuaChecksum=${DO_LUA_CHECKSUM}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DENY_LOGIN_ON_OVERLOADED_SERVER}" ]; then
  sed -i "s|^DenyLoginOnOverloadedServer=.*|DenyLoginOnOverloadedServer=${DENY_LOGIN_ON_OVERLOADED_SERVER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi


if [ -n "${PUBLIC}" ]; then
  sed -i "s|^Public=.*|Public=${PUBLIC}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${PUBLIC_NAME}" ]; then
  sed -i "s|^PublicName=.*|PublicName=${PUBLIC_NAME}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${PUBLIC_DESCRIPTION}" ]; then
  # Escape any forward slashes in the description for sed
  ESCAPED_DESC=$(printf '%s\n' "${PUBLIC_DESCRIPTION}" | sed 's/[\/&]/\\&/g')
  sed -i "s|^PublicDescription=.*|PublicDescription=${ESCAPED_DESC}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${MAX_PLAYERS}" ]; then
  sed -i "s|^MaxPlayers=.*|MaxPlayers=${MAX_PLAYERS}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${PING_LIMIT}" ]; then
  sed -i "s|^PingLimit=.*|PingLimit=${PING_LIMIT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${HOURS_FOR_LOOT_RESPAWN}" ]; then
  sed -i "s|^HoursForLootRespawn=.*|HoursForLootRespawn=${HOURS_FOR_LOOT_RESPAWN}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${MAX_ITEMS_FOR_LOOT_RESPAWN}" ]; then
  sed -i "s|^MaxItemsForLootRespawn=.*|MaxItemsForLootRespawn=${MAX_ITEMS_FOR_LOOT_RESPAWN}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${CONSTRUCTION_PREVENTS_LOOT_RESPAWN}" ]; then
  sed -i "s|^ConstructionPreventsLootRespawn=.*|ConstructionPreventsLootRespawn=${CONSTRUCTION_PREVENTS_LOOT_RESPAWN}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DROP_OFF_WHITELIST_AFTER_DEATH}" ]; then
  sed -i "s|^DropOffWhiteListAfterDeath=.*|DropOffWhiteListAfterDeath=${DROP_OFF_WHITELIST_AFTER_DEATH}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${NO_FIRE}" ]; then
  sed -i "s|^NoFire=.*|NoFire=${NO_FIRE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${ANNOUNCE_DEATH}" ]; then
  sed -i "s|^AnnounceDeath=.*|AnnounceDeath=${ANNOUNCE_DEATH}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${MINUTES_PER_PAGE}" ]; then
  sed -i "s|^MinutesPerPage=.*|MinutesPerPage=${MINUTES_PER_PAGE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi



if [ -n "${SAVE_WORLD_EVERY_MINUTES}" ]; then
  sed -i "s|^SaveWorldEveryMinutes=.*|SaveWorldEveryMinutes=${SAVE_WORLD_EVERY_MINUTES}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${PLAYER_SAFEHOUSE}" ]; then
  sed -i "s|^PlayerSafehouse=.*|PlayerSafehouse=${PLAYER_SAFEHOUSE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${ADMIN_SAFEHOUSE}" ]; then
  sed -i "s|^AdminSafehouse=.*|AdminSafehouse=${ADMIN_SAFEHOUSE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SAFEHOUSE_ALLOW_TRESPASS}" ]; then
  sed -i "s|^SafehouseAllowTrepass=.*|SafehouseAllowTrepass=${SAFEHOUSE_ALLOW_TRESPASS}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SAFEHOUSE_ALLOW_FIRE}" ]; then
  sed -i "s|^SafehouseAllowFire=.*|SafehouseAllowFire=${SAFEHOUSE_ALLOW_FIRE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SAFEHOUSE_ALLOW_LOOT}" ]; then
  sed -i "s|^SafehouseAllowLoot=.*|SafehouseAllowLoot=${SAFEHOUSE_ALLOW_LOOT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SAFEHOUSE_ALLOW_RESPAWN}" ]; then
  sed -i "s|^SafehouseAllowRespawn=.*|SafehouseAllowRespawn=${SAFEHOUSE_ALLOW_RESPAWN}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SAFEHOUSE_DAY_SURVIVED_TO_CLAIM}" ]; then
  sed -i "s|^SafehouseDaySurvivedToClaim=.*|SafehouseDaySurvivedToClaim=${SAFEHOUSE_DAY_SURVIVED_TO_CLAIM}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SAFEHOUSE_REMOVAL_TIME}" ]; then
  sed -i "s|^SafeHouseRemovalTime=.*|SafeHouseRemovalTime=${SAFEHOUSE_REMOVAL_TIME}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SAFEHOUSE_ALLOW_NON_RESIDENTIAL}" ]; then
  sed -i "s|^SafehouseAllowNonResidential=.*|SafehouseAllowNonResidential=${SAFEHOUSE_ALLOW_NON_RESIDENTIAL}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${ALLOW_DESTRUCTION_BY_SLEDGEHAMMER}" ]; then
  sed -i "s|^AllowDestructionBySledgehammer=.*|AllowDestructionBySledgehammer=${ALLOW_DESTRUCTION_BY_SLEDGEHAMMER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SLEDGEHAMMER_ONLY_IN_SAFEHOUSE}" ]; then
  sed -i "s|^SledgehammerOnlyInSafehouse=.*|SledgehammerOnlyInSafehouse=${SLEDGEHAMMER_ONLY_IN_SAFEHOUSE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${KICK_FAST_PLAYERS}" ]; then
  sed -i "s|^KickFastPlayers=.*|KickFastPlayers=${KICK_FAST_PLAYERS}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${SERVER_PLAYER_ID}" ]; then
  sed -i "s|^ServerPlayerID=.*|ServerPlayerID=${SERVER_PLAYER_ID}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi



if [ -n "${RCON_PORT}" ]; then
  sed -i "s|^RCONPort=.*|RCONPort=${RCON_PORT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${RCON_PASSWORD}" ]; then
  sed -i "s|^RCONPassword=.*|RCONPassword=${RCON_PASSWORD}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi


# Disable all types
if [ -n "${DISCORD_ENABLE}" ]; then
  if [ "${DISCORD_ENABLE,,}" == "true" ]; then
    sed -i "s/^DiscordEnable=.*/DiscordEnable=true/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
  else
    sed -i "s/^DiscordEnable=.*/DiscordEnable=false/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
  fi
fi

if [ -n "${DISCORD_TOKEN}" ]; then
  sed -i "s|^DiscordToken=.*|DiscordToken=${DISCORD_TOKEN}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DISCORD_CHANNEL}" ]; then
  sed -i "s|^DiscordChannel=.*|DiscordChannel=${DISCORD_CHANNEL}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DISCORD_CHANNEL_ID}" ]; then
  sed -i "s|^DiscordChannelID=.*|DiscordChannelID=${DISCORD_CHANNEL_ID}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${PASSWORD}" ]; then
	sed -i "s/Password=.*/Password=${PASSWORD}/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Limit number of different accounts per Steam user
if [ -n "${MAX_ACCOUNTS_PER_USER}" ]; then
  sed -i "s|^MaxAccountsPerUser=.*|MaxAccountsPerUser=${MAX_ACCOUNTS_PER_USER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Allow co-op/splitscreen players
if [ -n "${ALLOW_COOP}" ]; then
  sed -i "s|^AllowCoop=.*|AllowCoop=${ALLOW_COOP}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Players are allowed to sleep
if [ -n "${SLEEP_ALLOWED}" ]; then
  sed -i "s|^SleepAllowed=.*|SleepAllowed=${SLEEP_ALLOWED}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Players need to sleep
if [ -n "${SLEEP_NEEDED}" ]; then
  sed -i "s|^SleepNeeded=.*|SleepNeeded=${SLEEP_NEEDED}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Knockdowns are allowed in PVP
if [ -n "${KNOCKED_DOWN_ALLOWED}" ]; then
  sed -i "s|^KnockedDownAllowed=.*|KnockedDownAllowed=${KNOCKED_DOWN_ALLOWED}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Sneak mode hides player from others
if [ -n "${SNEAK_MODE_HIDE_FROM_PLAYERS}" ]; then
  sed -i "s|^SneakModeHideFromOtherPlayers=.*|SneakModeHideFromOtherPlayers=${SNEAK_MODE_HIDE_FROM_PLAYERS}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi


if [ -n "${WORKSHOP_IDS}" ]; then
 	echo "*** INFO: Found Workshop IDs including ${WORKSHOP_IDS} ***"
	sed -i "s/WorkshopItems=.*/WorkshopItems=${WORKSHOP_IDS}/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
	
fi

# Show Steam usernames and avatars in the Players list
if [ -n "${STEAM_SCOREBOARD}" ]; then
  sed -i "s|^SteamScoreboard=.*|SteamScoreboard=${STEAM_SCOREBOARD}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Enable Steam VAC
if [ -n "${STEAM_VAC}" ]; then
  sed -i "s|^SteamVAC=.*|SteamVAC=${STEAM_VAC}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Enable UPnP port forwarding
if [ -n "${UPNP}" ]; then
  sed -i "s|^UPnP=.*|UPnP=${UPNP}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Enable VOIP
if [ -n "${VOICE_ENABLE}" ]; then
  sed -i "s|^VoiceEnable=.*|VoiceEnable=${VOICE_ENABLE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# VOIP min distance
if [ -n "${VOICE_MIN_DISTANCE}" ]; then
  sed -i "s|^VoiceMinDistance=.*|VoiceMinDistance=${VOICE_MIN_DISTANCE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# VOIP max distance
if [ -n "${VOICE_MAX_DISTANCE}" ]; then
  sed -i "s|^VoiceMaxDistance=.*|VoiceMaxDistance=${VOICE_MAX_DISTANCE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi


# VOIP directional audio
if [ -n "${VOICE_3D}" ]; then
  sed -i "s|^Voice3D=.*|Voice3D=${VOICE_3D}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Speed limit
if [ -n "${SPEED_LIMIT}" ]; then
  sed -i "s|^SpeedLimit=.*|SpeedLimit=${SPEED_LIMIT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Login queue
if [ -n "${LOGIN_QUEUE_ENABLED}" ]; then
  sed -i "s|^LoginQueueEnabled=.*|LoginQueueEnabled=${LOGIN_QUEUE_ENABLED}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${LOGIN_QUEUE_CONNECT_TIMEOUT}" ]; then
  sed -i "s|^LoginQueueConnectTimeout=.*|LoginQueueConnectTimeout=${LOGIN_QUEUE_CONNECT_TIMEOUT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Broadcast IP
if [ -n "${SERVER_BROWSER_ANNOUNCED_IP}" ]; then
  sed -i "s|^server_browser_announced_ip=.*|server_browser_announced_ip=${SERVER_BROWSER_ANNOUNCED_IP}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Respawn options
if [ -n "${PLAYER_RESPAWN_WITH_SELF}" ]; then
  sed -i "s|^PlayerRespawnWithSelf=.*|PlayerRespawnWithSelf=${PLAYER_RESPAWN_WITH_SELF}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${PLAYER_RESPAWN_WITH_OTHER}" ]; then
  sed -i "s|^PlayerRespawnWithOther=.*|PlayerRespawnWithOther=${PLAYER_RESPAWN_WITH_OTHER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Sleep time multiplier
if [ -n "${FAST_FORWARD_MULTIPLIER}" ]; then
  sed -i "s|^FastForwardMultiplier=.*|FastForwardMultiplier=${FAST_FORWARD_MULTIPLIER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Safehouse behavior
if [ -n "${DISABLE_SAFEHOUSE_WHEN_PLAYER_CONNECTED}" ]; then
  sed -i "s|^DisableSafehouseWhenPlayerConnected=.*|DisableSafehouseWhenPlayerConnected=${DISABLE_SAFEHOUSE_WHEN_PLAYER_CONNECTED}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Faction settings
if [ -n "${FACTION}" ]; then
  sed -i "s|^Faction=.*|Faction=${FACTION}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${FACTION_DAY_SURVIVED_TO_CREATE}" ]; then
  sed -i "s|^FactionDaySurvivedToCreate=.*|FactionDaySurvivedToCreate=${FACTION_DAY_SURVIVED_TO_CREATE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${FACTION_PLAYERS_REQUIRED_FOR_TAG}" ]; then
  sed -i "s|^FactionPlayersRequiredForTag=.*|FactionPlayersRequiredForTag=${FACTION_PLAYERS_REQUIRED_FOR_TAG}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi



# Disable radio by access level
if [ -n "${DISABLE_RADIO_STAFF}" ]; then
  sed -i "s|^DisableRadioStaff=.*|DisableRadioStaff=${DISABLE_RADIO_STAFF}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DISABLE_RADIO_ADMIN}" ]; then
  sed -i "s|^DisableRadioAdmin=.*|DisableRadioAdmin=${DISABLE_RADIO_ADMIN}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DISABLE_RADIO_GM}" ]; then
  sed -i "s|^DisableRadioGM=.*|DisableRadioGM=${DISABLE_RADIO_GM}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DISABLE_RADIO_OVERSEER}" ]; then
  sed -i "s|^DisableRadioOverseer=.*|DisableRadioOverseer=${DISABLE_RADIO_OVERSEER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DISABLE_RADIO_MODERATOR}" ]; then
  sed -i "s|^DisableRadioModerator=.*|DisableRadioModerator=${DISABLE_RADIO_MODERATOR}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${DISABLE_RADIO_INVISIBLE}" ]; then
  sed -i "s|^DisableRadioInvisible=.*|DisableRadioInvisible=${DISABLE_RADIO_INVISIBLE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Command and action logs
if [ -n "${CLIENT_COMMAND_FILTER}" ]; then
  sed -i "s|^ClientCommandFilter=.*|ClientCommandFilter=${CLIENT_COMMAND_FILTER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${CLIENT_ACTION_LOGS}" ]; then
  sed -i "s|^ClientActionLogs=.*|ClientActionLogs=${CLIENT_ACTION_LOGS}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Perk logging
if [ -n "${PERK_LOGS}" ]; then
  sed -i "s|^PerkLogs=.*|PerkLogs=${PERK_LOGS}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Item number limit
if [ -n "${ITEM_LIMIT_PER_CONTAINER}" ]; then
  sed -i "s|^ItemNumbersLimitPerContainer=.*|ItemNumbersLimitPerContainer=${ITEM_LIMIT_PER_CONTAINER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Blood splat lifetime
if [ -n "${BLOOD_SPLAT_LIFESPAN_DAYS}" ]; then
  sed -i "s|^BloodSplatLifespanDays=.*|BloodSplatLifespanDays=${BLOOD_SPLAT_LIFESPAN_DAYS}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Allow non-ASCII usernames
if [ -n "${ALLOW_NON_ASCII_USERNAME}" ]; then
  sed -i "s|^AllowNonAsciiUsername=.*|AllowNonAsciiUsername=${ALLOW_NON_ASCII_USERNAME}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Enable global sound on ban/kick
if [ -n "${BAN_KICK_GLOBAL_SOUND}" ]; then
  sed -i "s|^BanKickGlobalSound=.*|BanKickGlobalSound=${BAN_KICK_GLOBAL_SOUND}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi


# Remove player corpses on corpse removal
if [ -n "${REMOVE_PLAYER_CORPSES}" ]; then
  sed -i "s|^RemovePlayerCorpsesOnCorpseRemoval=.*|RemovePlayerCorpsesOnCorpseRemoval=${REMOVE_PLAYER_CORPSES}|" "$INI_FILE"
fi

# Trash delete all
if [ -n "${TRASH_DELETE_ALL}" ]; then
  sed -i "s|^TrashDeleteAll=.*|TrashDeleteAll=${TRASH_DELETE_ALL}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# PVP melee while hit reaction
if [ -n "${PVP_MELEE_WHILE_HIT}" ]; then
  sed -i "s|^PVPMeleeWhileHitReaction=.*|PVPMeleeWhileHitReaction=${PVP_MELEE_WHILE_HIT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Mouse over to see display name
if [ -n "${MOUSEOVER_TO_SEE_NAME}" ]; then
  sed -i "s|^MouseOverToSeeDisplayName=.*|MouseOverToSeeDisplayName=${MOUSEOVER_TO_SEE_NAME}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Hide players behind you
if [ -n "${HIDE_PLAYERS_BEHIND}" ]; then
  sed -i "s|^HidePlayersBehindYou=.*|HidePlayersBehindYou=${HIDE_PLAYERS_BEHIND}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# PVP melee damage modifier
if [ -n "${PVP_MELEE_DAMAGE}" ]; then
  sed -i "s|^PVPMeleeDamageModifier=.*|PVPMeleeDamageModifier=${PVP_MELEE_DAMAGE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# PVP firearm damage modifier
if [ -n "${PVP_FIREARM_DAMAGE}" ]; then
  sed -i "s|^PVPFirearmDamageModifier=.*|PVPFirearmDamageModifier=${PVP_FIREARM_DAMAGE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Car engine attraction modifier
if [ -n "${CAR_ENGINE_ATTRACTION}" ]; then
  sed -i "s|^CarEngineAttractionModifier=.*|CarEngineAttractionModifier=${CAR_ENGINE_ATTRACTION}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Player bumping
if [ -n "${PLAYER_BUMP_PLAYER}" ]; then
  sed -i "s|^PlayerBumpPlayer=.*|PlayerBumpPlayer=${PLAYER_BUMP_PLAYER}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Map remote player visibility
if [ -n "${MAP_REMOTE_VISIBILITY}" ]; then
  sed -i "s|^MapRemotePlayerVisibility=.*|MapRemotePlayerVisibility=${MAP_REMOTE_VISIBILITY}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Backups count
if [ -n "${BACKUPS_COUNT}" ]; then
  sed -i "s|^BackupsCount=.*|BackupsCount=${BACKUPS_COUNT}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"fi

# Backups on start
if [ -n "${BACKUPS_ON_START}" ]; then
  sed -i "s|^BackupsOnStart=.*|BackupsOnStart=${BACKUPS_ON_START}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Backups on version change
if [ -n "${BACKUPS_ON_VERSION_CHANGE}" ]; then
  sed -i "s|^BackupsOnVersionChange=.*|BackupsOnVersionChange=${BACKUPS_ON_VERSION_CHANGE}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

# Backups period
if [ -n "${BACKUPS_PERIOD}" ]; then
  sed -i "s|^BackupsPeriod=.*|BackupsPeriod=${BACKUPS_PERIOD}|" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi


# Disable all types
if [ "${DISABLE_ANTICHEAT_ALL,,}" == "true" ]; then
  for i in {1..24}; do
    sed -i "s/^AntiCheatProtectionType${i}=.*/AntiCheatProtectionType${i}=false/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
    
  done
fi
# Disable specific types
if [ -n "$DISABLE_ANTICHEAT" ]; then
  for i in $DISABLE_ANTICHEAT; do
    if [[ "$i" =~ ^[0-9]+$ ]] && [ "$i" -ge 1 ] && [ "$i" -le 24 ]; then
      sed -i "s/^AntiCheatProtectionType${i}=.*/AntiCheatProtectionType${i}=false/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
      
    fi
  done
fi

# -------- INI ----------


# Fix to a bug in start-server.sh that causes to no preload a library:
# ERROR: ld.so: object 'libjsig.so' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.
export LD_LIBRARY_PATH="${STEAMAPPDIR}/jre64/lib:${LD_LIBRARY_PATH}"

## Fix the permissions in the data and workshop folders
chown -R 1000:1000 /home/steam/pz-dedicated/steamapps/workshop /home/steam/Zomboid

# Run the debug script before starting the server
/server/scripts/debug_env.sh

su - steam -c "export LANG=${LANG} && export LD_LIBRARY_PATH=\"${STEAMAPPDIR}/jre64/lib:${LD_LIBRARY_PATH}\" && cd ${STEAMAPPDIR} && pwd && ./start-server.sh ${ARGS}"
#exec bash
