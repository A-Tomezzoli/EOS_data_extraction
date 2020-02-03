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
% Description:   Select sub IMG conditions on rectangle to match dimension 
%                of input image in case rectangle is out of bounds
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function [subIMG,h,w] = f_subIMG(IMG)

[HB,WB] = size(IMG);

rect = getrect;

h = round(rect(2):rect(2)+rect(4)); % Height of rectangle
w = round(rect(1):rect(1)+rect(3)); % Widht of rectangle
if w(1)   < 1;  w = 1:w(end); end 
if w(end) > WB; w = w(1):WB;  end
if h(1)   < 1;  h = 1:h(end); end
if h(end) > HB; h = h(1):HB;  end

subIMG = IMG(h,w);
h = h(1);
w = w(1);