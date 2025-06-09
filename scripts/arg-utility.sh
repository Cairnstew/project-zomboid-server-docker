# Utility: Convert variable to lowercase
tolower() {
  echo "${1,,}"
}

# Utility: Check if variable is "1" or "true" (case insensitive)
is_enabled() {
  local val
  val=$(tolower "$1")
  [[ "$val" == "1" || "$val" == "true" ]]
}

# Append to ARGS or JVM_ARGS with debugging info
append_arg() {
  local -n arr_ref=$1
  local arg=$2
  arr_ref="${arr_ref} ${arg}"
  echo "[DEBUG] Added argument: ${arg}"
}

# Build JVM Args based on environment variables
build_jvm_args() {
  JVM_ARGS=""
  if [[ -n "$MEMORY" ]]; then
    append_arg JVM_ARGS "-Xmx${MEMORY} -Xms${MEMORY}"
  fi

  if is_enabled "$ZOMBOID_STEAM"; then
    append_arg JVM_ARGS "-Dzomboid.steam=1"
  elif [[ -n "$ZOMBOID_STEAM" ]]; then
    append_arg JVM_ARGS "-Dzomboid.steam=0"
  fi

  if [[ -n "$DEPLOYMENT_USER_CACHEDIR" ]]; then
    append_arg JVM_ARGS "-Ddeployment.user.cachedir=\"${DEPLOYMENT_USER_CACHEDIR}\""
  fi

  if is_enabled "$SOFTRESET"; then
    append_arg JVM_ARGS "-Dsoftreset"
  fi

  if is_enabled "$DEBUG_JVM"; then
    append_arg JVM_ARGS "-Ddebug"
  fi
}

# Build Client Args based on environment variables
build_client_args() {
  ARGS=""
  local flag_mappings=(
    "SAFEMODE:-safemode"
    "NOSOUND:-nosound"
    "AITEST:-aitest"
    "NOVOIP:-novoip"
    "DEBUG:-debug"
    "DEBUGTRANSLATION:-debugtranslation"
    "IMGUI:-imgui"
    "IMGUIDEBUGVIEWPORTS:-imguidebugviewports"
  )

  for mapping in "${flag_mappings[@]}"; do
    local var="${mapping%%:*}"
    local arg="${mapping#*:}"
    if is_enabled "${!var}"; then
      append_arg ARGS "${arg}"
    fi
  done

  [[ -n "$DEBUGLOG_CLIENT" ]] && append_arg ARGS "-debuglog=${DEBUGLOG_CLIENT}"
  [[ -n "$CONNECT" ]] && append_arg ARGS "+connect ${CONNECT}"
  [[ -n "$PASSWORD" ]] && append_arg ARGS "+password ${PASSWORD}"
  [[ -n "$MODFOLDERS" ]] && append_arg ARGS "-modfolders ${MODFOLDERS}"
}

# Build Server Args based on environment variables
build_server_args() {
  [[ -n "$DISABLELOG" ]] && append_arg ARGS "-disablelog=${DISABLELOG}"
  [[ -n "$DEBUGLOG" ]] && append_arg ARGS "-debuglog=${DEBUGLOG}"
  [[ -n "$ADMINUSERNAME" ]] && append_arg ARGS "-adminusername ${ADMINUSERNAME}"
  [[ -n "$ADMINPASSWORD" ]] && append_arg ARGS "-adminpassword ${ADMINPASSWORD}"
  [[ -n "$STATISTIC" ]] && append_arg ARGS "-statistic ${STATISTIC}"
  [[ -n "$PORT" ]] && append_arg ARGS "-port ${PORT}"
  [[ -n "$UDPPORT" ]] && append_arg ARGS "-udpport ${UDPPORT}"

  if is_enabled "$STEAMVAC"; then
    append_arg ARGS "-steamvac true"
  elif [[ "$(tolower "$STEAMVAC")" == "false" ]]; then
    append_arg ARGS "-steamvac false"
  fi

  if [[ -n "$SERVERNAME" ]]; then
    append_arg ARGS "-servername \"${SERVERNAME}\""
  else
    SERVERNAME="servertest"
  fi
}

# Copy preset file if needed
handle_server_preset() {
  if [[ -n "$SERVERPRESET" ]]; then
    local preset_path="${STEAMAPPDIR}/media/lua/shared/Sandbox/${SERVERPRESET}.lua"
    local dest_dir="${HOMEDIR}/Zomboid/Server"
    local dest_file="${dest_dir}/${SERVERNAME}_SandboxVars.lua"

    if [[ ! -f "$preset_path" ]]; then
      echo "*** ERROR: the preset ${SERVERPRESET} doesn't exist. Please fix the configuration before starting the server ***"
      exit 1
    fi

    if [[ ! -f "$dest_file" || "$(tolower "$SERVERPRESETREPLACE")" == "true" ]]; then
      echo "*** INFO: New server will be created using the preset ${SERVERPRESET} ***"
      echo "*** Copying preset file from \"$preset_path\" to \"$dest_file\" ***"
      mkdir -p "$dest_dir"
      cp -nf "$preset_path" "$dest_file"
      sed -i "1s/return.*/SandboxVars = {/" "$dest_file"
      dos2unix "$dest_file"
      chmod 644 "$dest_file"
    fi
  fi
}
