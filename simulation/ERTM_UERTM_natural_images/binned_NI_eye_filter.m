%% timing
datestr(now)
start_time = clock;

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
groups = ["images", "controls"];
n_background = 1000;
sqrt_contrast_m=2;

disk = 'D:';
load([disk,'\pixel_space\ImgStats.mat']);
ImgStats.Settings.targetSizePix = tar_size;
var_B = {[1,7,4],[1,7,7],[1,10,3],[1,10,7],[7,3,6],[4,6,5],[6,6,7],[5,10,7],[6,10,5],[8,2,6],[10,2,4],[9,6,4],[10,5,7],[9,9,3],[8,10,7]};

controls = zeros(tar_size,tar_size,n_background,2);
images = zeros(tar_size,tar_size,n_background,2);

line_sigmas = zeros(length(groups),3,tar_size);

%% choose TM methods
TMs = ["direct_template_matching", "adaptX_white_template_matching", "norm_template_matching",...
    "norm_adaptX_white_template_matching", "eye_template_matching", "norm_eye_template_matching"];
TMs_short = ["TM", "WTM","RTM", "WRTM", "ETM", "ERTM"];
diameter = 4; % pupil size
w = 550; %wavelength

appendixes = ["", ",r_power", ",'dichotomy',sigmas", ",'dichotomy',sigmas_w,r_power", ",diameter, w", ",'dichotomy',sigmas_w,diameter,w"];

%% iteration
%data to save
d_t = 1;
max_err = 5e-4;
max_iter = 20;

%% result boxes
amp_all = zeros(length(targets),length(groups),length(TMs),max_iter);
amp_all(:,:,:,1) = 0.1; % initial amplitude
d_all = zeros(length(targets),length(groups),length(TMs),2,max_iter);
threshold=zeros(length(groups)*length(TMs),length(targets));

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
        [~,controls(:,:,i,1)] = loadPatchAtIndex(ImgStats, sampled_bin_ids1(i), [disk,'\pixel_space']);
        [~,controls(:,:,i,2)] = loadPatchAtIndex(ImgStats, sampled_bin_ids2(i), [disk,'\pixel_space']);
        images(:,:,i,1) = contrast_modulate(controls(:,:,i,1),sqrt_contrast_m);
        images(:,:,i,2) = contrast_modulate(controls(:,:,i,2),sqrt_contrast_m); 
    end
    
    r_power = evaluate_power(controls(:,:,:,1),1);
    
    %% detectability computation
    for T=1:length(targets)
        target = targets(T);
        for G=1:length(groups)
            for M=1:length(TMs)
                for I=1:max_iter-1
                    eval('amp_'+target+'=amp_all(T,G,M,I)*'+target+';');
                   if M==1
                       appendix = appendixes(M);
                       [r1,~,sigmas] = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                       line_sigmas(G,1,:)= sigmas;
                   elseif M==2
                       appendix = appendixes(M);
                       [r3,~,sigmas_w] = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                       line_sigmas(G,2,:)= sigmas_w;
                   elseif M==3
                       appendix = appendixes(M);
                       r1 = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                   elseif M==4 || M==6
                       appendix = appendixes(M);
                       r3 = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                   elseif M==5
                       appendix = appendixes(M);
                       [r3,~,sigmas_w] = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                       line_sigmas(G,3,:)= sigmas_w;
                   elseif M==6
                       appendix = appendixes(M);
                       r3 = eval(TMs(M)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                   end

                     if M ~= 1 && M ~= 3
                        if M == 2 || M == 5
                            appendix = appendixes(1);
                            r1 = eval(TMs(1)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                            r2 = eval(TMs(1)+'(amp_'+target+','+groups(G)+',1'+appendix+');');
                        elseif M == 4 || M == 6
                            appendix = appendixes(3);
                            r1 = eval(TMs(3)+'(amp_'+target+','+groups(G)+',0'+appendix+');');
                            r2 = eval(TMs(3)+'(amp_'+target+','+groups(G)+',1'+appendix+');');
                        end
                        appendix = appendixes(M);
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

                       if abs(d-d_t) <= max_err
                            break;
                       end
                 end
                 threshold(length(TMs)*(G-1)+M,T) = amp_all(T,G,M,I+1);
            end
        end
    end
%% save results
bin_name = num2str(item_B);
bin_name = regexprep(bin_name, '  ', '_');
save(['eye_cm4_ni_b', bin_name,'.mat'],'amp_all', 'd_all', 'threshold','line_sigmas');
disp(bin_name);

end

%% end timing and display in hours
datestr(now)
end_time = clock;
etime(end_time, start_time) / 3600.0
