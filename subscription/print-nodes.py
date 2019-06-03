#! /bin/python3

import os
import sys
import wcwidth
from tabulate import tabulate

WORK_PATH=os.getcwd()+'/ssrSubUpd/node.list'
table_data=[]
bfr=''

table_header = ['NO.', 'Server', 'Profile Name', 'Group Name']

with open(WORK_PATH, mode='r') as file:
    for row in file:
        bfr=row.strip('\n')
        table_data.append(bfr.split('|'))

print("")
print(tabulate(table_data, headers=table_header, tablefmt='fancy_grid', colalign=("left","left","left","left")))
print("")
