% Assuming 'clinicalTable' is already loaded
admitIdx = strcmpi(clinicalTable.Class, 'admission');
dischargeIdx = strcmpi(clinicalTable.Class, 'discharge');

% Average values
avgSBP_admit = mean(clinicalTable.SBP(admitIdx), 'omitnan');
avgSBP_discharge = mean(clinicalTable.SBP(dischargeIdx), 'omitnan');

avgDBP_admit = mean(clinicalTable.DBP(admitIdx), 'omitnan');
avgDBP_discharge = mean(clinicalTable.DBP(dischargeIdx), 'omitnan');

avgHR_admit = mean(clinicalTable.HR(admitIdx), 'omitnan');
avgHR_discharge = mean(clinicalTable.HR(dischargeIdx), 'omitnan');

avgConsciousness_admit = mean(clinicalTable.Consciousness(admitIdx), 'omitnan');
avgConsciousness_discharge = mean(clinicalTable.Consciousness(dischargeIdx), 'omitnan');

avgRR_admit = mean(clinicalTable.RR(admitIdx), 'omitnan');
avgRR_discharge = mean(clinicalTable.RR(dischargeIdx), 'omitnan');

avgBT_admit = mean(clinicalTable.BT(admitIdx), 'omitnan');
avgBT_discharge = mean(clinicalTable.BT(dischargeIdx), 'omitnan');

% avgPulse_admit = mean(clinicalTable.HR(admitIdx), 'omitnan');
% avgPulse_discharge = mean(clinicalTable.HR(dischargeIdx), 'omitnan');

avgabdominal_symptoms_admit = mean(clinicalTable.abdominal_symptoms(admitIdx), 'omitnan');
avgabdominal_symptoms_discharge = mean(clinicalTable.abdominal_symptoms(dischargeIdx), 'omitnan');

% Cancer pattern
numCancer0_admit = sum(clinicalTable.Cancer_within_five_years == 0 & admitIdx);
numCancer0_discharge = sum(clinicalTable.Cancer_within_five_years == 0 & dischargeIdx);

% === Generate sentences ===
fprintf("Conclusion:\n");
if avgSBP_admit > avgSBP_discharge
    fprintf("- Higher SBP is observed in admitted patients (%.1f vs %.1f).\n", avgSBP_admit, avgSBP_discharge);
else
    fprintf("- Higher SBP is observed in discharged patients (%.1f vs %.1f).\n", avgSBP_discharge, avgSBP_admit);
end

if avgDBP_admit > avgDBP_discharge
    fprintf("- Higher DBP is observed in admitted patients (%.1f vs %.1f).\n", avgDBP_admit, avgDBP_discharge);
else
    fprintf("- Higher DBP is observed in discharged patients (%.1f vs %.1f).\n", avgDBP_discharge, avgDBP_admit);
end

if avgConsciousness_admit > avgConsciousness_discharge
    fprintf("- Higher Consciousness is observed in admitted patients (%.1f vs %.1f).\n", avgConsciousness_admit, avgConsciousness_discharge);
else
    fprintf("- Higher Consciousness is observed in discharged patients (%.1f vs %.1f).\n", avgConsciousness_discharge, avgConsciousness_admit);
end

if avgabdominal_symptoms_admit > avgabdominal_symptoms_discharge
    fprintf("- Higher abdominal_symptoms is observed in admitted patients (%.1f vs %.1f).\n", avgabdominal_symptoms_admit, avgabdominal_symptoms_discharge);
else
    fprintf("- Higher abdominal_symptoms is observed in discharged patients (%.1f vs %.1f).\n", avgabdominal_symptoms_discharge, avgabdominal_symptoms_admit);
end

if avgHR_admit > avgHR_discharge
    fprintf("- Higher HR is observed in admitted patients (%.1f vs %.1f).\n", avgHR_admit, avgHR_discharge);
else
    fprintf("- Higher HR is observed in discharged patients (%.1f vs %.1f).\n", avgHR_discharge, avgHR_admit);
end

if avgBT_admit > avgBT_discharge
    fprintf("- Higher BT is observed in admitted patients (%.1f vs %.1f).\n", avgBT_admit, avgBT_discharge);
else
    fprintf("- Higher BT is observed in discharged patients (%.1f vs %.1f).\n", avgBT_discharge, avgBT_admit);
end

if avgRR_admit > avgRR_discharge
    fprintf("- Higher RR is observed in admitted patients (%.1f vs %.1f).\n", avgRR_admit, avgRR_discharge);
else
    fprintf("- Higher RR is observed in discharged patients (%.1f vs %.1f).\n", avgRR_discharge, avgRR_admit);
end
if numCancer0_discharge > numCancer0_admit
    fprintf("- More patients with Cancer=0 are found in the Discharge group (%d vs %d).\n", numCancer0_discharge, numCancer0_admit);
else
    fprintf("- More patients with Cancer=0 are found in the Admission group (%d vs %d).\n", numCancer0_admit, numCancer0_discharge);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Separate admission and discharge
isAdmit = clinicalTable.Class == "admission";
isDischarge = clinicalTable.Class == "discharge";

% Compare SBP
fprintf("Average SBP (Admission): %.2f\n", mean(clinicalTable.SBP(isAdmit), 'omitnan'));
fprintf("Average SBP (Discharge): %.2f\n", mean(clinicalTable.SBP(isDischarge), 'omitnan'));

% Compare Cancer marker
fprintf("Patients with Cancer_within_five_years=0 in Discharge group: %d\n", sum(clinicalTable.Cancer_within_five_years==0 & isDischarge));
fprintf("Patients with Cancer_within_five_years=0 in Admission group: %d\n", sum(clinicalTable.Cancer_within_five_years==0 & isAdmit));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
boxplot([clinicalTable.SBP(isAdmit); clinicalTable.SBP(isDischarge)], ...
    [repmat("Admission", sum(isAdmit), 1); repmat("Discharge", sum(isDischarge), 1)]);
title("SBP Distribution by Class");
ylabel("SBP Value");

boxplot([clinicalTable.RR(isAdmit); clinicalTable.RR(isDischarge)], ...
    [repmat("Admission", sum(isAdmit), 1); repmat("Discharge", sum(isDischarge), 1)]);
title("RR Distribution by Class");
ylabel("RR Value");

boxplot([clinicalTable.HR(isAdmit); clinicalTable.HR(isDischarge)], ...
    [repmat("Admission", sum(isAdmit), 1); repmat("Discharge", sum(isDischarge), 1)]);
title("HR Distribution by Class");
ylabel("HR Value");

boxplot([clinicalTable.BT(isAdmit); clinicalTable.BT(isDischarge)], ...
    [repmat("Admission", sum(isAdmit), 1); repmat("Discharge", sum(isDischarge), 1)]);
title("BT Distribution by Class");
ylabel("BT Value");

boxplot([clinicalTable.DBP(isAdmit); clinicalTable.DBP(isDischarge)], ...
    [repmat("Admission", sum(isAdmit), 1); repmat("Discharge", sum(isDischarge), 1)]);
title("DBP Distribution by Class");
ylabel("DBP Value");

boxplot([clinicalTable.abdominal_symptoms(isAdmit); clinicalTable.abdominal_symptoms(isDischarge)], ...
    [repmat("Admission", sum(isAdmit), 1); repmat("Discharge", sum(isDischarge), 1)]);
title("abdominal symptoms Distribution by Class");
ylabel("abdominal_symptoms Value");

%%%%%%%%%%%%%%%%%%% cancer SEPERATE SEPERATE AVERAGE


isAdmit = clinicalTable.Class == "admission";
isDischarge = clinicalTable.Class == "discharge";

fprintf("Average SBP (Admission): %.2f\n", mean(clinicalTable.SBP(isAdmit), 'omitnan'));
fprintf("Average SBP (Discharge): %.2f\n", mean(clinicalTable.SBP(isDischarge), 'omitnan'));

fprintf("Patients with Cancer=0 in Discharge group: %d\n", ...
    sum(clinicalTable.Cancer_within_five_years(isDischarge) == 0));
fprintf("Patients with Cancer=0 in Admission group: %d\n", ...
    sum(clinicalTable.Cancer_within_five_years(isAdmit) == 0));
