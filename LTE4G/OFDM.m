function OFDMsignals = OFDM(basebandSignals,CPlength)
    %���� basebandSignals��һ������Ҫ���͵�����  ��ģΪ   carrier_wave_Num * OFDM_NUM
    %ע�� basebandSignals �ѽ���Ƶ������
    %���� OFDM_NUMΪһ��֡�ں��е�ofdm������
    %����ֻ���𷵻ش���OFDM����
    carrier_wave_Num = length(basebandSignals(:,1));
    OFDM_NUM = length(basebandSignals(1,:));
    %Ԥ����ռ�
    OFDM = zeros(OFDM_NUM, carrier_wave_Num);
    cp = zeros(OFDM_NUM, carrier_wave_Num + CPlength);
    OFDMsignals = zeros(1, (carrier_wave_Num+CPlength)*OFDM_NUM);
    for m= 1:OFDM_NUM
        basebandSignal = basebandSignals(:, m);
        OFDM(m, :) = ifft(basebandSignal, carrier_wave_Num) .* (carrier_wave_Num^(1/2));                                         %ʹ��ifft����OFDM�ź�
        cp(m, 1:CPlength) = OFDM(m, carrier_wave_Num-CPlength+1 : carrier_wave_Num);                                         %���ѭ��ǰ׺
        cp(m, CPlength+1 : end) = OFDM(m, :);
        OFDMsignals(((m-1)*(carrier_wave_Num+CPlength)+1) : (m*(carrier_wave_Num+CPlength))) = cp(m,:);                       %���ɲ���ת�����OFDMsignal
    end
end