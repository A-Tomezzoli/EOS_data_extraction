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
% Description:   Least square approximation of a circle
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function [xc,yc,rc]=approximation_cercle(x,y)

abc=[x y ones(length(x),1)]\-(x.^2+y.^2);
a=abc(1); b=abc(2); c=abc(3);
xc=-a/2;
yc=-b/2;
rc=sqrt((xc^2+yc^2)-c);