% Define the source folder and the destination folders
sourceFolder = 'D:\abdominal xray\internal_all_age';
dischargeFolder = fullfile(sourceFolder, 'Discharge');
admissionFolder = fullfile(sourceFolder, 'Admission');

% Initialize arrays to hold age data
agesDischarged = [];
agesAdmitted = [];

% Extract age data from discharge folder
dischargeFiles = dir(fullfile(dischargeFolder, '*.png')); % Assuming images are in .png format
for i = 1:length(dischargeFiles)
    filename = dischargeFiles(i).name;
    parts = split(filename, '_');
    % Extract the age, which is the second to last part, then convert to number
    ageStr = parts{end-1};
    age = str2double(ageStr);
    agesDischarged = [agesDischarged; age];
end

% Extract age data from admission folder
admissionFiles = dir(fullfile(admissionFolder, '*.png'));
for i = 1:length(admissionFiles)
    filename = admissionFiles(i).name;
    parts = split(filename, '_');
    % Extract the age, which is the second to last part, then convert to number
    ageStr = parts{end-1};
    age = str2double(ageStr);
    agesAdmitted = [agesAdmitted; age];
end

% Plotting the age distributions
figure;
subplot(1,2,1);
histogram(agesDischarged, 'BinWidth', 5);
title('Age Distribution of Discharged Patients');
xlabel('Age');
ylabel('Count');

subplot(1,2,2);
histogram(agesAdmitted, 'BinWidth', 5);
title('Age Distribution of Admitted Patients');
xlabel('Age');
ylabel('Count');

% Display summary statistics
disp('Discharged Patients Age Summary:');
disp(['Mean Age: ', num2str(mean(agesDischarged))]);
disp(['Median Age: ', num2str(median(agesDischarged))]);
disp(['Standard Deviation: ', num2str(std(agesDischarged))]);

disp('Admitted Patients Age Summary:');
disp(['Mean Age: ', num2str(mean(agesAdmitted))]);
disp(['Median Age: ', num2str(median(agesAdmitted))]);
disp(['Standard Deviation: ', num2str(std(agesAdmitted))]);