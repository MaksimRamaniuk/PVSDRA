clear; clc;

N = 9;
fraq = 7;
WIDTH = 9;

K = 1;
rom = zeros(N-1,1);
for i = 0:N-1
    rom(i+1) = atan(2^(-i));
    K = K * 1/(sqrt(1+2^(-2*i)));
end
Q = 2^(fraq);
K_q = round(K * Q);
rom_q = round(rom * Q);

fprintf('ROM:\n');
disp(rom_q.');
fprintf('K:\n');
disp(K_q.');

phi(1) = 2*pi/17;
phi(2) = pi/2;
phi_q = round(phi * Q);

fprintf('Phi:\n');
disp(phi_q.');

x = 0.5;
y = 0.5;
fprintf('Start point: (%.6f, %.6f)\n', x, y);

for i = 1:2
    R = [cos(phi(i)), -sin(phi(i));
         sin(phi(i)),  cos(phi(i))];
    p = [x; y];

    p_rot = R * p;

    fprintf('New point: (%.6f, %.6f)\n', p_rot(1), p_rot(2));
    x = p_rot(1);
    y = p_rot(2);
end

