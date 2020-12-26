clear;
clc;
DATA = randomData(1e5, 1);          %生成随机序列
baseDATA = conCoding(DATA.');      %卷积
baseDATA = baseDATA.';
deDATA = conDecoding(baseDATA);
[errorNum, errorBer] = biterr(DATA, deDATA,[], 'row-wise');