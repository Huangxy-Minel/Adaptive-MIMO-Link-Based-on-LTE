function rout = ZF_receiver (rin,H) % rin, rout 是 [tx_num*1] 矩阵
H_in = H.';
%H_ZF = (H_in' * H_in) \ H_in'; %求出ZF矩阵
%rout = H_ZF * rin;             %反算X
rout = H_in \ rin;           %方法2：理论算法，直接用H*Y反算X  
end