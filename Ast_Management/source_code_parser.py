# Author: Jack
# 27-10-20

import json
from os import listdir
from os.path import isfile, join
import os
import yaml
from yaml import FullLoader

if __name__ == '__main__':

    this_dir, _ = os.path.split(__file__)
    base_name = os.path.basename(this_dir)
    config = this_dir.replace(base_name, 'config.yaml')
    with open(config, 'r') as yaml_file:
        cfg = yaml.load(yaml_file, Loader=FullLoader)
    smart_ponzi_source_code = os.path.expanduser(cfg['config']['smart_ponzi_source_code'])
    not_smart_ponzi_source_code_dir = os.path.expanduser(cfg['config']['not_smart_ponzi_source_code'])

    sub_directories = [x[0] for x in os.walk(smart_ponzi_source_code + '/')]
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

                with open(not_smart_ponzi_source_code_dir + '/' + contract_name, 'w') as file:
                    file.write(source_code)



