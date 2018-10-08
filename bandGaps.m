%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function finds the gaps between bands in the frequency matrix
%%% omega, and returns an array of the mins and maxs in the bandgaps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% param: omega = The frequency matrix output by eigs3D.m
% returns:
function [bottomsOfGaps,topsOfGaps] = bandGaps(omega, tolerance)

mins = transpose(min(transpose(real(omega)))); %Find the min and max of each band
maxs = transpose(max(transpose(real(omega))));

extremums = [mins, maxs]; %Create a list of the extremums

%Find where the max of a band is less than the min of the next (bands cannot cross each other)
gaps = extremums(1:end-1,2) + tolerance < extremums(2:end,1);

bottomsOfGaps = extremums(1:end-1,2);		topsOfGaps = extremums(2:end,1);
bottomsOfGaps = bottomsOfGaps(gaps);		topsOfGaps = topsOfGaps(gaps); %Return the vals at those locations