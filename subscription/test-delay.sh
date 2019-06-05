#! /bin/sh

#########################
#                       #
#  IMPORTANT NOTICE:    #
#                       #
#  I don't know how to  #
#  test delay like the  #
#  client on android,   #
#  so I can just use    #
#  'ping' instead...    #
#                       #
#  In other words, the  #
#  result is just only  #
#  between client and   #
#  server.              #
#                       #
#  If you have some     #
#  idea, PLEASE tell    #
#  me how to do it.     #
#  Many of thanks.      #
#                       #
# -- Captain Timothy -- #
#                       #
#########################

counter=1
minimum=0
str=''
CURRENT_PATH=$(cd "$(dirname "$0")";pwd)
WORK_PATH=$CURRENT_PATH/ssrSubUpd

# Count nodes
TOTAL=$(wc -l $WORK_PATH/delay/address.list | grep -o -E "[[:digit:]]+")

echo -en "\033c\e[3J"

echo -en "\033c\e[3J"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "▓                          ▓"
echo "▓  Fake Node Latency Test  ▓"
echo "▓        Using Ping        ▓"
echo "▓                          ▓"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"

echo "Please wait while progress bar is running..."

echo ''
echo "Last Node:"
echo ''

# Direction
#
#     A
#     |
# D---+---C
#     |
#     B

echo "** Server: NaN"
# ----123456789▓123456789▓
echo "** Delay: NaN"
echo ''

# ----123456789▓123456789▓
echo -e "Current status: \033[s0 of 0 Node(s)"
echo ''

echo -e "Server: "
# ----123456789▓123456789▓
echo "Delay: "

# Use 'ping -c 4 $addr' to test average latency
for addr in $(cat $WORK_PATH/delay/address.list)
do
    ## print testing progress "0 of 0"
    echo -e "\033[u$counter of $TOTAL Node(s)"

    ## clear current server and print new server
    echo -e "\033[1B\033[8C\033[K$addr"

    ## test delay
    ping -c 4 $addr > $WORK_PATH/delay/delay.report.tmp & PID=$!

    ## move cursor 2 lines below
    echo -e "\033[2B\c"

    ## print progress bar
    printf "Graphic Timer: ["

    while kill -0 $PID 2> /dev/null
    do
        printf  "▓"
        sleep 1
    done
    printf "] done!\n"

    ## save all ping log to one file
    cat $WORK_PATH/delay/delay.report.tmp >> $WORK_PATH/delay/delay.report
    echo '' >> $WORK_PATH/delay/delay.report

    ## process the ping report to get average latency
    cat $WORK_PATH/delay/delay.report.tmp | grep -E '=.*/(.*)/*\.*/*\.*ms|0 received' -o | sed -e 's/.*\/\(.*\)\/.*\/.*ms.*/\1/' > $WORK_PATH/delay/delay.print.tmp

    ## if there is no package received, set delay as 99999
    sed -i 's/0\ received/99999/' $WORK_PATH/delay/delay.print.tmp

    ## save server address and latency to file for print and compare
    echo "$addr|$(cat $WORK_PATH/delay/delay.print.tmp)" >> $WORK_PATH/delay/delay.print

    ## print delay
    echo -e "\033[u\033[3B\033[9D$(cat $WORK_PATH/delay/delay.print.tmp)"
    sleep 0.3

    ## print addr to history
    echo -e "\033[7A\033[11C\033[K$addr"
    
    ## print latency to history
    echo -e "\033[10C\033[K$(cat $WORK_PATH/delay/delay.print.tmp)"

    ## clear current delay
    echo -e "\033[4B\033[7C\033[K"

    ## clear timer
    echo -e "\033[1B\033[K\033[1B\033[K"

    let counter++

done

# Add name resolve error to result list
sed -i 's/|$/|Network\ Error/g' $WORK_PATH/delay/delay.print

# Create file to compare delay
cat $WORK_PATH/delay/delay.print | sed -e 's/^.*|//g; s/Network\ Error/99999/g' >> $WORK_PATH/delay/delay.compare

# Add time out mark
sed -i 's/99999/Time\ out/g' $WORK_PATH/delay/delay.print

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
    ## if new node is faster than old node
    
        ### remove old source file
		if [ $minimum -lt 10 ]
		then
            str="0$minimum"
		else
            str="$minimum"
		fi

        if [ $minimum -ne 0 ]
        then
		    rm $WORK_PATH/subscription.json.source/$str
        fi

        if [ -f "$WORK_PATH"/json/$str.json ]
		then
            rm $WORK_PATH/json/$str.json
        fi

        ### remove old json file if exist

		echo $delay > $WORK_PATH/delay/delay.min
        let minimum=$counter
	else
    ## if new node is slower than old node

        ### remove new source file
		if [ $counter -lt 10 ]
		then
            str="0$counter"
		else
            str="$counter"
		fi

        if [ $counter -ne 0 ]
        then
		    rm "$WORK_PATH/subscription.json.source/$str"
        fi

        if [ -f "$WORK_PATH"/json/$str.json ]
		then
            rm $WORK_PATH/json/$str.json
        fi
	fi

    let counter++
	sed -i '1d' $WORK_PATH/delay/delay.compare
done

# Print result
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
