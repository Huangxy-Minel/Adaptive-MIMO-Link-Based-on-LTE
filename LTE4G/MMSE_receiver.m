function rout = MMSE_receiver (rin,H,sigmaz) % rin, rout 是 [tx_num*1] 矩阵
H_in = H.';
H_ZF = (H_in' * H_in + sigmaz * eye(size(H))) \ H_in'; %求出ZF矩阵
rout = H_ZF * rin;             %反算X