%�������������01����
%���룺len--���ݳ��ȣ�txNum--������������
%���������Ϊlen��01������У���ֵ0.5������1xlen�о���
function DATA = randomData(len, txNum)   
    rng(11);
    DATA = randi([0 1], txNum, len);
end