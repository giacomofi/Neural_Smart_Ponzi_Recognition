from pyspark import SparkContext, SparkConf
from os import listdir
from os.path import isfile, join, abspath
import sys

if __name__ == '__main__':
    # Setting Spark context
    conf = SparkConf().setAppName("Word Counter")
    sc = SparkContext(conf=conf)
    sc.setLogLevel("ERROR")

    words = sc.textFile('/home/giacomo/PycharmProjects/ast_generator/Ponzi Semantic Documents/*.txt').flatMap(lambda line: line.split(' '))
    word_counts = words.map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b).top(50, key= lambda x: x[1])
    word_counts.saveAsTextFile('/home/giacomo/PycharmProjects/ast_generator/word count not ponzi')




