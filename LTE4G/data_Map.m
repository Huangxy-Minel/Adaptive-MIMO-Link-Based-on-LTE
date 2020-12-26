%输入
%baseDATA：一根发射天线上的数据，行向量
%modeformat：每个子载波上的调制阶数，carrier_wave_Num行向量
%输出
%basebandSignals：carrier_wave_Num * OFDM_NUM矩阵
function basebandSignals= data_Map(baseDATA,txNum,rxNum,carrier_wave_Num,f_gap,modformat,OFDM_NUM,pilot_pos,pilot_data)
%此函数负责生成OFDM函数需要的basebandSignals
%包含调制和插入导频的工作
%输入是一个包含一个子帧数据的行向量baseDATA，目标是将它结合导频后，写成carrier_wave_Num * OFDM_NUM矩阵的形式
%f_gap是导频的频域间隔，导频的时域分布，就设定为子帧的头尾2个OFDM符号
%OFDM_NUM 是 一个帧含有的OFDM符号数
%pilot_data 是分配给此天线的导频数据，为只有一个1的向量

basebandSignals = zeros(carrier_wave_Num , OFDM_NUM);

baseDataIdx = 1;                                        %数据指针
data_pos = setdiff([1:carrier_wave_Num],pilot_pos);     %数据位置

%调制的同时插入导频
for OFDMIdx = 1:OFDM_NUM
    %逐个符号逐个子载波调制，基于modformat的指导
%     if (OFDMIdx == 1) || (OFDMIdx == OFDM_NUM)                  %只有头尾的OFDM符号有导频
    if(1)
        for dataIdx = 1:length(data_pos)    
            %先计算该子载波上需要多少数据
            M = modformat(data_pos(dataIdx));
            tempData = baseDATA(baseDataIdx : baseDataIdx + M -1);
            baseDataIdx = baseDataIdx + M;      %更新数据位置
            basebandSignals(data_pos(dataIdx),OFDMIdx) = myPSK(tempData,2^M);
        end
        for j = 1:length(pilot_pos)
            %导频位置赋值
            if mod(j,txNum) == 0
                basebandSignals(pilot_pos(j),OFDMIdx) = pilot_data(end);
            else
                basebandSignals(pilot_pos(j),OFDMIdx) = pilot_data(mod(j,txNum));
            end
        end
    else    %非头尾OFDM符号
        for i = 1:carrier_wave_Num    
            %先计算该子载波上需要多少数据
            M = modformat(i);
            if M == 0
                continue
            end
            tempData = baseDATA(baseDataIdx : baseDataIdx + M -1);
            baseDataIdx = baseDataIdx + M;      %更新数据位置
            basebandSignals(i,OFDMIdx) = myPSK(tempData,2^M);
        end
    end
end

end