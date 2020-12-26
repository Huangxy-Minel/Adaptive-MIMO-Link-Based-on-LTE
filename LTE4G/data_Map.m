%����
%baseDATA��һ�����������ϵ����ݣ�������
%modeformat��ÿ�����ز��ϵĵ��ƽ�����carrier_wave_Num������
%���
%basebandSignals��carrier_wave_Num * OFDM_NUM����
function basebandSignals= data_Map(baseDATA,txNum,rxNum,carrier_wave_Num,f_gap,modformat,OFDM_NUM,pilot_pos,pilot_data)
%�˺�����������OFDM������Ҫ��basebandSignals
%�������ƺͲ��뵼Ƶ�Ĺ���
%������һ������һ����֡���ݵ�������baseDATA��Ŀ���ǽ�����ϵ�Ƶ��д��carrier_wave_Num * OFDM_NUM�������ʽ
%f_gap�ǵ�Ƶ��Ƶ��������Ƶ��ʱ��ֲ������趨Ϊ��֡��ͷβ2��OFDM����
%OFDM_NUM �� һ��֡���е�OFDM������
%pilot_data �Ƿ���������ߵĵ�Ƶ���ݣ�Ϊֻ��һ��1������

basebandSignals = zeros(carrier_wave_Num , OFDM_NUM);

baseDataIdx = 1;                                        %����ָ��
data_pos = setdiff([1:carrier_wave_Num],pilot_pos);     %����λ��

%���Ƶ�ͬʱ���뵼Ƶ
for OFDMIdx = 1:OFDM_NUM
    %�������������ز����ƣ�����modformat��ָ��
%     if (OFDMIdx == 1) || (OFDMIdx == OFDM_NUM)                  %ֻ��ͷβ��OFDM�����е�Ƶ
    if(1)
        for dataIdx = 1:length(data_pos)    
            %�ȼ�������ز�����Ҫ��������
            M = modformat(data_pos(dataIdx));
            tempData = baseDATA(baseDataIdx : baseDataIdx + M -1);
            baseDataIdx = baseDataIdx + M;      %��������λ��
            basebandSignals(data_pos(dataIdx),OFDMIdx) = myPSK(tempData,2^M);
        end
        for j = 1:length(pilot_pos)
            %��Ƶλ�ø�ֵ
            if mod(j,txNum) == 0
                basebandSignals(pilot_pos(j),OFDMIdx) = pilot_data(end);
            else
                basebandSignals(pilot_pos(j),OFDMIdx) = pilot_data(mod(j,txNum));
            end
        end
    else    %��ͷβOFDM����
        for i = 1:carrier_wave_Num    
            %�ȼ�������ز�����Ҫ��������
            M = modformat(i);
            if M == 0
                continue
            end
            tempData = baseDATA(baseDataIdx : baseDataIdx + M -1);
            baseDataIdx = baseDataIdx + M;      %��������λ��
            basebandSignals(i,OFDMIdx) = myPSK(tempData,2^M);
        end
    end
end

end