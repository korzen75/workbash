#!/usr/bin/env bash

function printHelp () {
cat - << END_OF_HELP

    скрипт выводит информацию согласно заданных пареметров
    Использование параметров $0 -[par] arg
    Возможные параметры:
      -d <N> - использовать только конкретное устройство N-integer 0...13
      -f     - вывести рабочую частоту устройства
      -s     - вывести уровень сигнала
      -c     - вывести текущее значение автонастройки
      -h     - вывести помощь по запуску скрипта
    одновременно можно вывести только один параметр (кроме устройства)
    если параметр введен неверно, то будет выведен уровень сигнала
    попробуйте еще раз...
    
END_OF_HELP
}

function showFreq(){
# если выбрано показать текущую рабочую частоту, то выводим
    if [ $chDev -eq 15 ] ; then
       for ((n=1; n<=$numDevice; n++ ));
         do
            local tempDevStr=`echo $strDevice`$n
            #echo $tempDevStr
            v4l2-ctl --device=$tempDevStr --all | grep "Frequency:" | cut -d'(' -f2- | sed -e 's/\ .*$//'
       done;
    else
       echo "show frequncy for $strDevice"
       v4l2-ctl --device=$strDevice --all | grep "Frequency:" | cut -d'(' -f2- | sed -e 's/\ .*$//'
    fi
}

function showAFC(){
# если выбрано показать текущее значение автонастройки, то выводим
    if [ $chDev -eq 15 ] ; then
       for ((n=1; n<=$numDevice; n++ ));
         do
            local tempDevStr=`echo $strDevice`$n
            #echo $tempDevStr
            v4l2-ctl --device=$tempDevStr --all | grep "Signal strength" | cut -d/ -f3-
       done;
    else
       echo "show AFC for $strDevice"
       v4l2-ctl --device=$strDevice --all | grep "Signal strength" | cut -d/ -f3-
    fi
}

function showStrh(){
# если выбрано показать уровень сигнала, то выводим
    if [ $chDev -eq 15 ] ; then
       for ((n=1; n<=$numDevice; n++ ));
         do
            local tempDevStr=`echo $strDevice`$n
            #echo $tempDevStr
            v4l2-ctl --device=$tempDevStr --all | grep "Signal strength" | cut -d: -f2- | sed -e 's/\%.*$//' | sed 's/^[ \t]*//'
       done;
    else
       echo "show strenght for $strDevice"
       v4l2-ctl --device=$strDevice --all | grep "Signal strength" | cut -d: -f2- | sed -e 's/\%.*$//' | sed 's/^[ \t]*//'
    fi
}

function chDevice(){
# нам нужно определить какие устройства на конкретном хосте
# на готвью будет /dev/gotview_pcmN (где N от 1...6)
# на хапуге будет /dev/radioN (где N от 0...13)
# выполняем проверку на gotview_pcm
    
    local numDev=`ls -l /dev/ | grep gotview_pcm | wc -l`
    if [ $numDev -eq 6 ] ; then
        strDevice="/dev/gotview_pcm"
        strNameDevice="gotview_pcm"
      else strDevice="/dev/radio"
    fi
    if [ $strDevice = "/dev/radio" ]; then
        numDevice=14
        strNameDevice="radio"
      else numDevice=6
    fi
}

function parsParam(){
# парсим параметры и аргументы
  while getopts ":safhd:" Option
    do
      case $Option in
          "d") chDev=${OPTARG} ;;
          "s") strh="y" ;;
          "f") freq="y" ;;
          "a") afc="y" ;;
          "h") printHelp ; exit 1 ;;
          * ) strh="y"  ;;
      esac
    done
}

function showInfo (){
    # echo "Выводим необходимое нам..."
    
    if [ -n "$strh" ] ; then
        showStrh 
    fi
    
    if [ -n "$freq" ] ; then
        showFreq
    fi
    
    if [ -n "$afc" ] ; then
        showAFC
    fi
    
}


# для облегчения разбора скрипта 
# принимаем что рабочий диапазон только 0...13
# 15 - вывести информацию на все устройства
declare -i chDev=15
declare strh=""
declare freq=""
declare afc=""
declare strDevice=""
declare -i numDevice=6
declare strNameDevice=""

parsParam "$@"
chDevice
if [ $chDev -lt 15  ] ; then
    # проверка на правильный диапазон значений
    if [ $strNameDevice = "gotview_pcm" ] ; then
        if [[ $chDev -gt 0  && $chDev -lt 7  ]] ; then
            tempStr=`echo $strDevice`$chDev
            strDevice="$tempStr"
            showInfo
          else echo "не верное значение номера устройства"
        fi
      else
        if [ $strNameDevice = "radio" ] ; then
          if [[ $chDev -ge 0 && $chDev -le 13 ]] ; then
             tempStr=`echo $strDevice`$chDev
             strDevice="$tempStr"
             showInfo
            else echo "не верное значение номера устройства"
          fi
        fi
    fi
else 
    showInfo
fi

