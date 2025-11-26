clear; clc;

Order = 6;          % Порядок фильтра
N = 12;     % Разрядность (Q1.11)

h = fir1(Order-1, 0.2);
fprintf('Коэффициенты FIR:\n');
disp(h);

h1 = h(1:3);
h2 = h(4:6);

rom1 = zeros(4,1);
rom2 = zeros(4,1);

for addr = 0:3
    bits = bitget(addr, [1 2]);
%     fprintf('Адрес: %d (%d %d) \n', addr, bits(2), bits(1));
    for i = 1:2
        if bits(i) == 1 
            bits(i) = -1;
        else
            bits(i) = 1;
        end
    end
    rom1(addr+1) = (-1/2)*(h1(1) + bits(2)*h1(2) + bits(1)*h1(3));
    rom2(addr+1) = (-1/2)*(h2(1) + bits(2)*h2(2) + bits(1)*h2(3));
end

Q = 2^(N-1);
rom1_q = round(rom1 * Q);
rom2_q = round(rom2 * Q);

fprintf('ROM1 (Q1.11):\n');
disp(rom1_q.');

fprintf('ROM2 (Q1.11):\n');
disp(rom2_q.');

x = zeros(1, 8);
x(1) = 1;
y = filter(h, 1, x);
fprintf('FIR matlab:\n');
disp(y);

% Q1_0 = -(h1(1)/2 + h1(2)/2 + h1(3)/2);
% fprintf('Q(0) for 1 table:\n');
% disp(Q1_0*(2^(N-1)));
% Q2_0 = -(h2(1)/2 + h2(2)/2 + h2(3)/2);
% fprintf('Q(0) for 2 table:\n');
% disp(Q2_0*(2^(N-1)));