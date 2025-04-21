% % % === Step 1: Load Metadata ===
% % opts = detectImportOptions('D:\abdominal xray\_excel\intenranl_ER_AXR_220328_finalnew.xlsx');
% % data = readtable('D:\abdominal xray\_excel\intenranl_ER_AXR_220328_finalnew.xlsx', opts);
% % 
% % % Clean up columns (drop Unnamed, handle missing data)
% % data(:, contains(data.Properties.VariableNames, 'Unnamed')) = [];
% % data = rmmissing(data);  % Or use fillmissing if small missing %

% === Step 2: Prepare Image Dataset Info ===
imgRoot = 'D:\abdominal xray\internal_all_age_Aug';
folders = {'admission', 'discharge'};
labels = [];
featuresImg = [];
featuresTab = [];

net = resnet50;
imgSize = net.Layers(1).InputSize;
layer = 'avg_pool';

for k = 1:2
    folder = folders{k};
    label = k - 1; % admission = 0, discharge = 1
    imgFiles = dir(fullfile(imgRoot, folder, '*.png'));

    for i = 1:length(imgFiles)
        filename = imgFiles(i).name;
        parts = split(filename, '_');
        imgID = str2double(parts{1});
        studyDate = datetime(parts{2}, 'InputFormat', 'yyyyMMdd');

        % Match with Excel
        idx = find(data.ID == imgID & data.StudyDate == studyDate);
        if isempty(idx), continue; end  % Skip if no match

        % === Image Feature Extraction ===
        img = imread(fullfile(imgFiles(i).folder, filename));
        if size(img, 3) == 1
            img = repmat(img, [1 1 3]); % Convert grayscale to RGB
        end
        img = imresize(img, imgSize(1:2));
        imgFeature = activations(net, img, layer, 'OutputAs', 'rows');

        % === Tabular Feature Extraction ===
        tab = data(idx, :);

        % Extract numeric + binary fields
        numericFeat = [tab.SBP, tab.DBP, tab.HR, tab.RR, tab.BT, tab.SpO2];
        binaryFeat = double([tab.HTN, tab.DM, tab.TB, tab.Hepatitis, ...
                             tab.abdominal_symptoms, tab.a_stomachache, ...
                             tab.Cancer_within_five_years]);

        tabFeature = [numericFeat, binaryFeat];

        % === Combine & Store ===
        load bert_embeddings.mat
        textFeature = embeddings(idx, :);  % Add the [CLS] token vector

        combinedFeature = [imgFeature, tabFeature, textFeature];
        featuresImg = [featuresImg; combinedFeature];
        labels = [labels; label];
    end
end

% === Step 3: Normalize Tabular Features ===
featuresTab = normalize(featuresTab);

% === Step 4: Concatenate and Train Classifier ===
X = [featuresImg, featuresTab];
Y = categorical(labels);

cv1 = cvpartition(Y, 'HoldOut', 0.10);
XTemp = X(training(cv1), :);
YTemp = Y(training(cv1));
XTest = X(test(cv1), :);
YTest = Y(test(cv1));

% Step 2: Second split - 77.78% train, 22.22% val from 90% → gives ~70/20 split overall
cv2 = cvpartition(YTemp, 'HoldOut', 2/9);  % ≈ 22.22%
XTrain = XTemp(training(cv2), :);
YTrain = YTemp(training(cv2));
XVal = XTemp(test(cv2), :);
YVal = YTemp(test(cv2));

% Check distribution sizes
fprintf("Train: %d | Validation: %d | Test: %d\n", ...
    height(XTrain), height(XVal), height(XTest));

% === Step 3: Train classifier ===
mdl = fitcensemble(XTrain, YTrain);  % or try fitcecoc, fitcsvm, patternnet, etc.

% === Step 4: Validate ===
YValPred = predict(mdl, XVal);
valAccuracy = sum(YValPred == YVal) / numel(YVal);
fprintf('Validation Accuracy: %.2f%%\n', valAccuracy * 100);

% === Step 5: Final test ===
YPred = predict(mdl, XTest);
testAccuracy = sum(YPred == YTest) / numel(YTest);
fprintf('Test Accuracy: %.2f%%\n', testAccuracy * 100);

% === Step 6: Evaluate with confusion matrix ===
confMat = confusionmat(YTest, YPred);
disp('Test Confusion Matrix:');
disp(confMat);