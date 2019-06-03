#! /bin/python3

import os
import sys
import wcwidth
from tabulate import tabulate

FILE=os.getcwd()+'/ssrSubUpd/delay/delay.print'
table_data=[]
bdy=''
nu=1

table_header = ['NO.', 'Server', 'Delay']

with open(FILE, mode='r') as file:
    for row in file:
        bdy=row.strip('\n')
        bdy=str(nu)+'|'+bdy
        table_data.append(bdy.split('|'))
        nu=nu+1

print("")
print(tabulate(table_data, headers=table_header, tablefmt='fancy_grid', colalign=("left","left","left")))
print("")
