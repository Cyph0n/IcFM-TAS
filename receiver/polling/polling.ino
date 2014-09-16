#include "avr/delay.h"

#define COEFF -1.919       // Pre-calculated for 5 kHz mark frequency
#define N 110	           // Number of samples per bit - calculated for 11.025 kS/sec
#define BITS_NEEDED 19
#define START_IDX 4
#define STOP_IDX (BITS_NEEDED-START_IDX)
#define MIN_VOLTAGE 0.2
#define THRESHOLD_BITS 10
#define MAX_BITS 100

// For all but the last sample, the clock should be 64
// to increase accuracy. A delay of 4.828 us should be added
// after processing to maintain sampling frequency.

// Need prescaler of 8 for to get timing exact for
// the last sample (77.5625 us). A delay of 6.3905 us should be made.


// Used in Goertzel's algorithm
volatile float q0, q1, q2;
volatile float mag;
volatile float threshold;

// General
volatile unsigned char i, j;
volatile unsigned char done = 0;
volatile float sample;
volatile int val;
volatile unsigned int n = 0;
volatile unsigned char bits[BITS_NEEDED];

// Used to find valid frame
volatile const unsigned char seq[] = {1, 0, 1, 0, 0, 1, 0, 1};
volatile unsigned char v = 0;

void setup() {
    // AVcc source and left adjust
    ADMUX |= (1 << REFS0 | 1 << ADLAR);
  
    // Enable ADC
    ADCSRA |= (1 << ADEN);
  
    // Start the ADC
    ADCSRA |= (1 << ADSC);
    
    // Wait for first conversion to complete; 25 clocks
    while ((ADCSRA & (1 << ADSC)))
        ;
  
    Serial.begin(9600);
    
    // Write waiting message to LCD
    
}

void loop() {
    unsigned char non_zero = 0;
    
    // Keep sampling until "non-zero" sample encountered
    while (non_zero == 0) {
        ADCSRA |= (1 << ADSC);
        
        // 13 clocks
        while (ADCSRA & (1 << ADSC))
            ;
        
        val = (ADCL >> 6) | (ADCH << 2);
        sample = 5 * ((float)val / 1024);
        
        // 1/2 clock
        if (sample > MIN_VOLTAGE)
            non_zero = 1;
            
        Serial.println(sample);
    }
    
    float mn = 9999.0;
    float mx = 0.0;
    
    q0 = 0;
    q1 = 0;
    q2 = 0;
    
    // Read some bits to calculate suitable threshold
    for (i = 0; i < THRESHOLD_BITS; i++) {
//        Serial.println(micros());
        
        // Rest of samples (64 prescaler)
        ADCSRA |= (1 << ADPS2 | 1 << ADPS1);
        
        for (j = 0; j < (N-1); j++) {
            ADCSRA |= (1 << ADSC);
            
            while (ADCSRA & (1 << ADSC))
                ;
                
            val = (ADCL >> 6) | (ADCH << 2);
            sample = 5 * ((float)val / 1024);
            
            q0 = COEFF * q1 - q2 + sample;
            q2 = q1;
            q1 = q0;
            
            _delay_us(4.828);
        }
        
        // Last sample (8 prescaler)
        ADCSRA &= ~(1 << ADPS2);
        ADCSRA |= (1 << ADPS1 | 1 << ADPS0);
        ADCSRA |= (1 << ADSC);
            
        while (ADCSRA & (1 << ADSC))
            ;
            
        val = (ADCL >> 6) | (ADCH << 2);
        sample = 5 * ((float)val / 1024);
        
        q0 = COEFF * q1 - q2 + sample;
        q2 = q1;
        q1 = q0;
        
        _delay_us(6.3905);
        
        // Processing
        mag = q1 * q1 + q2 * q2 - q1 * q2 * COEFF;
        
        // Min and max
        if (mag < mn)
            mn = mag;
        if (mag > mx)
            mx = mag;
        
        // Reset filter values    
        q0 = 0;
        q1 = 0;
        q2 = 0;
    }
    
    Serial.println(micros());
    
    // Compute bit threshold
    threshold = (mx*0.1 + mn*1.5)/2;
    
    Serial.println("======");
    Serial.println(threshold);
    
    i = 0;
    q0 = 0;
    q1 = 0;
    q2 = 0;
    
    // Keep reading bits until sequence found
    while (i < BITS_NEEDED) {
//        Serial.println(micros());
        
        // Rest of samples (64 prescaler)
        ADCSRA |= (1 << ADPS2 | 1 << ADPS1);
        
        for (j = 0; j < (N-1); j++) {
            ADCSRA |= (1 << ADSC);
            
            while (ADCSRA & (1 << ADSC))
                ;
                
            val = (ADCL >> 6) | (ADCH << 2);
            sample = 5 * ((float)val / 1024);
            
            q0 = COEFF * q1 - q2 + sample;
            q2 = q1;
            q1 = q0;
            
            _delay_us(4.828);
        }
        
        // Last sample (8 prescaler)
        ADCSRA &= ~(1 << ADPS2);
        ADCSRA |= (1 << ADPS1 | 1 << ADPS0);
        ADCSRA |= (1 << ADSC);
            
        while (ADCSRA & (1 << ADSC))
            ;
            
        val = (ADCL >> 6) | (ADCH << 2);
        sample = 5 * ((float)val / 1024);
        
        q0 = COEFF * q1 - q2 + sample;
        q2 = q1;
        q1 = q0;
        
        _delay_us(6.3905);
        
        // Processing
        mag = q1 * q1 + q2 * q2 - q1 * q2 * COEFF;
    
        if (mag > threshold)
            bits[i] = 1;
        else
            bits[i] = 0;
        
        // Ensure validity of frame as you go; if invalid, start from scratch
        if (i < START_IDX) {
            if (bits[i] == seq[v])
                v++;
            else {
                i = -1;
                v = 0;
            }
        }
        
        else if (i >= STOP_IDX) {
            if (bits[i] == seq[v])
                v++;
            else {
                i = -1;
                v = 0;
            }
        }
        
        // Reset values for next bit
        q0 = 0;
        q1 = 0;
        q2 = 0;
        
        i++;
    }
    
    // Process frame and display signs on LCD
    
    // Delay for 3-5 s
    
    // Write waiting message to LCD
    
}
