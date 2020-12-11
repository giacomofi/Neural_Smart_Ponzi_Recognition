#
# Author: giacomo
# 27 - 11 - 20
# Logistic Regression - Decision Tree - Random Forest - Multinomial Naive Bayes
#

from sklearn.naive_bayes import MultinomialNB
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.linear_model import LogisticRegression


def logistic_regression(penalty, C, class_weight, warm_start, random_state, solver):
    """
    Return a logistic regression model
    :param penalty:
    :param C:
    :param class_weight:
    :param warm_start:
    :param random_state:
    :param solver:
    :return:
    """
    logistic_regression_parameters = {
        'penalty': penalty,
        'C': C,
        'class_weight': class_weight,
        'warm_start': warm_start,
        'random_state': random_state,
        'solver': solver
    }
    # Defining model
    model = GridSearchCV(LogisticRegression(), logistic_regression_parameters, cv=5, verbose=1, n_jobs=-1)
    return model


def decision_tree(criterion, max_depth, min_samples_split, max_features, random_state):
    """
    Returns a decision tree classifier
    :param criterion: The function to measure the quality of a split. Supported criteria are “gini” for the Gini impurity and “entropy” for the information gain
    :param max_depth: The maximum depth of the tree. If None, then nodes are expanded until all leaves are pure or until all leaves contain less than min_samples_split samples
    :param min_samples_split: The minimum number of samples required to split an internal node
    :param max_features: The number of features to consider when looking for the best split
    :param random_state: Controls the randomness of the estimator. The features are always randomly permuted at each split, even if splitter is set to "best"
    :return:
    """
    decision_tree_parameters = {
        'criterion': criterion,
        'max_depth': max_depth,
        'min_samples_split': min_samples_split,
        'max_features': max_features,
        'random_state': random_state
    }
    # Defining model
    model = GridSearchCV(DecisionTreeClassifier(), decision_tree_parameters, cv=5, verbose=1, n_jobs=-1)
    return model


def random_forest(n_estimators, criterion, max_depth, bootstrap, min_samples_split, max_features, warm_start, random_state):
    """
    This function return a random forest model
    :param n_estimators: The number of trees in the forest. Default is 100
    :param criterion: The function to measure the quality of a split. Supported criteria are “gini” for the Gini impurity and “entropy” for the information gain
    :param max_depth: The maximum depth of the tree. If None, then nodes are expanded until all leaves are pure or until all leaves contain less than min_samples_split samples
    :param bootstrap: Whether bootstrap samples are used when building trees. If False, the whole dataset is used to build each tree
    :param min_samples_split: The minimum number of samples required to split an internal node
    :param max_features: The number of features to consider when looking for the best split
    :param warm_start: When set to True, reuse the solution of the previous call to fit and add more estimators to the ensemble, otherwise, just fit a whole new forest
    :param random_state: Controls both the randomness of the bootstrapping of the samples used when building trees (if bootstrap=True) and the sampling of the features to consider when looking for the best split at each node (if max_features < n_features)
    :return:
    """
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
    # Defining model
    model = GridSearchCV(RandomForestClassifier(), random_forest_parameters, cv=5, verbose=1, n_jobs=-1)
    return model


def multinomial_naive_bayes(fit_prior, alpha):
    """
    Return a multinomial naive Bayes model
    :param fit_prior: Whether to learn class prior probabilities or not. If false, a uniform prior will be used.
    :param alpha: Additive (Laplace/Lidstone) smoothing parameter (0 for no smoothing).
    :return:
    """
    multinomial_nonlinear_bayes_parameters = {
        'fit_prior': fit_prior,
        'alpha': alpha
    }
    # Defining model
    model = GridSearchCV(MultinomialNB(), multinomial_nonlinear_bayes_parameters, cv=5, verbose=1, n_jobs=-1)
    return model
