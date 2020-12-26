function OFDMsignalsRecv = myChannel(recvSignals, SNR)
    txNum = length(recvSignals(:, 1, 1));
    rxNum = length(recvSignals(1, :, 1));
    maxZeroLen = 0;          %�����Ϊ100��Ϊ�����㷨�������У�ÿһ֡���Ჹ��1000��0
    OFDMsignalsRecv = zeros(rxNum, length(recvSignals(1, 1, :)) + maxZeroLen);
    for i = 1:rxNum
        recv = zeros(1, length(recvSignals(1, 1, :)) + maxZeroLen);
        for j = 1:txNum
            rng(i*j + i+j);
            temp = squeeze(recvSignals(j, i, :)).';    %��ȡ���ź�
            %��֡ͷǰ���������0��֡β��ȫ����
%             len = randi([0,maxZeroLen]);
            len = 0;
            recv = recv + [zeros(1, len), temp, zeros(1, maxZeroLen-len)];
        end
        OFDMsignalsRecv(i, :) = recv./txNum;
    end
    OFDMsignalsRecv = awgn(OFDMsignalsRecv, SNR, 'measured');
    
end