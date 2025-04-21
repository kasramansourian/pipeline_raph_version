function [frame_num,time] = bits2timecode(sync_ind,decodedData)
%% Extract timestamps and frame numbers within the second
% https://en.wikipedia.org/wiki/Linear_timecode

        frame_num_ones_bits = cell(size(sync_ind));
        usr_bits_1 = cell(size(sync_ind));
        frame_num_tens_bits = cell(size(sync_ind));
        drop_color_frame_bits = cell(size(sync_ind));
        usr_bits_2 = cell(size(sync_ind));
        seconds_ones_bits = cell(size(sync_ind));
        usr_bits_3 = cell(size(sync_ind));
        seconds_tens_bits = cell(size(sync_ind));
        flag_bit_1 = cell(size(sync_ind));
        usr_bits_4 = cell(size(sync_ind));
        minutes_ones_bits = cell(size(sync_ind));
        usr_bits_5 = cell(size(sync_ind));
        minutes_tens_bits = cell(size(sync_ind));
        flag_bit_2 = cell(size(sync_ind));
        usr_bits_6 = cell(size(sync_ind));
        hours_ones_bits = cell(size(sync_ind));
        usr_bits_7 = cell(size(sync_ind));
        hours_tens_bits = cell(size(sync_ind));
        flag_bit_3 = cell(size(sync_ind));
        flag_bit_4 = cell(size(sync_ind));
        usr_bits_8 = cell(size(sync_ind));
        delete = [];
for i = 1:size(sync_ind,1)
    if sync_ind(i) < 80
        delete = [delete;i];
    else
        start_ind = sync_ind(i)-64;
        end_ind = sync_ind(i)-1;
        % frame number ones place
        frame_num_ones_bits{i} = num2str(bi2de(decodedData(start_ind:(start_ind-1+4))'));
        % user bits field 1
        usr_bits_1{i} = num2str(bi2de(decodedData((start_ind+4):(start_ind-1+8))'));
        % frame number tens place
        frame_num_tens_bits{i} = num2str(bi2de(decodedData((start_ind+8):(start_ind-1+10))'));
        % drop frame / color frame flags
        drop_color_frame_bits{i} = num2str(bi2de(decodedData((start_ind+10):(start_ind-1+12))'));
        % user bits field 2
        usr_bits_2{i} = num2str(bi2de(decodedData((start_ind+12):(start_ind-1+16))'));
        % seconds_bits ones place
        seconds_ones_bits{i} = num2str(bi2de(decodedData((start_ind+16):(start_ind-1+20))'));
        % user bits field 3
        usr_bits_3{i} = num2str(bi2de(decodedData((start_ind+20):(start_ind-1+24))'));
        % seconds_bits tens place
        seconds_tens_bits{i} = num2str(bi2de(decodedData((start_ind+24):(start_ind-1+27))'));
        % flag bit
        flag_bit_1{i} = num2str(bi2de(decodedData((start_ind+27):(start_ind-1+28))'));
        % user bits field 4
        usr_bits_4{i} = num2str(bi2de(decodedData((start_ind+28):(start_ind-1+32))'));
        % minutes_bits ones place
        minutes_ones_bits{i} = num2str(bi2de(decodedData((start_ind+32):(start_ind-1+36))'));
        % user bits field 5
        usr_bits_5{i} = num2str(bi2de(decodedData((start_ind+36):(start_ind-1+40))'));
        % minutes_bits tens place
        minutes_tens_bits{i} = num2str(bi2de(decodedData((start_ind+40):(start_ind-1+43))'));
        % flag bit
        flag_bit_2{i} =num2str(bi2de(decodedData((start_ind+43):(start_ind-1+44))'));
        % user bits field 6
        usr_bits_6{i} =num2str(bi2de(decodedData((start_ind+44):(start_ind-1+48))'));
        % hours_bits ones place
        hours_ones_bits{i} = num2str(bi2de(decodedData((start_ind+48):(start_ind-1+52))'));
        % user bits field 7
        usr_bits_7{i} = num2str(bi2de(decodedData((start_ind+52):(start_ind-1+56))'));
        % hours_bits tens place
        hours_tens_bits{i} = num2str(bi2de(decodedData((start_ind+56):(start_ind-1+58))'));
        % flag bit
        flag_bit_3{i} = num2str(bi2de(decodedData((start_ind+58):(start_ind-1+59))'));
         % flag bit
        flag_bit_4{i} = num2str(bi2de(decodedData((start_ind+59):(start_ind-1+60))'));
        % user bits field 8
        usr_bits_8{i} = num2str(bi2de(decodedData((start_ind+60):(start_ind-1+64))'));
    end
end
%for i = delete(end)+1:size(sync_ind,1)
time = [strcat(hours_tens_bits,hours_ones_bits),strcat(minutes_tens_bits,minutes_ones_bits) strcat(seconds_tens_bits,seconds_ones_bits)];
frame_num = [strcat(frame_num_tens_bits,frame_num_ones_bits)];
time = cellfun(@str2num,time(2:end,:));
frame_num = cellfun(@str2num,frame_num(2:end,:));

end

