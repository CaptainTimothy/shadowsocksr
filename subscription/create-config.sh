#! /bin/sh

WORK_PATH=$(cd "$(dirname "$0")";pwd)/ssrSubUpd

# Process the file to a shadowsocksR config file.
mkdir $WORK_PATH/json

for file in $(ls $WORK_PATH/subscription.json.source)
do
	echo -e "{\n\t\"server\":\"\c" > $WORK_PATH/json/$file.json									# Server IP / domain.
	echo "$(cat $WORK_PATH/subscription.json.source/$file | head -n 1)\"," >> $WORK_PATH/json/$file.json
	sed -i '1d' $WORK_PATH/subscription.json.source/$file
	
	echo -e "\t\"server_ipv6\":\"::\"," >> $WORK_PATH/json/$file.json								# Server IPv6 address.
	
	echo -e "\t\"server_port\":\c" >> $WORK_PATH/json/$file.json									# Server port.
	echo "$(cat $WORK_PATH/subscription.json.source/$file | head -n 1)," >> $WORK_PATH/json/$file.json
	sed -i '1d' $WORK_PATH/subscription.json.source/$file
	
	echo -e "\t\"protocol\":\"\c" >> $WORK_PATH/json/$file.json									# Server protocol.
	echo "$(cat $WORK_PATH/subscription.json.source/$file | head -n 1)\"," >> $WORK_PATH/json/$file.json
	sed -i '1d' $WORK_PATH/subscription.json.source/$file
	
	echo -e "\t\"method\":\"\c" >> $WORK_PATH/json/$file.json									# Server method.
	echo "$(cat $WORK_PATH/subscription.json.source/$file | head -n 1)\"," >> $WORK_PATH/json/$file.json
	sed -i '1d' $WORK_PATH/subscription.json.source/$file
	
	echo -e "\t\"obfs\":\"\c" >> $WORK_PATH/json/$file.json										# Server obfs.
	echo "$(cat $WORK_PATH/subscription.json.source/$file | head -n 1)\"," >> $WORK_PATH/json/$file.json
	sed -i '1d' $WORK_PATH/subscription.json.source/$file
	
	echo -e "\t\"local_address\":\"127.0.0.1\"," >> $WORK_PATH/json/$file.json							# Local host address.
	
	echo -e "\t\"local_port\":1080," >> $WORK_PATH/json/$file.json									# Local port.
	
	echo -e "\t\"password\":\"\c" >> $WORK_PATH/json/$file.json									# Server password.
	echo "$(cat $WORK_PATH/subscription.json.source/$file | head -n 1)\"," >> $WORK_PATH/json/$file.json
	sed -i '1d' $WORK_PATH/subscription.json.source/$file
	
	echo -e "\t\"obfs_param\":\"\c" >> $WORK_PATH/json/$file.json									# Server obfs param.
	echo "$(cat $WORK_PATH/subscription.json.source/$file | head -n 1)\"," >> $WORK_PATH/json/$file.json
	sed -i '1d' $WORK_PATH/subscription.json.source/$file
	
	echo -e "\t\"protocol_param\":\"\c" >> $WORK_PATH/json/$file.json								# Server protocol param.
	echo "$(cat $WORK_PATH/subscription.json.source/$file | head -n 1)\"," >> $WORK_PATH/json/$file.json
	sed -i '1d' $WORK_PATH/subscription.json.source/$file
	
	echo -e "\t\"speed_limit_per_con\":0," >> $WORK_PATH/json/$file.json								# Speed limit.
	echo -e "\t\"speed_limit_per_user\":0," >> $WORK_PATH/json/$file.json
	
	echo -e "\t\"timeout\":300," >> $WORK_PATH/json/$file.json 									# Timeout.
	echo -e "\t\"udp_timeout\":300," >> $WORK_PATH/json/$file.json
	
	echo -e "\t\"dns_ipv6\":true," >> $WORK_PATH/json/$file.json									# DNS settings.
	
	echo -e "\t\"connect_verbose_info\":0," >> $WORK_PATH/json/$file.json 								# Connect info.
	
	echo -e "\t\"redirect\":\"\"," >> $WORK_PATH/json/$file.json 									# Redirection settings.
	
	echo -e "\t\"fast_open\":false," >> $WORK_PATH/json/$file.json 								# TCP fast open.

	echo -e "\t\"remarks\":\"\c" >> $WORK_PATH/json/$file.json									# Server marks.
	echo "$(cat $WORK_PATH/subscription.json.source/$file | head -n 1)\"," >> $WORK_PATH/json/$file.json
	sed -i '1d' $WORK_PATH/subscription.json.source/$file


	echo -e "\t\"group\":\"\c" >> $WORK_PATH/json/$file.json									# Server group.
	echo -e "$(cat $WORK_PATH/subscription.json.source/$file | head -n 1)\"\n}" >> $WORK_PATH/json/$file.json
	sed -i '1d' $WORK_PATH/subscription.json.source/$file
done

