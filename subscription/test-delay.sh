#! /bin/sh

counter=1
minimum=0
CURRENT_PATH=$(cd "$(dirname "$0")";pwd)
WORK_PATH=$CURRENT_PATH/ssrSubUpd

echo -en "\033c\e[3J"

echo -en "\033c\e[3J"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "▓                     ▓"
echo "▓  Node Latency Test  ▓"
echo "▓                     ▓"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"

echo "Please wait while progress bar is running..."
echo -e "\033[s"
echo "Last Node:"

# ----123456789▓123456789▓
echo "** Server: NaN"

# ----123456789▓123456789▓
echo "** Delay: NaN"

echo ''
# ----123456789▓123456789▓
echo -e "Server: \033[s"

# ----123456789▓123456789▓
echo "Delay: "

# Use 'ping -c 4 $addr' to test average latency
for addr in $(cat $WORK_PATH/delay/address.list)
do
    # clear current server and print new server
    echo -e "\033[u\033[K"
    echo -e "\033[u$addr"

    # test delay
    ping -c 4 $addr > $WORK_PATH/delay/delay.report.tmp & PID=$!

    # move cursor 2 lines below
    echo -e "\033[2B\c"

    # print progress bar
    printf "Graphic Timer: ["

    while kill -0 $PID 2> /dev/null
    do
        printf  "▓"
        sleep 1
    done
    printf "] done!\n"

    # save all ping log to one file
    cat $WORK_PATH/delay/delay.report.tmp >> $WORK_PATH/delay/delay.report
    echo '' >> $WORK_PATH/delay/delay.report

    # process the ping report to get average latency
    cat $WORK_PATH/delay/delay.report.tmp | grep -E '=.*/(.*)/*\.*/*\.*ms|0 received' -o | sed -e 's/.*\/\(.*\)\/.*\/.*ms.*/\1/' > $WORK_PATH/delay/delay.print.tmp

    # if there is no package received, set delay as 99999
    sed -i 's/0\ received/99999/' $WORK_PATH/delay/delay.print.tmp

    # save server address and latency to file for print and compare
    echo "$addr|$(cat $WORK_PATH/delay/delay.print.tmp)" >> $WORK_PATH/delay/delay.print
    cat $WORK_PATH/delay/delay.print.tmp >> $WORK_PATH/delay/delay.compare

    # print delay
    echo -e "\033[3A\033[7C$(cat $WORK_PATH/delay/delay.print.tmp)"
    sleep 0.3

    # move addr to history
    echo -e "\033[5A\033[11C\033[K"
    echo -e "\033[1A\033[11C$addr"
    
    # move latency to history
    echo -e "\033[10C\033[K"
    echo -e "\033[1A\033[10C$(cat $WORK_PATH/delay/delay.print.tmp)"

    # clear timer
    echo -e "\033[4B\033[K\c"

    # clear current delay
    echo -e "\033[2A\033[7C\033[K\c"

    let counter++

done

# Print Latency List to user
echo -en "\033c\e[3J"
python $CURRENT_PATH/print-delay.py

# Reset "counter"
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

                if [ -f "$WORK_PATH"/json/0$minimum.json ]
		        then
                    rm $WORK_PATH/json/0$minimum.json
                fi
            fi
		else
			rm $WORK_PATH/subscription.json.source/$minimum

            if [ -f "$WORK_PATH"/json/$minimum.json ]
		    then
                rm $WORK_PATH/json/$minimum.json
            fi
		fi

        # remove old json file if exist

		echo $delay > $WORK_PATH/delay/delay.min
        let minimum=$counter
	else
    # if new node is slower than old node

        # remove new source file
		if [ $counter -lt 10 ]
		then
			rm "$WORK_PATH/subscription.json.source/0$counter"

            if [ -f "$WORK_PATH"/json/0$counter.json ]
		    then
                rm $WORK_PATH/json/0$counter.json
            fi
		else
			rm "$WORK_PATH/subscription.json.source/$counter"

            if [ -f "$WORK_PATH"/json/$counter.json ]
		    then
                rm $WORK_PATH/json/$counter.json
            fi
		fi

        # remove new source file if exist
	fi

    let counter++
	sed -i '1d' $WORK_PATH/delay/delay.compare
done

# Tell user result
echo ''
if [ -f $WORK_PATH/json/* ]
then
    echo -e "\033[32m\033[01mNO.$(ls $WORK_PATH/subscription.json.source) node has the minimum latency.\033[0m"
    echo ''
    exit 0
fi
echo "Seems that all your node(s) is(are) died. :("
echo ''
exit 1
