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

if [ "${COOP}" == "1" ] || [ "${COOP,,}" == "true" ]; then
  ARGS="${ARGS} -coop"
fi

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

if [ -n "${IP}" ]; then
  ARGS="${ARGS} -ip ${IP}"
fi

if [ "${GUI}" == "1" ] || [ "${GUI,,}" == "true" ]; then
  ARGS="${ARGS} -gui"
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

if [ -n "${PASSWORD}" ]; then
	sed -i "s/Password=.*/Password=${PASSWORD}/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${MOD_IDS}" ]; then
 	echo "*** INFO: Found Mods including ${MOD_IDS} ***"
	sed -i "s/Mods=.*/Mods=${MOD_IDS}/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${WORKSHOP_IDS}" ]; then
 	echo "*** INFO: Found Workshop IDs including ${WORKSHOP_IDS} ***"
	sed -i "s/WorkshopItems=.*/WorkshopItems=${WORKSHOP_IDS}/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
	
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

# Fix to a bug in start-server.sh that causes to no preload a library:
# ERROR: ld.so: object 'libjsig.so' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.
export LD_LIBRARY_PATH="${STEAMAPPDIR}/jre64/lib:${LD_LIBRARY_PATH}"

## Fix the permissions in the data and workshop folders
chown -R 1000:1000 /home/steam/pz-dedicated/steamapps/workshop /home/steam/Zomboid

su - steam -c "export LANG=${LANG} && export LD_LIBRARY_PATH=\"${STEAMAPPDIR}/jre64/lib:${LD_LIBRARY_PATH}\" && cd ${STEAMAPPDIR} && pwd && ./start-server.sh ${ARGS}"
