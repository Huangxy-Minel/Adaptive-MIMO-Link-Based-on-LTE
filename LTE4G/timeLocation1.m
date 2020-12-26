function [noHeadSig,delf,position] = timeLocation1(recsig,n,m,Rs,protectLen,rcos,sps)  %时间同步，序列循环n次，每次长度2^m-1   Rs是输入信号采样频率
    Mway = length(recsig(:,1));      %发送天线数
    %len = length(recsig(1,:));       %数据长度
    delf = zeros(Mway,1);
    noHeadSig = recsig;      %返回去头部序列
    %创建反馈序列
	coef = dec2bin(primpoly(m))-'0';
	coef = coef(2:end);
	%生成双极性m序列
    tmep_mseq = 2.*mseq(coef)-1;
    mlen = length(tmep_mseq);                 %m序列长度
    %上采样后的序列来同步
    tmep_mseq  = upfirdn(tmep_mseq.', rcos, sps); 
    %tmep_mseq = tmep_mseq(1+sps*span/2:(end-sps*span/2));
    
    mlen = sps*mlen;
    
    
    for i = 1:Mway
        [temp1, temp2] = xcorr(recsig(i,:), tmep_mseq);
        %方法1，滑动求和最大
        window = 1:mlen:1+(n-1)*mlen; 
        add = zeros(1,length(temp1)-(n-1)*mlen);
        for k = 1:length(temp1)-3*mlen
            add(k) = sum(abs(temp1(window)));
            window = window +1;
        end
        [~,pos]=max(add);
        temp = temp2(pos)+1;
        position = temp;
        %temp = temp + (n-1)*(2^m-1)*sps;
        
%         %方法二直接找最大
%         [~,pos]=max(abs(temp1));
%         while abs(abs(temp1(pos+2^m-1))/abs(temp1(pos))-1)<0.3
%             pos = pos + 2^m-1;
%         end
%         temp = temp2(pos)+1;

        noHeadSig = noHeadSig(temp:end-protectLen-1+temp);                 %去尾巴
        %频率
%         temSig = noHeadSig;      %含头部序列
%         delfre = 0;
%         mlen = length(tmep_mseq);
%         for j = 1:n-1
%             Rk = sum(conj(temSig((j-1)*mlen+1:j*mlen)).* temSig(j*mlen+1:(j+1)*mlen));  %相关值
%             delfre = delfre+atan(imag(Rk)/real(Rk))*Rs/(2*pi*mlen);
%         end
%         delf(i)=delfre/(n-1);           %取平均
%         m = 1:length(noHeadSig(i,:));                                                          %syn_n*(2^syn_m-1)+1 + round*(OFDM_Num * (carrier_wave_Num+CPlength)+protectLen) : syn_n*(2^syn_m-1)+OFDM_Num * (carrier_wave_Num+CPlength) + round*(OFDM_Num * (carrier_wave_Num+CPlength)+protectLen);
%         f = exp(1i*2*pi*delf(i) * m / Rs);
%         noHeadSig = noHeadSig ./ f;                                                 %频率同步
    end
end

    