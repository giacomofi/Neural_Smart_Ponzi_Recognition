#
# Author: giacomo
# 01 - 12 - 20
# ParsingError exception. Used to understand if the parser misses some fields of the AST
#

class ParsingError(RuntimeError):
    def __init__(self, arg):
        self.args = arg
