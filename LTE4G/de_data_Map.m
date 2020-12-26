function res = de_data_Map(rxNum, basebandSignalsRecv, OFDM_Num, data_pos, modformat, carrier_wave_Num)
    res = [];
    debaseDATA = [];
    for i = 1:OFDM_Num
        OFDMFrame = basebandSignalsRecv((i-1)*carrier_wave_Num+1 : i*carrier_wave_Num); %获取一个OFDM帧
%             if (i == 1) || (i == OFDM_Num)  %当为头帧与尾帧，只解调数据位
        if(1)
            for dataIdx = 1:length(data_pos)
                M = modformat(data_pos(dataIdx));
                if M == 0
                    continue
                end
                debaseDATA = [debaseDATA, mypskDemod(OFDMFrame(data_pos(dataIdx)), 2^M)];
            end
        else                            %中间帧全部解调
            for dataIdx = 1:carrier_wave_Num
                M =  modformat(dataIdx);
                debaseDATA = [debaseDATA, mypskDemod(OFDMFrame(dataIdx), 2^M)];
            end
        end
    end
    res = [res;debaseDATA];
end