#!/bin/bash

export PYTHONPATH=$PYTHONPATH:$(pwd)/cryptsy

CGMINER=cgminer/cgminer
CGMINER_CONF=.cgminer/cgminer.conf

# More portable than 'pidof'.
function CGMinerPid
{
	echo $(ps aux | grep -v grep | grep -i cgminer | awk '{print $2}')
}

function KillCGMiner
{
	pid=$(CGMinerPid)
	if [ $pid ]
	then
		kill -p $pid
	fi
}

function CleanExit
{
	KillCGMiner
	if [ $# -gt 0 ]
	then
		echo $1
	fi
	exit 1
}

function BestSupported
{
	coin_list=$(python ./best_coin.py)
	for c in $coin_list
	do
		if [ -d $c ]
		then
			echo $c
			return
		fi
	done
	CleanExit "No supported currencies in $coin_list"
}

function NewCGMiner
{
	KillCGMiner
	./$1/gen_cgminer_conf.sh $CGMINER_CONF
	screen -d -m $CGMINER
}

# Main entry point.
best_coin="not_a_coin"
while true
do
	cur_best=$(BestSupported)
	if [ $cur_best != $best_coin ]
	then
		echo Switching to new best: $cur_best
		best_coin=$cur_best
		NewCGMiner $best_coin
	fi
	./$best_coin/liquidate.py
	sleep 5

done
