function rout = MMSE_receiver (rin,H,sigmaz) % rin, rout �� [tx_num*1] ����
H_in = H.';
H_ZF = (H_in' * H_in + sigmaz * eye(size(H))) \ H_in'; %���ZF����
rout = H_ZF * rin;             %����X