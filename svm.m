% SVM.M This script splits the E set in train, test subsets and trains
% writer dependent SVMs in order to classify between original and forged
% signatures. In the last step it tests the trained SVMS on the test set.
%
% E set: The dataset describes 10 writers
%        10x24 original | 10x14 random forgeries | 10x24 skilled forgeries
%
% Train: 14 org + 14 random forgeries
% Test : 10 org + 24 skilled forgeries

load(fullfile(pwd,'data','E_set.mat'));

return_class = @(x) str2double(cell2mat(x));

%% Train, Test assignment
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

%% SVM training
z = E.images.features(strcmp(E.images.identities,'random_forgery'),:);
rf_idx = (1:14);
models = cell(numel(E.meta.classes),1);
for c=E.meta.classes
    label = return_class(c) - 1;
    x = E.images.features(E.images.labels' == label & E.images.set == 1,:);
    
    X = [x; z(rf_idx,:)];
    Y = [ones(14,1); zeros(14,1)];
    
    SVMModel = fitcsvm(X,Y,'KernelFunction','rbf',...
    'Standardize',false,'ClassNames',{'1','0'});
    models{return_class(c)} = SVMModel;
        
    rf_idx = rf_idx + 14;
end
    
%% SVM testing

for c=E.meta.classes
    label = return_class(c) - 1;

    X = E.images.features(E.images.labels' == label & E.images.set == 3,:);
    Y_true = [ones(10,1); zeros(24,1)];
    
    [Y_pred,score] = predict(models{return_class(c)},X);
    Y_pred = str2num(cell2mat(Y_pred));
    
    C = confusionmat(Y_true, Y_pred);
    results.confusion_matrix{return_class(c)} = C;
    results.precision(return_class(c)) = C(2,2) / (C(2,2) + C(1,2));
    results.recall(return_class(c)) = C(2,2) / (C(2,2) + C(2,1));
    results.f1(return_class(c)) = 2 * results.precision(return_class(c)) * results.recall(return_class(c)) ...
                                    /(results.precision(return_class(c)) + results.recall(return_class(c)));
end
