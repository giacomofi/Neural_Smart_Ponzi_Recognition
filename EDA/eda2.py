#
# Author: giacomo
# 22-11-20
# Exploratory data analysis for contracts2.csv

import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import os
import yaml
from yaml import FullLoader

if __name__ == '__main__':
    this_dir, _ = os.path.split(__file__)
    base_name = os.path.basename(this_dir)
    config = this_dir.replace(base_name, 'config.yaml')
    with open(config, 'r') as yaml_file:
        cfg = yaml.load(yaml_file, Loader=FullLoader)
    contract_name = os.path.expanduser(cfg['config']['contracts2_csv'])
    # Set theme for seaborn
    sns.set_theme(style="whitegrid")
    # Reading dataset
    contracts = pd.read_csv(contract_name)
    # Building count plot for target variable
    sns.countplot(x="Target", data=contracts)
    plt.legend()
    # Show plot
    plt.show()