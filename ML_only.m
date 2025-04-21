%%%%%%%% used Histogram of Oriented Gradients for feature extraction


% Set dataset path
datasetPath = 'D:\abdominal xray\internal_all_age_Aug';

% Load images
imds = imageDatastore(datasetPath, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames'); % Folder names used as labels

% Split into training (80%) and testing (20%)
[trainImgs, testImgs] = splitEachLabel(imds, 0.8, 'randomized');

% Feature Extraction Using HOG (Histogram of Oriented Gradients)
trainFeatures = [];
testFeatures = [];

for i = 1:numel(trainImgs.Files)
    img = imread(trainImgs.Files{i});
    img = imresize(img, [128 128]); % Resize for consistency
    if size(img,3) == 3
        img = rgb2gray(img); % Convert to grayscale
    end
    features = extractHOGFeatures(img); % Extract HOG features
    trainFeatures = [trainFeatures; features]; % Store features
end

for i = 1:numel(testImgs.Files)
    img = imread(testImgs.Files{i});
    img = imresize(img, [128 128]);
    if size(img,3) == 3
        img = rgb2gray(img);
    end
    features = extractHOGFeatures(img);
    testFeatures = [testFeatures; features];
end

% Get labels
trainLabels = trainImgs.Labels;
testLabels = testImgs.Labels;

% Train SVM Classifier
svmModel = fitcsvm(trainFeatures, trainLabels, 'KernelFunction', 'linear', 'Standardize', true);

% Test the SVM Model
predictions = predict(svmModel, testFeatures);

% Compute Accuracy
accuracy = sum(predictions == testLabels) / numel(testLabels);
fprintf('SVM Test Accuracy: %.2f%%\n', accuracy * 100);


% Compute AUC for Admission (Class 1)
actualNumeric = double(testLabels) - 1; % Convert categorical to numeric (0 or 1)
predictedNumeric = double(predictions) - 1;
[X_adm, Y_adm, ~, AUC_adm] = perfcurve(actualNumeric, predictedNumeric, 1);
fprintf('AUC for Admission: %.2f\n', AUC_adm);

% Confusion Matrix
figure;
confusionchart(testLabels, predictions);
title('Confusion Matrix - SVM with HOG');

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
fprintf('F1-Score: %.4f\n', f1_score);
fprintf('Specificity: %.2f\n', specificity);

% Compute AUC for Discharge (Class 0)
[X_dis, Y_dis, ~, AUC_dis] = perfcurve(actualNumeric, predictedNumeric, 0);
fprintf('AUC for Discharge: %.2f\n', AUC_dis);

% % Plot Combined AUC Curve
figure;
plot(X_adm, Y_adm, 'b-', 'LineWidth', 2);
hold on;
plot([0 1], [0 1], 'k--'); % Diagonal line for random classifier
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title(['ROC Curve (AUC = ', num2str(AUC_adm, '%.2f'), ')']);
legend('ROC Curve', 'Random Classifier', 'Location', 'southeast');
grid on;
hold off;

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



%%%%%%%%%%%% 

% Extract GLCM Features
trainFeatures = [];
testFeatures = [];

for i = 1:numel(trainImgs.Files)
    img = imread(trainImgs.Files{i});
    img = imresize(img, [128 128]);
    if size(img,3) == 3
        img = rgb2gray(img);
    end
    glcm = graycomatrix(img); % Compute GLCM
    stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
    features = [stats.Contrast, stats.Correlation, stats.Energy, stats.Homogeneity];
    trainFeatures = [trainFeatures; features];
end

for i = 1:numel(testImgs.Files)
    img = imread(testImgs.Files{i});
    img = imresize(img, [128 128]);
    if size(img,3) == 3
        img = rgb2gray(img);
    end
    glcm = graycomatrix(img);
    stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
    features = [stats.Contrast, stats.Correlation, stats.Energy, stats.Homogeneity];
    testFeatures = [testFeatures; features];
end

% Train and Test SVM
svmModel = fitcsvm(trainFeatures, trainLabels, 'KernelFunction', 'linear', 'Standardize', true);
predictions = predict(svmModel, testFeatures);

% Accuracy & Confusion Matrix
accuracy = sum(predictions == testLabels) / numel(testLabels);
fprintf('SVM Test Accuracy (GLCM): %.2f%%\n', accuracy * 100);
figure;
confusionchart(testLabels, predictions);
title('Confusion Matrix - GLCM + SVM');

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
fprintf('F1-Score: %.4f\n', f1_score);
fprintf('Specificity: %.2f\n', specificity);







%%%%%%%% neecha wala resenet50 ko use kar ka features nikal raha ha or us
%%%%%%%% ka bad siraf ML laga raha ha

% % Set dataset path
% datasetPath = 'D:\abdominal xray\internal_all_age';
% 
% % Load images
% imds = imageDatastore(datasetPath, ...
%     'IncludeSubfolders', true, ...
%     'LabelSource', 'foldernames'); % Folder names used as labels
% 
% % Split into training (80%) and testing (20%)
% [trainImgs, testImgs] = splitEachLabel(imds, 0.8, 'randomized');
% 
% % Load ResNet50 Model (for feature extraction)
% net = resnet50;
% inputSize = net.Layers(1).InputSize;
% 
% % Preprocessing: Convert grayscale images to RGB
% augmentedTrain = augmentedImageDatastore(inputSize(1:2), trainImgs, ...
%     'ColorPreprocessing', 'gray2rgb');
% augmentedTest = augmentedImageDatastore(inputSize(1:2), testImgs, ...
%     'ColorPreprocessing', 'gray2rgb');
% 
% % Extract Features Using ResNet50 (Remove last layers)
% featureLayer = 'fc1000'; % Use last fully connected layer
% trainFeatures = activations(net, augmentedTrain, featureLayer, 'OutputAs', 'rows');
% testFeatures = activations(net, augmentedTest, featureLayer, 'OutputAs', 'rows');
% 
% % Get labels
% trainLabels = trainImgs.Labels;
% testLabels = testImgs.Labels;
% 
% % Train SVM Classifier
% svmModel = fitcsvm(trainFeatures, trainLabels, 'KernelFunction', 'linear', 'Standardize', true);
% 
% % Test the SVM Model
% predictions = predict(svmModel, testFeatures);
% 
% % Compute Accuracy
% accuracy = sum(predictions == testLabels) / numel(testLabels);
% fprintf('SVM Test Accuracy: %.2f%%\n', accuracy * 100);
% 
% % Confusion Matrix
% figure;
% confusionchart(testLabels, predictions);
% title('Confusion Matrix - SVM');
% 
% confMat = confusionmat(actualNumeric, predictedNumeric);
% TP = confMat(2,2);
% FP = confMat(1,2);
% TN = confMat(1,1);
% FN = confMat(2,1);
% 
% % Compute Metrics
% precision = TP / (TP + FP);
% recall = TP / (TP + FN);
% f1_score = 2 * (precision * recall) / (precision + recall);
% specificity = TN / (TN + FP);
% 
% % Display Results
% fprintf('Precision: %.2f\n', precision);
% fprintf('Recall (Sensitivity): %.2f\n', recall);
% fprintf('F1-Score: %.4f\n', f1_score);
% fprintf('Specificity: %.2f\n', specificity);
% 
% 
% % Convert Labels for AUC Calculation
% actualNumeric = double(testLabels) - 1; % Convert categorical to numeric (0 or 1)
% predictedNumeric = double(predictions) - 1;
% 
% % Compute AUC for Admission (Class 1)
% [X_adm, Y_adm, ~, AUC_adm] = perfcurve(actualNumeric, predictedNumeric, 1);
% fprintf('AUC for Admission: %.2f\n', AUC_adm);
% 
% % Compute AUC for Discharge (Class 0)
% [X_dis, Y_dis, ~, AUC_dis] = perfcurve(actualNumeric, predictedNumeric, 0);
% fprintf('AUC for Discharge: %.2f\n', AUC_dis);
% 
% % Plot Combined AUC Curve
% figure;
% plot(X_adm, Y_adm, 'b-', 'LineWidth', 2);
% hold on;
% plot([0 1], [0 1], 'k--'); % Diagonal line for random classifier
% xlabel('False Positive Rate');
% ylabel('True Positive Rate');
% title(['ROC Curve (AUC = ', num2str(AUC_adm, '%.2f'), ')']);
% legend('ROC Curve', 'Random Classifier', 'Location', 'southeast');
% grid on;
% hold off;
% 
% % Plot ROC Curves for Both Classes
% figure;
% plot(X_adm, Y_adm, 'b-', 'LineWidth', 2); % Admission class (blue)
% hold on;
% plot(X_dis, Y_dis, 'r-', 'LineWidth', 2); % Discharge class (red)
% plot([0 1], [0 1], 'k--'); % Random classifier
% 
% xlabel('False Positive Rate');
% ylabel('True Positive Rate');
% title(['ROC Curve (Admission AUC = ', num2str(AUC_adm, '%.2f'), ...
%        ', Discharge AUC = ', num2str(AUC_dis, '%.2f'), ')']);
% legend('Admission ROC', 'Discharge ROC', 'Random Classifier', 'Location', 'southeast');
% grid on;
% hold off;
