clc;
clear;
rng('default');
%%����ѡ��
CONCODE = 1;            %�Ƿ���Ҫ�����
TIMEFLAG = 1;           %�Ƿ�ʱ��ͬ��
ADIPTIVED = 1;          %�Ƿ�����Ӧ
RAYLEIGH = 1;           %�Ƿ�������ŵ�
AWGN = 1;               %�Ƿ��AWGN�ŵ�
ZFMMSEFLAG = 1;         %0ʹ��ZF��1ʹ��MMSE
SNR = 8;               %�����
%% ��ʼ������
Fc = 2*1e9;                             %��Ƶ2GHz
Bt = 2*1e6;                             %����2MHz
carrier_wave_Num = 512;                 %���ز�����
OFDM_Num = 4;                          %ÿһ֡������OFDM֡����
if TIMEFLAG
    protectLen = 100;                       %�����������
else
    protectLen = 0;
end
conProtect = 4;                         %����뱣�����
syn_n = 4;                              %ͬ��ͷ�ظ�����
syn_m = 7;                              %ͬ��ͷ����2^m - 1
Fs = Bt;                                %carrier_wave_Num * Bt / (carrier_wave_Num +1); %ϵͳ������
DATAlength = 1e6;                       %�ܳ���
col = 5;                                %��֯���
row = 5;
%% �����ŵ�����
CPlength = 12;                          %ѭ��ǰ׺����
maxDolpler = 100;                        %���������Ƶ��
% Delay = [0 4] ./ Fs;
% Gain = [0 -10];
Delay = [0 30 150 310 370 710 1090 1730 2510] .* 10^(-9);   %�ྶʱ��
Gain = [0 -1.5 -1.4 -3.6 -0.6 -9.1 -7.0 -12.0 -16.9];       %�ྶ����
%% MIMO����
txNum = 1;                              %����������Ŀ
rxNum = 1;                              %����������Ŀ
gap = 10;                                %��Ƶ���
%% �������˲���
rolloff = 0.2;                         %��������
span = 20;
sps = 5;                                %�ϲ���
rcos = rcosdesign(rolloff, span, sps, 'sqrt');  %����ƽ�����������˲���
%% �����ŵ�
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
%% ֡����
frameLen = OFDM_Num * (carrier_wave_Num+CPlength) + syn_n * (2^syn_m-1) + protectLen;    %����֡����
%% ����Ӧ����
modformat = zeros(txNum, carrier_wave_Num);
for tx = 1:txNum
    modformat(tx, :) = 1*ones(1,carrier_wave_Num);         %ÿ�����ز��ĵ��Ʒ�ʽ
end
%% ��Ƶ��ز���
pilot_pos = [];                                 %��¼��Ƶ�����ز���λ��
for i = 1:txNum
    pilot_pos = [pilot_pos,i:gap:carrier_wave_Num-(txNum-i)];                 %��Ƶλ��
end
pilot_pos = sort(pilot_pos);
data_pos = setdiff([1:carrier_wave_Num],pilot_pos);     %���������ز��е�λ��
%�������ݱ�����dataBitNum
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
%% ��Դ
DATAlength = DATAlength/txNum;
DATA = randomData(DATAlength, txNum);          %�����������
zeroNum = 0;
DATA = [zeros(txNum, zeroNum), DATA];
DATAlength = DATAlength+zeroNum;
DATA_pos(1:txNum,1) = 1;                       %ÿ�����ߵ�ǰ��������λ��
recvDATA = zeros(size(DATA));                  %���������������
DATArecv_pos(1:rxNum,1) = 1;                   %ÿ�����ߵ�ǰ��������λ��
%% �����ѭ����ÿ��ѭ�����ͽ���OFDM_Num��OFDM֡
round = 0;  %��¼ѭ������
while(1)
    %% ���ͷ�
    sendDATA = [];  %����ǰ����֡��������
    %��ÿ�����߷��͵����ݣ�ÿ�����߷��͵����ݴ�С���ܲ�ͬ
    for tx = 1:txNum
        %���жϵ�ǰ���������Ƿ��㹻
        resDATALen = DATAlength - DATA_pos(tx) + 1;     %������ʣ�෢�����ݳ���
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
                frameDATA = [DATA(tx, DATA_pos(tx):DATAlength), zeros(1, dataBitNum(tx)-resDATALen)];                            %�����ߴ˷���֡�д���������
                DATA_pos(tx) = DATAlength + 1;
            else
                frameDATA = DATA(tx, DATA_pos(tx):DATA_pos(tx)+dataBitNum(tx)-1);
                DATA_pos(tx) = DATA_pos(tx) + dataBitNum(tx);
            end
        end
        if CONCODE
            baseDATA = conCoding(frameDATA);      %���
        else
            baseDATA = frameDATA;
        end 
        baseDATA = interleaver(baseDATA, col);%��֯
        pilot_data = [zeros(1,tx-1),0.707+0.707j,zeros(1,txNum-tx)];
        basebandSignals = data_Map(baseDATA,txNum,rxNum,carrier_wave_Num,gap,modformat(tx,:),OFDM_Num,pilot_pos,pilot_data);  %���ֵ���
        OFDMsignals = OFDM(basebandSignals,CPlength);       %OFDM����
        if TIMEFLAG
            OFDMsignals = addFrameHead(OFDMsignals, syn_n, syn_m);      %���ͬ��ͷ
        end
        sendDATA = [sendDATA; OFDMsignals];                 %, zeros(1,protectLen)];       %��֡�����뱣�����
    end
    sendDATA = upfirdn(sendDATA.', rcos, sps);               %�ϲ��������˲���������Ƶ����ԭ����sps��
    sendDATA = [sendDATA.',zeros(txNum,protectLen)];                     %�ϲ�����β�����뱣�����
    %���ز�
    t = 0:1/Fs/sps:1/Fs/sps*(length(sendDATA)-1);
    for tx = 1:txNum
        sendDATA(tx, :) = sendDATA(tx, :) .* exp(1i*(2*pi*(Fc)*t));
    end
    %% �ŵ�
    %�����ŵ�
    if RAYLEIGH && AWGN
        %     [recvSignals, pathGain] = Rayleigh_MIMO(txNum, rxNum, sendDATA, sps*Fs, Delay, Gain, maxDolpler, chanlist, randSeed);
        [recvSignals, pathGain] = Rayleigh_MIMOv2(txNum, rxNum, sendDATA, Delay, allChans);
        recvFrame = myChannel(recvSignals, SNR);      %��������������֡ͷǰ�����������
    elseif RAYLEIGH
        [recvSignals, pathGain] = Rayleigh_MIMOv2(txNum, rxNum, sendDATA, Delay, allChans);
        recvFrame = myChannel(recvSignals, 100);      %��������������֡ͷǰ�����������
    elseif AWGN
        recvFrame = awgn(sendDATA, SNR, 'measured');
    else
        recvFrame = sendDATA;
    end
    %% ���շ�
    %     recvFrame = sendDATA;
    % ���ز�
    t = 0:1/Fs/sps:1/Fs/sps*(length(recvFrame)-1);
    for rx =1:rxNum
        recvFrame(rx,:) = recvFrame(rx,:).* exp(1i*(-2*pi*Fc*t));
    end
    recvFrameNew = [];
    %ʱ��ͬ��
    if TIMEFLAG
        for rx =1:rxNum
            [recvFrame1temp, fd,position] = timeLocation1(recvFrame(rx,:), syn_n, syn_m, sps*Fs, protectLen,rcos,sps);      %ʱ��ͬ��
            recvFrameNew = [recvFrameNew;recvFrame1temp];
        end
    else
        recvFrameNew = recvFrame;
    end
    %���������˲���
    recvFrame = upfirdn(recvFrameNew.', rcos, 1,sps);        %�����������˲����˲������²���
    recvFrame = recvFrame.';
    recvFrame = recvFrame(:,span+1:length(recvFrame)-span);   %ȥ���˲�������ͷβ 0
    %��ÿ�������ϵ�OFDM�źŽ��
    basebandSignalsRecv = zeros(rxNum, carrier_wave_Num * OFDM_Num);
    allH = zeros(txNum,rxNum,carrier_wave_Num,OFDM_Num);
    for i = 1:rxNum
        OFDMsignalsRecv = recvFrame(i,:);   %һ�������ϵ�OFDM�ź�
        if TIMEFLAG
            [OFDMsignalsRecv, fd] = timeLocation(OFDMsignalsRecv, syn_n, syn_m, Fs);      %ʱ��ͬ��
            OFDMsignalsRecv = OFDMsignalsRecv(1:OFDM_Num * (carrier_wave_Num+CPlength));            %ȥ��β����0figure
        end
%         m = syn_n*(2^syn_m-1)+1 :syn_n*(2^syn_m-1)+OFDM_Num * (carrier_wave_Num+CPlength);
%         f = exp(1i*2*pi*fd * m / Fs);
%         OFDMsignalsRecv = OFDMsignalsRecv ./ f;                                                 %Ƶ��ͬ��
        [tempRecv,H] =  deOFDM(OFDMsignalsRecv, carrier_wave_Num, CPlength, pilot_pos, txNum, gap); %��OFDM
        allH(:,i,:,:) = H;                  %��ȡ�ŵ����ƾ���
        basebandSignalsRecv(i, :) = reshape(tempRecv, 1, []);
    end
    %�ŵ�����
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
    %�⽻֯����
    for rx = 1:rxNum
        debaseDATA = de_data_Map(rxNum, ZF_out(rx,:), OFDM_Num, data_pos, modformat(rx,:), carrier_wave_Num);
        debaseDATA = deinterleaver(debaseDATA, row);
        %         %��������֮ǰ������ҪС��0.02 �����Ч���ȽϺ�
        if CONCODE
            deframeDATA = conDecoding(debaseDATA);
        else
            deframeDATA = debaseDATA;
        end
        %����������
        resDATArecvLen = DATAlength - DATArecv_pos(rx) + 1;     %�����߻�δ���ܵ������ݴ�С
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
    %�ж��Ƿ��������ݽ������
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
    %�ж��Ƿ���Ҫ����Ӧ
    if ADIPTIVED
        modformat = myChow(txNum, rxNum, carrier_wave_Num, OFDM_Num, allH, SNR, 100, Barg);
        %�����ܹ��ı�����Ŀ
        for i = 1:txNum
            temp = modformat(i,:);
            if CONCODE
                if mod(sum(temp),2) %���Ϊ����
                    [~, maxPos] = max(temp);
%                     modformat(i,maxPos) = modformat(i,maxPos) - 1;      %�ٷ�һ��bit
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
