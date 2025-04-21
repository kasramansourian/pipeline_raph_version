function [data] = load_corrupted(filename, PD)

fid = fopen(filename);
fseek(fid,0,'eof');

NUM_HEADER_BYTES = 1024;
fseek(fid,0,'bof');
hdr = fread(fid, NUM_HEADER_BYTES, 'char*1');
info = getHeader(hdr);
    
temp=fread(fid);
inds=strfind(temp',[0,1,2,3,4,5,6,7,8,255]);
bytes=zeros(length(inds),1024);
sample_nums=zeros(length(inds),1);
for i=1:length(inds)
    temp1=temp(inds(i)-2060:inds(i)-1);
    sample_num=uint8(temp1(1:8));
    sample_nums(i)=typecast(sample_num,'uint64');
    temp2=reshape(temp(inds(i)-2048:inds(i)-1),2,1024);
    temp3=temp2;
    temp3(1,:)=256*temp2(1,:);
    temp4=sum(temp3);
    bytes(i,:)=temp4;
    isNegative=int16(bitget(temp4,16));
    temp4=int16(bitset(temp4,16,0))+(-2^15)*isNegative;
    bytes(i,:)=temp4;
end
%figure
%plot(reshape(bytes',[],1).* info.header.bitVolts)
bytes=bytes.*info.header.bitVolts;
if PD
    lim=3;
else
    lim=4.6;
end
pulse = bytes(all(bytes<lim,2)&~all(bytes==-32767*info.header.bitVolts,2)&sample_nums<=40*60*30000,:);
temp=sample_nums(all(bytes<lim,2)&~all(bytes==-32767*info.header.bitVolts,2)&sample_nums<=40*60*30000);
[~,ia]=unique(temp);
temp_fill1=-4.91*ones(temp(end)+1024-temp(1),1);

for i=1:length(temp)
    if ismember(i,ia)
        temp_fill1(temp(i)+1-min(temp):temp(i)+1024-min(temp)) =pulse(i,:);
    elseif std(pulse(i,:))>std(temp_fill1(temp(i)+1-min(temp):temp(i)+1024-min(temp)))
        temp_fill1(temp(i)+1-min(temp):temp(i)+1024-min(temp)) =pulse(i,:);
    end
end
data=medfilt1(temp_fill1);
fclose(fid);

end
function info = getHeader(hdr)
eval(char(hdr'));
info.header = header;
end
