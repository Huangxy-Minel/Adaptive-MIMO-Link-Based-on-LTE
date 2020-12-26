%���룺input--channelNum*inputLen����Delay--channelNum�о���Gain--channelNum�о���
%���룺txNum--�������߸�����rxNum--�������߸�����SNR--�����
%�����ϵ��txNum��input������ͬ
%�����output--��˳�������i�����ߵ������������ߵķ����źŹ��ŵ�
function [output, pathGain] = Rayleigh_MIMOv2(txNum, rxNum, input, Delay, allChans)
    output = zeros(txNum, rxNum, length(input(1,:)));
    pathGain = zeros(txNum, rxNum, length(input(1,:)), length(Delay));
    %��i�����߷����j������
    for i = 1:txNum
        for j = 1:rxNum
%             rng(1000*i + 100*j + 21);                    %��Ҫһ���������������֤�������ŵ����໥����
            chan = allChans{i, j};
%             chan = rayleighchan(1/Fs, maxDolpler, Delay, Gain);
%             chan.StorePathGains = 1;
%             chan.ResetBeforeFiltering = 0;
%             recvSignal = filter(chan,input(i,:));   %���������ŵ�
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