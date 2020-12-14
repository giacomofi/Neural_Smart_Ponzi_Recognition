#
# Author: giacomo
# 22-11-20
# Exploratory data analysis for contracts.csv ponzi.csv not_ponzi.csv

import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import os
from wordcloud import WordCloud, STOPWORDS
import yaml
from yaml import FullLoader

if __name__ == '__main__':
    this_dir, _ = os.path.split(__file__)
    base_name = os.path.basename(this_dir)
    config = this_dir.replace(base_name, 'config.yaml')
    with open(config, 'r') as yaml_file:
        cfg = yaml.load(yaml_file, Loader=FullLoader)
    contract_name = os.path.expanduser(cfg['config']['contracts_csv'])
    ponzi_name = os.path.expanduser(cfg['config']['ponzi_csv'])
    not_ponzi_name = os.path.expanduser(cfg['config']['not_ponzi_csv'])
    # Set theme for seaborn
    sns.set_theme(style="whitegrid")
    # Reading dataset
    contracts = pd.read_csv(contract_name)
    # Building count plot for target variable
    sns.countplot(x="Target", data=contracts)
    # Show plot
    plt.show()

    text = ' '
    stopwords = set(STOPWORDS)

    # iterate through the csv file
    for x in contracts.Wildcard:

        # typecaste each val to string
        x = str(x)

        # split the value
        values = x.split()

        # Converts each token into lowercase
        for i in range(len(values)):
            values[i] = values[i].lower()

        for words in values:
            text = text + words + ' '
    # Define WordCloud

    wc = WordCloud(max_words=100,
                   width=744,
                   height=544,
                   background_color='white',
                   stopwords=stopwords,
                   contour_width=3,
                   contour_color='steelblue',
                   min_font_size=10).generate(text)

    # plot the WordCloud image
    plt.figure(figsize=(14, 14))
    plt.imshow(wc)
    plt.axis("off")
    plt.savefig(this_dir + '/Most Used Terms in Wildcards')

    ponzi = pd.read_csv(ponzi_name)
    not_ponzi = pd.read_csv(not_ponzi_name)
    text = ' '

    # iterate through the csv file
    for x in ponzi.Text:

        # typecaste each val to string
        x = str(x)

        # split the value
        values = x.split()

        # Converts each token into lowercase
        for i in range(len(values)):
            values[i] = values[i].lower()

        for words in values:
            text = text + words + ' '

    wc = WordCloud(max_words=100,
                   width=744,
                   height=544,
                   background_color='white',
                   stopwords=stopwords,
                   contour_width=3,
                   contour_color='steelblue',
                   min_font_size=10).generate(text)

    # plot the WordCloud image
    plt.figure(figsize=(14, 14))
    plt.imshow(wc)
    plt.axis("off")
    plt.savefig(this_dir + '/Most used terms in Ponzies')

    text = ' '

    # iterate through the csv file
    for x in not_ponzi.Text:

        # typecaste each val to string
        x = str(x)

        # split the value
        values = x.split()

        # Converts each token into lowercase
        for i in range(len(values)):
            values[i] = values[i].lower()

        for words in values:
            text = text + words + ' '

    wc = WordCloud(max_words=100,
                   width=744,
                   height=544,
                   background_color='white',
                   stopwords=stopwords,
                   contour_width=3,
                   contour_color='steelblue',
                   min_font_size=10).generate(text)

    # plot the WordCloud image
    plt.figure(figsize=(14, 14))
    plt.imshow(wc)
    plt.axis("off")
    plt.savefig(this_dir + '/Most used terms in Not Ponzies')

