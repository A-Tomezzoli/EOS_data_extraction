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
% Description:   Identify Hip Joint Centre
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function [HJC, r]= f_EOS_anatID_Hip_v3(Front,Sagit,side)

font_inst = 16;

%% 1- Frontal View
% 1.1 - Height and Width of Image
[H,W] = size(Front);
    
% 1.2 - Plot Pre-Zoomed Image 
Yimg = 1:round(H/2);
fig = figure;
img = imshow(Front(Yimg,:));
set(fig,'units','normalized','outerposition',[0 0 1 1]);
text(100, 100,'RIGHT','color',[1 1 1],'HorizontalAlignment','left')
text(W - 100, 100,'LEFT','color',[1 1 1],'HorizontalAlignment','right')

% 1.3 - Zoom on Hip
switch side
    case 'right'
        title({'Select the zone around the Right Hip'},'FontSize',font_inst,'FontWeight','demi');
    case 'left'
        title({'Select the zone around the Left Hip'},'FontSize',font_inst,'FontWeight','demi');
end
[J,H,W] = f_subIMG(Front);

% 1.4 - Negative of image for clarity
K = imcomplement(J); 

% 1.5 - Update Image
delete(fig.Children.Children(1:end-1)); 
img.CData = K; hold on
[h,w] = size(img.CData);
xx = [1 w];
yy = [1 h];
axis([xx yy]);

% 1.6 - Get Points 
title({'CLICK points on countour of the FEMORAL HEAD, press ENTER when finished'},...
       'FontSize',font_inst, 'FontWeight','demi');
    
cond1 = 'No';    
while strcmp(cond1,'No')% Multiple tries if needed
    % Select points of the circle 
    [x,y]=getpts;
    % Centre of the circle and radius
    [x_hip,y_hip(1),r_hip(1)] = approximation_cercle(x,y);
    % Plot
    plot(x,y,'+r')
    trace_cercle(x_hip,y_hip(1),r_hip(1),'c','-');
    % Is the fit right?
    cond1 = questdlg('Is the fit right?');
    delete(fig.Children.Children(1:3))
end
    
% 1.7 - Points in Coordinate system EOS
x_hip    = x_hip   +W;
y_hip(1) = y_hip(1)+H;


%% 2 - Sagittal View  
% 2.1 - Height and Width of Image
[~,W] = size(Sagit);

% 2.1 - Update Image
delete(fig.Children.Children(1:end-1)); 
img.CData = Sagit(Yimg,:); hold on
[h,w] = size(img.CData);
xx = [1 w];
yy = [1 h];
axis([xx yy]);
% Plot height of the hip identified on Frontal view
plot(xlim,[y_hip(1)+r_hip(1), y_hip(1)+r_hip(1)],'c')
plot(xlim,[y_hip(1)-r_hip(1), y_hip(1)-r_hip(1)],'c')
text(100, 100,'FRONT','color',[1 1 1],'HorizontalAlignment','left')
text(W - 100, 100,'BACK','color',[1 1 1],'HorizontalAlignment','right')

% 2.3 - Zoom on Hip    
switch side
    case 'right'
        title({'Select the zone around the Right Hip'},'FontSize',font_inst,'FontWeight','demi');
    case 'left'
        title({'Select the zone around the Left Hip'},'FontSize',font_inst,'FontWeight','demi');
end
[J,H,W] = f_subIMG(Sagit);

% 2.4 - Negative of image for clarity
K = imcomplement(J); 

% 2.5 - Update Image
delete(fig.Children.Children(1:end-1)); 
img.CData = K; hold on
[h,w] = size(img.CData);
xx = [1 w];
yy = [1 h];
axis([xx yy]);
% Add Height of Hip identified on frontal view 
y_tmp = y_hip(1) - H;
plot(xlim,[y_tmp+r_hip(1), y_tmp+r_hip(1)],'c')
plot(xlim,[y_tmp-r_hip(1), y_tmp-r_hip(1)],'c')

% 2.6 - Get Points 
title({'CLICK points on countour of the FEMORAL HEAD, press ENTER when finished'},...
       'FontSize',font_inst, 'FontWeight','demi');
    
cond1 = 'No';    
while strcmp(cond1,'No')% Multiple tries if needed
    % Select points of the circle 
    [z,y]=getpts;
    % Centre of the circle and radius
    [z_hip,y_hip(2),r_hip(2)] = approximation_cercle(z,y);
    % Plot
    plot(z,y,'+r')
    trace_cercle(z_hip,y_hip(2),r_hip(2),'c','-');
    % Is the fit right?
    cond1 = questdlg('Is the fit right?');
    delete(fig.Children.Children(1:3))
end

% 1.7 - Points in Coordinate system EOS
z_hip   = z_hip    + W;
y_hip(2)= y_hip(2) + H;    

close

% OUTPUT - Hip Joint Center in Global - in PX
x = round(x_hip); 
y = round(mean(y_hip));
z = round(z_hip);
r = round(mean(r_hip));

HJC = [x y z];
end
