%���룺input--channelNum*inputLen����Delay--channelNum�о���Gain--channelNum�о���
%���룺txNum--�������߸�����rxNum--�������߸�����SNR--�����
%�����ϵ��txNum��input������ͬ
%�����output--��˳�������i�����ߵ������������ߵķ����źŹ��ŵ�
function [output, pathGain] = Rayleigh_MIMO(txNum, rxNum, input, Fs, Delay, Gain, maxDolpler, chanlist, randSeed)
    output = zeros(txNum, rxNum, length(input(1,:)));
    pathGain = zeros(txNum, rxNum, length(input(1,:)), length(Delay));
    %��i�����߷����j������
    for i = 1:txNum
        for j = 1:rxNum
            %�չ�rand����ʹ���������һЩ
            chan = chanlist((i-1)*rxNum+j);
            recvSignal = filter(chan,input(i,:));   %���������ŵ�
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