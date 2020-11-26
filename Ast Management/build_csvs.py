import csv
from ast_parser_tools import ASTSemanticExtraction

# Author: Jack
# 22-11-20
# Use build_semantic.py to get your semantic csv starting from  Solidity ASTs
# Semantic is defined by all variables, structs, wildcards, inheritance relationships and so on

if __name__ == '__main__':
    def semantic_extraction():
        with open('/home/giacomo/PycharmProjects/ast_generator/Docs/ponzi.csv', 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['Name', 'Text'])
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts + ast.inheritance_relationships + ast.modifiers + ast.events + ast.state_variables + ast.structs + ast.struct_components + ast.functions + ast.wildcards])
        parser.reset()
        parser.reset_ast_object()
        parser.semantic_extraction('/home/giacomo/PycharmProjects/ast_generator/Not Smart Ponzi AST/')
        with open('/home/giacomo/PycharmProjects/ast_generator/Docs/not_ponzi.csv', 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['Name', 'Text'])
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts + ast.inheritance_relationships + ast.modifiers + ast.events + ast.state_variables + ast.structs + ast.struct_components + ast.functions + ast.wildcards])
        parser.reset()
        parser.reset_ast_object()
        parser.semantic_extraction('/home/giacomo/PycharmProjects/ast_generator/Ponzi Abstract Syntax Trees/')
        with open('/home/giacomo/PycharmProjects/ast_generator/Docs/contracts2.csv', 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['Name', 'Text', 'Target'])
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts + ast.inheritance_relationships + ast.modifiers + ast.events + ast.state_variables + ast.structs + ast.struct_components + ast.functions + ast.wildcards, 0])
            parser.reset()
            parser.reset_ast_object()
            parser.semantic_extraction('/home/giacomo/PycharmProjects/ast_generator/Not Smart Ponzi AST/')
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts + ast.inheritance_relationships + ast.modifiers + ast.events + ast.state_variables + ast.structs + ast.struct_components + ast.functions + ast.wildcards, 1])

    parser = ASTSemanticExtraction()
    parser.semantic_extraction('/home/giacomo/PycharmProjects/ast_generator/Ponzi Abstract Syntax Trees/')
    semantic_extraction()







