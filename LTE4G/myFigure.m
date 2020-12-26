SNR = [4 8 12 16 20 24];
TotalBer1 = [0.0095 0.0143 0.0135 0.0072 0.0040 0.0028];
TotalBer2 = [0.0067 0.0128 0.0091 0.0055 0.0030 0.0021];
round = [979 450 334 308 306 306];
figure;
subplot(1,2,1)
semilogy(SNR,TotalBer1,'b');
hold on;
semilogy(SNR,TotalBer2,'r');
legend('����1','����2');
xlabel('SNR/dB');ylabel('BER');
title('��ͬSNR�����µ�������');
subplot(1,2,2)
plot(SNR,round);
xlabel('SNR/dB');ylabel('�������');
title('��ͬSNR�����µĴ������');

% SNR = [4 8 12 16 20 24];
% TotalBer1 = [0.0103 0.0060 0.0020 0.0013 0.000987 0.00088];
% round = [627 520 535 519 538 523];
% figure;
% subplot(1,2,1)
% semilogy(SNR,TotalBer1,'b');
% xlabel('SNR/dB');ylabel('BER');
% title('��ͬSNR�����µ�������');
% subplot(1,2,2)
% plot(SNR,round);
% xlabel('SNR/dB');ylabel('�������');
% title('��ͬSNR�����µĴ������');