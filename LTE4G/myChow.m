function res = myChow(txNum, rxNum, carrier_wave_Num, OFDM_Num, allH, SNR, It, allBarg)
    H = zeros(txNum, rxNum, carrier_wave_Num);      %计算每个子载波上的SNR
    for rx = 1:rxNum
        for tx = 1:txNum
            for ofdmNum = 1:OFDM_Num
                H(tx,rx,:) = H(tx,rx,:) + allH(tx,rx,:,ofdmNum);
            end
            H(tx,rx,:) = H(tx,rx,:)./OFDM_Num;
            H(tx,rx,:) = abs(H(tx,rx,:));
            H(tx,rx,:) = H(tx,rx,:).^2 .* 10^(SNR/10);
        end
    end
    bi = zeros(txNum, carrier_wave_Num);        %计算tx天线发送到rx天线发送多少bit
    biRound = zeros(txNum, carrier_wave_Num);
    diffi = zeros(txNum, carrier_wave_Num);      %每个信道的剩余容量
    for tx = 1:txNum
        for rx = tx             %只考虑tx号天线发送至tx号接受天线，例如1号发送天线到1号接受天线
%             gama = 0;
            gama = 1;
            Barg = allBarg(tx);
            for it = 1:It
                Btotal = 0;
                Btotal2 = 0;
                UsedCarriers = carrier_wave_Num;
                for i = 1:carrier_wave_Num              %计算每个子载波上最大发送bit
%                     bi(tx,i) = log2(1+H(tx,rx,i)/10^(gama/10));
                    bi(tx,i) = log2(1+H(tx,rx,i)*gama);
                    biRound(tx,i) = fix(bi(tx,i));
                    if biRound(tx,i) > 4
                        biRound(tx,i) = 4;
                    end
                    Btotal = Btotal + biRound(tx,i);         %总共发射的bit数
                    diffi(tx,i) = bi(tx,i) - biRound(tx,i);
                    if biRound(tx,i) <= 0            %若该子载波发送比特等于零，代表不使用
                        UsedCarriers = UsedCarriers - 1;
                    end
                end
                if Btotal <= Barg / 2 && it == 1          %代表第一次遍历发现信道很差
                    break;
                elseif Btotal == 0                        %代表信道条件很好
                    biRound(tx,:) = biRound2;
                    break;
                end
                if it ~= 1
                    if temp1 < 0 && Btotal > Barg
                        break;
                    end
                end
                biRound2 = biRound(tx,:);       %记录上一次的biRound
                temp1 = (Barg-Btotal)/UsedCarriers;
                temp2 = 10^(SNR/10);
                gama = ((1+temp2*gama)*(2^temp1)-1) / temp2;
                if gama < 0
                    break
                end
%                 gama = gama * temp2 / ((temp2+1)/(2^temp1)-1);
%                 gama = gama + 10 * log(2^((Btotal-Barg)/UsedCarriers));
                if Btotal == Barg
                    break;
                end
            end
            while(1)
                if Btotal > Barg    %假如当前发送bit数大于期望，则可以选择剩余容量最小的子载波少发一个bit
                    minF = 999;
                    minPos = 0;
                    for pos = 1:carrier_wave_Num
                        if biRound(tx,pos) > 0       %首先保证这个子载波发送bit数大于0
                            if diffi(tx,pos) < minF  %寻找剩余容量最小的一个子载波
                                minF = diffi(tx,pos);
                                minPos = pos;
                            end
                        end
                    end
                    biRound(tx,minPos) = biRound(tx,minPos) - 1;
                    diffi(tx,minPos) = diffi(tx,minPos) + 1;
                    Btotal = Btotal -1;
                elseif Btotal < Barg                %选取剩余容量最大的一个子载波，多发一个bit
                    maxF = 0;
                    maxPos = 0;
                    for pos = 1:carrier_wave_Num
                        if biRound(tx,pos) < 4      %最大调制方法是16QAM
                            if diffi(tx,pos) > maxF 
                                maxF = diffi(tx,pos);
                                maxPos = pos;
                            end
                        end
                    end
                    if diffi(tx,maxPos) < 0.8
                        break
                    end
                    biRound(tx,maxPos) = biRound(tx,maxPos) + 1;
                    diffi(tx,maxPos) = diffi(tx,maxPos) - 1;
                    Btotal = Btotal + 1;
                else
                    break;
                end
            end
        end
    end
    %获取的的bRound即每个子载波发送的bit数
    res = biRound;
end