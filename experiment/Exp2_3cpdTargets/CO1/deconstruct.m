subject = 'CO1';
load(['Stimulus_',subject,'.mat']);
load(['Results_',subject,'.mat']);
load(['Experiment_',subject,'.mat']);
save(['vars_Stimulus_',subject,'.mat'], '-struct', 'Stimulus');
save(['vars_Results_',subject,'.mat'], '-struct', 'Results');
save(['vars_Experiments_',subject,'.mat'], '-struct', 'Experiment');