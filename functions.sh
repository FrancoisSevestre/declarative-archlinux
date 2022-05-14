#!/usr/bin/env bash


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

log0()
{
  printf "[layer0] "
}

is_root()
{
  if ((EUID)); then
    false
  else
    true
  fi
}

is_OK()
# Usage: is_OK "command" "pre-message" "error message"
{
  printf '%s...' "$2"
  if $1 >> install.log 2>&1 && true || false; then
    printf '%s\n' "$(green "OK")"
  else
    printf '%s\n' "$(red "$3")"
    exit 1
  fi
}

is_OK_verbose()
# Usage: is_OK "command" "pre-message" "error message"
{
  printf '%s...\n' "$2"
  if $1 && true || false; then
    printf '%s...%s\n' "$2" "$(green "OK")"
  else
    printf '%s...%s\n' "$2" "$(red "$3")"
    killall tail
    exit 1
  fi
}
