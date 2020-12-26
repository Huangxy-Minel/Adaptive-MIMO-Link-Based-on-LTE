function OFDMsignals = OFDM(basebandSignals,CPlength)
    %输入 basebandSignals是一个天线要发送的数据  规模为   carrier_wave_Num * OFDM_NUM
    %注意 basebandSignals 已将导频插入了
    %其中 OFDM_NUM为一个帧内含有的ofdm符号数
    %这里只负责返回串行OFDM符号
    carrier_wave_Num = length(basebandSignals(:,1));
    OFDM_NUM = length(basebandSignals(1,:));
    %预分配空间
    OFDM = zeros(OFDM_NUM, carrier_wave_Num);
    cp = zeros(OFDM_NUM, carrier_wave_Num + CPlength);
    OFDMsignals = zeros(1, (carrier_wave_Num+CPlength)*OFDM_NUM);
    for m= 1:OFDM_NUM
        basebandSignal = basebandSignals(:, m);
        OFDM(m, :) = ifft(basebandSignal, carrier_wave_Num) .* (carrier_wave_Num^(1/2));                                         %使用ifft生成OFDM信号
        cp(m, 1:CPlength) = OFDM(m, carrier_wave_Num-CPlength+1 : carrier_wave_Num);                                         %添加循环前缀
        cp(m, CPlength+1 : end) = OFDM(m, :);
        OFDMsignals(((m-1)*(carrier_wave_Num+CPlength)+1) : (m*(carrier_wave_Num+CPlength))) = cp(m,:);                       %生成并串转换后的OFDMsignal
    end
end