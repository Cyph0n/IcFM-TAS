function plotFFT(s, Fs)
    L = length(s);
    NFFT = 2^nextpow2(L);
    
    S = fft(s, NFFT)/L;
    S = 2*abs(S(1:NFFT/2+1));
    f = Fs/2 * linspace(0, 1, NFFT/2 + 1);
    
    plot(f, S)
end