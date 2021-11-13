function otf = CSF_cpi(up, len, ppd,d,w,x)
  % Waton's descriptive OTF
  % u = frequency c/image
  % d = diameter mm
  % w = wavelength nm
  
  u = up / (len/ppd);
  otf = CSF_cpd(u, d, w, x);
end
