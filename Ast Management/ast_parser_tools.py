from os import listdir
import os
from os.path import isfile, join, abspath
from json import JSONDecodeError
from ast_build import AST
import json
from parsing_error import ParsingError


class ASTSemanticExtraction:
    # Global
    name = ''
    pragmas = []
    contracts = []
    structs = []
    inheritance_relationships = []
    function_parameters_relationships = {}
    struct_components = []
    base_contracts_container = []
    state_variables = []
    modifiers = []
    wildcards = []
    events = []
    libraries = []
    functions = []
    ast_objects = []
    delimiter = ' '

    def semantic_extraction(self, directory):
        """
        Semantic extraction from a Solidity AST. Start from the root of the tree, then it will be explored in deep.
        The AST is a SourceUnit type.
        WARNING: Some types of operations and statements could contain operation and statements of the same type, so in some cases, recursion is unavoidable.
        Fields of a AST: children
        :param directory:
        """
        # Return all json files inside directory
        ast = self.get_ast(directory)
        for a in ast:
            # The AST we're analyzing
            data = self.open_file(directory, a)
            if data is not None:
                children = data['children']
                for child in children:
                    if child is not None:
                        typing = child['type']
                        if typing == 'PragmaDirective':
                            self.pragma_directive_extraction(child)
                        elif typing == 'ContractDefinition':
                            self.contract_definition_extraction(child)
            self.ast_objects.append(self.build_ast())
            self.reset()

    def mono_semantic_extraction(self, directory, ast):
        """
        Use this as alternative to semantic extraction if you want to parse just one file
        :param ast:
        :param directory:
        """
        data = self.open_file(directory, ast)
        if data is not None:
            children = data['children']
            for child in children:
                if child is not None:
                    typing = child['type']
                    if typing == 'PragmaDirective':
                        self.pragma_directive_extraction(child)
                    elif typing == 'ContractDefinition':
                        self.contract_definition_extraction(child)
                    else:
                        raise ParsingError('AST field missed')

    @staticmethod
    def get_ast(directory):
        """
        Get your contracts' ast
        :param directory: The directory in which your AST are located
        :return: json ast of your solidity contracts
        """
        return [f for f in listdir(directory) if isfile(join(directory, f))]

    def open_file(self, directory, file_name):
        """
        Load AST from json file
        :param file_name: The file to open
        :param directory: The directory which is location of file_name
        :return: data of the current AST which has been analyzed
        """
        name = file_name.split('.')
        self.name = name[0].split('AST')[0]
        try:
            with open(directory + str(file_name), 'r') as r:
                try:
                    data = json.load(r)
                    return data
                except JSONDecodeError:
                    pass
        except FileNotFoundError:
            print("The file does not exists or maybe you're looking for it in the wrong directory")
        finally:
            r.close()

    def pragma_directive_extraction(self, childs):
        """
        One of the possible type of a child is PragmaDirective. With this function you can extract information from that type of child
        :param childs: All the elements inside the AST
        """
        # Pragma name
        name = childs['name']
        # Pragma version
        value = childs['value']
        self.pragmas.append(name + ' ' + value)

    def contract_definition_extraction(self, childs):
        """
        Analyzes all the elements inside the contract
        :param childs:
        """
        # Contract name
        name = childs['name']
        # Base contracts field is for all the contracts inherited by the current contract
        base_contracts = childs['baseContracts']
        # All sub field inside contracts
        sub_nodes = childs['subNodes']
        self.contracts.append(name)
        # Check if a contract inherits from other contracts
        if len(base_contracts) == 0:
            pass
        else:
            # If yes, relationships are saved
            self.inheritance_relationship_extraction(name, base_contracts)
        # Now, we must check all the sub fields of the contract
        for sub_node in sub_nodes:
            sub_node_type = sub_node['type']
            if sub_node_type == 'StateVariableDeclaration':
                self.state_variable_declaration_extraction(sub_node)
            elif sub_node_type == 'StructDefinition':
                self.struct_definition_extraction(sub_node)
            elif sub_node_type == 'EventDefinition':
                self.event_definition_extraction(sub_node)
            elif sub_node_type == 'UsingForDeclaration':
                self.using_for_declaration_extraction(sub_node)
            elif sub_node_type == 'ModifierDefinition':
                self.modifier_definition_extraction(sub_node)
            elif sub_node_type == 'FunctionDefinition':
                self.function_definition_analysis(sub_node)
            else:
                raise ParsingError('AST field missed')

    def function_definition_analysis(self, element):
        """
        Analyzes all the elements inside a function definition
        :param element: element must be FunctionDefinition type
        """
        function_name = element['name']
        self.functions.append(function_name)
        function_parameters = element['parameters']['parameters']
        if len(function_parameters) == 0:
            pass
        else:
            parameters = []
            for parameter in function_parameters:
                parameters.append(parameter['name'])
            func_par_relation = {function_name: parameters}
            self.function_parameters_relationships.update(func_par_relation)
        body = element['body']
        if len(body) == 0:
            pass
        else:
            self.body_analysis(body)

    def inheritance_relationship_extraction(self, name, base_contracts):
        """
        Save the inheritance relationships of the contract currently analyzed.
        :param name: the contract in exam
        :param base_contracts: the contracts inheritated by the contract currently analyzed
        """
        for base_contract in base_contracts:
            relationship = name + ' inherits from ' + base_contract['baseName']['namePath']
            self.inheritance_relationships.append(relationship)

    def state_variable_declaration_extraction(self, element):
        """
        Function to extract StateVariableDeclaration type infos
        :param element: element must be StateVariableDeclaration
        """
        if element['variables'] is not None:
            element_variable = element['variables'][0]['name']
            self.state_variables.append(element_variable)

    def struct_definition_extraction(self, element):
        """
        Function to extract StructDefinition type infos
        :param element: element must be StructDefinition
        """
        struct_name = element['name']
        self.structs.append(struct_name)
        # Every struct has some members inside
        members = element['members']
        m_list = []
        # Each member must be checked
        for member in members:
            member_type = member['type']
            if member_type == 'VariableDeclaration':
                member_name = member['name']
                component = struct_name + ' has ' + member_name
                self.struct_components.append(component)
            else:
                raise ParsingError('AST field missed')

    def event_definition_extraction(self, element):
        """
        Function to extract EventDefinition type infos
        :param element: element must be EventDefinition
        """
        event_name = element['name']
        self.events.append(event_name)

    def using_for_declaration_extraction(self, element):
        """
        Function to extract UsingForDeclaration type extraction
        :param element: element must be UsingForDeclaration
        """
        library_name = element['libraryName']
        self.libraries.append(library_name)

    def modifier_definition_extraction(self, element):
        """
        ModifierDefinition analysis
        :param element: element must be ModifierDefinition
        """
        self.modifiers.append(element['name'])
        # Modifier has statements inside. We must check them to look for interesting infos
        statements = element['body']['statements']
        for statement in statements:
            # Each statement has a type. We must analyse them separately
            statement_type = statement['type']
            # This type has the same fields of the StateVariableDeclarationStatement type
            if statement_type == 'VariableDeclarationStatement':
                self.state_variable_declaration_extraction(statement)
            elif statement_type == 'ExpressionStatement':
                self.expression_statement_extraction(statement)
            elif statement_type == 'IfStatement':
                self.if_statement_analysis(statement)
            else:
                raise ParsingError('AST field missed')

    @staticmethod
    def identifier_extraction(element):
        """
        Extract Identifier type name
        :param element: element must be Identifier type
        :return:
        """
        return element['name']

    def member_access_name(self, element):
        """
        Extract MemberAccess type infos
        :param element: element must be MemberAccess type
        """
        member_extraction = ''
        expression = element['expression']
        member_name = element['memberName']
        if expression['type'] == 'Identifier':
            name = self.identifier_extraction(expression)
            member_extraction += name + self.delimiter + member_name
        elif expression['type'] == 'NumberLiteral':
            number = self.number_literal_extraction(expression)
            member_extraction = number + self.delimiter + member_name
        elif expression['type'] == 'StringLiteral':
            string = self.string_literal_extraction(expression)
            member_extraction = string + self.delimiter + member_name
        elif expression['type'] == 'BooleanLiteral':
            boolean = self.boolean_literal_extraction(expression)
            member_extraction = boolean + self.delimiter + member_name
        elif expression['type'] == 'FunctionCall':
            pass
        # Possible recursive case
        elif expression['type'] == 'IndexAccess':
            member_extraction = self.index_access_extraction(expression) + self.delimiter + member_name
        # Here the element contains an element of the same type. Recursive case
        elif expression['type'] == 'MemberAccess':
            member_name = element['memberName']
            # It must contain the first member of the expression and then the following result of the expression
            member_extraction += self.member_access_name(expression) + self.delimiter + member_name
            return member_extraction
        else:
            raise ParsingError('AST field missed')
        return member_extraction

    def number_literal_extraction(self, element):
        """
        NumberLiteral type infos extraction
        :param element: element is NumberLiteral
        :return:
        """
        if element['subdenomination'] is not None:
            return element['number'] + self.delimiter + element['subdenomination']
        else:
            return element['number']

    @staticmethod
    def boolean_literal_extraction(element):
        """
        BooleanLiteral type infos extraction
        Possible fields: value
        :param element: element must be BooleanLiteral type
        :return:
        """
        return str(element['value'])

    @staticmethod
    def string_literal_extraction(element):
        """
        StringLiteral type infos extraction
        Possible fields: value
        :param element: element must be StringLiteral type
        :return:
        """
        return element['value']

    @staticmethod
    def elementary_type_name_expression(element):
        return element['typeName']['name']

    def function_call_extraction(self, element):
        """
        This function analyze the workflow of a FunctionCall type inside the tree
        Fields: expression
        :param element: element must be FunctionCall type
        """
        # The function call expression
        expression = element['expression']
        # The function name
        function_call_infos = ''
        # Check expression type
        if expression['type'] == 'Identifier':
            function_call_infos += self.identifier_extraction(expression)
        elif expression['type'] == 'MemberAccess':
            function_call_infos += self.member_access_name(expression)
        elif expression['type'] == 'ElementaryTypeName':
            function_call_infos += self.elementary_type_name_expression(expression)
        else:
            raise ParsingError('AST field missed')
        return function_call_infos

    def index_access_extraction(self, element):
        """
        Index Access type infos extraction -- Possible recursive case
        Fields are: base and index
        base: the base of the index. Ex: list[0]. base is list
        index: the index
        WARNING: IndexAccess is a particular case of recursion because, both of the base and index field could have an inner IndexAccess type, so both must be checked for recursion.
        :param element: element must be IndexAccess
        """
        base = element['base']
        base_name = ''
        index_info = ''
        index_type = element['index']['type']
        # Check base type
        if base['type'] == 'Identifier':
            base_name = element['base']['name']
        elif base['type'] == 'IndexAccess':
            if index_type == 'Identifier':
                index_info += self.index_access_extraction(base) + self.delimiter + self.identifier_extraction(element['index'])
            elif index_type == 'NumberLiteral':
                index_info += self.index_access_extraction(base) + self.delimiter + self.number_literal_extraction(element['index'])
            elif index_type == 'IndexAccess':
                index_info += self.index_access_extraction(base) + self.delimiter + self.index_access_extraction(element['index'])
            elif index_type == 'MemberAccess':
                index_info += self.index_access_extraction(base) + self.delimiter + self.member_access_name(element['index'])
            else:
                raise ParsingError('AST field missed')
            return index_info
        # Check index type
        if index_type == 'Identifier':
            index_info += base_name + self.delimiter + self.identifier_extraction(element['index'])
        elif index_type == 'NumberLiteral':
            index_info = base_name + self.delimiter + self.number_literal_extraction(element['index'])
        # Recursive Case
        elif index_type == 'IndexAccess':
            index_info += base_name + self.delimiter + self.index_access_extraction(element['index'])
            return index_info
        # Recursive Case
        elif index_type == 'MemberAccess':
            index_info += self.member_access_name(element['index'])
        elif index_type == 'FunctionCall':
            index_info += self.function_call_extraction(element['index'])
        else:
            raise ParsingError('AST field missed')
        return index_info

    def binary_operation_extraction(self, element):
        """
        BinaryOperation type dissecting
        Fields are operator, left and right
        operator: the binary operator
        left: left part of binary operation
        right: right part of binary operation
        :param element: element must be the 'condition' field
        :return: element must be a BinaryOperation
        """
        # BinaryOperation has a left and a right part plus an operator
        left_part = ''
        right_part = ''
        name = ''
        operator = self.symbol_to_semantic(element['operator'])
        left = element['left']
        right = element['right']
        # Every possible type of expression must be checked
        if left['type'] == 'FunctionCall':
            left_part = self.function_call_extraction(left)
        elif left['type'] == 'Identifier':
            left_part = self.identifier_extraction(left)
        elif left['type'] == 'NumberLiteral':
            left_part = self.number_literal_extraction(left)
        elif left['type'] == 'BooleanLiteral':
            left_part = self.boolean_literal_extraction(left)
        elif left['type'] == 'StringLiteral':
            left_part = self.string_literal_extraction(left)
        elif left['type'] == 'MemberAccess':
            left_part = self.member_access_name(left)
        # This case is recursive. We have a binary operation inside another a binary operation
        elif left['type'] == 'BinaryOperation':
            # We must check the type of the right expression
            if right['type'] == 'NumberLiteral':
                right_part = self.number_literal_extraction(right)
            elif right['type'] == 'BooleanLiteral':
                right_part = self.boolean_literal_extraction(right)
            elif right['type'] == 'StringLiteral':
                right_part = self.string_literal_extraction(right)
            elif right['type'] == 'FunctionCall':
                right_part = self.function_call_extraction(right)
            elif right['type'] == 'Identifier':
                right_part = self.identifier_extraction(right)
            elif right['type'] == 'MemberAccess':
                right_part = self.member_access_name(right)
            # Recursion
            name += self.binary_operation_extraction(left) + self.delimiter + operator + self.delimiter + right_part
            return name
        # We must check every possible type of the right operation
        if right['type'] == 'FunctionCall':
            right_part = self.function_call_extraction(right)
        elif right['type'] == 'Identifier':
            right_part = self.identifier_extraction(right)
        elif right['type'] == 'MemberAccess':
            right_part = self.member_access_name(right)
        elif right['type'] == 'NumberLiteral':
            right_part = self.number_literal_extraction(right)
        elif right['type'] == 'BooleanLiteral':
            right_part = self.boolean_literal_extraction(right)
        elif right['type'] == 'StringLiteral':
            right_part = self.string_literal_extraction(right)
        # This case is recursive. We have a binary operation inside another a binary operation
        elif right['type'] == 'BinaryOperation':
            if left['type'] == 'FunctionCall':
                left_part = self.function_call_extraction(left)
            elif left['type'] == 'NumberLiteral':
                left_part = self.number_literal_extraction(left)
            elif left['type'] == 'Identifier':
                left_part = self.identifier_extraction(left)
            elif left['type'] == 'MemberAccess':
                left_part = self.member_access_name(left)
            # Recursion
            name += left_part + self.delimiter + operator + self.delimiter + self.binary_operation_extraction(right)
            return name
        name += left_part + self.delimiter + operator + self.delimiter + right_part
        return name

    def unary_operation_extraction(self, element):
        """
        Function which analyse the UnaryOperation type
        operator: the unary operator
        subExpression: the expression checked by unary operator
        :param element: element must be UnaryOperation type
        :return:
        """
        unary_operation_return = ''
        operator = self.symbol_to_semantic(element['operator'])
        sub_expression = element['subExpression']
        if sub_expression['type'] == 'Identifier':
            sub_expression_name = sub_expression['name']
            unary_operation_return += operator + self.delimiter + sub_expression_name
        else:
            raise ParsingError('AST field missed')
        return unary_operation_return

    def block_analysis(self, element):
        """
        Analysis of Block type
        Possible fields: statement
        Each statement has a type
        :param element: element must be Block type
        """
        statements = element['statements']
        # Statement list could be empty
        if len(statements) == 0:
            pass
        else:
            # For each statement check what type it is
            for statement in statements:
                # Statement ; it's not interesting
                if statement is not None and statement != ';':
                    # Check statement's type
                    statement_type = statement['type']
                    if statement_type == 'VariableDeclarationStatement':
                        self.state_variable_declaration_extraction(statement)
                    elif statement_type == 'IfStatement':
                        self.if_statement_analysis(statement)
                    elif statement_type == 'ExpressionStatement':
                        self.expression_statement_extraction(statement)
                    elif statement_type == 'WhileStatement':
                        self.while_statement_analysis(statement)
                    elif statement_type == 'ForStatement':
                        self.for_statement_analysis(statement)
                    elif statement_type == 'FunctionCall':
                        self.function_call_extraction(statement)
                    elif statement_type == 'BinaryOperation':
                        self.binary_operation_extraction(statement)
                    elif statement_type == 'MemberAccess':
                        self.member_access_name(statement)
                    else:
                        raise ParsingError('AST field missed')

    def body_analysis(self, element):
        """
        body field analysis
        Chek type, which could be IfStatement or Block
        :param element: element must be body field
        """
        body_type = element['type']
        if body_type == 'IfStatement':
            self.if_statement_analysis(element)
        elif body_type == 'Block':
            self.block_analysis(element)
        else:
            raise ParsingError('AST field missed')

    def if_statement_analysis(self, element):
        """
        Function to analyze a IfStatement type.
        We have some interesting fields:
        condition: the condition of the if statement
        trueBody: if the condition is true then something is done. trueBody contains that
        falseBody: if the condition is false then something is done. falseBody contains that
        :param element:
        """
        if_statement_returns = ''
        condition = element['condition']
        true_body = element['TrueBody']
        false_body = element['FalseBody']
        condition_type = condition['type']
        # Check condition type
        if condition_type == 'BinaryOperation':
            if_statement_returns = 'If ' + self.binary_operation_extraction(condition)
        elif condition_type == 'UnaryOperation':
            if_statement_returns = 'If ' + self.unary_operation_extraction(condition)
        self.wildcards.append(if_statement_returns)
        # TrueBody and FalseBody analysis
        if true_body is not None and true_body != ';':
            self.true_body_analysis(true_body)
        if false_body is not None and false_body != ';':
            self.false_body_analysis(false_body)

    def while_statement_analysis(self, element):
        """
        Function to analyse the WhileStatementType.
        Interesting fields.
        condition: the while condition
        body: the body of the while
        :param element:
        """
        while_condition_returns = ''
        condition = element['condition']
        body = element['body']
        condition_type = condition['type']
        # Check while condition
        if condition_type == 'BinaryOperation':
            while_condition_returns = 'While ' + self.binary_operation_extraction(condition)
        elif condition_type == 'UnaryOperation':
            while_condition_returns = 'While ' + self.unary_operation_extraction(condition)
        else:
            raise ParsingError('AST field missed')
        self.wildcards.append(while_condition_returns)
        # Analyzing body
        self.body_analysis(body)

    def for_statement_analysis(self, element):
        """
        ForStatement analysis
        Fields: are initExpression, conditionExpression, loopExpression
        initExpression: the initial state of the for loop. Ex: i = 0
        conditionLoop: the exit condition from loop. Ex: i < N
        loopExpression: the forward step of the loop. Ex: i++
        :param element: element must be a ForStatement
        """
        # initExpression could be None
        if element['initExpression'] is not None:
            # Check initExpression type
            if element['initExpression']['type'] == 'StateVariableDeclaration' or element['initExpression']['type'] == 'VariableDeclarationStatement':
                self.wildcards.append(self.state_variable_declaration_extraction(element['initExpression']))
            else:
                self.wildcards.append(self.expression_statement_extraction(element['initExpression']))
        else:
            pass
        # conditionExpression could be None
        if element['conditionExpression'] is not None:
            # if not None could be only a BinaryOperation
            self.wildcards.append(self.binary_operation_extraction(element['conditionExpression']))
        else:
            pass
        # loopExpression could be None
        if element['loopExpression'] is not None:
            # Check loopExpression type
            if element['loopExpression'] == 'ExpressionStatement':
                self.wildcards.append(self.expression_statement_extraction(element['loopExpression']))
            elif element['loopExpression'] == 'UnaryOperation':
                self.wildcards.append(self.unary_operation_extraction(element['loopExpression']))
        else:
            pass
        # Analyzing body
        body = element['body']
        self.body_analysis(body)

    def expression_statement_extraction(self, element):
        """
        Analysis of expression field of ExpressionStatement
        Possible types: BinaryOperation, VariableDeclarationStatement, IfStatement,
        ForStatement, WhileStatement, FunctionCall, MemberAccess, Identifier
        :param element: element must be an ExpressionStatement
        """
        expression = element['expression']
        expression_type = expression['type']
        if expression_type == 'BinaryOperation':
            self.wildcards.append(self.binary_operation_extraction(expression))
        elif expression_type == 'UnaryOperation':
            self.wildcards.append(self.unary_operation_extraction(expression))
        elif expression_type == 'Identifier':
            pass
        elif expression_type == 'VariableDeclarationStatement':
            self.state_variable_declaration_extraction(expression)
        elif expression_type == 'IfStatement':
            self.if_statement_analysis(expression)
        elif expression_type == 'ForStatement':
            self.for_statement_analysis(expression)
        elif expression_type == 'WhileStatement':
            self.while_statement_analysis(expression)
        elif expression_type == 'FunctionCall':
            self.function_call_extraction(expression)
        elif expression_type == 'MemberAccess':
            self.member_access_name(expression)
        else:
            raise ParsingError('AST field missed')

    def true_body_analysis(self, element):
        """
        TrueBody field analysis. Field which manages the false condition of the If statement
        Possible types: Block, ExpressionStatement
        :param element: Element must be an expression
        """
        true_body_type = element['type']
        if true_body_type == 'Block':
            self.block_analysis(element)
        elif true_body_type == 'ExpressionStatement':
            self.expression_statement_extraction(element)
        elif true_body_type == 'NumberLiteral':
            self.number_literal_extraction(element)
        elif true_body_type == 'MemberAccess':
            self.member_access_name(element)
        else:
            raise ParsingError('AST field missed')

    def false_body_analysis(self, element):
        """
        FalseBody field analysis. Field which manages the false condition of the If statement
        Possible types: Block, ExpressionStatement
        :param element: Element must be an expression
        """
        false_body_type = element['type']
        if false_body_type == 'Block':
            self.block_analysis(element)
        elif false_body_type == 'ExpressionStatement':
            self.expression_statement_extraction(element)
        elif false_body_type == 'NumberLiteral':
            self.number_literal_extraction(element)
        elif false_body_type == 'MemberAccess':
            self.member_access_name(element)
        else:
            print(element)
            raise ParsingError('AST field missed')

    def reset(self):
        """
        Reset all the AST parameters except for AST objects
        """
        self.name = ''
        self.pragmas = []
        self.contracts = []
        self.structs = []
        self.state_variables = []
        self.inheritance_relationships = []
        self.function_parameters_relationships = {}
        self.struct_components = []
        self.events = []
        self.modifiers = []
        self.wildcards = []
        self.libraries = []
        self.functions = []

    def reset_ast_object(self):
        """
        Reset AST list
        """
        self.ast_objects = []

    def return_values(self):
        """
        Print all the AST parser parameters
        """
        print(self.name)
        print(self.pragmas)
        print(self.contracts)
        print(self.structs)
        print(self.state_variables)
        print(self.inheritance_relationships)
        print(self.function_parameters_relationships)
        print(self.struct_components)
        print(self.modifiers)
        print(self.wildcards)
        print(self.libraries)
        print(self.functions)

    @staticmethod
    def symbol_to_semantic(symbol):
        """
        Converts an alphanumeric symbol to its semantic meaning
        :param symbol: Alphanumeric symbol that must be converted to its semantic
        :return:
        """
        symbol_switcher = {
            '+': 'plus',
            '-': 'minus',
            '*': 'multiplied by',
            '/': 'divided by',
            '!': 'not',
            '=': 'is equal to',
            '>': 'is greater then',
            '<': 'is less then',
            '==': 'corresponds to',
            '>=': 'is greater or equal to',
            '<=': 'is less or equal to',
            '+=': 'increments of',
            '-=': 'decreases of',
            '*=': 'is multiplied by',
            '/=': 'is divided by',
            '!=': 'is different from'
        }
        return symbol_switcher.get(symbol, 'Invalid symbol')

    def build_ast(self):
        """
        :return: Return an AST object
        """
        return AST(self.name, self.pragmas, self.contracts, self.structs, self.inheritance_relationships, self.function_parameters_relationships, self.struct_components,
                   self.state_variables, self.modifiers, self.wildcards, self.events, self.libraries, self.functions)










