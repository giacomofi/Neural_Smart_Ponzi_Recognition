from tabulate import tabulate
from texttable import Texttable

import latextable
if __name__ == '__main__':

    rows = [['Model', 'Target', 'Precision', 'Recall', 'F1-Score'],
            ['Decision Tree', '0', '0.99', '0.99', '0.99'],
            ['Decision Tree', '1', '0.93', '0.89', '0.91'],
            ['Logistic Regression', '0', '1.00', '1.00', '1.00'],
            ['Logistic Regression', '1', '0.99', '0.96', '0.97'],
            ['Multinomial Naive Bayes', '0', '1.00', '1.00', '1.00'],
            ['Multinomial Naive Bayes', '1', '1.00', '0.97', '0.99']]

    table = Texttable()
    table.set_cols_align(["c"] * 5)
    table.set_deco(Texttable.HEADER | Texttable.VLINES)
    table.add_rows(rows)

    print('Tabulate Table:')
    print(tabulate(rows, headers='firstrow'))

    print('\nTexttable Table:')
    print(table.draw())

    print('\nTabulate Latex:')
    print(tabulate(rows, headers='firstrow', tablefmt='latex'))

    print('\nTexttable Latex:')
    print(latextable.draw_latex(table, caption="Comparison of models performances."))

    rows1 = [['Word', 'Occurrences'],
             ['amount', '727'],
             ['balance', '456'],
             ['value', '346'],
             ['ether', '269'],
             ['collectedFees', '260'],
             ['length', '250'],
             ['persons', '196'],
             ['participants', '177'],
             ['investors', '151'],
             ['payout', '131']]

    table1 = Texttable()
    table1.set_cols_align(["c"] * 2)
    table1.set_deco(Texttable.HEADER | Texttable.VLINES)
    table1.add_rows(rows1)

    print('Tabulate Table:')
    print(tabulate(rows1, headers='firstrow'))

    print('\nTexttable Table:')
    print(table1.draw())

    print('\nTabulate Latex:')
    print(tabulate(rows1, headers='firstrow', tablefmt='latex'))

    print('\nTexttable Latex:')
    print(latextable.draw_latex(table1, caption="Occurrences of most used terms in Ponzi schemes contracts."))

    rows2 = [['Word', 'Occurrences'],
             ['totalSupply', '2194'],
             ['balanceOf', '1816'],
             ['approve', '1597'],
             ['_totalSupply', '1566'],
             ['allowance', '1512'],
             ['name', '1375'],
             ['balances', '1276'],
             ['decimals', '1262'],
             ['Invalid', '1186'],
             ['user', '1148']]

    table2 = Texttable()
    table2.set_cols_align(["c"] * 2)
    table2.set_deco(Texttable.HEADER | Texttable.VLINES)
    table2.add_rows(rows2)

    print('Tabulate Table:')
    print(tabulate(rows2, headers='firstrow'))

    print('\nTexttable Table:')
    print(table2.draw())

    print('\nTabulate Latex:')
    print(tabulate(rows2, headers='firstrow', tablefmt='latex'))

    print('\nTexttable Latex:')
    print(latextable.draw_latex(table2, caption="Occurrences of most used terms on other contracts."))