#
# Author: giacomo
# 22-11-20
# Use build_semantic_csv_version.py to get your semantic documents starting from a Solidity AST
# Semantic is defined by all variables, structs, wildcards, inheritance relationships and so on
# This version builds a csv file where we put as features all the parameters of AST

import csv
from ast_parser_tools import ASTSemanticExtraction

if __name__ == '__main__':
    def semantic_extraction():
        # Build the csv file
        with open('/home/giacomo/PycharmProjects/ast_generator/Docs/contracts.csv', 'w', newline='') as file:
            writer = csv.writer(file)
            # Start defining the first row of csv. We have Name - Contract - Inheritance Relationship - Pragma - Library - Modifier - Event - Variables - Struct - Struct Components
            # Function - Wildcard - Target
            writer.writerow(
                ['Name', 'Contract', 'Inheritance Relationship', 'Pragma', 'Library', 'Modifier', 'Event', 'Variables',
                 'Struct', 'Struct Components', 'Function', 'Wildcard', 'Target'])
            # Write AST features in csv file
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts, ast.inheritance_relationships, ast.pragmas, ast.libraries, ast.modifiers, ast.events, ast.state_variables, ast.structs, ast.struct_components, ast.functions, ast.wildcards, 1])
            # Reset parser
            parser.reset()
            parser.reset_ast_object()
            parser.semantic_extraction('/home/giacomo/PycharmProjects/ast_generator/Not Smart Ponzi AST/')
            # Same for Not Ponzi contracts
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts, ast.inheritance_relationships, ast.pragmas, ast.libraries, ast.modifiers, ast.events, ast.state_variables, ast.structs, ast.struct_components, ast.functions, ast.wildcards, 0])


    parser = ASTSemanticExtraction()
    parser.semantic_extraction('/home/giacomo/PycharmProjects/ast_generator/Ponzi Abstract Syntax Trees/')
    semantic_extraction()







