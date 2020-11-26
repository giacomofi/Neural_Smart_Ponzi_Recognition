# Author: Jack
# 27-10-20

from solidity_parser import parser
from os import listdir
from os.path import isfile, join
import json

#I list all my Ponzies inside the directory

ponzies = [f for f in listdir('/home/giacomo/PycharmProjects/ast_generator/Smart Ponzi') if isfile(join('/home/giacomo/PycharmProjects/ast_generator/Smart Ponzi', f))]


#Process all contracts and extracts all AST
for contract in ponzies:
    contract_divide = contract.split('.')
    contract_name = contract_divide[0]
    ast_name = contract_name + 'AST.json'

    with open('/home/giacomo/Scrivania/AST/' + str(ast_name),'w') as json_file:
        json.dump(parser.parse_file('/home/giacomo/PycharmProjects/ast_generator/Smart Ponzi/' + str(contract)),json_file)


