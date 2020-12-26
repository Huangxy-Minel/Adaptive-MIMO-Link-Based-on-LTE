function y = conDecoding(x)
constlen = 7;           %��������
tblen = 35;             %�������
codegen = [171 133];    %��ϵ��������Ϊ1/2
trellis = poly2trellis(constlen, codegen);
code = [x,zeros(1,tblen*2)];
out = vitdec(code.', trellis, tblen, 'cont', 'hard').';
y = out(tblen+1:end);    %���������ɵ��ӳ٣�ͨ����������
end
