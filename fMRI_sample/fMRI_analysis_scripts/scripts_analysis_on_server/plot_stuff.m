% plot ts or other stuff


data1 = importdata('/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/sub-0309/model/model015-ppi-model013_cope6_vmpfc/onsets/task-fribBids_run-01/model013_cope6_vmpfc_mean_ts.txt');
data2 = importdata('/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/sub-0309/model/model015-ppi-model013_cope6_vmpfc/onsets/task-fribBids_run-01/ppi_regressor_model013_cope6_vmpfc_ConStim.txt');
data3 = importdata('/export2/DATA/FRIB_FMRI/fmri_sample/derivatives/sub-0309/model/model015-ppi-model013_cope6_vmpfc/onsets/task-fribBids_run-01/ppi_regressor_model013_cope6_vmpfc_SumStim.txt');

data1_N = normalize(data1);
data2_N = normalize(data2);
data3_N = normalize(data3);

plot(data1_N)

hold on 

plot(data2_N)

hold on

plot(data3_N)