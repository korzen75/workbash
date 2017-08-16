#!/usr/bin/env bash

function printHelp () {
cat - << END_OF_HELP

    скрипт предназначен для рестарта сервисов в кроне (времянка)
    
    автор: korzen 2017

    последние изменения: 16/08/2017

	нет возможности использовать ансибл или другие средства, поэтому исходим из того что есть...
	
	заходим на хост по ssh 
	создадим необходимую структуру одной командой на целевом хосте
	mkdir -p /root/cron && cd /root/cron && touch restartService.sh && chmod +x restartService.sh && nano restartService.sh

	затем открываем любой редактор ---> скопируем и вставим строки ниже...
	раскомментируем необходимый массив для нужного хоста...
	по-умолчанию рестарт служб закомментирован и возможен только просмотр статуса служб...
	изменяем по необходимости...
	сохраняем...
	добавим в крон автоматический запуск.... 
	crontab -e


	#################################################################################
	для тех, кто в танке и не хочет разбираться с кроном, опишу кратко создание заданий в кроне
	
	Параметр		Допустимый интервал
	минуты			0-59
	часы			0-23
	день месяца		1-31
	месяц			1-12
	день недели		0-7 (0-Вс,1-Пн,2-Вт,3-Ср,4-Чт,5-Пт,6-Сб,7-Вс)
	
	Поле может быть задано явно или шаблоном:

	* — любая цифра;
	целое число;
	целые числа через запятую — задание дискретного множества значений, например 1,2,5;
	два целых числа, разделенные дефисом, соответствующие диапазону значений, например 3-6.

	Пример готовой строки сценария cron:

	# Выполнять задание в 18 часов 7 минут 13 мая если это пятница
	7 18 13 5 5 /root/cron/restartService.sh
	# Выполнять задание раз в час в 0 минут
	0 */1 * * * /root/cron/restartService.sh
	# Выполнять задание каждые семь часов в 0 минут
	0 */7 * * * /root/cron/restartService.sh
	# Выполнять задание по воскресеньям в 10 час 30 минут
	30 10 * * 0 /root/cron/restartService.sh

	в нашем случае необходимо по тех.заданию запуск ежедневно в 5 утра
	0 5 * * * /root/cron/restartService.sh

	#################################################################################

	все....
    
END_OF_HELP
}

declare Date=`date`;
declare ntpServer="192.168.1.50";
declare logFile="cronRestartService.log";
declare sleepTime="20";

# msk-tv-grab-02
#declare serviceArr=(ntp mpeg2lander-grabber-2 mpeg2lander-grabber-3 mpeg2lander-grabber-4 mpeg2lander-grabber-5 bsf-8201);

# frnk-grab-02 
#declare serviceArr=(ntp mpeg2lander-grabber-2 mpeg2lander-grabber-5 bsf-8201);

# frnk-enc-01
#declare serviceArr=(ntp encoder*);

# frnk-enc-03
#declare serviceArr=(ntp mpeg2lander-audiofp-all);

# record-broker
#declare serviceArr=(ntp record-broker*);

function printTopLog () {

	echo "" >> ${logFile};
	echo "" >> ${logFile};
	echo "### ${Date}" >> ${logFile};
	echo "" >> ${logFile};
	echo "restart services...." >> ${logFile};
	echo "" >> ${logFile};

}

function correctTime () {

	echo "" >> ${logFile};
	echo "time after correct" >> ${logFile};
	ntpdate -u ${ntpServer} >> ${logFile};

	for i in {0..5}; do
		ntpdate -ubs ${ntpServer};
		sleep ${sleepTime};
	done

	echo "" >> ${logFile};
	echo "time before correct...." >> ${logFile};
	sleep ${sleepTime};
	ntpdate -u ${ntpServer} >> ${logFile};
	echo "" >> ${logFile};
}

function restartServices () {

	for item in ${serviceArr[*]}; do
	    #sv -w 120 force-restart /etc/service/${item} >> ${logFile};
	    sv status /etc/service/${item} >> ${logFile};
	done
}

printTopLog
correctTime
restartServices

