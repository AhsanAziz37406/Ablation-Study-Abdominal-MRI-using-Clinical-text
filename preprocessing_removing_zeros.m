folderPath = 'D:\abdominal xray\internal_all_age\Discharge'; % Set your folder path
imageFiles = dir(fullfile(folderPath, '*.png')); % Change extension if needed

for i = 1:length(imageFiles)
    oldName = imageFiles(i).name;
    oldPath = fullfile(folderPath, oldName);
    
    % Find first non-zero character
    newName = regexprep(oldName, '^0+', '');
    
    newPath = fullfile(folderPath, newName);
    
    % Rename the file
    if ~strcmp(oldName, newName)
        movefile(oldPath, newPath);
        fprintf('Renamed: %s -> %s\n', oldName, newName);
    end
end
