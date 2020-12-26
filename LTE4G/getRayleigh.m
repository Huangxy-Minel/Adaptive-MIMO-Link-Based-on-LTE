function res = getRayleigh(txNum, rxNum, randSeed, Fs, Delay, Gain, maxDolpler, InitialTime)
    res=[]
    for tx = 1:txNum
        for rx = 1:rxNum
            rng(i+j);
            chan = rayleighchan(1/Fs, maxDolpler, Delay, Gain);
            chan.StorePathGains = 1;
            chan.ResetBeforeFiltering = 0;
            chanlist = [chanlist;chan];
            res = [res;tempChan];
        end
    end
end