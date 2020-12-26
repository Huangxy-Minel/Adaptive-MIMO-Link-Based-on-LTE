function output = addFrameHead(input, n, m)  % 循环n次，每次长度2^m-1
	temp = primpoly(m);
    coef = dec2bin(temp)-'0';
	coef = coef(2:end);
	temp = mseq(coef);
	head = 2 .* repmat(temp,[1,n]) - 1;
	output = [head,input];
end