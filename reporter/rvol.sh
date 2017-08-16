#!/usr/bin/env bash

function printHelp () {
cat - << END_OF_HELP

    скрипт предназначен для возвращения заданных параметров уровня громкости
    для радиограбберов после ребута системы (автор: korzen 2017)

    в этом варианте только хапуги без установки параметров, но в планах добавить тюнеры готвью
    и добавить необходимые параметры
    
    Возможные параметры:
      -d <N> - использовать только конкретное устройство N-integer 0...13
      -v   - установить уровень громкости в % (или всем, или конкретному устройству)      
      -c     - использовать файл конфигурации не по умолчанию
      -h     - вывести помощь по запуску скрипта
    
    попробуйте еще раз...
    
END_OF_HELP
}


declare logFile="/root/cron/radio_set.log";
declare sleepSec="5";
declare Date=`date`;

declare -A tuners
tuners[0]=60
tuners[1]=61
tuners[2]=62
tuners[3]=63
tuners[4]=64
tuners[5]=65
tuners[6]=66
tuners[7]=67
tuners[8]=68
tuners[9]=69
tuners[10]=70
tuners[11]=71
tuners[12]=72
tuners[13]=73

function restoreVolume () {

  for T in "${!tuners[@]}"; do      
    amixer -c ${T} set Component ${tuners[${T}]}% >> ${logFile};
  done

}

function writeLogFile () {
  echo "" >> ${logFile};
  echo "#########  ${Date}  #########" >> ${logFile};
  echo "### Set variables to volume tuners afters reboot" >> ${logFile};
  echo "#################################################" >> ${logFile};
  echo "" >> ${logFile};
  
}

sleep ${sleepSec};
writeLogFile;
restoreVolume;
