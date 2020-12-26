%函数：随机生成01序列
%输入：len--数据长度，txNum--发送天线数量
%输出：长度为len的01随机序列，均值0.5，返回1xlen行矩阵
function DATA = randomData(len, txNum)   
    rng(11);
    DATA = randi([0 1], txNum, len);
end