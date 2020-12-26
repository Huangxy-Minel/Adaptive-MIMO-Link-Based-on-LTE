function y = conCoding(x)
constlen = 7;           %束缚长度
codegen = [171 133];    %关系矩阵，码率为1/2
trellis = poly2trellis(constlen, codegen);
[y] = convenc(x.', trellis);
y = y.';
end
