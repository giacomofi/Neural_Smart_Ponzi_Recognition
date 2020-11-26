from ast_parser_tools import ASTSemanticExtraction

# Author: Jack
# 22-11-20
# Use build_semantic.py to get your semantic documents starting from a Solidity AST
# Semantic is defined by all variables, structs, wildcards, inheritance relationships and so on

parser = ASTSemanticExtraction()
parser.semantic_extraction('/home/giacomo/PycharmProjects/ast_generator/Ponzi Abstract Syntax Trees/')
for ast in parser.ast_objects:
    try:
        with open('/home/giacomo/PycharmProjects/ast_generator/Ponzi Semantic Documents/' + ast.name + '.txt', 'w') as file:
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
    finally:
        file.close()
    parser.reset()
parser.reset_ast_object()
parser.semantic_extraction('/home/giacomo/PycharmProjects/ast_generator/Not Smart Ponzi AST/')
for ast in parser.ast_objects:
    try:
        with open('/home/giacomo/PycharmProjects/ast_generator/Not Ponzi Semantic Documents/' + ast.name + '.txt', 'w') as file:
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
    finally:
        file.close()