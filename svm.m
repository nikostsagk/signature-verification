% SVM.M This script splits the E set in train, test subsets and trains
% writer dependent SVMs in order to classify between original and forged
% signatures.
%
% E set: The dataset describes 10 writers
%        10x24 original | 10x14 random forgeries | 10x24 skilled forgeries
%
% Train: 14 org + 14 random forgeries
% Test : 10 org + 24 skilled forgeries

load(fullfile(pwd,'data','E_set.mat'));

return_class = @(x) str2double(cell2mat(x));

for c=E.meta.classes
    label = return_class(c) - 1; % labels are zero indexed
    split = 0;
    for i=1:numel(E.images.labels)

        if isequal(E.images.labels(1,i),label) && strcmp(E.images.identities{i,1},'original')
            if split < 14
                E.images.set(i,1) = 1;
                split = split + 1;
            else
                E.images.set(i,1) = 3;
            end
        end
        
    end
    
end