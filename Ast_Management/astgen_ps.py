# Author: Jack
# 27-10-20

from solidity_parser import parser
from os import listdir
from os.path import isfile, join
import json
import os
import yaml
from yaml import FullLoader

if __name__ == '__main__':

    # I list all my Ponzies inside the directory
    this_dir, _ = os.path.split(__file__)
    base_name = os.path.basename(this_dir)
    config = this_dir.replace(base_name, 'config.yaml')
    with open(config, 'r') as yaml_file:
        cfg = yaml.load(yaml_file, Loader=FullLoader)
    data_dir = os.path.expanduser(cfg['config']['smart_ponzi_source_code'])
    smart_ponzi_ast_dir = os.path.expanduser(cfg['config']['ponzi_ast_location'])

    ponzies = [f for f in listdir(data_dir) if isfile(join(data_dir, f))]

    # Process all contracts and extracts all AST
    for contract in ponzies:
        contract_divide = contract.split('.')
        contract_name = contract_divide[0]
        ast_name = contract_name + 'AST.json'

        with open(smart_ponzi_ast_dir + '/' + str(ast_name), 'w') as json_file:
            json.dump(parser.parse_file(data_dir + '/' + str(contract)), json_file)
    yaml_file.close()
