import numpy as np
from scipy.signal import argrelextrema

righeFile = []
voci = []
x0 = 0
def optimizeData(data, n):
    if len(data) <= n:
        return np.arange(len(data)) # restituisce tutti gli indici se i dati sono meno o uguali a n
    
    optimized = []
    parts = []
    part_len = len(data) // n
    optimized.append(0)
    optimized.append(len(data)-1)
    for i in range(0,n):
        if i == n-1:
            parts.append(data[i*part_len:])
        else :
            parts.append(data[i*part_len:(i+1)*part_len])   
    for j in range(len(parts)):
        argMax = np.argmax(np.array(parts[j])) + j*part_len
        argMin = np.argmin(np.array(parts[j])) + j*part_len
        optimized.append(int(argMax))
        optimized.append(int(argMin))   
    optimized =list(set(optimized))
    optimized = np.sort(np.array(optimized))
    return optimized
# print(optimizeData(amp, 5)) 
# print(amp)

voci = []
divisions = 5

with open('prova_peto06.txt', 'r', encoding='utf-8') as f:
    righeFile = f.readlines()
    for i in range(4, len(righeFile), 2):
        riga = righeFile[i].strip()

# se la riga ha SOLO 4 numeri è header partial
        if len(riga.split()) == 4:

            header = riga.split()
            # print(header)
            partial_id = int(header[0])
            n_points = int(header[1])
            x0 = float(header[2])
            x1 = float(header[3])
            totDur = x1 - x0
            dur = []
            freq = []
            amp = []

            dati = righeFile[i + 1].split()
        
            for j in range(n_points):
                t = float(dati[j * 3])
                f0 = float(dati[j * 3 + 1])
                a0 = float(dati[j * 3 + 2])

                dur.append(t - x0)
                freq.append(f0)
                amp.append(a0)

            optAmpIdx = optimizeData(amp, divisions)
            optFreqIdx = optimizeData(freq, divisions)
            optAmp = np.array(amp)[optAmpIdx]
            optFreq = np.array(freq)[optFreqIdx]
            if totDur == 0:
                optAmpPos  = np.zeros(len(optAmp))
                optFreqPos = np.zeros(len(optFreq))
            else:
                optAmpPos  = np.array(dur)[optAmpIdx] / totDur
                optFreqPos = np.array(dur)[optFreqIdx] / totDur

            matFreq = np.vstack((optFreq, optFreqPos)).T
            matAmp = np.vstack((optAmp, optAmpPos)).T
            voci.append([x0, totDur, matFreq.tolist(), matAmp.tolist()])

print(str(voci).replace(",", ""))
