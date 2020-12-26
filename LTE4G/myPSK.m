function basebandSignal = myPSK(DATA, M)
    [txNum,DATAlength] = size(DATA);
    basebandSignal = zeros(txNum, DATAlength);
    switch(M)
        case 1
            basebandSignal = 0;
        case 2 %BPSK
            basebandSignal = pskmod(DATA, M);
        case 4
            DATATemp = zeros(txNum, DATAlength/2);
            for t = 1:txNum
                for i = 1:DATAlength/2
                    DATATemp(t, i) = DATA(t, 2*i-1)*2 + DATA(t, 2*i);
                end
            end
            basebandSignal = pskmod(DATATemp, M);
        case 8
            DATATemp = zeros(txNum, DATAlength/3);
            for t = 1:txNum
                for i = 1:DATAlength/3
                    DATATemp(t, i) = DATA(t, 3*(i-1)+1)*4 + DATA(t, 3*(i-1)+2)*2 +DATA(t, 3*(i-1)+3);
                end
            end
            basebandSignal = pskmod(DATATemp, M);
        case 16
            DATATemp = zeros(txNum, DATAlength/4);
            for t = 1:txNum
                for i = 1:DATAlength/4
                    DATATemp(t, i) = DATA(t, 4*(i-1)+1)*8 + DATA(t, 4*(i-1)+2)*4 + DATA(t, 4*(i-1)+3)*2+DATA(t, 4*(i-1)+4);
                end
            end
            basebandSignal = qammod(DATATemp, M)./sqrt(10);
    end
end