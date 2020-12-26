function OFDMsignalsRecv = myChannel(recvSignals, SNR)
    txNum = length(recvSignals(:, 1, 1));
    rxNum = length(recvSignals(1, :, 1));
    maxZeroLen = 0;          %补零最长为100，为后续算法正常进行，每一帧都会补上1000个0
    OFDMsignalsRecv = zeros(rxNum, length(recvSignals(1, 1, :)) + maxZeroLen);
    for i = 1:rxNum
        recv = zeros(1, length(recvSignals(1, 1, :)) + maxZeroLen);
        for j = 1:txNum
            rng(i*j + i+j);
            temp = squeeze(recvSignals(j, i, :)).';    %提取出信号
            %在帧头前加入随机个0，帧尾补全长度
%             len = randi([0,maxZeroLen]);
            len = 0;
            recv = recv + [zeros(1, len), temp, zeros(1, maxZeroLen-len)];
        end
        OFDMsignalsRecv(i, :) = recv./txNum;
    end
    OFDMsignalsRecv = awgn(OFDMsignalsRecv, SNR, 'measured');
    
end