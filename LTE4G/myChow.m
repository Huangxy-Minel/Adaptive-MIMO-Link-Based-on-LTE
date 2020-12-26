function res = myChow(txNum, rxNum, carrier_wave_Num, OFDM_Num, allH, SNR, It, allBarg)
    H = zeros(txNum, rxNum, carrier_wave_Num);      %����ÿ�����ز��ϵ�SNR
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
    bi = zeros(txNum, carrier_wave_Num);        %����tx���߷��͵�rx���߷��Ͷ���bit
    biRound = zeros(txNum, carrier_wave_Num);
    diffi = zeros(txNum, carrier_wave_Num);      %ÿ���ŵ���ʣ������
    for tx = 1:txNum
        for rx = tx             %ֻ����tx�����߷�����tx�Ž������ߣ�����1�ŷ������ߵ�1�Ž�������
%             gama = 0;
            gama = 1;
            Barg = allBarg(tx);
            for it = 1:It
                Btotal = 0;
                Btotal2 = 0;
                UsedCarriers = carrier_wave_Num;
                for i = 1:carrier_wave_Num              %����ÿ�����ز��������bit
%                     bi(tx,i) = log2(1+H(tx,rx,i)/10^(gama/10));
                    bi(tx,i) = log2(1+H(tx,rx,i)*gama);
                    biRound(tx,i) = fix(bi(tx,i));
                    if biRound(tx,i) > 4
                        biRound(tx,i) = 4;
                    end
                    Btotal = Btotal + biRound(tx,i);         %�ܹ������bit��
                    diffi(tx,i) = bi(tx,i) - biRound(tx,i);
                    if biRound(tx,i) <= 0            %�������ز����ͱ��ص����㣬����ʹ��
                        UsedCarriers = UsedCarriers - 1;
                    end
                end
                if Btotal <= Barg / 2 && it == 1          %�����һ�α��������ŵ��ܲ�
                    break;
                elseif Btotal == 0                        %�����ŵ������ܺ�
                    biRound(tx,:) = biRound2;
                    break;
                end
                if it ~= 1
                    if temp1 < 0 && Btotal > Barg
                        break;
                    end
                end
                biRound2 = biRound(tx,:);       %��¼��һ�ε�biRound
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
                if Btotal > Barg    %���統ǰ����bit�����������������ѡ��ʣ��������С�����ز��ٷ�һ��bit
                    minF = 999;
                    minPos = 0;
                    for pos = 1:carrier_wave_Num
                        if biRound(tx,pos) > 0       %���ȱ�֤������ز�����bit������0
                            if diffi(tx,pos) < minF  %Ѱ��ʣ��������С��һ�����ز�
                                minF = diffi(tx,pos);
                                minPos = pos;
                            end
                        end
                    end
                    biRound(tx,minPos) = biRound(tx,minPos) - 1;
                    diffi(tx,minPos) = diffi(tx,minPos) + 1;
                    Btotal = Btotal -1;
                elseif Btotal < Barg                %ѡȡʣ����������һ�����ز����෢һ��bit
                    maxF = 0;
                    maxPos = 0;
                    for pos = 1:carrier_wave_Num
                        if biRound(tx,pos) < 4      %�����Ʒ�����16QAM
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
    %��ȡ�ĵ�bRound��ÿ�����ز����͵�bit��
    res = biRound;
end