import pandas as pd

from sklearn.feature_extraction.text import CountVectorizer
from sklearn.model_selection import train_test_split
import model_switcher
from sklearn.metrics import confusion_matrix
from nltk.stem import WordNetLemmatizer

if __name__ == '__main__':

    lemmatizer = WordNetLemmatizer()
    contracts = pd.read_csv('/home/giacomo/PycharmProjects/ast_generator/Docs/contracts2.csv')

    features = ['Name', 'Text']
    X = contracts[features]
    y = contracts.Target
    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42, test_size=0.50, stratify=y)

    cv_text = CountVectorizer(stop_words='english', strip_accents= 'ascii', ngram_range=(1, 6), min_df=.001)
    cv_title = CountVectorizer(stop_words='english', strip_accents= 'ascii', ngram_range=(1, 3), min_df=.001)

    X_train_text = cv_text.fit_transform(X_train.Name)
    X_train_title = cv_title.fit_transform(X_train.Text)

    X_test_text = cv_text.transform(X_test.Name)
    X_test_title = cv_title.transform(X_test.Text)

    X_train_text_df = pd.DataFrame(X_train_text.todense(), columns=[x+'_text' for x in cv_text.get_feature_names()])
    X_train_title_df = pd.DataFrame(X_train_title.todense(), columns=[y+'_title' for y in cv_title.get_feature_names()])
    X_test_text_df = pd.DataFrame(X_test_text.todense(), columns=[x+'_text' for x in cv_text.get_feature_names()])
    X_test_title_df = pd.DataFrame(X_test_title.todense(), columns=[y+'_title' for y in cv_title.get_feature_names()])


    vecced_train_reddit_posts = pd.concat([X_train_text_df, X_train_title_df], axis=1)
    vecced_test_reddit_posts = pd.concat([X_test_text_df, X_test_title_df], axis=1)

    model = model_switcher.logistic_regression(['l1'],[1, 1.5, 2, 2.5],['balanced'],[True, False],[42],['liblinear'])

    model.fit(vecced_train_reddit_posts.values, y_train)

    print(f'Train score = {model.score(vecced_train_reddit_posts.values, y_train)}')
    print(f'Test score = {model.score(vecced_test_reddit_posts.values, y_test)}')

    predictions = model.predict(vecced_test_reddit_posts.values)
    print('--------')
    print(confusion_matrix(y_test, predictions))
    print(f'Best params = {model.best_params_}')
