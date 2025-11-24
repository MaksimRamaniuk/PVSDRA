fileID = fopen('y_out.hex', 'r');
data_hex = textscan(fileID, '%s');
fclose(fileID);

data_dec = hex2dec(data_hex{1});

N = 15; 
data_dec(data_dec >= 2^(N-1)) = data_dec(data_dec >= 2^(N-1)) - 2^N;

sound_new = double(data_dec) / 2^13;

[sound_old, fs] = audioread('sh_sound.wav');

sound_old = sound_old(:,1);
sound_new = sound_new(:);

audiowrite('sh_filtered.wav', sound_new, fs);

%%
[b,a] = butter(3,0.2);
[h, w] = freqz(b,a);

y = zeros(1,length(sound_old));

reg_xnm1 = 0;
reg_xnm2 = 0;
reg_xnm3 = 0;
reg_ynm1 = 0;
reg_ynm2 = 0;
reg_ynm3 = 0;

for n = 1:length(sound_old)
    y(n) = b(1)*sound_old(n) + b(2)*reg_xnm1 + b(3)*reg_xnm2 + b(4)*reg_xnm3 - a(2)*reg_ynm1 - a(3)*reg_ynm2 - a(4)*reg_ynm3;

    reg_xnm3 = reg_xnm2;
    reg_xnm2 = reg_xnm1;
    reg_xnm1 = sound_old(n);

    reg_ynm3 = reg_ynm2;
    reg_ynm2 = reg_ynm1;
    reg_ynm1 = y(n);
    
end
a0 = 1;
y =y*a0; 

%%
nfft = 512;
window = hamming(nfft);

figure;
subplot(1,3,1);
specgram(sound_old, nfft, fs, window, 475);
set(gca, 'Clim', [-65 15]);
xlabel('Время, с');
ylabel('Частота, Гц');
title('Исходный сигнал');
colorbar;

subplot(1,3,2);
specgram(sound_new, nfft, fs, window, 475);
set(gca, 'Clim', [-65 15]);
xlabel('Время, с');
ylabel('Частота, Гц');
title('Результат фильтра (VHDL)');
colorbar;

subplot(1,3,3);
specgram(y, nfft, fs, window, 475);
set(gca, 'Clim', [-65 15]);
xlabel('Время, с');
ylabel('Частота, Гц');
title('Результат фильтра (matlab)');
colorbar;

mse=0;
for n = 1:length(y)
    mse=mse + (y(n)^2 - sound_new(n)^2);    
end
mse = mse/length(y);


figure;
subplot(1,3,1);
t_old = (0:length(sound_old)-1) / fs;
plot(t_old, sound_old);
title('Исходный сигнал');
xlabel('Время, с');
ylabel('Амплитуда');
grid on;

subplot(1,3,2);
t_new = (0:length(sound_new)-1) / fs;
plot(t_new, sound_new);
title('Результат фильтра (VHDL)');
xlabel('Время, с');
grid on;

subplot(1,3,3);
plot(t_new, y);
title('Результат фильтра (matlab)');
xlabel('Время, с');
ylabel('Амплитуда');
grid on;
