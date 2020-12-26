function [modformat,dataBitNum,pilot_pos,data_pos] = QAMInfo(H,SNR,f_gap,OFDM_NUM)
%�����ŵ�����H,��С��: txNum * rxNum * carrier_wave_Num
%����SNR�����������ж���һ��֡�ĸ������ز��ĵ��Ʒ�ʽ
%����modformat Ϊ carrier_wave_Num �� �������������Ӧ���ز��ı�����
%�ݶ���ѡ�� ���Ʒ�ʽΪ QPSK �� 16QAM������modformat��Ԫ��ֻ��2��4
%modformat ��ʼ̬ȫ2
%dataBitNum ����һ֡ ������ ���ݱ���������ȡ���ݵ�ʱ����õ�
txNum  = H(:,1,1);
rxNum  = H(1,:,1);
carrier_wave_Num = H(1,1,:);
%% ����H���жϻ��modformat
modformat = 2*ones(1,carrier_wave_Num);
%����

%% ���㵼Ƶλ��pilot_pos
pilot_pos = []; 
for i = 1:txNum
    pilot_pos = [pilot_pos,i:gap:carrier_wave_Num-(txNum-i)];                 %��Ƶλ��
end
pilot_pos = sort(pilot_pos);
data_pos = setdiff([1:carrier_wave_Num],pilot_pos);     %����λ��

%% �������ݱ�����dataBitNum
dataBitNum = OFDM_NUM * sum(modformat) - 2 * sum(modformat(pilot_pos));

end