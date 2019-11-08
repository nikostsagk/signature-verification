%FEATURE_EXTRACTION.M This script extracts features from the fully
%connected layer of the pre-trained network.

run '../matlab/vl_setupnn.m'
load('net-epoch-74.mat');
load(fullfile(pwd,'data','E_set.mat'));
% clear meta state stats;

net.layers{1,end}.type = 'softmax' ;
res = [];
for i=1:numel(E.images.labels)
    res = vl_simplenn(net, E.images.data(:,:,:,i));
    E.images.features(i,:) = double(squeeze(gather(res(end-2).x))');
end

save(fullfile(pwd, 'data','E_set'),'E');