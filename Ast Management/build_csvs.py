#
# Author: giacomo
# 22-11-20
# Use build_semantic_csv_version.py to get your semantic documents starting from a Solidity AST
# Semantic is defined by all variables, structs, wildcards, inheritance relationships and so on
# This version builds 3 csv file where we put as features all the parameters of AST
# First csv contains the semantic of the Ponzi contracts while second csv contains the semantic of Not Ponzi contracts
# Third csv contains all Ponzi and Not Ponzi contracts but with the target variable which defines classes

import csv
from ast_parser_tools import ASTSemanticExtraction
import os


if __name__ == '__main__':

    this_dir, _ = os.path.split(__file__)
    data_dir = this_dir.replace('Ast Management', 'Docs')
    not_smart_ponzi_ast_dir = this_dir.replace('Ast Management', 'Not Smart Ponzi Ast')
    smart_ponzi_ast_dir = this_dir.replace('Ast Management', 'Ponzi Abstract Syntax Trees')
    ponzi_name = 'ponzi.csv'
    contract_name = 'contracts2.csv'
    not_ponzi_name = 'not_ponzi.csv'

    def semantic_extraction():
        # Start writing semantic for Ponzi contracts
        with open(data_dir + '/' + ponzi_name, 'w', newline='') as file:
            writer = csv.writer(file)
            # These csv are bit different. We have name and text only, because these csv are needed only to build word clouds
            writer.writerow(['Name', 'Text'])
            # Write Ponzi features in csv
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts + ast.inheritance_relationships + ast.modifiers + ast.events + ast.state_variables + ast.structs + ast.struct_components + ast.functions + ast.wildcards])
        # Reset parser
        parser.reset()
        parser.reset_ast_object()
        # Writing semantic for Not Ponzi Contracts
        # Same process of Ponzi contracts
        parser.semantic_extraction(not_smart_ponzi_ast_dir + '/')
        with open(data_dir + '/' + not_ponzi_name, 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['Name', 'Text'])
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts + ast.inheritance_relationships + ast.modifiers + ast.events + ast.state_variables + ast.structs + ast.struct_components + ast.functions + ast.wildcards])
        # Reset parser
        parser.reset()
        parser.reset_ast_object()
        parser.semantic_extraction(smart_ponzi_ast_dir + '/')
        # Writing complete semantic
        with open(data_dir + '/' + contract_name, 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['Name', 'Text', 'Target'])
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts + ast.inheritance_relationships + ast.modifiers + ast.events + ast.state_variables + ast.structs + ast.struct_components + ast.functions + ast.wildcards, 1])
            parser.reset()
            parser.reset_ast_object()
            parser.semantic_extraction(not_smart_ponzi_ast_dir + '/')
            for ast in parser.ast_objects:
                # Avoids empty text rows
                if ast.contracts:
                    writer.writerow([ast.name, ast.contracts + ast.inheritance_relationships + ast.modifiers + ast.events + ast.state_variables + ast.structs + ast.struct_components + ast.functions + ast.wildcards, 0])

    parser = ASTSemanticExtraction()
    parser.semantic_extraction(smart_ponzi_ast_dir + '/')
    semantic_extraction()







