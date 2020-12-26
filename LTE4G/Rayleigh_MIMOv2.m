%输入：input--channelNum*inputLen矩阵；Delay--channelNum行矩阵；Gain--channelNum行矩阵
%输入：txNum--发送天线个数；rxNum--接受天线个数；SNR--信噪比
%输入关系：txNum与input行数相同
%输出：output--按顺序输出第i根天线到其他各个天线的发送信号过信道
function [output, pathGain] = Rayleigh_MIMOv2(txNum, rxNum, input, Delay, allChans)
    output = zeros(txNum, rxNum, length(input(1,:)));
    pathGain = zeros(txNum, rxNum, length(input(1,:)), length(Delay));
    %第i个天线发向第j个天线
    for i = 1:txNum
        for j = 1:rxNum
%             rng(1000*i + 100*j + 21);                    %需要一个随机数，用来保证各瑞利信道间相互独立
            chan = allChans{i, j};
%             chan = rayleighchan(1/Fs, maxDolpler, Delay, Gain);
%             chan.StorePathGains = 1;
%             chan.ResetBeforeFiltering = 0;
%             recvSignal = filter(chan,input(i,:));   %经过瑞利信道
%             [recvSignal,tempPathGain] = chan(input(i,:).');
            [recvSignal,tempPathGain] = step(chan, input(i,:).');
            output(i, j, :) = recvSignal.';
            if length(tempPathGain(1,:)) == 1
                for k = 1:length(input(1,:))
                    pathGain(i, j, k, :) = tempPathGain;
                end
            else
                pathGain(i, j, :, :) = tempPathGain;
            end
        end
    end
end