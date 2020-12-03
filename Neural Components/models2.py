import pandas as pd

from sklearn.feature_extraction.text import CountVectorizer
from sklearn.model_selection import train_test_split
import model_switcher
from sklearn.metrics import confusion_matrix
from nltk.stem import WordNetLemmatizer

if __name__ == '__main__':

    # Defining a lemmatizer
    lemmatizer = WordNetLemmatizer()
    # Reading the contracts dataset
    contracts = pd.read_csv('/home/giacomo/PycharmProjects/ast_generator/Docs/contracts2.csv')

    # Features extraction
    # Setting X as Name and Text features
    # Setting y as Target column
    features = ['Name', 'Text']
    X = contracts[features]
    y = contracts.Target
    # Instantiating my train test split
    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42, test_size=0.50, stratify=y)

    cv_name = CountVectorizer(stop_words='english', strip_accents= 'ascii', ngram_range=(1, 6), min_df=.001)
    cv_text = CountVectorizer(stop_words='english', strip_accents= 'ascii', ngram_range=(1, 3), min_df=.001)

    X_train_name = cv_name.fit_transform(X_train.Name)
    X_train_text = cv_text.fit_transform(X_train.Text)

    X_test_name = cv_name.transform(X_test.Name)
    X_test_text = cv_text.transform(X_test.Text)

    X_train_name_df = pd.DataFrame(X_train_name.todense(), columns=[x+'_text' for x in cv_name.get_feature_names()])
    X_train_text_df = pd.DataFrame(X_train_text.todense(), columns=[y+'_title' for y in cv_text.get_feature_names()])
    X_test_name_df = pd.DataFrame(X_test_name.todense(), columns=[x+'_text' for x in cv_name.get_feature_names()])
    X_test_text_df = pd.DataFrame(X_test_text.todense(), columns=[y+'_title' for y in cv_text.get_feature_names()])

    model = model_switcher.logistic_regression(['l1'],[1, 1.5, 2, 2.5],['balanced'],[True, False],[42],['liblinear'])

    model.fit(X_train_text_df.values, y_train)

    print(f'Train score = {model.score(X_train_text_df.values, y_train)}')
    print(f'Test score = {model.score(X_test_text_df.values, y_test)}')

    predictions = model.predict(X_test_text_df.values)
    print('--------')
    print(confusion_matrix(y_test, predictions))
    print(f'Best params = {model.best_params_}')
