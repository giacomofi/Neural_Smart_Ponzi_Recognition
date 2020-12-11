from pyspark import SparkContext, SparkConf
import os

if __name__ == '__main__':
    # Setting Spark context
    conf = SparkConf().setAppName("Word Counter")
    sc = SparkContext(conf=conf)
    sc.setLogLevel("ERROR")
    this_dir, _ = os.path.split(__file__)
    data_dir = this_dir.replace('Word Counter Tools', 'Docs')
    words = sc.textFile(data_dir + '/Ponzi Semantic Documents/*.txt').flatMap(lambda line: line.split(' '))
    word_counts = words.map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b).top(50, key=lambda x: x[1])
    try:
        with open(data_dir + '/Most used terms in Ponzies.txt', 'w') as f:
            for word in word_counts:
                f.write(word[0] + ' ' + str(word[1]))
                f.write('\n')
    except FileNotFoundError:
        print('Path not Found')
    finally:
        f.close()




