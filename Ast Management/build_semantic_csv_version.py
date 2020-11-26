import csv
from ast_parser_tools import ASTSemanticExtraction

# Author: Jack
# 22-11-20
# Use build_semantic.py to get your semantic csv starting from  Solidity ASTs
# Semantic is defined by all variables, structs, wildcards, inheritance relationships and so on

if __name__ == '__main__':
    def semantic_extraction():
        with open('/home/giacomo/PycharmProjects/ast_generator/Docs/contracts.csv', 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(
                ['Name', 'Contract', 'Inheritance Relationship', 'Pragma', 'Library', 'Modifier', 'Event', 'Variables',
                 'Struct', 'Struct Components', 'Function', 'Wildcard', 'Target'])
            print(len(parser.ast_objects))
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts, ast.inheritance_relationships, ast.pragmas, ast.libraries, ast.modifiers, ast.events, ast.state_variables, ast.structs, ast.struct_components, ast.functions, ast.wildcards, 1])
            parser.reset()
            parser.reset_ast_object()
            parser.semantic_extraction('/home/giacomo/PycharmProjects/ast_generator/Not Smart Ponzi AST/')
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts, ast.inheritance_relationships, ast.pragmas, ast.libraries, ast.modifiers, ast.events, ast.state_variables, ast.structs, ast.struct_components, ast.functions, ast.wildcards, 0])


    parser = ASTSemanticExtraction()
    parser.semantic_extraction('/home/giacomo/PycharmProjects/ast_generator/Ponzi Abstract Syntax Trees/')
    semantic_extraction()







