# Author: Jack
# 27-10-20

from solidity_parser import parser
import os
from os import listdir
from os.path import isfile, join
import json

# I list all my Ponzies inside the directory
if __name__ == '__main__':

    this_dir, _ = os.path.split(__file__)
    data_dir = this_dir.replace('Ast Management', 'Not Smart Ponzi Source Code')
    not_smart_ponzi_ast_dir = this_dir.replace('Ast Management', 'Not Smart Ponzi Ast')

    not_ponzies = [f for f in listdir(data_dir) if isfile(join(data_dir, f))]
    defective_items = []
    # Process all contracts and extracts all AST
    for contract in not_ponzies:
        contract_divide = contract.split('.')
        contract_name = contract_divide[0]
        ast_name = contract_name + 'AST.json'

        with open(not_smart_ponzi_ast_dir + '/' + str(ast_name), 'w') as json_file:
            try:
                json.dump(parser.parse_file(data_dir + '/' + str(contract)), json_file)
            except TypeError:
                defective_items.append(contract)
            except AttributeError:
                defective_items.append(contract)

