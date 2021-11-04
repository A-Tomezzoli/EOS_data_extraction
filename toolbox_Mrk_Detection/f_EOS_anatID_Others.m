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
% Description:   Manual extraction of a set of 3D points.
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------






function [VerC]= f_EOS_anatID_Others(Sagit, Front);
font_inst = 16;
x = []; y = []; z= [];
y_face = [];    y_profil = [];

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


%% Get Point in the Sagital view
roi = images.roi.Point(gca, 'color', 'r', 'MarkerSize', 4, 'Position',[700, 700]);
pause()

y_face = roi.Position(2); 
z = roi.Position(1);


%% 1- Plot Sagital View
% 1.1 - Height and Width of Image
[Hs,Ws] = size(Sagit);

% 1.2 - Plot Image 
Yimg = 1: Hs;         
fig2 = figure(2);
img = imshow(Front(Yimg,:));
set(fig2,'units','normalized','outerposition',[0.4 0 0.36 1]);                 
text(100, 100,'RIGHT','color',[1 1 1],'HorizontalAlignment','left')
text(Ws + 150, 100,'LEFT','color',[1 1 1],'HorizontalAlignment','right')
title ({'Zoom = mouse wheel, ADJUST a point, ENTER'});

yline (y_face - 15, 'g') ; yline (y_face + 15, 'g');
roi = images.roi.Point(gca, 'color', 'r', 'MarkerSize', 4, 'Position',[700, y_face]);
pause();
x = roi.Position(1); 
y_profil = roi.Position(2); 

close (fig1)
close(fig2);

%% OUTPUT 
x = round(x);
y = round((y_face + y_profil)/2);
z = round(z);

VerC = [x y z];
end