#
# Author: giacomo
# 22-11-20
# Exploratory data analysis for contracts.csv ponzi.csv not_ponzi.csv

import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import os
from wordcloud import WordCloud, STOPWORDS

if __name__ == '__main__':
    this_dir, _ = os.path.split(__file__)
    data_dir = this_dir.replace('EDA', 'Docs')
    # Set theme for seaborn
    sns.set_theme(style="whitegrid")
    # Reading dataset
    contracts = pd.read_csv(data_dir + '/contracts.csv')
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

    ponzi = pd.read_csv(data_dir + '/ponzi.csv')
    not_ponzi = pd.read_csv(data_dir + '/not_ponzi.csv')
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

