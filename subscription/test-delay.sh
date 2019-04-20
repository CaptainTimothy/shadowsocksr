#! /bin/sh

counter=0
minimum=0
WORK_PATH=$(cd "$(dirname "$0")";pwd)/ssrSubUpd

# Test latency and write whole report to a file.
echo -e "\033c"
echo "Latency list:"
echo ''
echo '-----------------------------------------'
echo '| NO |        IP        |    Latency    |'



for addr in $(cat $WORK_PATH/delay/address.list)
do
	echo '|----|------------------|---------------|'
	if [ $counter -lt 10 ]
	then
		echo -e "| 0$counter | $addr  \t\c" 
	else
		echo -e "| $counter | $addr  \t\c" 
	fi
	ping -c 4 $addr > $WORK_PATH/delay/delay.report.tmp
	cat $WORK_PATH/delay/delay.report.tmp >> $WORK_PATH/delay/delay.report
	echo '' >> $WORK_PATH/delay/delay.report

	cat $WORK_PATH/delay/delay.report.tmp | grep -E '=.*/(.*)/*\.*/*\.*ms|0 received' -o | sed -e 's/.*\/\(.*\)\/.*\/.*ms.*/\1/' > $WORK_PATH/delay/delay.print.tmp
	sed -i 's/0\ received/99999/g' $WORK_PATH/delay/delay.print.tmp
	cat $WORK_PATH/delay/delay.print.tmp >> $WORK_PATH/delay/delay.compare

	echo -e "| $(cat $WORK_PATH/delay/delay.print.tmp)  \t|"
	let counter++

done
echo '-----------------------------------------'

# reset counter equal to 0
let counter=0

# Process the original report file and just keep the last row of each test in order to compare those latency.
###############
#cat $WORK_PATH/delay/delay.report | grep -E '=.*/(.*)/*\.*/*\.*ms|0 received' -o | sed -e 's/.*\/\(.*\)\/.*\/.*ms.*/\1/' >> $WORK_PATH/delay/delay.compare
#sed -i 's/0\ received/99999/g' $WORK_PATH/delay/delay.compare

# Compare those results and only keep lowest latency config file.
echo 10000 > $WORK_PATH/delay/delay.min
for delay in $(cat $WORK_PATH/delay/delay.compare)
do
	if [[ $(echo "$delay < $(cat $WORK_PATH/delay/delay.min)" | bc) -eq 1 ]]
	then
		if [ $minimum -gt 0 ]
		then
			if [ $minimum -lt 10 ]
			then
				rm $WORK_PATH/subscription.json.source/0$minimum
			else
				rm $WORK_PATH/subscription.json.source/$minimum
			fi
			if [ -f "$WORK_PATH"/json/$minimum.json ]
			then
				if [ $minimum -lt 10 ]
				then
					rm $WORK_PATH/json/0$minimum.json
				else
					rm $WORK_PATH/json/$minimum.json
				fi
			fi
		fi
		let minimum=counter
		echo $delay > $WORK_PATH/delay/delay.min
	else
		if [ $counter -lt 10 ]
		then
			rm "$WORK_PATH/subscription.json.source/0$counter"
		else
			rm "$WORK_PATH/subscription.json.source/$counter"
		fi
		if [ -f "$WORK_PATH/json/$counter.json" ]
		then
			if [ $counter -lt 10 ]
			then
				rm $WORK_PATH/json/0$counter.json
			else
				rm $WORK_PATH/json/$counter.json
			fi
		fi
	fi

	sed -i '1d' $WORK_PATH/delay/delay.compare
	let counter++
done

# Tell user the result.
echo ''
echo -e "\033[32m\033[01mNO.$(ls $WORK_PATH/subscription.json.source) node has the minimum latency.\033[0m"
echo ''
