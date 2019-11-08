function [net, stats] = cnn_writer_independent(varargin)

run '../matlab/vl_setupnn.m'


% Parameter defaults.
opts.train.batchSize = 128 ;
opts.train.numEpochs = 30 ;
opts.train.continue = true ;
opts.train.gpus = 1 ;
opts.train.learningRate = 0.001 ;
opts.expDir = fullfile(vl_rootnn, 'signature-verification', 'data', 'CEDAR-adam-') ;
opts.dataDir = fullfile(vl_rootnn, 'signature-verification', 'data', 'D_set.mat');
[opts, varargin] = vl_argparse(opts, varargin) ;

opts = vl_argparse(opts, varargin) ;

% --------------------------------------------------------------------
%                                                         Load data
% --------------------------------------------------------------------

load(opts.dataDir);
imdb = D;
clear D;

%---------------------------------------------------------------------
%                                                           NETWORK
%---------------------------------------------------------------------

f = 1/100;
net.layers = {} ;
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(11,11,1,32, 'single'), zeros(1, 32, 'single')}}, ...
                           'stride', 2, ...
                           'pad', 5);
net.layers{end+1} = struct('type','relu'); 
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(3,3,32,32, 'single'), zeros(1, 32, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 1);
net.layers{end+1} = struct('type','relu'); 
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(3,3,32,64, 'single'), zeros(1, 64, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 1);                       
net.layers{end+1} = struct('type','relu'); 
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [2 2], ...
                           'stride', 2);
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(3,3,64,128, 'single'), zeros(1, 128, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 1);
net.layers{end+1} = struct('type','relu'); 
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [2 2], ...
                           'stride', 2);
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(3,3,128,256, 'single'), zeros(1, 256, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 1);
net.layers{end+1} = struct('type','relu'); 
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [2 2], ...
                           'stride', 2);
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(3,3,256,512, 'single'), zeros(1, 512, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 1);
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'avg', ...
                           'pool', [5 7], ...
                           'stride', 5, ...
                           'pad', 0);
%-------------------------> FEATURE EXTRACTION <---------------------------                       
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(1,1,512,45, 'single'), zeros(1, 45, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 0);
net.layers{end+1} = struct('type', 'loss');

% Fill in any values we didn't specify explicitly
net.meta.inputSize = [80 120 1];
net.meta.trainOpts.learningRate = 0.001; %[0.3*ones(1,20) 0.01*ones(1,20) 0.001*ones(1,20) 0.0001*ones(1,20)];
net.meta.trainOpts.weightDecay = 0.0005;
net.meta.trainOpts.momentum = 0.3;
net.meta.trainOpts.numEpochs = 30; 
net.meta.trainOpts.batchSize = 128;

net = vl_simplenn_tidy(net) ;


% --------------------------------------------------------------------
%                                                                Train
% --------------------------------------------------------------------

use_gpu = ~isempty(opts.train.gpus) ;

% Start training
[net, stats] = cnn_train(net, imdb, @(imdb, batch) getBatch(imdb, batch, use_gpu), ...
  'train', find(imdb.images.set == 1), 'val', find(imdb.images.set == 2), opts.train) ;

%---------------------------------------------------------------------
%                                        Visualize the learned filters
%---------------------------------------------------------------------
%  figure(2); vl_tshow(net.layers{1}.weights{1}); title('Conv1 filters');
%  figure(3); vl_tshow(net.layers{3}.weights{1}); title('Conv2 filters');
%  figure(4); vl_tshow(net.layers{5}.weights{1}); title('Conv3 filters');
%  figure(5); vl_tshow(net.layers{8}.weights{1}); title('Conv4 filters');
%  figure(6); vl_tshow(net.layers{11}.weights{1}); title('Conv5 filters');
%  figure(7); vl_tshow(net.layers{14}.weights{1}); title('Conv6 filters');
%  figure(8); vl_tshow(net.layers{16}.weights{1}); title('Conv7 filters');


% --------------------------------------------------------------------
function [images, labels] = getBatch(imdb, batch, use_gpu)
% --------------------------------------------------------------------
% This is where we return a given set of images (and their labels) from
% our imdb structure.
% If the dataset was too large to fit in memory, getBatch could load images
% from disk instead (with indexes given in 'batch').

images = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.labels(batch) ;

if use_gpu
  images = gpuArray(images) ;
end
