function plotData(data, bit_time)
    t = 0:0.0001:(length(data)-1)*bit_time;
    x = zeros(1, length(t));
    
    stop_time = bit_time;
    c = 1;
    
    for i=1:length(t)
        if t(i) > stop_time
            c = c + 1;
            stop_time = stop_time + bit_time;
        end
        
        x(i) = data(c);
    end
    
    plot(t, x)
    grid on
end

