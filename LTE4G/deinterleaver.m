function ditl_out = deinterleaver(ditl_in,row)%row为交织深度
    %row = 5;
    len = length(ditl_in);
    ones_len = 0;
    if (mod(length(ditl_in),row)>0)
        ones_len = row - mod(length(ditl_in),row);
    end
    col = (len+ones_len)/row;
    ones_idx = row * (col:-1:col-ones_len+1);
    temp1 = zeros(1,len+ones_len);
    temp1(ones_idx) = ones(1,ones_len)*2;
    data_idx = temp1~=2;
    temp1(data_idx) = ditl_in;
    temp2 = (reshape(temp1,row,col))';
    temp3 = reshape(temp2,1,len+ones_len);
    ditl_out = temp3(1:len);
end