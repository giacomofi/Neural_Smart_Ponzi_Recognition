#
# Author: giacomo
# 22-11-20
# Exploratory data analysis for contracts.csv ponzi.csv not_ponzi.csv

import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
from wordcloud import WordCloud, STOPWORDS

if __name__ == '__main__':

    # Set theme for seaborn
    sns.set_theme(style="whitegrid")
    # Reading dataset
    contracts = pd.read_csv('/home/giacomo/PycharmProjects/ast_generator/Docs/contracts2.csv')
    # Building count plot for target variable
    sns.countplot(x="Target", data=contracts)
    plt.legend()
    # Show plot
    plt.show()
