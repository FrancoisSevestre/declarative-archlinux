#!/usr/bin/env bash

# Reads the config.yml file present in the cwd 
# Exemple: readconfig .install_type[0]
readconfig()
{
  yq -r ".$1" < config.yml
}

reset-screen()
{
  clear
  echo "## AutoInstall: ArchLinux ##"
}

red()
{
  echo -e "\e[1;31m$*\e[0m"
}

warning()
{
  echo -e "\e[1;41m$*\e[0m"
}

green()
{
  echo -e "\e[1;32m$*\e[0m"
}

is_root()
{
  if ((EUID)); then
    false
  else
    true
  fi
}

log (){
  LOG_LEVEL="INFO"
  MESSAGE="Executing command"
  COMMAND="echo 'No command given'"
  ALLOW_FAILURE=false
  LOG_FILE="install.log"
  SUCCESS_MESSAGE="OK"
  FAIL_MESSAGE="Fail"
  HELP="..." # TODO
  NO_TEST=false
  
  POSITIONAL_ARGS=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      --log-level|-l)
        LOG_LEVEL="$2"
        shift
        shift
        ;;
        
      --message|-m)
        MESSAGE="$2"
        shift
        shift
        ;;

      --command|-c)
        COMMAND="$2"
        shift
        shift
        ;;

      --allow-failure|-a)
        ALLOW_FAILURE=true
        shift
        ;;

      --no-test|-e)
        NO_TEST=true
        shift
        ;;

      --log-file|-f)
        LOG_FILE="$2"
        shift
        shift
        ;;

      --succes-message|-s)
        SUCCESS_MESSAGE="$2"
        shift
        shift
        ;;

      --fail-message|-n)  
        FAIL_MESSAGE="$2"
        shift
        shift
        ;;

      --help|-h)
        echo $HELP
        exit 0
        ;;

      --*|-*)
        echo "unknown argument $1"
        exit 1
        ;;

      *)
        POSITIONAL_ARGS+=("$1")
        shift
        ;;
    esac
  done
  

  printf '[%s]:%s...' "$LOG_LEVEL" "$MESSAGE"
  if [ $NO_TEST == false ]; then
    if $COMMAND >> "$LOG_FILE" 2>&1 && true || false; then
      printf '%s\n' "$(green "$SUCCESS_MESSAGE")"
    else
      if [ $ALLOW_FAILURE == true ]; then
        printf '%s\n' "$(red "$FAIL_MESSAGE, but ignored")"
      else
        printf '%s\n' "$(red "$FAIL_MESSAGE")"
        exit 1
      fi
    fi
  else
    printf '\n'
  fi
}
