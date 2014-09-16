Fs = 11025;
duration = 2;
bit_time = 10e-3;
voice_file = ['voice-', num2str(Fs), '.wav'];
out_file = ['out-', num2str(Fs)];
out_wav = [out_file, '.wav'];
out_wma = [out_file, '.wma'];
out_mp3 = [out_file, '.mp3'];
mark_freq = 5e3;
space_freq = 4e3;
samples_per_bit = floor(Fs * bit_time);
time_ratio = 2; % Ratio of mark time to zero time
data_amp = 0.2; % Amplitude of data
audio_amp = 2;

figure(1)

t = 0:1/Fs:duration-1/Fs;

% Frame outline (in bits):
% Start [4]-Speed [3]-Sign 1 [5]-Traffic [2]-Parity [1]-Stop [4]
data = [1,0,1,0,1,0,1,1,1,1,0,1,1,1,0,0,1,0,1];

% Load up audio files from current folder
a = audio_amp*audioread(voice_file);

subplot(321)
plot(t, a)
title('Audio Signal')
xlabel('Time (s)')
ylabel('Voltage')
grid on

% Plot the pure data signal
subplot(322)
plotData(data, bit_time)
title('Message Signal')
xlabel('Time (s)')
ylabel('Voltage')
grid on

% Encode 19 bits of data (our frame size) using FSK
[s, t] = makeFSK(data, duration, bit_time, mark_freq, space_freq, data_amp, time_ratio, Fs);

% p = audioplayer(s, Fs);
% playblocking(p)

subplot(323)
plot(t, s)
title('Message Signal (FSK)')
xlabel('Time (s)')
ylabel('Voltage')
grid on

mod = a' + s;

subplot(324)
plot(t, mod)
title('Modulated Signal (with noise)')
xlabel('Time (s)')
ylabel('Voltage')
grid on

% Plot FFT of modulated signal
subplot(325)
plotFFT(mod, Fs)
title('Spectrum')
xlabel('Frequency (Hz)')
ylabel('Voltage')
grid on

% Normalize vector to prevent clipping for audiowrite: -1 <= y < +1
% delta = 0.001;
% mod = mod / (max(abs(mod)) + delta);

% Determine which part of signal to decode
range = 111:12345;
sig = mod(range);
fsk = s(range);

% Test sampling 1 to 10 frame times
d = decodeMessage(sig, length(data), bit_time, mark_freq, space_freq, 0, 2, Fs);
[found, frame] = findFrame(d, length(data), [1,0,1,0], [0,1,0,1]);

% Test Goertzel algorithm
dg = goertz(sig, mark_freq, Fs, samples_per_bit, 38);
[fg, frame_g] = findFrame(dg, length(data), [1,0,1,0], [0,1,0,1]);

disp(['for mod: '])
disp([num2str(d)])
disp([num2str(dg)])

disp(['for just FSK: '])
disp([num2str(decodeMessage(fsk, length(data), bit_time, mark_freq, space_freq, 0, 1, Fs))])
disp([num2str(goertz(fsk, mark_freq, Fs, samples_per_bit, 19))])

disp([num2str(frame)])
disp([num2str(data)])
disp([num2str(frame_g)])

figure(1)

subplot(326)
plotData(frame_g, bit_time)
title('Decoded Data')
xlabel('Time (s)')
ylabel('Voltage')
grid on

% p = audioplayer(mod, Fs);
% playblocking(p)

% Normalize audio data
if max(mod) >= 1 || min(mod) < -1
    delta = 0.001;
    mod = mod/(max(abs(mod))+delta);
end

max(mod)
min(mod)

% Write to wav file
audiowrite(out_wav, mod, Fs, 'BitsPerSample', 16)

% Encode to WMA using ffmpeg
if strcmp(computer, 'MACI64')
    ffmpeg = '/usr/local/bin/ffmpeg';
else
    ffmpeg = '"bin/ffmpeg.exe"';
end

cmd = [ffmpeg, ' -y ', ' -i ', out_wav, ' -ar ', num2str(Fs), ' -acodec ', 'wmav1', ' ', out_wma];
[status, cmdout] = system(cmd);

% Write to MP3 file
mp3write(mod, Fs, 8, out_mp3, '-m m -h --cbr -b 64')

% Write plain FSK to audio; see if recovery easier
% mp3write(s, Fs, 8,['fsk-', num2str(Fs), '.mp3'], '-m m --cbr -b 64')