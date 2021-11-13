%% timing
datestr(now)
start_time = clock;

%% simulation
simulation_name = mfilename;

%% load a prepared experiment (after manual cd)
% subject = '';
% load(['Experiment_', subject, '_patched.mat']);
% load(['Stimulus', subject, '_patched.mat']);

%% choose targets
targets = ["rc", "sine", "tri", "sqr", "rect"];
tar_size = 128;
targets_1p5_cpd = create_targets_lower_freq(tar_size);
rc = targets_1p5_cpd(:,:,1);
sine = targets_1p5_cpd(:,:,2);
tri = targets_1p5_cpd(:,:,3);
sqr = targets_1p5_cpd(:,:,4);
rect = targets_1p5_cpd(:,:,5);

%% choose backgrounds
ppd = 60;
img_size = 2 * tar_size;
pho_recep_scaling = 120 / ppd;
groups = ["images", "controls"];
n_background = 500;
sqrt_contrast_m = 2;
pre_controls = zeros(img_size, img_size, n_background, 2);
controls = zeros(pho_recep_scaling*img_size,pho_recep_scaling*img_size,n_background,2);
images = zeros(pho_recep_scaling*img_size,pho_recep_scaling*img_size,n_background,2);

%% uncertainty
ks= 120 * 0.083;
mask = crop_patch_mask(pho_recep_scaling*img_size, pho_recep_scaling*img_size, pho_recep_scaling*tar_size, pho_recep_scaling*tar_size, 'normal', ks);
  
for T=1:length(targets)
    target = targets(T);
    eval(target+'=imresize('+target+',pho_recep_scaling,''nearest'');');
end

%% choose TM methods
TMs = ["uncertainty_norm_template_matching", "uncertainty_norm_eye_template_matching"];
TMs_short = ["uRTM", "uEWTM"];
diameter = 4; % pupil size
w = 550; %wavelength

%% iteration
%data to save
d_t = 1;
max_iter = 10;

%% result boxes
amp_all = zeros(length(targets),length(groups),length(TMs),max_iter);
amp_all(:,:,:,1) = 50; % initial amplitude
d_all = zeros(length(targets),length(groups),length(TMs),2,max_iter);
threshold=zeros(length(groups)*length(TMs),length(targets));

%% choose backgrounds
disk = 'D:';
load([disk,'\pixel_space\ImgStats.mat']);
ImgStats.Settings.targetSizePix = img_size;
var_B = {[7,3,6],[6,6,7],[5,10,7],[6,10,5],[10,2,4],[9,6,4],[10,5,7],[9,9,3],[8,10,7]};
% var_B = {[1,7,4],[1,7,7],[1,10,3],[1,10,7],[7,3,6],[4,6,5],[6,6,7],[5,10,7],[6,10,5],[8,2,6],[10,2,4],[9,6,4],[10,5,7],[9,9,3],[8,10,7]};
sigmas = [343, 1372];
sigmas_w = [343, 1372];

%% iteration across var
for B = 1:length(var_B)
    item_B = var_B{B};
    if item_B(1) == 0
        bin_ids = [1:max(ImgStats.patchIndex{1}{10,10,6})];
    else
        bin_ids = ImgStats.patchIndex{1}{item_B(1),item_B(2),item_B(3)};
    end
    
    sampled_bin_ids1 = datasample(bin_ids, n_background);
    sampled_bin_ids2 = datasample(bin_ids, n_background);
    %% generate backgrounds
    for i=1:n_background
        [~,pre_controls(:,:,i,1)] = loadPatchAtIndex(ImgStats, sampled_bin_ids1(i), [disk,'\pixel_space']);
        [~,pre_controls(:,:,i,2)] = loadPatchAtIndex(ImgStats, sampled_bin_ids2(i), [disk,'\pixel_space']);
        controls(:,:,i,1)=imresize(pre_controls(:,:,i,1),pho_recep_scaling,'nearest');
        controls(:,:,i,2)=imresize(pre_controls(:,:,i,2),pho_recep_scaling,'nearest');
        images(:,:,i,1) = contrast_modulate(controls(:,:,i,1),sqrt_contrast_m);
        images(:,:,i,2) = contrast_modulate(controls(:,:,i,2),sqrt_contrast_m);
    end
    
    %% detectability computation
    for T=1:length(targets)
        target = targets(T);
        for G=1:length(groups)
            for M=1:length(TMs)
               for I=1:max_iter
                   eval('amp_'+target+'=amp_all(T,G,M,I)*'+target+';');
                   if M==1
                       appendix = ',mask,''dichotomy_bound'',sigmas';
                       r1 = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                   elseif M==2
                       appendix = ',mask,''dichotomy_bound'',sigmas_w,diameter,w';
                       r3 = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                   end

                   if M == 2
                        appendix = ', mask,''dichotomy_bound'',sigmas';
                        r1 = eval(TMs(1)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                        r2 = eval(TMs(1)+'(amp_'+target+','+groups(G)+',1'+appendix+');');
                        appendix = ',mask,''dichotomy_bound'',sigmas_w,diameter,w';

                        r4 = eval(TMs(M)+'(amp_'+target+','+groups(G)+',1'+appendix+');');
                        mu_1 = [mean(r1); mean(r3)]; mu_2 = [mean(r2); mean(r4)];
                        d = classify_normals([mu_1,cov(r1,r3)],[mu_2,cov(r2,r4)], 'plotmode', false).norm_dprime;
                        d_all(T,G,M,2,I) = sqrt((var(r1)^2+var(r3)^2+var(r2)^2+var(r4)^2)/2);
                   else
                       r2 = eval(TMs(M)+'(amp_'+target+','+groups(G)+',1'+appendix+');');
                       [d, d_all(T,G,M,2,I)] = dprime(r1,r2);
                   end

                   d_all(T,G,M,1,I) = d;

                   if I < max_iter
                       if mod(I,2)
                           amp_all(T,G,M,I+1) = amp_all(T,G,M,I) * d_t / d;
                       else
                           amp_all(T,G,M,I+1) = 0.5*amp_all(T,G,M,I)*(1 + d_t / d);
                       end
                   end
               end
               
               try
                    [f,a,b]=psychometric_uncertain_template_matching(squeeze(amp_all(T,G,M,:)),squeeze(d_all(T,G,M,1,:)));
                    threshold(length(TMs)*(G-1)+M,T) = log((1+b)*exp(1)-b)/a;
               catch
                    threshold(length(TMs)*(G-1)+M,T) = amp_all(T,G,M,max_iter)/d_all(T,G,M,1,max_iter);
               end
            end
        end
    end

    %% save results
    bin_name = num2str(item_B);
    bin_name = regexprep(bin_name, '  ', '_');
    save(['uncertain_eye_cm4_ni_b', bin_name,'.mat'],'amp_all', 'd_all', 'threshold');
    disp(bin_name);
end

%% end timing and display in hours
datestr(now)
end_time = clock;
etime(end_time, start_time) / 3600.0
