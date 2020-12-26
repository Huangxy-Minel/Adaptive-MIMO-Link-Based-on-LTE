function itl_out = interleaver(itl_in,col)%col为交织深度
    %col = 5;
    len = length(itl_in);
    ones_len = 0;
    if (mod(length(itl_in),col)>0)
        ones_len = col - mod(length(itl_in),col);
    end
    row = (len+ones_len)/col;
    temp1 = [itl_in,ones(1,ones_len)*2];
    temp2 = (reshape(temp1,row,col))';
    temp3 = reshape(temp2,1,len+ones_len);
    idx = temp3 ~= 2;
    itl_out = temp3(idx);
end