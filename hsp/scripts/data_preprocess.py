import pickle
name = "/home/local/ASUAD/ubiswas2/coop-eval/hsp/scripts/data/info.pkl"
with open(name, 'rb') as f:
    list = pickle.load(f)
print(len(list))
print(list[1])