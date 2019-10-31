#! /bin/sh

server_no=1
CURRENT_PATH=$(cd "$(dirname "$0")";pwd)
WORK_PATH=$(cd "$(dirname "$0")";pwd)/ssrSubUpd
str=''

# Remove old files.
if [ -d "$WORK_PATH" ]
then
	rm -r $WORK_PATH
	if [ $? -ne 0 ]
	then
		echo -e "\033[31m\033[01m\033[05mFailed to delete previous work folder. Please check who's using this folder.\033[0m"
		lsof $WORK_PATH
	fi
fi

# Create work path.
mkdir $WORK_PATH

# remove commit in subscription.lst
cp $CURRENT_PATH/subscription.lst $WORK_PATH/subscription.list
sed -i '/^#/d' $WORK_PATH/subscription.list

# remove commit in exclude.lst
cp $CURRENT_PATH/exclude.lst $WORK_PATH/exclude.list
sed -i '/^#/d' $WORK_PATH/exclude.list

# Get subscription(s).
for subscription_link in $(cat $WORK_PATH/subscription.list)
do
	curl $subscription_link >> $WORK_PATH/subscription.source
	
	if [ $? != 0 ]
	then
		echo ''
		echo -e "\033[31m\033[01m\033[05mUpdate Failed. Check your internet connection\033[0m"
		exit 99
	fi
	echo '' >> $WORK_PATH/subscription.source
done


# Decode for the first time. (ssr://*)
for link in $(cat $WORK_PATH/subscription.source)
do
	echo "$link" | base64 -d >> $WORK_PATH/subscription.decode.01
done

# Remove "ssr://"
sed -i 's/^......//g' $WORK_PATH/subscription.decode.01

sed -i 's/_/\//g' $WORK_PATH/subscription.decode.01
sed -i 's/-/+/g' $WORK_PATH/subscription.decode.01

# Decode for the second time. (domain:port:*)
for link in $(cat $WORK_PATH/subscription.decode.01)
do
	echo $link | base64 -d >> $WORK_PATH/subscription.decode.02
	echo '' >> $WORK_PATH/subscription.decode.02
done

# Remove invalid node
for link in $(cat ${WORK_PATH}/subscription.decode.02)
do
    remark=$(echo ${link} | grep -Po "(?<=remarks=).*" | grep -Po ".*(?=&group=)" | sed -e 's/_/\//g' | sed -e 's/-/+/g' | base64 -d)

    for pattern in $(cat ${WORK_PATH}/exclude.list)
    do
        if [ ! -z "$(echo ${remark}${link} | grep ${pattern})" ]
        then
            sed -i "/$(echo ${link} | sed -e 's/\//\\\//g')/d" ${WORK_PATH}/subscription.decode.02
            break
        fi
    done
done
cat ${WORK_PATH}/subscription.decode.02


# Decode for the third time. (Decode password and etc.)

mkdir $WORK_PATH/subscription.json.source
for link in $(cat $WORK_PATH/subscription.decode.02)
do
    ## add "0" when number is less than 10
    if [ $server_no -lt 10 ]
    then
        str="0$server_no"
    else
        str="$server_no"
    fi

    ## split the whole thing line by line
    echo $link > $WORK_PATH/subscription.json.source/$str
    sed -i 's/:/\n/g' $WORK_PATH/subscription.json.source/$str
    sed -i 's/\/?obfsparam=/\n/g' $WORK_PATH/subscription.json.source/$str
    sed -i 's/&protoparam=/\n/g' $WORK_PATH/subscription.json.source/$str
    sed -i 's/&remarks=/\n/g' $WORK_PATH/subscription.json.source/$str
    sed -i 's/&group=/\n/g' $WORK_PATH/subscription.json.source/$str

    let server_no++
done

# Decode for the password and etc
for file in $(ls $WORK_PATH/subscription.json.source/)
do
    ## get line 6~10, replace, decode them, then replace again
    server_no=6
    while [ $server_no -lt 11 ]
    do
        pattern=$(sed -e "$server_no!d" $WORK_PATH/subscription.json.source/$file)

        sed -i "0,/$pattern/s/$pattern/MARK_HERE/" $WORK_PATH/subscription.json.source/$file

        sed -i "s/MARK_HERE/$(echo -e "$(echo $pattern | sed -e 's/_/\//g; s/-/+/g' | base64 -d)")/" $WORK_PATH/subscription.json.source/$file
        let server_no++
    done
done

# Generate a list for print nodes.

let server_no=1

for file in $(ls $WORK_PATH/subscription.json.source/)
do
    if [ $server_no -lt 10 ]
    then
        echo 0$server_no >> $WORK_PATH/node.list
    else
        echo $server_no >> $WORK_PATH/node.list
    fi
    cat $WORK_PATH/subscription.json.source/$file | head -n 1 >> $WORK_PATH/node.list
    cat $WORK_PATH/subscription.json.source/$file | tail -2 >> $WORK_PATH/node.list
    echo 'EOL' >> $WORK_PATH/node.list
    let server_no++
done

sed -i ':a;N;$!ba;s/\n/\|/g' $WORK_PATH/node.list
sed -i 's/EOL/\n/g' $WORK_PATH/node.list
sed -i -E 's/^\|//g; s/\|$//g' $WORK_PATH/node.list
sed -i '/^$/d' $WORK_PATH/node.list

# Create a list with server ip(s) in order to test latency.
mkdir $WORK_PATH/delay

for file in $(ls $WORK_PATH/subscription.json.source)
do
	cat $WORK_PATH/subscription.json.source/$file | head -n 1 >> $WORK_PATH/delay/address.list
done

# Print all node(s).
#echo -e "\033c\e[3J"
echo ''
/bin/python $CURRENT_PATH/print-nodes.py
echo ''
