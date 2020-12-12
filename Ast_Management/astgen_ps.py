# Author: Jack
# 27-10-20

from solidity_parser import parser
from os import listdir
from os.path import isfile, join
import json
import os

if __name__ == '__main__':

    # I list all my Ponzies inside the directory
    this_dir, _ = os.path.split(__file__)
    data_dir = this_dir.replace('Ast_Management', 'Smart_Ponzi')
    smart_ponzi_ast_dir = this_dir.replace('Ast_Management', 'Ponzi_Abstract_Syntax_Trees')

    ponzies = [f for f in listdir(data_dir) if isfile(join(data_dir, f))]

    # Process all contracts and extracts all AST
    for contract in ponzies:
        contract_divide = contract.split('.')
        contract_name = contract_divide[0]
        ast_name = contract_name + 'AST.json'

        with open(smart_ponzi_ast_dir + '/' + str(ast_name), 'w') as json_file:
            json.dump(parser.parse_file(data_dir + '/' + str(contract)), json_file)
