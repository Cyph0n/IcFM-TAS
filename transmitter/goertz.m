function bits = goertz(data, target_freq, Fs, N, bit_count)
    k = floor(0.5 + (N * target_freq)/Fs);
    w = (2*pi/N) * k;
    cosine = cos(w);
    sine = sin(w);
    coeff = 2 * cosine
    
    mx = 0;
    mn = 65535;
    mag = zeros(1, bit_count);
    
    for i=1:bit_count
        % The meat of the algorithm
        q0 = 0;
        q1 = 0;
        q2 = 0;
        
        % Adjust portion of data to process depending on bit
        if i == 1
            bit_data = data(1:N);
        else
            bit_data = data((i-1)*N:i*N);
        end

        for j=1:N
            q0 = coeff * q1 - q2 + bit_data(j);
            q2 = q1;
            q1 = q0;
        end
        
        m_i = q1 * q1 + q2 * q2 - q1 * q2 * coeff;
        mag(i) = m_i;
        
        % Compute max and min on the fly
        if mag(i) > mx
            mx = mag(i);
        end
        
        if mag(i) < mn
            mn = mag(i);
        end
    end
    
    % Find suitable threshold dynamically
    threshold = (mx*0.75 + mn*2.5)/2;
    
    
    for i=1:bit_count
        if mag(i) > threshold
            bits(i) = 1;
        else
            bits(i) = 0;
        end
    end
    
    disp(['magnitudes: ', num2str(mag)])
end