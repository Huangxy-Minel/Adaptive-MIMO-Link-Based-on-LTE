function output = addFrameHead(input, n, m)  % ѭ��n�Σ�ÿ�γ���2^m-1
	temp = primpoly(m);
    coef = dec2bin(temp)-'0';
	coef = coef(2:end);
	temp = mseq(coef);
	head = 2 .* repmat(temp,[1,n]) - 1;
	output = [head,input];
end