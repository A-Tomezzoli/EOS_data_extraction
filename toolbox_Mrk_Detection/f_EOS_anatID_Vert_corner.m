% Author     :   A. Tomezzoli, https://orcid.org/0000-0003-0751-5552 
%                Biomechanics and Impact Mechanics Laboratory (LBMC)
%                Univ Lyon, Univ Gustave Eiffel, , LBMC UMR_T9406, F69622, Lyon, France
%                https://lbmc.univ-gustave-eiffel.fr 
% License    :   Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code:   https://gitlab.unige.ch/KLab/fusion_internal_point_extraction
% Reference  :    		
%                
%                
% Date       :   August 2021
% -------------------------------------------------------------------------
% Description:   Manual extraction of a set of 2D points, in the sagittal plane.
%                The number of points and their labels are defined in 
%                GUI_Mrk8Detection > Vertebr_corner_01 to _03 
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------



function [VerC]= f_EOS_anatID_Vert_corner(Sagit, vertebrae_name, vertebrae_segment, vertebrae_n);
font_inst = 16;

%% 1- Plot Sagital View
% 1.1 - Height and Width of Image
[H,W] = size(Sagit);

% 1.2 - Plot Image 
Yimg = 1: H;         
fig1 = figure(1);
img = imshow(Sagit(Yimg,:));
set(fig1,'units','normalized','outerposition',[0.02 0 0.36 1]);                 
text(100, 100,'ANTERIOR','color',[1 1 1],'HorizontalAlignment','left')
text(W - 100, 100,'POSTERIOR','color',[1 1 1],'HorizontalAlignment','right')
title ({'Zoom = mouse wheel, ADJUST a point, ENTER'});

%% Get Point

%drawline ('Position',[600,600 ; 800,1100], 'LineWidth', 1, 'MarkerSize', 1);
y = []; z= [];
lab = [];

if      vertebrae_segment == 'T'
    z_start = 1200;     incr = 120;
elseif vertebrae_segment == 'L'
    z_start = 2600;     incr = 200;
else
    z_start = 500;     incr = 100;
end


for i = 1:vertebrae_n
    lab = ['     ', vertebrae_name{i}]; 
%    zoom on; pause(); zoom off; 
    if i==1
        roi(i) = images.roi.Point(gca, 'label', lab, 'LabelVisible', 'hover', 'LabelAlpha', 0, 'LabelTextColor', 'r', ...
        'color', 'r', 'MarkerSize', 4, 'Position',[700, z_start]);
        pause();
    else
        roi(i) = images.roi.Point(gca, 'label', lab, 'LabelVisible', 'hover', 'LabelAlpha', 0, 'LabelTextColor', 'r', ...
            'color', 'r', 'MarkerSize', 4, 'Position',[y(i-1, 1) (incr + z(i-1, 1))]);
        pause();
    end
  
    %zoom out
    y(i,1) = roi(i).Position(1); 
    z(i,1) = roi(i).Position(2);
end

close

% OUTPUT 
y = round(y);
z = round(z);

VerC = [y(1:end,1)  z(1:end,1)];
end