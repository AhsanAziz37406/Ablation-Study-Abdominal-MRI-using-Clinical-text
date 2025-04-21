admissionFolder = 'D:\abdominal xray\internal_all_age\Admission';
dischargeFolder = 'D:\abdominal xray\internal_all_age\Discharge';

% Get image filenames
admissionFiles = dir(fullfile(admissionFolder, '*.png'));
dischargeFiles = dir(fullfile(dischargeFolder, '*.png'));


% Extract IDs from filenames (assuming format: 8413_20211001_050318.png etc.)
getID = @(name) extractBefore(name, '_');
admissionIDs = unique(arrayfun(@(x) getID(x.name), admissionFiles, 'UniformOutput', false));
dischargeIDs = unique(arrayfun(@(x) getID(x.name), dischargeFiles, 'UniformOutput', false));


% Initialize with missing
clinicalTable.Class = repmat("unknown", height(clinicalTable), 1);

for i = 1:height(clinicalTable)
    idStr = string(clinicalTable.ID(i));
    
    if any(admissionIDs == idStr)
        clinicalTable.Class(i) = "admission";
    elseif any(dischargeIDs == idStr)
        clinicalTable.Class(i) = "discharge";
    end
end


