#! /bin/sh

counter=1
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
let counter=1

# Make a copy for json directory if necessery.
if [ "$(ls $WORK_PATH/json/)" != ""  ]
then
	cp -r "$WORK_PATH/json" "$WORK_PATH/json_full"
fi

# Compare those results and only keep lowest latency config file.
echo 10000 > $WORK_PATH/delay/delay.min
for delay in $(cat $WORK_PATH/delay/delay.compare)
do
	if [[ $(echo "$delay < $(cat $WORK_PATH/delay/delay.min)" | bc) -eq 1 ]]
	then
    # if new node is faster than old node
    
        # remove old source file
		if [ $minimum -lt 10 ]
		then
            if [ $minimum -ne 0 ]
            then
			    rm $WORK_PATH/subscription.json.source/0$minimum
            fi
		else
			rm $WORK_PATH/subscription.json.source/$minimum
		fi

        # remove old json file if exist
		if [ -f "$WORK_PATH"/json/$minimum.json ]
		then
			if [ $minimum -lt 10 ]
			then
				if [ $minimum -ne 0 ]
				then
				    rm $WORK_PATH/json/0$minimum.json
                fi
			else
				rm $WORK_PATH/json/$minimum.json
			fi
		fi

		echo $delay > $WORK_PATH/delay/delay.min
        let minimum=$counter
	else
    # if new node is slower than old node

        # remove new source file
		if [ $counter -lt 10 ]
		then
			rm "$WORK_PATH/subscription.json.source/0$counter"
		else
			rm "$WORK_PATH/subscription.json.source/$counter"
		fi

        # remove new source file if exist
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

    let counter++
	sed -i '1d' $WORK_PATH/delay/delay.compare
done

# tell user about the result
echo ''
if [ $(ls $WORK_PATH/subscription.json.source/) = "" ]
then
    echo "Seems that all your node(s) is(are) died. :("
    exit 1
fi
echo -e "\033[32m\033[01mNO.$(ls $WORK_PATH/subscription.json.source) node has the minimum latency.\033[0m"
echo ''
