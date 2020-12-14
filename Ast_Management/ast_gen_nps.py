# Author: Jack
# 27-10-20

from solidity_parser import parser
import os
from os import listdir
from os.path import isfile, join
import json
import yaml
from yaml import FullLoader

# I list all my Ponzies inside the directory
if __name__ == '__main__':

    this_dir, _ = os.path.split(__file__)
    base_name = os.path.basename(this_dir)
    config = this_dir.replace(base_name, 'config.yaml')
    with open(config, 'r') as yaml_file:
        cfg = yaml.load(yaml_file, Loader=FullLoader)
    not_smart_ponzi_source_code = os.path.expanduser(cfg['config']['not_smart_ponzi_source_code'])
    not_smart_ponzi_ast_dir = os.path.expanduser(cfg['config']['not_ponzi_ast_location'])

    not_ponzies = [f for f in listdir(not_smart_ponzi_source_code) if isfile(join(not_smart_ponzi_source_code, f))]
    defective_items = []
    # Process all contracts and extracts all AST
    for contract in not_ponzies:
        contract_divide = contract.split('.')
        contract_name = contract_divide[0]
        ast_name = contract_name + 'AST.json'

        with open(not_smart_ponzi_ast_dir + '/' + str(ast_name), 'w') as json_file:
            try:
                json.dump(parser.parse_file(not_smart_ponzi_source_code + '/' + str(contract)), json_file)
            except TypeError:
                defective_items.append(contract)
            except AttributeError:
                defective_items.append(contract)

