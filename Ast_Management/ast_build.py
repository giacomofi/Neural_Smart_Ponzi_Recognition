#
# Author: giacomo
# 22-11-20
#
# Class AST. If you need to instantiate an ast object use this

class AST:

    name = ''
    pragmas = []
    contracts = []
    structs = []
    inheritance_relationships = {}
    function_parameters_relationships = {}
    struct_components = {}
    base_contracts_container = []
    state_variables = []
    modifiers = []
    wildcards = []
    events = []
    libraries = []
    functions = []

    def __init__(self, name, pragmas, contracts, structs, inheritance_relationships, function_parameters, struct_components, state_variables, modifiers, wildcards, events, libraries, functions):
        """
        Ast object
        :param name: Ast of the file named 'name'
        :param pragmas: Pragmas used
        :param contracts: Defined contracts
        :param structs: Defined structs
        :param inheritance_relationships: Inheritance relationships between structs
        :param function_parameters:
        :param struct_components:
        :param state_variables:
        :param modifiers:
        :param wildcards:
        :param events:
        :param libraries:
        :param functions:
        """
        self.name = name
        self.pragmas = pragmas
        self.contracts = contracts
        self.structs = structs
        self.inheritance_relationships = inheritance_relationships
        self.function_parameters = function_parameters
        self.struct_components = struct_components
        self.state_variables = state_variables
        self.modifiers = modifiers
        self.wildcards = wildcards
        self.events = events
        self.libraries = libraries
        self.functions = functions

    def return_pragmas(self):
        """
        :return: pragmas of solidity source code
        """
        return self.pragmas

    def return_contracts(self):
        """
        :return: contracts of solidity source code
        """
        return self.contracts

    def return_structs(self):
        """
        :return: structs of the contract
        """
        return self.structs

    def return_inheritance_relationships(self):
        """
        :return: inheritance relationships between contracts
        """
        return self.inheritance_relationships

    def return_function_parameters(self):
        """
        :return: parameters of contracts' functions
        """
        return self.function_parameters

    def return_struct_components(self):
        """
        :return: structs' variables
        """
        return self.struct_components

    def return_state_variables(self):
        """
        :return: global variables of contract
        """
        return self.state_variables

    def return_modifiers(self):
        """
        :return: modifiers of the contract
        """
        return self.modifiers

    def return_wildcards(self):
        """
        :return: wildcards of the contract
        """
        return self.wildcards

    def return_events(self):
        """
        :return: events defined inside
        """
        return self.events

    def return_libraries(self):
        """
        :return: libraries inside contracts
        """
        return self.libraries

    def return_functions(self):
        """
        :return: functions of contract
        """
        return self.functions

    def return_name(self):
        """
        Return the AST name
        :return:
        """
        return self.name