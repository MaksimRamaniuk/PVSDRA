clear; clc;

N = 6;          % Порядок фильтра
Order = 12;     % Разрядность (Q1.11)

h = fir1(N-1, 0.2);
fprintf('Коэффициенты FIR:\n');
disp(h);

h1 = h(1:3);
h2 = h(4:6);

rom1 = zeros(8,1);
rom2 = zeros(8,1);

for addr = 0:7
    bits = bitget(addr, [1 2 3]);
    for i = 1:3
        if bits(i) == 1 
            bits(i) = -1;
        else
            bits(i) = 1;
        end
    end
    rom1(addr+1) = (-1/2)*(bits(1)*h1(1) + bits(2)*h1(2) + bits(3)*h1(3));
    rom2(addr+1) = (-1/2)*(bits(1)*h2(1) + bits(2)*h2(2) + bits(3)*h2(3));
end

Q = 2^(Order-1);
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