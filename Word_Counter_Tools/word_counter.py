from pyspark import SparkContext, SparkConf
import os
import yaml
from yaml import FullLoader

if __name__ == '__main__':
    # Setting Spark context
    conf = SparkConf().setAppName("Word Counter")
    sc = SparkContext(conf=conf)
    sc.setLogLevel("ERROR")
    this_dir, _ = os.path.split(__file__)
    base_name = os.path.basename(this_dir)
    config = this_dir.replace(base_name, 'config.yaml')
    with open(config, 'r') as yaml_file:
        cfg = yaml.load(yaml_file, Loader=FullLoader)
    ponzi_semantic_documents = os.path.expanduser(cfg['config']['ponzi_semantic_documents'])
    data_dir = os.path.expanduser(cfg['config']['docs'])
    words = sc.textFile(ponzi_semantic_documents + '/*.txt').flatMap(lambda line: line.split(' '))
    word_counts = words.map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b).top(50, key=lambda x: x[1])
    try:
        with open(data_dir + '/Most_used_terms_in_Ponzies.txt', 'w') as f:
            for word in word_counts:
                f.write(word[0] + ' ' + str(word[1]))
                f.write('\n')
    except FileNotFoundError:
        print('Path not Found')
    finally:
        f.close()




