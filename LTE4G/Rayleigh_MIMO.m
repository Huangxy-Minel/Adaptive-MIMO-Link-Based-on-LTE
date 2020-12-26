%输入：input--channelNum*inputLen矩阵；Delay--channelNum行矩阵；Gain--channelNum行矩阵
%输入：txNum--发送天线个数；rxNum--接受天线个数；SNR--信噪比
%输入关系：txNum与input行数相同
%输出：output--按顺序输出第i根天线到其他各个天线的发送信号过信道
function [output, pathGain] = Rayleigh_MIMO(txNum, rxNum, input, Fs, Delay, Gain, maxDolpler, chanlist, randSeed)
    output = zeros(txNum, rxNum, length(input(1,:)));
    pathGain = zeros(txNum, rxNum, length(input(1,:)), length(Delay));
    %第i个天线发向第j个天线
    for i = 1:txNum
        for j = 1:rxNum
            %空过rand函数使随机数差距大一些
            chan = chanlist((i-1)*rxNum+j);
            recvSignal = filter(chan,input(i,:));   %经过瑞利信道
            output(i, j, :) = recvSignal;
            if length(chan.PathGains(:,1)) == 1
                for k = 1:length(input(1,:))
                    pathGain(i, j, k, :) = chan.PathGains;
                end
            else
                pathGain(i, j, :, :) = chan.PathGains;
            end
        end
    end
end