function output = mypskDemod(rDATA, M)
    [rxNum,DATAlength] = size(rDATA);
    if M~=16
        deDATA = pskdemod(rDATA, M);    
    end
    if M==16
        deDATA = qamdemod(rDATA*sqrt(10),M);
    end
    %M进制转2进制
    if M == 2
        output = deDATA;
    end
    if M == 4   %表示将结果转换成2进制
        tempDATA = zeros(rxNum, DATAlength*2);
        for r = 1:rxNum
            for i = 1:DATAlength
                tempDATA(r, 2*i) = rem(deDATA(r, i),2);
                tempDATA(r, 2*i-1) = rem(floor(deDATA(r, i)/2), 2);
            end
        end
        output = tempDATA;
    end
    if M == 8   %表示将结果转换成2进制
        tempDATA = zeros(rxNum, DATAlength*3);
        for r = 1:rxNum
            for i = 1:DATAlength
                tempDATA(r, 4*(i-1)+1) = rem(floor(deDATA(r, i)/4), 2);
                tempDATA(r, 4*(i-1)+2) = rem(floor(deDATA(r, i)/2), 2);
                tempDATA(r, 4*(i-1)+3) = rem(floor(deDATA(r, i)), 2);
            end
        end
        output = tempDATA;
    end
    if M == 16
        tempDATA = zeros(rxNum, DATAlength*4);
        for r = 1:rxNum
            for i = 1:DATAlength
                tempDATA(r, 4*(i-1)+1) = rem(floor(deDATA(r, i)/8),2);
                tempDATA(r, 4*(i-1)+2) = rem(floor(deDATA(r, i)/4), 2);
                tempDATA(r, 4*(i-1)+3) = rem(floor(deDATA(r, i)/2), 2);
                tempDATA(r, 4*(i-1)+4) = rem(floor(deDATA(r, i)), 2);
            end
        end
        output = tempDATA;
    end
        
        
end