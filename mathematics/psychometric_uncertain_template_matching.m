function [dp_func, alpha, beta] = psychometric_uncertain_template_matching(amp, dp)
% Geisler, Wilson S. "Psychometric functions of uncertain template matching observers." Journal of vision 18.2 (2018): 1-1.
%
% Input:
% amp - the vector of target amplitude
% dp - the vector of d prime 
%
% Output:
% alpha, beta - parameters in the model
% func - the function handle of the model

myfittype = fittype('log((exp(a*x)+b)/(1+b))', 'dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});
dp_func = fit(amp, dp, myfittype, 'StartPoint', [1,1], 'Lower', [0,0]);

c=coeffvalues(dp_func);
alpha = c(1);
beta = c(2);

end