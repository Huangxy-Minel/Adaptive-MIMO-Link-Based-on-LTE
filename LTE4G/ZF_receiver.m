function rout = ZF_receiver (rin,H) % rin, rout �� [tx_num*1] ����
H_in = H.';
%H_ZF = (H_in' * H_in) \ H_in'; %���ZF����
%rout = H_ZF * rin;             %����X
rout = H_in \ rin;           %����2�������㷨��ֱ����H*Y����X  
end