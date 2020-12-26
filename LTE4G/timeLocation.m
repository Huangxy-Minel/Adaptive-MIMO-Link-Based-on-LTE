function [noHeadSig,delf] = timeLocation(recsig,n,m,Rs)  %时间同步，序列循环n次，每次长度2^m-1   Rs是输入信号采样频率
    Mway = length(recsig(:,1));      %发送天线数
    len = length(recsig(1,:));       %数据长度
    delf = zeros(Mway,1);
    noHeadSig = recsig;      %返回去头部序列
    %创建反馈序列
	coef = dec2bin(primpoly(m))-'0';
	coef = coef(2:end);
	%生成双极性m序列
    tmep_mseq = 2.*mseq(coef)-1;
    mlen = length(tmep_mseq);                 %m序列长度

    for i = 1:Mway
%         [temp1, temp2] = xcorr(recsig(i,1:frameLen), tmep_mseq);
% %         方法1，滑动求和最大
%         window = [1,1+mlen,1+2*mlen,1+3*mlen];
%         add = zeros(1,length(temp1)-3*mlen);
%         for k = 1:length(temp1)-3*mlen
%             add(k) = sum(abs(temp1(window)));
%             window = window +1;
%         end
%         [~,pos]=max(add);
%         temp = temp2(pos)+1;
%         position = temp;
%         temp = temp + (n-1)*(2^m-1);
%         
%         %方法二直接找最大
%         [~,pos]=max(abs(temp1));
%         while abs(abs(temp1(pos+2^m-1))/abs(temp1(pos))-1)<0.3
%             pos = pos + 2^m-1;
%         end
%         temp = temp2(pos)+1;

        noHeadSig(:,1:n*mlen) = [];                 %头部序列变空
        %频率
        temSig = recsig(i,:);      %含头部序列
        delfre = 0;
        for j = 1:n-1
            Rk = sum(conj(temSig((j-1)*mlen+1:j*mlen)).* temSig(j*mlen+1:(j+1)*mlen));  %相关值
            delfre = delfre+atan(imag(Rk)/real(Rk))*Rs/(2*pi*mlen);
        end
        delf(i)=delfre/(n-1);           %取平均
    end
end

    