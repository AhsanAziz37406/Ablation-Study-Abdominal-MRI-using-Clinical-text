% Define the source folder and the destination folders
sourceFolder = 'D:\abdominal xray\internal_all_age';
dischargeFolder = fullfile(sourceFolder, 'Discharge');
admissionFolder = fullfile(sourceFolder, 'Admission');

% Create the discharge and admission folders if they don't exist
if ~exist(dischargeFolder, 'dir')
    mkdir(dischargeFolder);
end

if ~exist(admissionFolder, 'dir')
    mkdir(admissionFolder);
end

% Get the list of image files in the source folder
imageFiles = dir(fullfile(sourceFolder, '*.png')); % Assuming images are in .png format

% Loop through each file and move it to the corresponding folder
for i = 1:length(imageFiles)
    filename = imageFiles(i).name;
    if filename(end-4) == '0'
        movefile(fullfile(sourceFolder, filename), dischargeFolder);
    elseif filename(end-4) == '1'
        movefile(fullfile(sourceFolder, filename), admissionFolder);
    end
end
