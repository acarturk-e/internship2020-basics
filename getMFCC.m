function [coef, nVd] = getMFCC(aIn,fs,nCoef,E_th)
%GETMFCC Get MFCC coefficients from voiced segments.
%
%   This function checks for voiced speech in 30 ms
%segments with 10ms overlap at each side with Hamming
%window applied. For voiced segments, the MFCC algorithm
%is called.
%
%   Inputs:
%
%   aIn     Audio input as a double array
%   fs      Sampling frequency in Hz
%   nCoef   Number of MFCC coefficients requested
%   E_th    The threshold average energy for
%           voiced/unvoiced decision
% 
%   Outputs:
%
%   coef    MFCC coefficients of voiced segments
%   nVd     Number of voiced segments
%

    %% Constants
    n_10ms = 0.01*fs;
    w = hamming(3*n_10ms);

    %% Data & basic features
    if sum(size(aIn) ~= 1) ~= 1
        error('getMFCC:multichannel', ...
            'Error!\nThe given audio input is multichannel. ' + ...
            'This function accepts single channel inputs only.' + ...
            'MFCC feature extraction failed.');
    end
    aIn = aIn / max(aIn);
    L = floor(length(aIn)/n_10ms);

    %% Preprocessing, VAD
    y = reshape(aIn(1:n_10ms*L),[n_10ms,L]);
    y = [y(:,1:end-2);y(:,2:end-1);y(:,3:end)];
    y = y .* (w*ones(1,L-2));
    E = sum(y.^2) ./ (3*n_10ms);
    isVoiced = E > E_th;
    nVd = sum(isVoiced);

    % Throw an error if there is not at least 50 ms of voiced speech
    if nVd < 3
        error('getMFCC:notVoiced', ...
            "The given audio doesn't have enough voiced segments. " + ...
            'MFCC feature extraction failed.');
    end

    y = y(:,isVoiced);

    %% MFCC feature extraction
    coef = mfcc(y,fs,'NumCoeffs',nCoef-1);
    coef = permute(coef,[2,3,1]);
    % An attempt to minimize channel effects:
    coef = coef - ones(nCoef,1)*mean(coef);

end
