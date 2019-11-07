function  [imrot] = im_rotation(im,theta)
%IM_ROTATION This function returns a rotated image.
%
% Args
% im    : The input image.
% theta : Angle degrees.
%
% Returns
% imrot : The input image rotated counter-clockwise by the given angles.
%         It preserves original dimensions.


[ref_h,ref_w,~] = size(im);

% Rotation & setting white corners
Irot=imrotate(im,theta);
Mrot = ~imrotate(true(size(im)),theta);
Irot(Mrot&~imclearborder(Mrot)) = 0;

[imr_h,imr_w,~]=size(Irot);

% Going back to reference Height
sc=max(imr_h/ref_h,imr_w/ref_w);
imrot=imresize(Irot,1/sc);

% Going back to reference Width
hpad = round((ref_h - size(imrot,1))/2);
hpad(hpad<0) = 0;
wpad = round((ref_w - size(imrot,2))/2);
wpad(wpad<0) = 0;

imrot = padarray(imrot,[hpad wpad],0,'both');
imrot = imrot(1:ref_h,1:ref_w); % Sometimes it creates 81x121 arrays
end
