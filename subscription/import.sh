#! /bin/sh

counter=6
CURRENT_PATH=$(cd "$(dirname "$0")";pwd)
WORK_PATH=$(cd "$(dirname "$0")";pwd)/ssrLnkImp
SSR_PATH=$(cd "$(dirname "$0")/../";pwd)

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

# Write link into a file
echo $1 > $WORK_PATH/import.src

# Remove "ssr://", replace "_" and "-"
sed -i 's/^......//g' $WORK_PATH/import.src 2> /dev/null
sed -i 's/_/\//g' $WORK_PATH/import.src 2> /dev/null
sed -i 's/-/+/g' $WORK_PATH/import.src 2> /dev/null

# Decode for the second time. (domain:port:*)
cat $WORK_PATH/import.src | base64 -d >> $WORK_PATH/import.decode 2> /dev/null

# Decode for the third time. (Decode password and etc.)
## split the whole thing line by line
sed -i 's/:/\n/g' $WORK_PATH/import.decode 2> /dev/null
sed -i 's/\/?obfsparam=/\n/g' $WORK_PATH/import.decode 2> /dev/null
sed -i 's/&protoparam=/\n/g' $WORK_PATH/import.decode 2> /dev/null
sed -i 's/&remarks=/\n/g' $WORK_PATH/import.decode 2> /dev/null
sed -i 's/&group=/\n/g' $WORK_PATH/import.decode 2> /dev/null

## Decode for the password and etc
while [ $counter -lt 11 ]
do
    line=$(sed -e "$counter!d" $WORK_PATH/import.decode 2> /dev/null)
    sed -i "s/$line/MARK_HERE/" $WORK_PATH/import.decode 2> /dev/null
    sed -i "s/MARK_HERE/$(echo -e "$(echo $line | sed -e 's/_/\//g; s/-/+/g' 2> /dev/null | base64 -d 2> /dev/null)")/" $WORK_PATH/import.decode 2> /dev/null
    let counter++
done

# Generate user-config.json
echo -e "{\n\t\"server\":\"\c" > $WORK_PATH/user-config.json									# Server IP / domain.
echo "$(cat $WORK_PATH/import.decode | head -n 1)\"," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/import.decode 2> /dev/null

echo -e "\t\"server_ipv6\":\"::\"," >> $WORK_PATH/user-config.json								# Server IPv6 address.

echo -e "\t\"server_port\":\c" >> $WORK_PATH/user-config.json									# Server port.
echo "$(cat $WORK_PATH/import.decode | head -n 1)," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/import.decode 2> /dev/null

echo -e "\t\"protocol\":\"\c" >> $WORK_PATH/user-config.json									# Server protocol.
echo "$(cat $WORK_PATH/import.decode | head -n 1)\"," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/import.decode 2> /dev/null

echo -e "\t\"method\":\"\c" >> $WORK_PATH/user-config.json									# Server method.
echo "$(cat $WORK_PATH/import.decode | head -n 1)\"," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/import.decode 2> /dev/null

echo -e "\t\"obfs\":\"\c" >> $WORK_PATH/user-config.json										# Server obfs.
echo "$(cat $WORK_PATH/import.decode | head -n 1)\"," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/import.decode 2> /dev/null

echo -e "\t\"local_address\":\"127.0.0.1\"," >> $WORK_PATH/user-config.json							# Local host address.

echo -e "\t\"local_port\":1080," >> $WORK_PATH/user-config.json									# Local port.

echo -e "\t\"password\":\"\c" >> $WORK_PATH/user-config.json									# Server password.
echo "$(cat $WORK_PATH/import.decode | head -n 1)\"," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/import.decode 2> /dev/null

echo -e "\t\"obfs_param\":\"\c" >> $WORK_PATH/user-config.json									# Server obfs param.
echo "$(cat $WORK_PATH/import.decode | head -n 1)\"," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/import.decode 2> /dev/null

echo -e "\t\"protocol_param\":\"\c" >> $WORK_PATH/user-config.json								# Server protocol param.
echo "$(cat $WORK_PATH/import.decode | head -n 1)\"," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/import.decode 2> /dev/null

echo -e "\t\"speed_limit_per_con\":0," >> $WORK_PATH/user-config.json								# Speed limit.
echo -e "\t\"speed_limit_per_user\":0," >> $WORK_PATH/user-config.json

echo -e "\t\"timeout\":300," >> $WORK_PATH/user-config.json 									# Timeout.
echo -e "\t\"udp_timeout\":300," >> $WORK_PATH/user-config.json

echo -e "\t\"dns_ipv6\":true," >> $WORK_PATH/user-config.json									# DNS settings.

echo -e "\t\"connect_verbose_info\":0," >> $WORK_PATH/user-config.json 								# Connect info.

echo -e "\t\"redirect\":\"\"," >> $WORK_PATH/user-config.json 									# Redirection settings.

echo -e "\t\"fast_open\":false," >> $WORK_PATH/user-config.json 								# TCP fast open.

echo -e "\t\"remarks\":\"\c" >> $WORK_PATH/user-config.json									# Server marks.
echo "$(cat $WORK_PATH/import.decode | head -n 1)\"," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/import.decode 2> /dev/null


echo -e "\t\"group\":\"\c" >> $WORK_PATH/user-config.json									# Server group.
echo -e "$(cat $WORK_PATH/import.decode | head -n 1)\"\n}" >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/import.decode 2> /dev/null

# Replace old config
if [ -f "$SSR_PATH/user-config.json.old" ]
then
	rm $SSR_PATH/user-config.json.old
fi
mv $SSR_PATH/user-config.json $SSR_PATH/user-config.json.old

# Copy new files
cp $WORK_PATH/user-config.json $SSR_PATH/user-config.json

# Remove temporary files.
rm -rf $WORK_PATH
