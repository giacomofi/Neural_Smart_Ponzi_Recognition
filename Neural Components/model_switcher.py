#
# Author: giacomo
# 27 - 11 - 20
# Models
#

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix
from sklearn.neighbors import KNeighborsClassifier

import nltk
from nltk.stem import WordNetLemmatizer


def logistic_regression(penalty, C, class_weight, warm_start, random_state, solver):

    logistic_regression_parameters = {
        'penalty': penalty,
        'C': C,
        'class_weight': class_weight,
        'warm_start': warm_start,
        'random_state': random_state,
        'solver': solver
    }
    model = GridSearchCV(LogisticRegression(), logistic_regression_parameters, cv=5, verbose=1, n_jobs=-1)
    return model


def decision_tree(criterion, max_depth, min_samples_split, max_features, random_state):

    decision_tree_parameters = {
        'criterion': criterion,
        'max_depth': max_depth,
        'min_samples_split': min_samples_split,
        'max_features': max_features,
        'random_state': random_state
    }
    model = GridSearchCV(DecisionTreeClassifier(), decision_tree_parameters, cv=5, verbose=1, n_jobs=-1)
    return model


def random_forest(n_estimators, criterion, max_depth, bootstrap, min_samples_split, max_features, warm_start, random_state):

    random_forest_parameters = {
        'n_estimators': n_estimators,
        'criterion': criterion,
        'max_depth': max_depth,
        'bootstrap': bootstrap,
        'min_samples_split': min_samples_split,
        'max_features': max_features,
        'warm_start': warm_start,
        'random_state': random_state
    }
    model = GridSearchCV(RandomForestClassifier(), random_forest_parameters, cv=5, verbose=1, n_jobs=-1)
    return model


def multinomial_nonlinear_bayes(fit_prior, alpha):
    multinomial_nonlinear_bayes_parameters = {
        'fit_prior': fit_prior,
        'alpha': alpha
    }

    model = GridSearchCV(MultinomialNB(), multinomial_nonlinear_bayes_parameters, cv=5, verbose=1, n_jobs=-1)
    return model
