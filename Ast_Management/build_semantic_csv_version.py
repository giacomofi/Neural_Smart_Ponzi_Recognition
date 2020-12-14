#
# Author: giacomo
# 22-11-20
# Use build_semantic_csv_version.py to get your semantic documents starting from a Solidity AST
# Semantic is defined by all variables, structs, wildcards, inheritance relationships and so on
# This version builds a csv file where we put as features all the parameters of AST

import csv
from ast_parser_tools import ASTSemanticExtraction
import os
import yaml
from yaml import FullLoader

if __name__ == '__main__':
    def semantic_extraction(contract, not_p_ast):
        # Build the csv file

        with open(contract, 'w', newline='') as file:
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
            parser.semantic_extraction(not_p_ast)
            # Same for Not Ponzi contracts
            for ast in parser.ast_objects:
                writer.writerow([ast.name, ast.contracts, ast.inheritance_relationships, ast.pragmas, ast.libraries, ast.modifiers, ast.events, ast.state_variables, ast.structs, ast.struct_components, ast.functions, ast.wildcards, 0])

    this_dir, _ = os.path.split(__file__)
    base_name = os.path.basename(this_dir)
    config = this_dir.replace(base_name, 'config.yaml')
    with open(config, 'r') as yaml_file:
        cfg = yaml.load(yaml_file, Loader=FullLoader)
    contract_name = os.path.expanduser(cfg['config']['contracts_csv'])
    smart_ponzi_ast_dir = os.path.expanduser(cfg['config']['ponzi_ast_location'])
    not_smart_ponzi_ast_dir = os.path.expanduser(cfg['config']['not_ponzi_ast_location'])
    parser = ASTSemanticExtraction()
    parser.semantic_extraction(smart_ponzi_ast_dir)
    semantic_extraction(contract_name, not_smart_ponzi_ast_dir)







