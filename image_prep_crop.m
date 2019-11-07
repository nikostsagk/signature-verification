function [cropped_image,thin_imagegray]=image_prep_crop(db_name, image_path, originality, writer_id, sig_id, thin_level)
%IMAGE_PREP_CROP This function returns crops the excessive information
%from an image and applies a thinning transformation.
%
% Args
% db_name        : Database name ('CEDAR',' MCYT','GPDS_synthetic',
%                  'GPDS300', 'UTSig').
%                  Default: 'CEDAR'
% image_path     : Image path (<path>)
% originality    : Signature originality ('original' or 'false')
% writer_id      : Writer ID (<int>)
% sig_id         : Signature ID (<int>)
% thin_level     : Thinning level (<double>)
%
% Returns
% cropped_image  : An array of cells each containing cropped images in <logical>
%                  format.
% thin_imagegray : An array of cells each containing cropped images in <uint8>
%                  format.

% SOS implementation with MIN rectangle
% For db_name other than 'CEDAR' needs debugging.

if strcmp(db_name,'CEDAR')
    if strcmp(originality,'original')
        sign_file=fullfile(image_path, strcat('original_', num2str(writer_id), '_', num2str(sig_id), '.png'));
    elseif strcmp(originality,'false')
        sign_file=fullfile(image_path, strcat('forgeries_', num2str(writer_id), '_', num2str(sig_id), '.png'));
    end
elseif strcmp(db_name,'MCYT')
    if strcmp(originality,'original')
        d=dir([image_path '\writer_' num2str(writer_id) '\*.bmp']);
        sign_file=[image_path 'writer_' num2str(writer_id) '\' d(sig_id).name];
    elseif strcmp(originality,'false')
        d=dir([image_path '\writer_' num2str(writer_id) '\*.bmp']);
        sign_file=[image_path '\writer_' num2str(writer_id) '\' d(sig_id).name];
    end
elseif strcmp(db_name,'GPDS_synthetic')
    if strcmp(originality,'original')
        %d=dir([image_path '\writer_' num2str(writer_id) '\*.bmp']);
        if writer_id<10
            if sig_id<10
                sign_file=[image_path '00' num2str(writer_id) '\c-00' num2str(writer_id) '-0' num2str(sig_id) '.jpg'];
            else
                sign_file=[image_path '00' num2str(writer_id) '\c-00' num2str(writer_id) '-' num2str(sig_id) '.jpg'];
            end
        elseif writer_id<100
            if sig_id<10
                sign_file=[image_path '0' num2str(writer_id) '\c-0' num2str(writer_id) '-0' num2str(sig_id) '.jpg'];
            else
                sign_file=[image_path '0' num2str(writer_id) '\c-0' num2str(writer_id) '-' num2str(sig_id) '.jpg'];
            end
        else
            if sig_id<10
                sign_file=[image_path num2str(writer_id) '\c-' num2str(writer_id) '-0' num2str(sig_id) '.jpg'];
            else
                sign_file=[image_path num2str(writer_id) '\c-' num2str(writer_id) '-' num2str(sig_id) '.jpg'];
            end
        end
    elseif strcmp(originality,'false')
        if writer_id<10
            if sig_id<10
                sign_file=[image_path '00' num2str(writer_id) '\cf-00' num2str(writer_id) '-0' num2str(sig_id) '.jpg'];
            else
                sign_file=[image_path '00' num2str(writer_id) '\cf-00' num2str(writer_id) '-' num2str(sig_id) '.jpg'];
            end
        elseif writer_id<100
            if sig_id<10
                sign_file=[image_path '0' num2str(writer_id) '\cf-0' num2str(writer_id) '-0' num2str(sig_id) '.jpg'];
            else
                sign_file=[image_path '0' num2str(writer_id) '\cf-0' num2str(writer_id) '-' num2str(sig_id) '.jpg'];
            end
        else
            if sig_id<10
                sign_file=[image_path  num2str(writer_id) '\cf-' num2str(writer_id) '-0' num2str(sig_id) '.jpg'];
            else
                sign_file=[image_path  num2str(writer_id) '\cf-' num2str(writer_id) '-' num2str(sig_id) '.jpg' ];
            end
        end
    end
elseif strcmp(db_name,'GPDS300')
    if strcmp(originality,'original')
        sign_file=[image_path 'writer' num2str(writer_id) '\simg' num2str(sig_id) '.bmp'];
    elseif strcmp(originality,'false')
        sign_file=[image_path 'writer' num2str(writer_id) '\simg' num2str(sig_id) '.bmp'];
    end
elseif strcmp(db_name,'UTSig')
    if strcmp(originality,'original')
        sign_file=[image_path num2str(writer_id) '\' num2str(sig_id) '.tif'];
    elseif strcmp(originality,'false_1')
        sign_file=[image_path num2str(writer_id) '\' num2str(sig_id) '.tif'];
    elseif strcmp(originality,'false_3')
        sign_file=[image_path num2str(writer_id) '\' num2str(sig_id) '.tif'];
    elseif strcmp(originality,'false_2')
        d=dir([image_path num2str(writer_id) '\*.tif']);
        sign_file=[image_path num2str(writer_id) '\' d(sig_id).name];
        %sign_file=[image_path num2str(writer_id) '\' num2str(sid) '.tif'];
        
    end
end
simage=imread(sign_file);

%figure, subplot(2, 2, 1), imshow(simage), title('original image')

bw_level=graythresh(simage);
bw_image=im2bw(simage,bw_level);

%subplot(2, 2, 2), imshow(bw_image), title('black and white image')
   

thin_image = bwmorph(~bw_image, 'thin', thin_level);
   
thin_image = ~thin_image;
[x,y]=find(thin_image==0);
thin_imagegray=uint8(255*ones(size(simage)));% gray level information
for i=1:length(x)
    thin_imagegray(x(i),y(i))=simage(x(i),y(i));
end
%subplot(2, 2, 3), imshow(thin_image), title('thinned bw image')

% Crop the  thinned image
% --------------------------------------------------------------------------------------------
[~,x]=find(~thin_image);

% find the extreme x values and try to cut the outliers
% x in ascending order
xs=sort(x);

outlier_distance=3;
while xs(1)<(xs(2)-outlier_distance)
    xs(1)=[];
end
while xs(end)>(xs(end-1)+outlier_distance)
    xs(end)=[];
end

xmin=xs(1)-1;
xmax=xs(end)+1;

% crop the image
cropped_image=thin_image;
cropped_image(:,xmax:end)=[];
cropped_image(:,1:xmin)=[];

thin_imagegray(:,xmax:end)=[];
thin_imagegray(:,1:xmin)=[];

[y,~]=find(~cropped_image);
% y in ascending order
ys=sort(y);

while ys(1)<(ys(2)-outlier_distance)
    ys(1)=[];
end
while ys(end)>(ys(end-1)+outlier_distance)
    ys(end)=[];
end

ymin=ys(1)-1;
ymax=ys(end)+1;

cropped_image(ymax:end, :)=[];
cropped_image(1:ymin,:)=[];
thin_imagegray(ymax:end, :)=[];
thin_imagegray(1:ymin,:)=[];
%subplot(2, 2, 4), imshow(cropped_image), title('cropped image')
