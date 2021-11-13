function skew = skew(x)

data = x(:);
l = length(data);
m = mean(data);
s = std(data);

if s == 0
    skew = Inf;
else
    skew = sum(((data-m)/s).^3)/l;
end