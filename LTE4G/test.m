clear;
clc;
DATA = randomData(1e5, 1);          %�����������
baseDATA = conCoding(DATA.');      %���
baseDATA = baseDATA.';
deDATA = conDecoding(baseDATA);
[errorNum, errorBer] = biterr(DATA, deDATA,[], 'row-wise');