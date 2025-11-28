[b,a] = butter(3,0.2);
[h, w] = freqz(b,a);
plot(w/pi,abs(h))

scale_factor = 2^13; % 8192
b_fixed = round(b * scale_factor);
a_fixed = round(a(2:4) * scale_factor); % a1, a2, a3
x = [1 zeros(1,128)];
y = zeros(1,length(x));

reg_xnm1 = 0;
reg_xnm2 = 0;
reg_xnm3 = 0;
reg_ynm1 = 0;
reg_ynm2 = 0;
reg_ynm3 = 0;

for n = 1:length(x)
    y(n) = b(1)*x(n) + b(2)*reg_xnm1 + b(3)*reg_xnm2 + b(4)*reg_xnm3 - a(2)*reg_ynm1 - a(3)*reg_ynm2 - a(4)*reg_ynm3;

    reg_xnm3 = reg_xnm2;
    reg_xnm2 = reg_xnm1;
    reg_xnm1 = x(n);

    reg_ynm3 = reg_ynm2;
    reg_ynm2 = reg_ynm1;
    reg_ynm1 = y(n);
end

% figure;
% subplot(211)
% stem(x); ylim([-1 1]);
% 
% subplot(212)
% stem(y,'r'); ylim([-0.5 0.5]);