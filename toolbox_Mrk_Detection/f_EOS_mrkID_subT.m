% Author     :   X. Gasparutto
%                Kinesiology Laboratory (K-LAB)
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License    :   Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code:   https://gitlab.unige.ch/KLab/fusion_internal_point_extraction
% Reference  :   "Can the fusion of motion capture and 3D medical imaging reduce the extrinsic 		
%                variability due to marker misplacements?" 
%                X. Gasparutto, J. Wegrzyk, K. Rose-Dulcina, D. Hannouche, S. Armand; Plos One
% Date       :   December 2019
% -------------------------------------------------------------------------
% Description:   Simple Threshold, works for a single marker on sub image         
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function [mrk_local] = f_EOS_mrkID_subT(subIMG,r_cut)

% Filter 
subF_IMG = wiener2(subIMG,[10 10]);
% Threshold
Fmax = max(max(subF_IMG));
subF_IMG(subF_IMG < r_cut * Fmax) = 0;
% Edge
subEF_IMG = edge(subF_IMG);
% Image fill
subIEF_IMG = imfill(subEF_IMG,'holes');
rp = regionprops(subIEF_IMG);
% Remove area < 15
for i =1:size(rp,1); tmp1(i) = rp(i).Area; end
tmp2 = find(tmp1 > 15);
if isempty(tmp2)==0;rp = rp(tmp2);end
%
% Get Mrk Position in Local
if size(rp,1) == 1 % Filter Worked fine, only one region
    mrk_local = rp.Centroid;
elseif (size(rp,1) == 2) && (abs(rp(1).Area - rp(2).Area) < 40) % 40 is arbitrary
    % special case when mrk is on side of image, sometimes fishing weights
    % seems cut in half
    mrk_local = (rp(1).Centroid + rp(2).Centroid) /2;
else % did not work fine
    mrk_local = NaN;
end    