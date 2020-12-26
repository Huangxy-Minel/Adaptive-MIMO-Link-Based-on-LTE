function [basebandSignals,H] = deOFDM(OFDMsignals, carrier_wave_Num, CPlength, pilot_pos,txNum,gap)
    %����Ϊȥ��ͷ���Ĵ���֡���ݣ��ֳɶ�����OFDM���Ž��
    %����һ��carrier_wave_Num * OFDM_NUM�����ݾ���
    %% ����ֻ����OFDM���
    OFDM_NUM = length(OFDMsignals)/(carrier_wave_Num + CPlength);    %OFDM���Ÿ���
    basebandSignals = zeros(carrier_wave_Num,OFDM_NUM);                   %���ؾ���
    dcp = zeros(OFDM_NUM, carrier_wave_Num);
    for m = 1:OFDM_NUM
        dcp(m,:) = OFDMsignals(((m-1)*carrier_wave_Num + m*CPlength+1):(m*(carrier_wave_Num+CPlength))); %ȥcp
        basebandSignals(:,m) = fft(dcp(m,:),carrier_wave_Num)./(carrier_wave_Num^(1/2));                   %FFT���OFDM�ź�
    end
    %% ��ȡ��Ƶ������ŵ�����
    rxNum = 1;                              
    H = zeros(txNum,rxNum,carrier_wave_Num,OFDM_NUM);               %ĳ���������߻�֪���ŵ������������ŵ�����Ҫ������ƴ��
%     pilot1 = basebandSignals(pilot_pos,1)/exp(1i*pi/4);
%     pilot2 = basebandSignals(pilot_pos,OFDM_NUM)/exp(1i*pi/4);
%     for i = 1:txNum
%         pilot_pos_t = [i:gap:carrier_wave_Num-(txNum-i)];                 %ĳһ�ض�channel�ĵ�Ƶλ��
%         pilot1 = basebandSignals(pilot_pos_t,1)/exp(1i*pi/4);
%         pilot2 = basebandSignals(pilot_pos_t,OFDM_NUM)/exp(1i*pi/4);
%         H(i,1,:,1) = interp1( pilot_pos_t.',pilot1,[1:carrier_wave_Num].','linear','extrap');       %�ڲ�
%         H(i,1,:,OFDM_NUM) = interp1( pilot_pos_t.',pilot2,[1:carrier_wave_Num].','linear','extrap');
%         for j = 1:carrier_wave_Num          %2���ڲ�
%             H(i,1,j,:) = interp1( [1,OFDM_NUM].',[H(i,1,j,1),H(i,1,j,OFDM_NUM)],[1:OFDM_NUM].','linear','extrap');
%         end
%     end
    for i = 1:txNum
        pilot_pos_t = [i:gap:carrier_wave_Num-(txNum-i)];                 %ĳһ�ض�channel�ĵ�Ƶλ��
        for j = 1:OFDM_NUM
            pilot = basebandSignals(pilot_pos_t,j)/exp(1i*pi/4);
            H(i,1,:,j) = interp1( pilot_pos_t.',pilot,[1:carrier_wave_Num].','linear','extrap');       %�ڲ�
            %H(i,1,:,j) = interp1( (pilot_pos_t).',abs(pilot),[1:carrier_wave_Num].','linear','extrap').*exp(1i*interp1( (pilot_pos_t).',angle(pilot),(1:carrier_wave_Num).','linear','extrap'));
        end
    end
end