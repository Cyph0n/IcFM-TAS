function [found, seq]=findFrame(data, frame_size, start_bits, stop_bits)
    d = frame_size - length(stop_bits);
    
    found = 0;
    i = 1;
    
    start = 1;
    stop = 1;
    
    seq = zeros(1, frame_size);
    
    while i <= length(data)
        if found == 0
            if (length(data) - (i-1)) < frame_size
                break;
            end
            
            if data(i:i+length(start_bits)-1) == start_bits
                found = 1;
                start = i;
            end
        end
        
        if found == 1 && i == (start + d)
            if data(i:i+length(stop_bits)-1) == stop_bits
                stop = i+length(stop_bits)-1;
                
                % Parity check
                num_ones = 0;
                frame = data(start:stop);
                
                for j=1:length(frame)
                    if frame(j) == 1
                        num_ones = num_ones + 1;
                    end
                end
                
                if frame(15) == mod(num_ones, 2)
                    disp(['Found at ', num2str(i)])
                    break;
                else
                    disp(['Rejected ', num2str(start)])
                    found = 0;
                end
            else
                i = start + 1;
                found = 0;
            end
        end
        
        i = i + 1;
    end
    
    if found
        seq = data(start:stop);
    end
end