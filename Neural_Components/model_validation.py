import pandas as pd
import os
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.model_selection import cross_val_score
from nltk.stem import WordNetLemmatizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.model_selection import GridSearchCV

this_dir, _ = os.path.split(__file__)
data_dir = this_dir.replace('Neural_Components', 'Docs')
# Defining a lemmatizer
lemmatizer = WordNetLemmatizer()
# Reading the contracts dataset
contracts = pd.read_csv(data_dir + '/contracts2.csv')

# Features extraction
# Setting X as Name and Text features
# Setting y as Target column
features = ['Name', 'Text']
X = contracts[features]
y = contracts.Target

# Defining CountVectorizer both for Name and Text feature
cv_name = CountVectorizer(stop_words='english', strip_accents='ascii', ngram_range=(1, 6), min_df=.0001)
cv_text = CountVectorizer(stop_words='english', strip_accents='ascii', ngram_range=(1, 3), min_df=.0001)

# Getting matrices for Name and Text
X_name = cv_name.fit_transform(X.Name)
X_text = cv_text.fit_transform(X.Text)

# Concatenating back together Name and Text features
X_name_df = pd.DataFrame(X_name.todense(), columns=[x + '_text' for x in cv_name.get_feature_names()])
X_text_df = pd.DataFrame(X_text.todense(), columns=[y + '_title' for y in cv_text.get_feature_names()])

# Model parameters
mn_params = {
    'fit_prior': [True],
    'alpha': [0, 0.5, 1]}

# Model definition
model = GridSearchCV(MultinomialNB(),
                     mn_params,
                     cv=5,
                     verbose=1,
                     n_jobs=-1)
# Validating model
scores = cross_val_score(model, X_text_df.values, y, cv=5)
print("Scams detected with accuracy: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))