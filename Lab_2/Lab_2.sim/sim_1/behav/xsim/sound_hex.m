[sound, fs] = audioread('sh_sound.wav') ;

h_q13 = round(sound * 2^13);
h_q13 = min(max(h_q13, -2^13), 2^13-1);
fid = fopen('sh_sound.hex', 'w');
for i = 1:length(h_q13)
     val = mod(h_q13(i), 2^15);
     fprintf(fid, '%04x\n', val);
end
fclose(fid);
