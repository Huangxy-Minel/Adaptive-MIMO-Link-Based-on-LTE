function y = conDecoding(x)
constlen = 7;           %束缚长度
tblen = 35;             %回溯深度
codegen = [171 133];    %关系矩阵，码率为1/2
trellis = poly2trellis(constlen, codegen);
code = [x,zeros(1,tblen*2)];
out = vitdec(code.', trellis, tblen, 'cont', 'hard').';
y = out(tblen+1:end);    %回溯深度造成的延迟，通过补零修正
end
