#
# Author: giacomo
# 22-11-20
# Use build_semantic.py to get your semantic documents starting from a Solidity AST
# Semantic is defined by all variables, structs, wildcards, inheritance relationships and so on
# This version builds a txt file for each AST


############### DEPRECATED ##################

from ast_parser_tools import ASTSemanticExtraction
import os
import yaml
from yaml import FullLoader

if __name__ == '__main__':

    this_dir, _ = os.path.split(__file__)
    base_name = os.path.basename(this_dir)
    config = this_dir.replace(base_name, 'config.yaml')
    with open(config, 'r') as yaml_file:
        cfg = yaml.load(yaml_file, Loader=FullLoader)
    ponzi_semantic_documents = os.path.expanduser(cfg['config']['ponzi_semantic_documents'])
    not_ponzi_semantic_documents = os.path.expanduser(cfg['config']['not_ponzi_semantic_documents'])
    ponzi_ast_dir = os.path.expanduser(cfg['config']['ponzi_ast_location'])
    not_ponzi_ast_dir = os.path.expanduser(cfg['config']['not_ponzi_ast_location'])
    # Instantiating the parser
    parser = ASTSemanticExtraction()
    # Get semantic from all the Ponzi AST
    parser.semantic_extraction(ponzi_ast_dir + '/')
    # Check every AST object
    for ast in parser.ast_objects:
        try:
            # Generating semantic documents for Smart Ponzies
            with open(ponzi_semantic_documents + ast.name + '.txt', 'w') as file:
                # Check all the AST objects parameters
                # If a parameter is empty then we don't have semantic, so, no file writing
                if len(ast.pragmas) != 0:
                    for pragma in ast.pragmas:
                        file.write(pragma)
                        file.write(' ')
                    file.write('\n')
                if len(ast.contracts) != 0:
                    for contract in ast.contracts:
                        file.write(contract)
                        file.write(' ')
                    file.write('\n')
                if len(ast.libraries) != 0:
                    for library in ast.libraries:
                        file.write(library)
                        file.write(' ')
                    file.write('\n')
                if len(ast.structs) != 0:
                    for struct in ast.structs:
                        file.write(struct)
                        file.write(' ')
                    file.write('\n')
                if len(ast.struct_components) != 0:
                    for component in ast.struct_components:
                        file.write(component)
                        file.write('\n')
                if len(ast.state_variables) != 0:
                    for variable in ast.state_variables:
                        file.write(variable)
                        file.write(' ')
                    file.write('\n')
                if len(ast.functions) != 0:
                    for function in ast.functions:
                        if function is not None:
                            file.write(function)
                            file.write(' ')
                    file.write('\n')
                if len(ast.inheritance_relationships) != 0:
                    for relation in ast.inheritance_relationships:
                        file.write(relation)
                        file.write(' ')
                    file.write('\n')
                if len(ast.modifiers) != 0:
                    for modifier in ast.modifiers:
                        file.write(modifier)
                        file.write(' ')
                    file.write('\n')
                if len(ast.events) != 0:
                    for event in ast.events:
                        file.write(event)
                        file.write(' ')
                    file.write('\n')
                if len(ast.wildcards) != 0:
                    for wildcard in ast.wildcards:
                        if wildcard is not None:
                            file.write(wildcard)
                            file.write('\n')
        except FileNotFoundError:
            print("The file does not exists or maybe you're looking for it in the wrong directory")
    # Reset parser
    parser.reset()
    parser.reset_ast_object()
    # Semantic extraction from Not Ponzies AST
    parser.semantic_extraction(not_ponzi_ast_dir + '/')
    # We repeat the same process, but now we build semantic for Not Ponzies
    for ast in parser.ast_objects:
        try:
            with open(not_ponzi_semantic_documents + ast.name + '.txt',
                      'w') as file:
                if len(ast.pragmas) != 0:
                    for pragma in ast.pragmas:
                        file.write(pragma)
                        file.write(' ')
                    file.write('\n')
                if len(ast.contracts) != 0:
                    for contract in ast.contracts:
                        file.write(contract)
                        file.write(' ')
                    file.write('\n')
                if len(ast.libraries) != 0:
                    for library in ast.libraries:
                        file.write(library)
                        file.write(' ')
                    file.write('\n')
                if len(ast.structs) != 0:
                    for struct in ast.structs:
                        file.write(struct)
                        file.write(' ')
                    file.write('\n')
                if len(ast.struct_components) != 0:
                    for component in ast.struct_components:
                        file.write(component)
                        file.write('\n')
                if len(ast.state_variables) != 0:
                    for variable in ast.state_variables:
                        file.write(variable)
                        file.write(' ')
                    file.write('\n')
                if len(ast.functions) != 0:
                    for function in ast.functions:
                        if function is not None:
                            file.write(function)
                            file.write(' ')
                    file.write('\n')
                if len(ast.inheritance_relationships) != 0:
                    for relation in ast.inheritance_relationships:
                        file.write(relation)
                        file.write(' ')
                    file.write('\n')
                if len(ast.modifiers) != 0:
                    for modifier in ast.modifiers:
                        file.write(modifier)
                        file.write(' ')
                    file.write('\n')
                if len(ast.events) != 0:
                    for event in ast.events:
                        file.write(event)
                        file.write(' ')
                    file.write('\n')
                if len(ast.wildcards) != 0:
                    for wildcard in ast.wildcards:
                        if wildcard is not None:
                            file.write(wildcard)
                            file.write('\n')
        except FileNotFoundError:
            print("The file does not exists or maybe you're looking for it in the wrong directory")