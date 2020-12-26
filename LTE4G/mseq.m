function [seq]=mseq(coef)
    % �˺�����������m����
    % coefΪ����ϵ������
    m=length(coef);
    len=2^m-1; % �õ��������ɵ�m���еĳ���
    seq=zeros(1,len); % �����ɵ�m����Ԥ����
    registers = [1 zeros(1, m-2) 1]; % ���Ĵ��������ʼ���
    for i=1:len
        seq(i)=registers(m);
        backQ = mod(sum(coef.*registers) , 2); %�ض��Ĵ�����ֵ����������㣬����Ӻ�ģ2
        registers(2:length(registers)) = registers(1:length(registers)-1); % ��λ
        registers(1)=backQ; % ������ֵ���ڵ�һ���Ĵ�����λ��
    end
end