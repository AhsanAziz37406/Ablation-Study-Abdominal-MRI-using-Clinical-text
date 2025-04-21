inputFolder = 'D:\abdominal xray\internal_all_age\Admission';
outputFolder = 'D:\abdominal xray\internal_all_age_Aug\Admission';

% Create the output folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Load admission images
imds = imageDatastore(inputFolder, ...
    'IncludeSubfolders', false, ...
    'FileExtensions', '.png', ...
    'LabelSource', 'foldernames');

% Number of existing and desired images
numOriginal = numel(imds.Files);
targetNum = 1800;
numToGenerate = targetNum - numOriginal;

% Copy original images to new folder
for i = 1:numOriginal
    [~, name, ext] = fileparts(imds.Files{i});
    newName = fullfile(outputFolder, [name ext]);
    copyfile(imds.Files{i}, newName);
end

% Set augmentation options
augmenter = imageDataAugmenter( ...
    'RandRotation', [-10 10], ...
    'RandXTranslation', [-5 5], ...
    'RandYTranslation', [-5 5], ...
    'RandXScale', [0.9 1.1], ...
    'RandYScale', [0.9 1.1], ...
    'RandXReflection', true);

% Read image size
sampleImage = readimage(imds,1);
imgSize = size(sampleImage);

% Create augmented image datastore
augimds = augmentedImageDatastore(imgSize(1:2), imds, ...
    'DataAugmentation', augmenter);

% Generate and save augmented images
counter = 1;
imageIdx = 1;

while counter <= numToGenerate
    % Reset the augimds if all images have been read
    if ~hasdata(augimds)
        reset(augimds);
    end
    
    % Read next augmented image
    data = read(augimds);
    img = data.input{1};  % Extract from cell

    % Get corresponding original image name
    idx = mod(imageIdx-1, numOriginal) + 1;
    [~, name, ext] = fileparts(imds.Files{idx});

    % Save with modified name
    newFilename = fullfile(outputFolder, sprintf('%s_aug%d%s', name, counter, ext));
    imwrite(img, newFilename);

    counter = counter + 1;
    imageIdx = imageIdx + 1;
end

disp('✅ Balanced dataset with augmented admission images created!');