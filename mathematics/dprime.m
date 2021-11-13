function [d, sigma]=dprime(response1,response2)
mu1=mean(response1);
mu2=mean(response2);
sigma1=std(response1);
sigma2=std(response2);
sigma = sqrt((sigma1.^2+sigma2.^2)/2);
d=abs(mu2-mu1)/sigma;
end