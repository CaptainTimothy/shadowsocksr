#! /bin/sh

WORK_PATH=$(cd "$(dirname "$0")";pwd)/ssrImpLnk

# Create work path.
mkdir $WORK_PATH

echo $1 > $WORK_PATH/link.decode.01

# Remove "ssr://"
sed -i 's/^......//g' $WORK_PATH/link.decode.01

# Decode for the second time. (domain:port:*)
for link in $(cat $WORK_PATH/link.decode.01)
do
	echo $link | base64 -d >> $WORK_PATH/link.decode.02
	echo '' >> $WORK_PATH/link.decode.02
done

# Decode for the third time. (Decode password and etc.)
for link in $(cat $WORK_PATH/link.decode.02)
do
	echo -e "$link\c" | sed -e 's/\(.*\)http_simple:.*/\1/' >> $WORK_PATH/link.decode.03
	echo -e "http_simple:\c" >> $WORK_PATH/link.decode.03
	echo -e "$link\c" | sed -e 's/.*http_simple:\(.*\)\/.*/\1/' | base64 -d >> $WORK_PATH/link.decode.03
	echo -e "/?obfsparm=\c" >> $WORK_PATH/link.decode.03
	echo -e "$link\c" | sed -e 's/.*obfsparam=\(.*\)&protoparam.*/\1/' | base64 -d >> $WORK_PATH/link.decode.03
	echo -e "&protoparam=\c" >> $WORK_PATH/link.decode.03
	echo -e "$link\c" | sed -e 's/.*protoparam=\(.*\)&remarks.*/\1/' | base64 -d >> $WORK_PATH/link.decode.03

	echo '' >> $WORK_PATH/link.decode.03
	let line++
done

# Convert those decoded links line by line.
mkdir $WORK_PATH/link.json.source

for link in $(cat $WORK_PATH/link.decode.03)
do
	echo "$link" | sed -e 's/:/\n/; s/:/\n/; s/:/\n/; s/:/\n/; s/:/\n/' | sed -e 's/\/?obfsparm=/\n/' -e 's/&protoparam=/\n/' -e 's/&remarks=/\n/' > "$WORK_PATH/link.json.source/$server_no"
	let "server_no++"
done

# Process the file to a shadowsocksR config file.

mv $WORK_PATH/link.json.source/* $WORK_PATH/link.json.source/user-config.source							# Rename file to "user-config.source"

echo -e "{\n\t\"server\":\"\c" > $WORK_PATH/user-config.json									# Server IP / domain.
echo "$(cat $WORK_PATH/link.json.source/user-config.source | head -n 1)\"," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/link.json.source/user-config.source

echo -e "\t\"server_ipv6\":\"::\"," >> $WORK_PATH/user-config.json								# Server IPv6 address.

echo -e "\t\"server_port\":\c" >> $WORK_PATH/user-config.json									# Server port.
echo "$(cat $WORK_PATH/link.json.source/user-config.source | head -n 1)," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/link.json.source/user-config.source

echo -e "\t\"protocol\":\"\c" >> $WORK_PATH/user-config.json									# Server protocol.
echo "$(cat $WORK_PATH/link.json.source/user-config.source | head -n 1)," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/link.json.source/user-config.source

echo -e "\t\"method\":\"\c" >> $WORK_PATH/user-config.json									# Server method.
echo "$(cat $WORK_PATH/link.json.source/user-config.source | head -n 1)," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/link.json.source/user-config.source

echo -e "\t\"obfs\":\"\c" >> $WORK_PATH/user-config.json									# Server obfs.
echo "$(cat $WORK_PATH/link.json.source/user-config.source | head -n 1)," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/link.json.source/user-config.source

echo -e "\t\"local_address\":\"127.0.0.1\"," >> $WORK_PATH/user-config.json							# Local host address.

echo -e "\t\"local_port\":1080," >> $WORK_PATH/user-config.json									# Local port.

echo -e "\t\"password\":\"\c" >> $WORK_PATH/user-config.json									# Server password.
echo "$(cat $WORK_PATH/link.json.source/user-config.source | head -n 1)," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/link.json.source/user-config.source

echo -e "\t\"obfs_param\":\"\c" >> $WORK_PATH/user-config.json									# Server obfs param.
echo "$(cat $WORK_PATH/link.json.source/user-config.source | head -n 1)," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/link.json.source/user-config.source

echo -e "\t\"protocol_param\":\"\c" >> $WORK_PATH/user-config.json								# Server obfs param.
echo "$(cat $WORK_PATH/link.json.source/user-config.source | head -n 1)," >> $WORK_PATH/user-config.json
sed -i '1d' $WORK_PATH/link.json.source/user-config.source

echo -e "\t\"speed_limit_per_con\":0" >> $WORK_PATH/user-config.json								# Speed limit.
echo -e "\t\"speed_limit_per_user\":0" >> $WORK_PATH/user-config.json

echo -e "\t\"timeout\":300," >> $WORK_PATH/user-config.json 									# Timeout.
echo -e "\t\"udp_timeout\":300," >> $WORK_PATH/user-config.json

echo -e "\t\"dns_ipv6\":true" >> $WORK_PATH/user-config.json									# DNS settings.

echo -e "\t\"connect_verbose_info\":0," >> $WORK_PATH/user-config.json 								# Connect info.

echo -e "\t\"redirect\":\"\"," >> $WORK_PATH/user-config.json 									# Redirection settings.

echo -e "\t\"fast_open\":false\n}" >> $WORK_PATH/user-config.json 								# TCP fast open.

# Replace "user-config.json"
mv $SSR_PATH/user-config.json $SSR_PATH/user-config.old
cp $WORK_PATH/user-config.json $SSR_PATH/

# remove temprory files
rm -rf $WORK_PATH
