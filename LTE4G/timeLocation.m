function [noHeadSig,delf] = timeLocation(recsig,n,m,Rs)  %ʱ��ͬ��������ѭ��n�Σ�ÿ�γ���2^m-1   Rs�������źŲ���Ƶ��
    Mway = length(recsig(:,1));      %����������
    len = length(recsig(1,:));       %���ݳ���
    delf = zeros(Mway,1);
    noHeadSig = recsig;      %����ȥͷ������
    %������������
	coef = dec2bin(primpoly(m))-'0';
	coef = coef(2:end);
	%����˫����m����
    tmep_mseq = 2.*mseq(coef)-1;
    mlen = length(tmep_mseq);                 %m���г���

    for i = 1:Mway
%         [temp1, temp2] = xcorr(recsig(i,1:frameLen), tmep_mseq);
% %         ����1������������
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
%         %������ֱ�������
%         [~,pos]=max(abs(temp1));
%         while abs(abs(temp1(pos+2^m-1))/abs(temp1(pos))-1)<0.3
%             pos = pos + 2^m-1;
%         end
%         temp = temp2(pos)+1;

        noHeadSig(:,1:n*mlen) = [];                 %ͷ�����б��
        %Ƶ��
        temSig = recsig(i,:);      %��ͷ������
        delfre = 0;
        for j = 1:n-1
            Rk = sum(conj(temSig((j-1)*mlen+1:j*mlen)).* temSig(j*mlen+1:(j+1)*mlen));  %���ֵ
            delfre = delfre+atan(imag(Rk)/real(Rk))*Rs/(2*pi*mlen);
        end
        delf(i)=delfre/(n-1);           %ȡƽ��
    end
end

    