function [features] = getMFCC_stat(aIn,fs,nCoef,E_th)
%GETMFCC_STAT MFCC feature mean & covariance matrix extraction from audio.
%   Some details here

    %% Get entire MFCC data
    [coef,nVoiced] = getMFCC(aIn,fs,nCoef,E_th);
    covM_triu = (1:nCoef) >= (1:nCoef)';

    %% Extract statistical features
    avgV = mean(coef,2);
    coef = coef-avgV;
    covM = coef*coef'/(nVoiced - 1);

    features = [avgV;covM(covM_triu)];

end
