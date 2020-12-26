function res = getRayleighv2(txNum, rxNum, Fs, Delay, Gain, maxDolpler, randSeed)
    for tx = 1:txNum
        for rx = 1:rxNum
            seed = randSeed(tx,rx);
            tempChan = comm.RayleighChannel(...
                'SampleRate',Fs, ...
                'PathDelays',Delay, ...
                'AveragePathGains',Gain, ...
                'NormalizePathGains',true, ...
                'MaximumDopplerShift',maxDolpler, ...
                'RandomStream','mt19937ar with seed', ...
                'Seed',seed, ...
                'PathGainsOutputPort',true);
            res(tx,rx) = {tempChan};
        end
    end
end