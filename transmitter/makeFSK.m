function [s, t] = makeFSK(data, duration, el_length, mark_freq, space_freq, data_amp, time_ratio, Fs)
    dt = 1/Fs;
    t = 0:dt:duration-dt;
    T = length(t);
    
    % Mark and space carriers
    mc = data_amp*sin(2*pi*mark_freq*t);
    sc = data_amp*sin(2*pi*space_freq*t);
    
    b = 1; % Current bit in data sequence
    stop_time = el_length;
    
    s = zeros(1, T);
    
    for i=1:T
        if t(i) > stop_time
            stop_time = stop_time + el_length;
            
            if b < length(data)
                b = b + 1;
            else
                b = 1;
            end
        end
        
        % Half of time mark, rest 0
        if t(i) <= (stop_time - el_length/time_ratio)
            if data(b) == 0
                s(i) = sc(i);
            else
                s(i) = mc(i);
            end
        end
    end
end