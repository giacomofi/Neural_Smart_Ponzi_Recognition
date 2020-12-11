#
# Author: giacomo
# 22-11-20
# Exploratory data analysis for contracts2.csv

import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import os

if __name__ == '__main__':
    this_dir, _ = os.path.split(__file__)
    data_dir = this_dir.replace('EDA', 'Docs')
    # Set theme for seaborn
    sns.set_theme(style="whitegrid")
    # Reading dataset
    contracts = pd.read_csv(data_dir + '/contracts2.csv')
    # Building count plot for target variable
    sns.countplot(x="Target", data=contracts)
    plt.legend()
    # Show plot
    plt.show()