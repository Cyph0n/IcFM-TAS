function data=decodeMessage(sig, nBits, el_length, mark_freq, space_freq, limits, n, Fs)
    duration = length(sig)/Fs;
    dt = 1/Fs;
    t = 0:dt:duration-dt;
    
    if limits
        t = t(limits(1):limits(2));
        sig = sig(limits(1):limits(2));
    end
    
    T = length(t);
    
    stop_time = el_length + t(1);
    start_idx = 1;
    c = 1; % Bit tracker
    
    data = zeros(1, nBits*n);
    
%     figure(2)
    
    for i=1:T
        % Stop after decoding nBits*n i.e. n "frames"
        if c > nBits*n
            break;
        end

        % If bit duration exceeded
        if t(i) > stop_time
            % Get time domain info for current bit
            b = sig(start_idx:i-1);
            L = length(b);
            
            % Compute FFT for bit
            NFFT = 2^nextpow2(L);
            
            B = fft(b, NFFT)/L;
            B = 2*abs(B(1:NFFT/2+1));
            f = Fs/2 * linspace(0,1,NFFT/2+1);
            f_div = f(2)-f(1);
            
            %%% debug
%             mid = ceil(length(f)/2);
%             
%             subplot(8,6,c)
%             plot(f(mid:end), B(mid:end))
            
            %%% end debug
            
            % Maximum magnitudes in spectrum
%             s = sort(B, 'descend');
%             m = s(1:5);
            
%             disp(['2*f_div = ', num2str(2*f_div), ' c = ', num2str(c), ' idx = ', num2str(i)])
            
            % Coherent detection of bit
%             for j=1:length(B)
%                 % If current mag is one of maximum selected
%                 if any(m == B(j))
%                     %%%% debug
%                     disp([num2str(B(j)), ' ', num2str(f(j))])
%                     
%                     if abs(f(j)-mark_freq) <= 2*f_div
%                         disp(['abs(f_mark) = ', num2str(abs(f(j)-mark_freq))])
%                         found = 1;
%                         break;
%                     elseif abs(f(j)-space_freq) <= 2*f_div
%                         disp(['abs(f_space) = ', num2str(abs(f(j)-space_freq))])
%                         data(c) = 0;
%                         break;
%                     end
%                 end
%             end

%             mag = zeros(1, 2);
%             exact = zeros(1, 2);
% 
%             for j=1:length(B)
%                 if abs(f(j)-mark_freq) <= f_div/4 && exact(1) == 0
%                     disp(['f_mark = ', num2str(f(j))])
%                     mag(1) = B(j);
%                     
%                     if f(j) == mark_freq
%                         exact(1) = 1;
%                     end
%                 elseif abs(f(j)-space_freq) <= f_div/4 && exact(2) == 0
%                     disp(['f_space = ', num2str(f(j))])
%                     mag(2) = B(j);
%                     
%                     if f(j) == space_freq
%                         exact(2) = 1;
%                     end
%                 end
%             end
%             
%             disp(['Found: ', num2str(mag(1)), ', ', num2str(mag(2))])
%             
%             if mag(1) > mag(2)
%                 data(c) = 1;
%             else
%                 data(c) = 0;
%             end
            
            mark_idx = round(mark_freq / f_div);
            space_idx = round(space_freq / f_div);
            
            if B(mark_idx) > B(space_idx)
                data(c) = 1;
            else
                data(c) = 0;
            end

            c = c + 1;
            stop_time = stop_time + el_length;
            start_idx = i;
        end
    end
end