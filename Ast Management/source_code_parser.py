# Author: Jack
# 27-10-20

import json
from os import listdir
from os.path import isfile, join
import os


sub_directories = [x[0] for x in os.walk('/home/giacomo/PycharmProjects/ast_generator/Not Smart Ponzi/')]
for sub_dir in sub_directories:
    s = sub_dir
    contracts = [f for f in listdir(sub_dir) if isfile(join(sub_dir, f))]
    for contract in contracts:
        contract_parts = contract.split('.')
        json_contract_name = contract_parts[0]
        contract_name = json_contract_name + '.sol'
        with open(sub_dir + '/' + contract,'r') as json_contract:
            print('Analysing contract ' + contract)
            print('-----')
            contract_data = json.load(json_contract)
            source_code = ''
            if contract_data['status'] == '1':
                source_code = contract_data['result'][0]['SourceCode']
            else:
                pass

            with open('/home/giacomo/Scrivania/contracts source code/' + contract_name,'w') as file:
                file.write(source_code)



