# Author: Jack
# 27-10-20

from solidity_parser import parser
from os import listdir
from os.path import isfile, join
import json

# I list all my Ponzies inside the directory

not_ponzies = [f for f in listdir('/home/giacomo/PycharmProjects/ast_generator/Not Smart Ponzi Source Code') if isfile(join('/home/giacomo/PycharmProjects/ast_generator/Not Smart Ponzi Source Code', f))]
defective_items = []
# Process all contracts and extracts all AST
for contract in not_ponzies:
    contract_divide = contract.split('.')
    contract_name = contract_divide[0]
    ast_name = contract_name + 'AST.json'

    with open('/home/giacomo/Scrivania/AST Not Ponzi/' + str(ast_name),'w') as json_file:
        try:
            json.dump(parser.parse_file('/home/giacomo/PycharmProjects/ast_generator/Not Smart Ponzi Source Code/' + str(contract)),json_file)
        except TypeError:
            defective_items.append(contract)
        except AttributeError:
            defective_items.append(contract)

