%% timing
datestr(now)
start_time = clock;

%% simulation
simulation_name = mfilename;

%% functions
gamma_correction = @(x, bit, gamma) (x./(2^bit-1)).^(1/gamma)*(2^bit-1);
gamma_amplification = @(x, bit, gamma) (x./(2^bit-1)).^gamma *(2^bit-1);

%% load a prepared experiment (after manual cd)
% subject = '';
% load(['Experiment_', subject, '_patched.mat']);
% load(['Stimulus', subject, '_patched.mat']);

%% choose targets
targets = ["sine", "tri", "sqr", "rect"];
tar_size = Stimulus.sideLength;
sine = Stimulus.targets(:,:,1) * Stimulus.bgMean;
tri = Stimulus.targets(:,:,2) * Stimulus.bgMean;
sqr = Stimulus.targets(:,:,3) * Stimulus.bgMean;
rect = Stimulus.targets(:,:,4) * Stimulus.bgMean;

%% choose backgrounds
ppd = Stimulus.ppd;
img_size = Stimulus.totalPx;
can_size = Stimulus.scenePx;
pho_recep_scaling = 120 / ppd;
groups = ["images", "controls"];
n_background = 2000;
background_lumi = Stimulus.bgMean;
background_std = Stimulus.bgContrast * Stimulus.bgMean;
sqrt_contrast_m = Stimulus.sqrtContrast_m;
pre_controls = zeros(img_size, img_size, n_background, 2);
controls = zeros(pho_recep_scaling*img_size,pho_recep_scaling*img_size,n_background,2);
images = zeros(pho_recep_scaling*img_size,pho_recep_scaling*img_size,n_background,2);
two_sigmas = zeros(length(groups),2,2);

%% uncertainty
ks= 120 * 0.083;
mask = crop_patch_mask(pho_recep_scaling*img_size, pho_recep_scaling*img_size, pho_recep_scaling*tar_size, pho_recep_scaling*tar_size, 'normal', ks);
  
for T=1:length(targets)
    target = targets(T);
    eval(target+'=imresize('+target+',pho_recep_scaling,''nearest'');');
end

%% choose TM methods
TMs = ["uncertainty_direct_template_matching", "uncertainty_eye_template_matching",...
    "uncertainty_norm_template_matching", "uncertainty_norm_eye_template_matching"];
TMs_short = ["uTM", "uETM","uRTM", "uEWTM"];
diameter = 4; % pupil size
w = 550; %wavelength

%% iteration
%data to save
d_t = 1;
max_iter = 10;

%% result boxes
amp_all = zeros(length(targets),length(groups),length(TMs),max_iter);
amp_all(:,:,:,1) = 0.01; % initial amplitude
d_all = zeros(length(targets),length(groups),length(TMs),2,max_iter);
threshold=zeros(length(groups)*length(TMs),length(targets));

%% generate backgrounds
pre_controls(:,:,:,1) = create_power_noise_sample_field(img_size,img_size, can_size,can_size,...
    n_background, 1, background_lumi, background_std);
pre_controls(:,:,:,2) = create_power_noise_sample_field(img_size,img_size, can_size,can_size,...
    n_background, 1, background_lumi, background_std);
for i=1:n_background          
    controls(:,:,i,1)=imresize(pre_controls(:,:,i,1),pho_recep_scaling,'nearest');
    controls(:,:,i,2)=imresize(pre_controls(:,:,i,2),pho_recep_scaling,'nearest');
    images(:,:,i,1) = contrast_modulate(controls(:,:,i,1),sqrt_contrast_m);
    images(:,:,i,2) = contrast_modulate(controls(:,:,i,2),sqrt_contrast_m);
end

controls_gc = gamma_correction(controls, Experiment.monitorBit, Experiment.monitorGamma);
controls_gc = round(controls_gc);
controls_gc(controls_gc > 2^Experiment.monitorBit-1) = 2^Experiment.monitorBit-1;
controls_gc(imag(controls_gc)~=0) = real(controls_gc(imag(controls_gc)~=0));
controls = gamma_amplification(controls_gc, Experiment.monitorBit, Experiment.monitorGamma);

images_gc = gamma_correction(images, Experiment.monitorBit, Experiment.monitorGamma);
images_gc = round(images_gc);
images_gc(images_gc > 2^Experiment.monitorBit-1) = 2^Experiment.monitorBit-1;
images_gc(imag(images_gc)~=0) = real(images_gc(imag(images_gc)~=0));
images = gamma_amplification(images_gc, Experiment.monitorBit, Experiment.monitorGamma);

r_power = 1;

%% detectability computation
for T=1:length(targets)
    target = targets(T);
    for G=1:length(groups)
        for M=1:length(TMs)
           for I=1:max_iter
               eval('amp_'+target+'=amp_all(T,G,M,I)*'+target+';');
               if M==1
                   appendix = ',mask';
                   [r1,sigmas,~] = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                   two_sigmas(G,1,:)= sigmas;
               elseif M==2
                   appendix = ',mask,diameter,w';
                   [r3,sigmas_w,~] = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                   two_sigmas(G,2,:)= sigmas_w;
               elseif M==3
                   appendix = ',mask,''dichotomy_bound'',sigmas';
                   r1 = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
               elseif M==4
                   appendix = ',mask,''dichotomy_bound'',sigmas_w,diameter,w';
                   r3 = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
              end
               
              if M == 2 || M == 4
                    if M == 2
                        appendix = ', mask';
                        r1 = eval(TMs(M-1)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                        r2 = eval(TMs(M-1)+'(amp_'+target+','+groups(G)+',1'+appendix+');');
                        appendix = ',mask,diameter,w';
                    elseif M == 4
                        appendix = ', mask,''dichotomy_bound'',sigmas';
                        r1 = eval(TMs(M-1)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                        r2 = eval(TMs(M-1)+'(amp_'+target+','+groups(G)+',1'+appendix+');');
                        appendix = ',mask,''dichotomy_bound'',sigmas_w,diameter,w';
                    end
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

           [f,a,b]=psychometric_uncertain_template_matching(squeeze(amp_all(T,G,M,:)),squeeze(d_all(T,G,M,1,:)));
           threshold(length(TMs)*(G-1)+M,T) = log((1+b)*exp(1)-b)/a;

        end
    end
    disp(T);
end

%% save results
save([simulation_name,'.mat'],'amp_all', 'd_all', 'threshold','r_power', 'two_sigmas');

%% end timing and display in hours
datestr(now)
end_time = clock;
etime(end_time, start_time) / 3600.0

%% plot results
load([simulation_name,'.mat']);
db_threshold_plot(mag2db(threshold),groups,TMs_short,targets,...
    simulation_name);
