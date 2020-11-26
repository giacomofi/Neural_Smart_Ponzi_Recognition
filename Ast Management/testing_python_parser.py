# Author: Jack
# 27-10-20


from os import listdir
from os.path import isfile, join
import json
from ast_parser_tools import ASTSemanticExtraction


#I list all my Ponzies inside the directory

s = ASTSemanticExtraction()
ponzies = s.get_ast('/home/giacomo/PycharmProjects/ast_generator/Ponzi Abstract Syntax Trees')
not_ponzies = s.get_ast('/home/giacomo/PycharmProjects/ast_generator/Not Smart Ponzi AST')
dire = '/home/giacomo/PycharmProjects/ast_generator/Ponzi Abstract Syntax Trees/LittleCactusAST.json'


s.mono_semantic_extraction('EtheramidAST.json')
s.return_values()
# data = s.open_file(dire)
# s.mono_semantic_extraction(str(data))


