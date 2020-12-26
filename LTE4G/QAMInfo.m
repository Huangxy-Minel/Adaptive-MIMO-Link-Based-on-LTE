function [modformat,dataBitNum,pilot_pos,data_pos] = QAMInfo(H,SNR,f_gap,OFDM_NUM)
%输入信道矩阵H,大小是: txNum * rxNum * carrier_wave_Num
%输入SNR，根据输入判断下一子帧的各个子载波的调制方式
%返回modformat 为 carrier_wave_Num 的 行向量，代表对应子载波的比特数
%暂定可选的 调制方式为 QPSK 和 16QAM，即：modformat中元素只有2和4
%modformat 初始态全2
%dataBitNum 是下一帧 包含的 数据比特数，在取数据的时候会用到
txNum  = H(:,1,1);
rxNum  = H(1,:,1);
carrier_wave_Num = H(1,1,:);
%% 根据H，判断获得modformat
modformat = 2*ones(1,carrier_wave_Num);
%……

%% 计算导频位置pilot_pos
pilot_pos = []; 
for i = 1:txNum
    pilot_pos = [pilot_pos,i:gap:carrier_wave_Num-(txNum-i)];                 %导频位置
end
pilot_pos = sort(pilot_pos);
data_pos = setdiff([1:carrier_wave_Num],pilot_pos);     %数据位置

%% 计算数据比特数dataBitNum
dataBitNum = OFDM_NUM * sum(modformat) - 2 * sum(modformat(pilot_pos));

end