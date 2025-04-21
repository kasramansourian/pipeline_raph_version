
%Upload Data to Bucket (From bucket will autopopulate Elias)
bucket_path = '/Volumes/upload/ocd/Preprocessed/';
code_path = mfilename("fullpath"); %gets path of current running file 
code_path = code_path(1:end-16);
preprocessed_path = [code_path 'Preprocessed/'];

status = copyfile(preprocessed_path,bucket_path);

if status == 1
    rmdir(preprocessed_path,'s')
end