%DATA_PREPARATION.M This script prepares centered, thinned signatures for
%training. It creates the development set (D) and the exploitation set (E).
% 
% D : Contains the signatures from writers 11-55 (45 writers).
% E : Contains the signatures from the rest 10 writers.
%
% Specifically performs the following tasks:
%   1)Computes the complement.
%   2)Resize images to 80x120.
%   3)Data augmentation for the D set, (in the last 45 writers).
%      i)  Rotate -10 to +10 degrees.
%      ii) Noise addition.
%   4)Exploitation and Development set creation
%   5)Setting: train,val
%   6)Standardizing

imdb = load(fullfile(pwd, 'data','cropped_images.mat'));
writer_number = 55;
signature_number = 24;
ref_h = 80;
ref_w = 120;

for i=1:writer_number
    for j=1:signature_number
        %% 1) Find complement
        imdb.original{i,j} = imcomplement(imdb.original{i,j});
        imdb.forgeries{i,j} = imcomplement(imdb.forgeries{i,j});
        
        %% 2) Resize to 80x120
        imdb.original{i,j} = imresize(imdb.original{i,j},[ref_h ref_w],'bilinear');
        imdb.forgeries{i,j} = imresize(imdb.forgeries{i,j},[ref_h ref_w],'bilinear');
        imdb.labels(i,j) = i;
    end
end

%% 3) Data augmentation
rotated = cell(45,signature_number,2); % 45: writers
noisy = cell(45,signature_number,2);
noisy_rotated = cell(45, signature_number,2);

rotated_labels = zeros(45,signature_number);
noisy_labels = zeros(45, signature_number);
noisy_rotated_labels = zeros(45, signature_number);

for z=1:2 % (:,:,1) original, (:,:,2) forgeries
    k = 1;
    for i=11:55
        m = 1;
        for j=1:signature_number
            
            if z == 1
                images = imdb.original;
            elseif z == 2
                images = imdb.forgeries;
            end
            
            % Rotation
            theta = randi([-10 10],1,1);
            rotated{k,m,z} = im_rotation(images{i,j},theta);
            rotated_labels(k,m) = i;

            % Salt & peper noise
            noisy{k,m,z}(:,:) = imnoise(images{i,j},'salt & pepper', 0.02);
            noisy_labels(k,m) = i;

            % Salt & pepper in rotated
            noisy_rotated{k,m,z}(:,:) = imnoise(rotated{k,m,z},'salt & pepper', 0.02);
            noisy_rotated_labels(k,m) = i;

            m = m + 1;
        end
        k = k + 1;
    end
end

%concatenating
imdb.augmented.original = cat(1, rotated(:,:,1), noisy(:,:,1), noisy_rotated(:,:,1));
imdb.augmented.forgeries = cat(1, rotated(:,:,2), noisy(:,:,2), noisy_rotated(:,:,2));
imdb.augmented.labels = cat(1, rotated_labels, noisy_labels, noisy_rotated_labels);

%% 4) Development set "D" and Exploitation set "E"
data = reshape(imdb.augmented.original',[],1); % 3240 original
data = cat(1, data, reshape(imdb.augmented.forgeries',[],1)); % plus 3240 forgeries
labels = reshape(imdb.augmented.labels',[],1)';
labels = repmat(labels,1,2);

D.images.data = single(zeros(ref_h, ref_w, 1, length(data)));
D.images.labels = labels;

for i=1:size(D.images.data,4)
    D.images.data(:,:,1,i) = single(cell2mat(data(i)));
end

random_forgeries_number = 14;
original = cell(10,signature_number);
forgeries = cell(10,signature_number);
rndm_forgeries = cell(10,random_forgeries_number); % Random forgeries from D set
labels = cell(10,signature_number);
rndm_labels = cell(10,random_forgeries_number);

for i=1:10 % 10 first writers
    for j=1:signature_number
        original{i,j} = imdb.original{i,j};
        forgeries{i,j} = imdb.forgeries{i,j};
        labels{i,j} = imdb.labels(i,j);
    end
    
    for k=1:random_forgeries_number
        writer = randi([11 55], 1);
        signat = randi(24, 1);
        rndm_forgeries{i,k} = imdb.original{writer, signat};
        rndm_labels{i,k} = writer;
        
    end
end

data = cat(1, reshape(original',[],1), reshape(rndm_forgeries',[],1), reshape(forgeries',[],1));
labels = cat(1, reshape(labels',[],1), reshape(rndm_labels',[],1), reshape(labels',[],1));
E.images.data = single(zeros(ref_h, ref_w, 1, length(data)));
E.images.labels = cell2mat(labels');

for i=1:size(E.images.data,4)
    E.images.data(:,:,1,i) = single(cell2mat(data(i)));
end



%% Setting train val on Development set
D.meta.sets = {'train','val','test'};
E.meta.sets = D.meta.sets;

D.meta.classes = arrayfun(@(x)sprintf('%d',x),11:55,'uniformoutput',false);
E.meta.classes = arrayfun(@(x)sprintf('%d',x),1:10,'uniformoutput',false);

% Pick random validation 80/20%
for i=1:numel(D.images.labels)
        D.images.set(i,1) = randi(100,1);
        if D.images.set(i,1) <= 20
            D.images.set(i,1) = 2; % val
        else
            D.images.set(i,1) = 1; % train
        end
end

E.images.set = ones(numel(E.images.labels),1);
% train: 14 genuine + 14 random forgeries | test: 10 genuine + 24 sk. forgeries
E.images.set(141:240) = 3; E.images.set(381:end) = 3;
    
%% Standardizing
samples = numel(D.images.labels);
z = reshape(D.images.data,[],samples);
n = std(z,0,1);
z = bsxfun(@rdivide, z, mean(n));
D.images.data = reshape(z, ref_h, ref_w, 1, []);
D.images.data_mean = mean(D.images.data,4);

samples = numel(E.images.labels);
z = reshape(E.images.data,[],samples);
n = std(z,0,1);
z = bsxfun(@rdivide, z, mean(n));
E.images.data = reshape(z, ref_h, ref_w, 1, []);
E.images.data_mean = mean(E.images.data(:,:,:,E.images.set == 1), 4);

save(fullfile(pwd, 'data','D_set'),'D');
save(fullfile(pwd, 'data','E_set'),'E');