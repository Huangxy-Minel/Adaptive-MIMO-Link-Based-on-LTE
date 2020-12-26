function y = conCoding(x)
constlen = 7;           %��������
codegen = [171 133];    %��ϵ��������Ϊ1/2
trellis = poly2trellis(constlen, codegen);
[y] = convenc(x.', trellis);
y = y.';
end
