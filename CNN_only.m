%%%%%%%%%%%%% with 70:20:10

datasetPath = 'D:\abdominal xray\internal_all_age_Aug';

% Load images
imds = imageDatastore(datasetPath, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames'); % Folder names used as labels

% Split dataset: 70% train, 20% validation, 10% test
[imdsTrain, imdsRemain] = splitEachLabel(imds, 0.7, 'randomized');
[imdsVal, imdsTest] = splitEachLabel(imdsRemain, 2/3, 'randomized');  % 2/3 of 30% = 20% val, 1/3 of 30% = 10% test

% Load ResNet50 Model
net = darknet53;
inputSize = net.Layers(1).InputSize;

% Modify last layers for binary classification
lgraph = layerGraph(net);

% Remove fully connected, softmax, and classification layers
lgraph = removeLayers(lgraph, {'conv53', 'softmax', 'output'});

% Add a Global Average Pooling (GAP) layer
gapLayer = globalAveragePooling2dLayer('Name', 'gap_layer');
newFc = fullyConnectedLayer(2, 'Name', 'new_fc'); % Binary classification
newSoftmax = softmaxLayer('Name', 'new_softmax');
newClassOutput = classificationLayer('Name', 'new_classOutput');

% Add new layers to the network
lgraph = addLayers(lgraph, gapLayer);
lgraph = addLayers(lgraph, newFc);
lgraph = addLayers(lgraph, newSoftmax);
lgraph = addLayers(lgraph, newClassOutput);

% Connect layers properly
lgraph = connectLayers(lgraph, 'avg1', 'gap_layer');
lgraph = connectLayers(lgraph, 'gap_layer', 'new_fc');
lgraph = connectLayers(lgraph, 'new_fc', 'new_softmax');
lgraph = connectLayers(lgraph, 'new_softmax', 'new_classOutput');

% Preprocessing: Convert grayscale images to RGB
augmentedTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain, ...
    'ColorPreprocessing', 'gray2rgb');
augmentedVal = augmentedImageDatastore(inputSize(1:2), imdsVal, ...
    'ColorPreprocessing', 'gray2rgb');
augmentedTest = augmentedImageDatastore(inputSize(1:2), imdsTest, ...
    'ColorPreprocessing', 'gray2rgb');

% Define Training Options
options = trainingOptions('adam', ...
    'MiniBatchSize', 16, ...
    'MaxEpochs', 10, ...
    'InitialLearnRate', 0.0001, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', augmentedVal, ...
    'ValidationFrequency', 5, ...
    'Plots', 'training-progress', ...
    'Verbose', true);

% Train the Model
trainedNet = trainNetwork(augmentedTrain, lgraph, options);

% Test the Model
predictions = classify(trainedNet, augmentedTest);
actualLabels = imdsTest.Labels;

% Compute Accuracy
accuracy = sum(predictions == actualLabels) / numel(actualLabels);
fprintf('Test Accuracy: %.2f%%\n', accuracy * 100);

% Convert Labels for Metrics Calculation
actualNumeric = double(actualLabels) - 1; % Convert categorical to numeric (0 or 1)
predictedNumeric = double(predictions) - 1;

% % Display Confusion Matrix
% figure;
% confusionchart(actualLabels, predictions);
% title('Confusion Matrix');

% Display Raw Confusion Matrix
figure;
cm = confusionchart(actualLabels, predictions);
title('Confusion Matrix (Counts)');

% Display Percentage Confusion Matrix
figure;
confMat = confusionmat(actualLabels, predictions);
confMatPercent = 100 * confMat ./ sum(confMat, 2); % Row-wise percentage

% Create categorical labels for chart
uniqueLabels = categories(actualLabels);
cmPercent = confusionchart(uniqueLabels, uniqueLabels);
cmPercent.Title = 'Confusion Matrix (%)';
cmPercent.ColumnSummary = 'column-normalized';
cmPercent.RowSummary = 'row-normalized';
cmPercent.Normalization = 'row-normalized';


% Compute Confusion Matrix
confMat = confusionmat(actualNumeric, predictedNumeric);
TP = confMat(2,2);
FP = confMat(1,2);
TN = confMat(1,1);
FN = confMat(2,1);

% Compute Metrics
precision = TP / (TP + FP);
recall = TP / (TP + FN);
f1_score = 2 * (precision * recall) / (precision + recall);
specificity = TN / (TN + FP);

% Display Results
fprintf('Precision: %.2f\n', precision);
fprintf('Recall (Sensitivity): %.2f\n', recall);
fprintf('F1-Score: %.2f\n', f1_score);
fprintf('Specificity: %.2f\n', specificity);

% Compute AUC
predScores = predict(trainedNet, augmentedTest); % Get probabilities

% Ensure correct probability selection for positive class
if size(predScores, 2) > 1
    predScores = predScores(:, 2); % Select probability for class 1
end

[X, Y, ~, AUC] = perfcurve(actualNumeric, predScores, 1);
fprintf('AUC Value: %.2f\n', AUC);

% Plot Combined AUC Curve
figure;
plot(X, Y, 'b-', 'LineWidth', 2);
hold on;
plot([0 1], [0 1], 'k--'); % Diagonal line for random classifier
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title(['ROC Curve (AUC = ', num2str(AUC, '%.2f'), ')']);
legend('ROC Curve', 'Random Classifier', 'Location', 'southeast');
grid on;
hold off;




%%%%%%%%%%% with 80:20 
% Set dataset path
datasetPath = 'D:\abdominal xray\internal_all_age_Aug';

% Load images and split into Training (80%) & Testing (20%)
imds = imageDatastore(datasetPath, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames'); % Folder names used as labels

% Split into training and testing sets
[trainImgs, testImgs] = splitEachLabel(imds, 0.8, 'randomized');

% Load ResNet50 Model
net = densenet201;
inputSize = net.Layers(1).InputSize;

% Modify last layers for binary classification
lgraph = layerGraph(net);

% Remove fully connected, softmax, and classification layers
lgraph = removeLayers(lgraph, {'fc1000', 'fc1000_softmax', 'ClassificationLayer_fc1000'});

% Add a Global Average Pooling (GAP) layer
gapLayer = globalAveragePooling2dLayer('Name', 'gap_layer');
newFc = fullyConnectedLayer(2, 'Name', 'new_fc'); % Binary classification
newSoftmax = softmaxLayer('Name', 'new_softmax');
newClassOutput = classificationLayer('Name', 'new_classOutput');

% Add new layers to the network
lgraph = addLayers(lgraph, gapLayer);
lgraph = addLayers(lgraph, newFc);
lgraph = addLayers(lgraph, newSoftmax);
lgraph = addLayers(lgraph, newClassOutput);

% Connect layers properly
lgraph = connectLayers(lgraph, 'avg_pool', 'gap_layer');
lgraph = connectLayers(lgraph, 'gap_layer', 'new_fc');
lgraph = connectLayers(lgraph, 'new_fc', 'new_softmax');
lgraph = connectLayers(lgraph, 'new_softmax', 'new_classOutput');

% Preprocessing: Convert grayscale images to RGB
augmentedTrain = augmentedImageDatastore(inputSize(1:2), trainImgs, ...
    'ColorPreprocessing', 'gray2rgb');

augmentedTest = augmentedImageDatastore(inputSize(1:2), testImgs, ...
    'ColorPreprocessing', 'gray2rgb');

% Define Training Options
options = trainingOptions('adam', ...
    'MiniBatchSize', 16, ...
    'MaxEpochs', 10, ...
    'InitialLearnRate', 0.0001, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', augmentedTest, ...
    'ValidationFrequency', 5, ...
    'Plots', 'training-progress', ...
    'Verbose', true);

% Train the Model
trainedNet = trainNetwork(augmentedTrain, lgraph, options);

% Test the Model
predictions = classify(trainedNet, augmentedTest);
actualLabels = testImgs.Labels;

% Compute Accuracy
accuracy = sum(predictions == actualLabels) / numel(actualLabels);
fprintf('Test Accuracy: %.2f%%\n', accuracy * 100);

% Convert Labels for Metrics Calculation
actualNumeric = double(actualLabels) - 1; % Convert categorical to numeric (0 or 1)
predictedNumeric = double(predictions) - 1;

% Display Confusion Matrix
figure;
confusionchart(actualLabels, predictions);
title('Confusion Matrix');

% Compute Confusion Matrix
confMat = confusionmat(actualNumeric, predictedNumeric);
TP = confMat(2,2);
FP = confMat(1,2);
TN = confMat(1,1);
FN = confMat(2,1);

% Compute Metrics
precision = TP / (TP + FP);
recall = TP / (TP + FN);
f1_score = 2 * (precision * recall) / (precision + recall);
specificity = TN / (TN + FP);

% Display Results
fprintf('Precision: %.2f\n', precision);
fprintf('Recall (Sensitivity): %.2f\n', recall);
fprintf('F1-Score: %.2f\n', f1_score);
fprintf('Specificity: %.2f\n', specificity);

% % Compute AUC

predScores = predict(trainedNet, augmentedTest); % Get probabilities

% Ensure correct probability selection for positive class
if size(predScores, 2) > 1
    predScores = predScores(:, 2); % Select probability for class 1
end

[X, Y, ~, AUC] = perfcurve(actualNumeric, predScores, 1);
fprintf('AUC Value: %.2f\n', AUC);

% Plot Combined AUC Curve
figure;
plot(X, Y, 'b-', 'LineWidth', 2);
hold on;
plot([0 1], [0 1], 'k--'); % Diagonal line for random classifier
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title(['ROC Curve (AUC = ', num2str(AUC, '%.2f'), ')']);
legend('ROC Curve', 'Random Classifier', 'Location', 'southeast');
grid on;
hold off;



%%%%% necah wali line combine AUC ka lia hain 


% Compute AUC for Admission (Class 1)
[X_adm, Y_adm, ~, AUC_adm] = perfcurve(actualNumeric, predScores, 1);
fprintf('AUC for Admission: %.2f\n', AUC_adm);

% Compute AUC for Discharge (Class 0)
[X_dis, Y_dis, ~, AUC_dis] = perfcurve(actualNumeric, predScores, 0);
fprintf('AUC for Discharge: %.2f\n', AUC_dis);

% Plot ROC Curves for Both Classes
figure;
plot(X_adm, Y_adm, 'b-', 'LineWidth', 2); % Admission class (blue)
hold on;
plot(X_dis, Y_dis, 'r-', 'LineWidth', 2); % Discharge class (red)
plot([0 1], [0 1], 'k--'); % Random classifier

xlabel('False Positive Rate');
ylabel('True Positive Rate');
title(['ROC Curve (Admission AUC = ', num2str(AUC_adm, '%.2f'), ...
       ', Discharge AUC = ', num2str(AUC_dis, '%.2f'), ')']);
legend('Admission ROC', 'Discharge ROC', 'Random Classifier', 'Location', 'southeast');
grid on;
hold off;

