#!/bin/bash
db_set () {
  byte_number= wc database | awk '{print $3}'
  bashmap "$1" ${byte_number}
  echo "$1,$2" >> database
}

db_get () {
  byte_number= bashmap "$1"
  value= sed -n ${byte_number}'p' database
  if [ ${value} == "" ]
  then
    grep -n "^$1," database | sed -e "s/^$1,//" | tail -n 1
  else
    echo ${value}
  fi
}

# for bashmap {
# echo md5 code for $1
md5()
{
  if [ X"$1" == X"" ]
  then
    echo ""
  else
    echo "$1" | md5sum - | cut -c 1-32
  fi
}

# Usage
#   > bashmap "key" "value"  # set map[key] = value.
#   > bashmap "key"          # print map[key]
bashmap()
{
  WX_BASHMAP_PREFIX="BASHMAP_"
  export WX_BASHMAP_PREFIX

  md5key=$(eval "md5 '$1'")
  case "$#" in
  1)
    eval "echo \$$WX_BASHMAP_PREFIX$md5key"
    ;;
  2)
    eval "export $WX_BASHMAP_PREFIX$md5key='$2'"
    ;;
  *)
    echo 'Usage:'
    echo '   bashmap "key" "value"'
    echo '   bashmap "key"'
    ;;
  esac
}

# Usage:
#    > bashmap_clear      # clear All map items
#    > bashmap_clear Key  # clear a map time by Key
bashmap_clear()
{
  WX_BASHMAP_PREFIX="BASHMAP_"
  export WX_BASHMAP_PREFIX


  case "$#" in
  0)
    for env in $(set | grep "^$WX_BASHMAP_PREFIX" | cut -d'=' -f1)
    do
      unset $env
    done
    ;;
  1)
    md5key=$(eval "md5 '$1'")
    unset $WX_BASHMAP_PREFIX$md5key
    ;;
  esac
}
# for bashmap }