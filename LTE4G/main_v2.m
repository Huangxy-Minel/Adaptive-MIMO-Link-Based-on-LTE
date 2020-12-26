clc;
clear;
rng('default');
%%功能选择
CONCODE = 1;            %是否需要卷积码
TIMEFLAG = 1;           %是否时间同步
ADIPTIVED = 1;          %是否自适应
RAYLEIGH = 1;           %是否过瑞利信道
AWGN = 1;               %是否过AWGN信道
ZFMMSEFLAG = 1;         %0使用ZF，1使用MMSE
SNR = 8;               %信噪比
%% 初始化参量
Fc = 2*1e9;                             %载频2GHz
Bt = 2*1e6;                             %带宽2MHz
carrier_wave_Num = 512;                 %子载波个数
OFDM_Num = 4;                          %每一帧所含的OFDM帧数量
if TIMEFLAG
    protectLen = 100;                       %保护间隔长度
else
    protectLen = 0;
end
conProtect = 4;                         %卷积码保护间隔
syn_n = 4;                              %同步头重复次数
syn_m = 7;                              %同步头长度2^m - 1
Fs = Bt;                                %carrier_wave_Num * Bt / (carrier_wave_Num +1); %系统采样率
DATAlength = 1e6;                       %总长度
col = 5;                                %交织深度
row = 5;
%% 瑞利信道参量
CPlength = 12;                          %循环前缀长度
maxDolpler = 100;                        %多普勒最大频移
% Delay = [0 4] ./ Fs;
% Gain = [0 -10];
Delay = [0 30 150 310 370 710 1090 1730 2510] .* 10^(-9);   %多径时延
Gain = [0 -1.5 -1.4 -3.6 -0.6 -9.1 -7.0 -12.0 -16.9];       %多径增益
%% MIMO参量
txNum = 1;                              %发射天线数目
rxNum = 1;                              %接受天线数目
gap = 10;                                %导频间隔
%% 升余弦滤波器
rolloff = 0.2;                         %滚降因子
span = 20;
sps = 5;                                %上采样
rcos = rcosdesign(rolloff, span, sps, 'sqrt');  %生成平方根升余弦滤波器
%% 生成信道
randSeed = [123 321 1234 4321; 12345 54321 123456 654321; 789 987 6789 9876; 56789 98765 456789 987654];
allChans = getRayleighv2(txNum, rxNum, sps*Fs, Delay, Gain, maxDolpler, randSeed);
% rng(468);
% chanlist = [];
% for i = 1:txNum
%     for j = 1:rxNum
%         chan = rayleighchan(1/(sps*Fs), maxDolpler, Delay, Gain);
%         chan.StorePathGains = 1;
%         chan.ResetBeforeFiltering = 0;
%         chanlist = [chanlist;chan];
%     end
% end
%% 帧参数
frameLen = OFDM_Num * (carrier_wave_Num+CPlength) + syn_n * (2^syn_m-1) + protectLen;    %发送帧长度
%% 自适应参数
modformat = zeros(txNum, carrier_wave_Num);
for tx = 1:txNum
    modformat(tx, :) = 1*ones(1,carrier_wave_Num);         %每个子载波的调制方式
end
%% 导频相关参量
pilot_pos = [];                                 %记录导频在子载波的位置
for i = 1:txNum
    pilot_pos = [pilot_pos,i:gap:carrier_wave_Num-(txNum-i)];                 %导频位置
end
pilot_pos = sort(pilot_pos);
data_pos = setdiff([1:carrier_wave_Num],pilot_pos);     %数据在子载波中的位置
%计算数据比特数dataBitNum
Barg = sum(modformat.');
dataBitNum = zeros(txNum, 1);
for i = 1:txNum
    temp = modformat(i,:);
    if CONCODE
        dataBitNum(i,1) = (OFDM_Num * sum(temp) - OFDM_Num * sum(temp(pilot_pos)))./2;
    else
    %     dataBitNum(i,1) = (OFDM_Num * sum(modformat) - OFDM_Num * sum(modformat(pilot_pos)))./2;
    dataBitNum(i,1) = (OFDM_Num * sum(temp) - OFDM_Num * sum(temp(pilot_pos)));
    end
end
%% 信源
DATAlength = DATAlength/txNum;
DATA = randomData(DATAlength, txNum);          %生成随机序列
zeroNum = 0;
DATA = [zeros(txNum, zeroNum), DATA];
DATAlength = DATAlength+zeroNum;
DATA_pos(1:txNum,1) = 1;                       %每个天线当前发送数据位置
recvDATA = zeros(size(DATA));                  %最终重组完的数据
DATArecv_pos(1:rxNum,1) = 1;                   %每个天线当前接受数据位置
%% 仿真大循环，每个循环发送接受OFDM_Num个OFDM帧
round = 0;  %记录循环次数
while(1)
    %% 发送方
    sendDATA = [];  %代表当前发送帧，多天线
    %分每个天线发送的数据，每根天线发送的数据大小可能不同
    for tx = 1:txNum
        %先判断当前发送数据是否足够
        resDATALen = DATAlength - DATA_pos(tx) + 1;     %该天线剩余发送数据长度
        if CONCODE
            if resDATALen < dataBitNum(tx) - conProtect
                frameDATA = [DATA(tx, DATA_pos(tx):DATAlength), zeros(1, dataBitNum(tx)-resDATALen - conProtect), zeros(1, conProtect)];
                DATA_pos(tx) = DATAlength + 1;
            else
                frameDATA = [DATA(tx, DATA_pos(tx):DATA_pos(tx)+dataBitNum(tx)-1 - conProtect), zeros(1, conProtect)];
                DATA_pos(tx) = DATA_pos(tx) + dataBitNum(tx) - conProtect;
            end
        else
            if resDATALen < dataBitNum(tx)
                frameDATA = [DATA(tx, DATA_pos(tx):DATAlength), zeros(1, dataBitNum(tx)-resDATALen)];                            %此天线此发送帧中待发送数据
                DATA_pos(tx) = DATAlength + 1;
            else
                frameDATA = DATA(tx, DATA_pos(tx):DATA_pos(tx)+dataBitNum(tx)-1);
                DATA_pos(tx) = DATA_pos(tx) + dataBitNum(tx);
            end
        end
        if CONCODE
            baseDATA = conCoding(frameDATA);      %卷积
        else
            baseDATA = frameDATA;
        end 
        baseDATA = interleaver(baseDATA, col);%交织
        pilot_data = [zeros(1,tx-1),0.707+0.707j,zeros(1,txNum-tx)];
        basebandSignals = data_Map(baseDATA,txNum,rxNum,carrier_wave_Num,gap,modformat(tx,:),OFDM_Num,pilot_pos,pilot_data);  %数字调制
        OFDMsignals = OFDM(basebandSignals,CPlength);       %OFDM调制
        if TIMEFLAG
            OFDMsignals = addFrameHead(OFDMsignals, syn_n, syn_m);      %添加同步头
        end
        sendDATA = [sendDATA; OFDMsignals];                 %, zeros(1,protectLen)];       %组帧并插入保护间隔
    end
    sendDATA = upfirdn(sendDATA.', rcos, sps);               %上采样，过滤波器，采样频率是原来的sps倍
    sendDATA = [sendDATA.',zeros(txNum,protectLen)];                     %上采样后、尾部插入保护间隔
    %乘载波
    t = 0:1/Fs/sps:1/Fs/sps*(length(sendDATA)-1);
    for tx = 1:txNum
        sendDATA(tx, :) = sendDATA(tx, :) .* exp(1i*(2*pi*(Fc)*t));
    end
    %% 信道
    %瑞利信道
    if RAYLEIGH && AWGN
        %     [recvSignals, pathGain] = Rayleigh_MIMO(txNum, rxNum, sendDATA, sps*Fs, Delay, Gain, maxDolpler, chanlist, randSeed);
        [recvSignals, pathGain] = Rayleigh_MIMOv2(txNum, rxNum, sendDATA, Delay, allChans);
        recvFrame = myChannel(recvSignals, SNR);      %加噪声，并且在帧头前加入随机干扰
    elseif RAYLEIGH
        [recvSignals, pathGain] = Rayleigh_MIMOv2(txNum, rxNum, sendDATA, Delay, allChans);
        recvFrame = myChannel(recvSignals, 100);      %加噪声，并且在帧头前加入随机干扰
    elseif AWGN
        recvFrame = awgn(sendDATA, SNR, 'measured');
    else
        recvFrame = sendDATA;
    end
    %% 接收方
    %     recvFrame = sendDATA;
    % 解载波
    t = 0:1/Fs/sps:1/Fs/sps*(length(recvFrame)-1);
    for rx =1:rxNum
        recvFrame(rx,:) = recvFrame(rx,:).* exp(1i*(-2*pi*Fc*t));
    end
    recvFrameNew = [];
    %时间同步
    if TIMEFLAG
        for rx =1:rxNum
            [recvFrame1temp, fd,position] = timeLocation1(recvFrame(rx,:), syn_n, syn_m, sps*Fs, protectLen,rcos,sps);      %时间同步
            recvFrameNew = [recvFrameNew;recvFrame1temp];
        end
    else
        recvFrameNew = recvFrame;
    end
    %根升余弦滤波器
    recvFrame = upfirdn(recvFrameNew.', rcos, 1,sps);        %过跟升余弦滤波器滤波器，下采样
    recvFrame = recvFrame.';
    recvFrame = recvFrame(:,span+1:length(recvFrame)-span);   %去掉滤波带来的头尾 0
    %对每根天线上的OFDM信号解调
    basebandSignalsRecv = zeros(rxNum, carrier_wave_Num * OFDM_Num);
    allH = zeros(txNum,rxNum,carrier_wave_Num,OFDM_Num);
    for i = 1:rxNum
        OFDMsignalsRecv = recvFrame(i,:);   %一根天线上的OFDM信号
        if TIMEFLAG
            [OFDMsignalsRecv, fd] = timeLocation(OFDMsignalsRecv, syn_n, syn_m, Fs);      %时间同步
            OFDMsignalsRecv = OFDMsignalsRecv(1:OFDM_Num * (carrier_wave_Num+CPlength));            %去掉尾部的0figure
        end
%         m = syn_n*(2^syn_m-1)+1 :syn_n*(2^syn_m-1)+OFDM_Num * (carrier_wave_Num+CPlength);
%         f = exp(1i*2*pi*fd * m / Fs);
%         OFDMsignalsRecv = OFDMsignalsRecv ./ f;                                                 %频率同步
        [tempRecv,H] =  deOFDM(OFDMsignalsRecv, carrier_wave_Num, CPlength, pilot_pos, txNum, gap); %解OFDM
        allH(:,i,:,:) = H;                  %获取信道估计矩阵
        basebandSignalsRecv(i, :) = reshape(tempRecv, 1, []);
    end
    %信道均衡
    ZF_out = zeros(size(basebandSignalsRecv));
    for i = 1:OFDM_Num
        for j = 1:carrier_wave_Num
            idx = (i-1)*carrier_wave_Num+j;
            if ZFMMSEFLAG
                ZF_out(:,idx) =  MMSE_receiver (basebandSignalsRecv(:,idx),allH(:,:,j,i),1/10^(SNR/10));
            else
                ZF_out(:,idx) =  ZF_receiver (basebandSignalsRecv(:,idx),allH(:,:,j,i));
            end
        end
    end   
    %解交织与卷积
    for rx = 1:rxNum
        debaseDATA = de_data_Map(rxNum, ZF_out(rx,:), OFDM_Num, data_pos, modformat(rx,:), carrier_wave_Num);
        debaseDATA = deinterleaver(debaseDATA, row);
        %         %加入卷积码之前误码率要小于0.02 卷积码效果比较好
        if CONCODE
            deframeDATA = conDecoding(debaseDATA);
        else
            deframeDATA = debaseDATA;
        end
        %填充接受数据
        resDATArecvLen = DATAlength - DATArecv_pos(rx) + 1;     %该天线还未接受到的数据大小
        if CONCODE
            if resDATArecvLen >  length(deframeDATA) - conProtect
                recvDATA(rx , DATArecv_pos(rx):DATArecv_pos(rx)+length(deframeDATA)-1 - conProtect) = deframeDATA(1:length(deframeDATA) - conProtect);
                DATArecv_pos(rx) = DATArecv_pos(rx) + length(deframeDATA) - conProtect;
            else
                recvDATA(rx, DATArecv_pos(rx):DATAlength) = deframeDATA(1:resDATArecvLen);
                DATArecv_pos(rx) = DATAlength + 1;
            end
        else
            if resDATArecvLen >  length(deframeDATA)
                recvDATA(rx , DATArecv_pos(rx):DATArecv_pos(rx)+length(deframeDATA)-1) = deframeDATA;
                DATArecv_pos(rx) = DATArecv_pos(rx) + length(deframeDATA);
            else
                recvDATA(rx, DATArecv_pos(rx):DATAlength) = deframeDATA(1:resDATArecvLen);
                DATArecv_pos(rx) = DATAlength + 1;
            end
        end
    end
    %判断是否所有数据接收完毕
    flag = 0;
    for rx = 1:rxNum
        DATArecv_pos
        if DATArecv_pos == 722921
            DATArecv_pos
        end
        if DATArecv_pos(rx) == DATAlength + 1
            flag = flag + 1;
        end
    end
    if flag == rx
        break;
    end
    round = round+1;
    %判断是否需要自适应
    if ADIPTIVED
        modformat = myChow(txNum, rxNum, carrier_wave_Num, OFDM_Num, allH, SNR, 100, Barg);
        %计算总共的比特数目
        for i = 1:txNum
            temp = modformat(i,:);
            if CONCODE
                if mod(sum(temp),2) %如果为奇数
                    [~, maxPos] = max(temp);
%                     modformat(i,maxPos) = modformat(i,maxPos) - 1;      %少发一个bit
                end
                temp = modformat(i,:);
                dataBitNum(i,1) = (OFDM_Num * sum(temp) - OFDM_Num * sum(temp(pilot_pos)))/2;
            else
                dataBitNum(i,1) = (OFDM_Num * sum(temp) - OFDM_Num * sum(temp(pilot_pos)));
            end
        end
    end
end
[errorNum, errorBer] = biterr(DATA(:, zeroNum+1 : end), recvDATA(:, zeroNum+1 : end),[], 'row-wise');
round
