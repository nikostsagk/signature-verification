%CROPPING.M This script calls the image_prep_crop.m function.
%
% signature_path   : Location of the CEDAR signature folder database.
%                    Default folder: <MATLAB>/data
% database_name    : Database name ('CEDAR',' MCYT','GPDS_synthetic',
%                    'GPDS300', 'UTSig').
%                    Default: 'CEDAR'
% thinning_level   : The level of the thinning process.
%                    Default: 1
% writer_number    : The total number of the writers.
%                    Default: 55 ('CEDAR' has 55 writers)
% signature_number : The total number of signatures per writer.
%                    Default: 24 ('CEDAR' has 24 sig/writer)
%
% original         : An array of cells. Each cell contains a thinned,
%                    centered signature, exempted from excess information.
% forgeries        : -"-

signature_path = fullfile(pwd,'data');
database_name = 'CEDAR';
thinning_level = 1;
writer_number = 55;
signature_number = 24;

original = cell(writer_number, signature_number); % original cropped
forgeries = cell(writer_number, signature_number); % forgeries cropped

%% for original
for i=1:writer_number
    for j=1:signature_number
        imagepath = fullfile(signature_path,'full_org');
        [~,original{i,j}] = ...
            image_prep_crop(database_name,imagepath,'original',i,j,thinning_level);
    end
end

%% for forgeries
for i=1:writer_number
    for j=1:signature_number
        imagepath = fullfile(signature_path,'full_forg');
        [~,forgeries{i,j}] = ...
            image_prep_crop(database_name,imagepath,'false',i,j,thinning_level);
    end
end

%% save cropped
save(fullfile(signature_path,'cropped_images'), 'original', 'forgeries');
