function [noHeadSig,delf,position] = timeLocation1(recsig,n,m,Rs,protectLen,rcos,sps)  %ʱ��ͬ��������ѭ��n�Σ�ÿ�γ���2^m-1   Rs�������źŲ���Ƶ��
    Mway = length(recsig(:,1));      %����������
    %len = length(recsig(1,:));       %���ݳ���
    delf = zeros(Mway,1);
    noHeadSig = recsig;      %����ȥͷ������
    %������������
	coef = dec2bin(primpoly(m))-'0';
	coef = coef(2:end);
	%����˫����m����
    tmep_mseq = 2.*mseq(coef)-1;
    mlen = length(tmep_mseq);                 %m���г���
    %�ϲ������������ͬ��
    tmep_mseq  = upfirdn(tmep_mseq.', rcos, sps); 
    %tmep_mseq = tmep_mseq(1+sps*span/2:(end-sps*span/2));
    
    mlen = sps*mlen;
    
    
    for i = 1:Mway
        [temp1, temp2] = xcorr(recsig(i,:), tmep_mseq);
        %����1������������
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
        
%         %������ֱ�������
%         [~,pos]=max(abs(temp1));
%         while abs(abs(temp1(pos+2^m-1))/abs(temp1(pos))-1)<0.3
%             pos = pos + 2^m-1;
%         end
%         temp = temp2(pos)+1;

        noHeadSig = noHeadSig(temp:end-protectLen-1+temp);                 %ȥβ��
        %Ƶ��
%         temSig = noHeadSig;      %��ͷ������
%         delfre = 0;
%         mlen = length(tmep_mseq);
%         for j = 1:n-1
%             Rk = sum(conj(temSig((j-1)*mlen+1:j*mlen)).* temSig(j*mlen+1:(j+1)*mlen));  %���ֵ
%             delfre = delfre+atan(imag(Rk)/real(Rk))*Rs/(2*pi*mlen);
%         end
%         delf(i)=delfre/(n-1);           %ȡƽ��
%         m = 1:length(noHeadSig(i,:));                                                          %syn_n*(2^syn_m-1)+1 + round*(OFDM_Num * (carrier_wave_Num+CPlength)+protectLen) : syn_n*(2^syn_m-1)+OFDM_Num * (carrier_wave_Num+CPlength) + round*(OFDM_Num * (carrier_wave_Num+CPlength)+protectLen);
%         f = exp(1i*2*pi*delf(i) * m / Rs);
%         noHeadSig = noHeadSig ./ f;                                                 %Ƶ��ͬ��
    end
end

    