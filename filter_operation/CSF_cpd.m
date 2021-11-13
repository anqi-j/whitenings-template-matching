function csf = CSF_cpd(u,d,w,x)
  % CSF based on Watson's descriptive OTF
  % x(1) = a   surround strength
  % x(2) = b   surround size
  % x(3) = n   surround shape exponent
  % x(4) = c   center size
  % u = frequency c/deg
  % d = diameter mm
  % w = wavelength nm
  
  a = x(1); b = x(2); n = x(3); c = x(4);
  u0 = d*pi()*10^6/(w*180);
  uh = u/u0;
  D = (acos(uh) - uh.*sqrt(1-uh.^2))*2/pi();
  u1 = 21.95 - 5.512*d + 0.3922*d^2;
  otf = sqrt(D).*(1 + (u/u1).^2).^-0.62;  % Watson OTF
  csf = otf.*(1-a*exp(-b*u.^n)).*exp(-c*u); % CSF
end

