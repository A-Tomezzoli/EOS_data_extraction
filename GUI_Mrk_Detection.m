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
% Description:   This toolbox have been developped to identify anatomical 
%                points of the lower limb and motion capture skin markers 
%                (equipped with lead beads) on EOS bi-plane X-rays.
% Dependencies : Image processing toolbox of Matlab
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------


% Author     :   A. Tomezzoli, https://orcid.org/0000-0003-0751-5552 
%                Biomechanics and Impact Mechanics Laboratory (LBMC)
%                Univ Lyon, Univ Gustave Eiffel, , LBMC UMR_T9406, F69622, Lyon, France
%                https://lbmc.univ-gustave-eiffel.fr             
% Date       :   August 2021
% -------------------------------------------------------------------------
% Description:   Mains changes: the Toolbox has been adapted to extract multiple data at
%                the upper limb and spine.        
%               - 'Automatic detection' panel
%                       'Add/Remove points': new button. Adds the possibility of removing points
%                       from automatic / manual detection. Points can be
%                       added without any previous automatic point
%                       detection.
%                       'Manual labelling': a dropdown list of predefined marker labels has been
%                       added. See the list below.
%                - 'Anatomical points' panel
%                       'Vertebr_corner': new button. Adds the possibility of extracting
%                        manually a set 2D points in the sagittal plane.
%                        Their number and labels are defined below.
%                       'Others': new button. Add the possibility of extracting manually 
%                        zero to 9 additional 3D points.  
%                        Knee and Pubic symphysis detection have been
%                        removed.
%                - 'Clear figure' button: clears all points plotted on figures.Data 
%                        is kept in tables. 
% -------------------------------------------------------------------------


function varargout = GUI_Mrk_Detection(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Mrk_Detection_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Mrk_Detection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

end



% --- Executes just before GUI_Mrk_Detection is made visible.
function GUI_Mrk_Detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Mrk_Detection (see VARARGIN)

addpath('toolbox_Mrk_Detection')

% Choose default command line output for GUI_Mrk_Detection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);            
if nargin == 3
    initial_dir = pwd;
elseif nargin > 4
    if strcmpi(varargin{1},'dir')
        if exist(varargin{2},'dir')
            initial_dir = varargin{2};
        else
            errordlg('Input argument must be a valid directory','Input Argument Error!')
            return
        end
    else
        errordlg('Unrecognized input argument','Input Argument Error!');
        return;
    end
end
end

% --- Outputs from this function are returned to the command line.
function varargout = GUI_Mrk_Detection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

%% Load DICOMs
% --- Executes on button press in loadfile.
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dir_path files Front Sagit AnatPt Info
% Clear figure tables and previous variables
AnatPt = [];
% Initialise tables
set(handles.Table_SkinMrk,'Data',[])
set(handles.Table_SkinMrk,'RowName',[])
set(handles.Table_AnatPt,'Data',[])



for i =1:45; R{i} = ['Mrk',num2str(i)];end                 
set(handles.Table_SkinMrk,'RowName',R)

cla(handles.axes3)

[files,dir_path] = uigetfile('data\*.*','Select Frontal and Sagittal view','MultiSelect','on');

% Check if both files have been selected
if size(files,2) == 2
    % Edit Text
    % Directory
    set(handles.Directory,'string',dir_path)
    % Files
    set(handles.FrontFile,'string',files{1})
    set(handles.SagittalFile,'string',files{2})

    % Load Image
    h = waitbar(0,'Processing');
    Front = dicomread([dir_path,'\',files{1}]);
    Info.Front = dicominfo([dir_path,'\',files{1}]);
    waitbar(0.5,h,'Processing');
    Sagit  = dicomread([dir_path,'\',files{2}]);
    Info.Sagit = dicominfo([dir_path,'\',files{1}]);
    waitbar(1,h,'Processing');
    close(h)
    imshow([Front Sagit])
    
    % Plot X Y Z
    W = size(Front,2);
    r = size(Sagit,2)/ 5;
    hold on;
    font = 16;
    quiver(40,40,r,0,'linewidth',2,'color','r','MaxHeadSize',2); text(r/2,r/4,'x','color','r','FontSize',font) % X
    quiver(40,40,0,r,'linewidth',2,'color','g','MaxHeadSize',2); text(r/4,3*r/5,'y','color','g','FontSize',font) % Y
    quiver(W + 40,40,r,0,'linewidth',3,'color','g','MaxHeadSize',2); text(W + r/2,r/4,'z','color','g','FontSize', font, 'FontWeight', 'bold') % Z
     quiver(W + 40,40,r,0,'linewidth',2,'color','b','MaxHeadSize',2); text(W + r/2,r/4,'z','color','b','FontSize',font) % Z   
    quiver(W + 40,40,0,r,'linewidth',2,'color','g','MaxHeadSize',2); text(W + r/4,3*r/5,'y','color','g','FontSize',font) % Y
else 
    msgbox('Select the FRONTAL and SAGITTAL files')
end
end



%% Skin Markers Detection
% --- Executes on button press in SkinMrk.
function SkinMrk_Callback(hObject, eventdata, handles)
% hObject    handle to SkinMrk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Front Sagit Info

r_cut = str2double(handles.r_cut.String); % add selection in GUI
test_fig = 'off'; % on / off
          
% Clear Markers in Figure      
axes(handles.axes3)
h_tmp = findobj('type','line'); % Find Markers on plot
delete(h_tmp(:));               % Delete Markers on plot

% Initialise Row Name
for i = 1:size(handles.Table_SkinMrk.RowName,1)
    Row{i} = ['Mrk',num2str(i)];
end
set(handles.Table_SkinMrk,'RowName',Row)
set(handles.Table_SkinMrk,'Data',[])


[mrk_eos,mrk_eos2] = f_EOS_mrkID(Front,Sagit,r_cut,test_fig);

% Plot MRK -> In Fig GUI
xdim = size(Front,2);
hold on
% Add Markers
    x = mrk_eos(:,1);
    y = mrk_eos(:,2);
    z = mrk_eos(:,3);
% Front view (X,Y)
    plot(x,y,'ro','MarkerSize', 8)                 
% Lateral view (Z,Y)              
    plot(z + xdim,y,'ro','MarkerSize',8)               
    
% Markers identified on side view
if exist('mrk_eos2')
    if isempty(mrk_eos2)== 0 % If additional markers have been detected on side view
    clear x y z
        x = mrk_eos2(:,1);
        y = mrk_eos2(:,2);
        z = mrk_eos2(:,3);
    % Front view (X,Y)
        plot(x,       y, 'mo', 'MarkerSize', 8)                    
    % Lateral view (Z,Y)             
        plot(z + xdim,y, 'mo', 'MarkerSize', 8)           
     end
end

% Fill Marker Table with values
% Table_SkinMrk
px2mm = Info.Sagit.PixelSpacing (1);
mrk_eos_mm = mrk_eos * px2mm; % EOS to mm
set(handles.Table_SkinMrk,'Data',mrk_eos_mm);

end



% --- Executes on button press in add_SkinMrk.
function add_SkinMrk_Callback(hObject, eventdata, handles)
% hObject    handle to add_SkinMrk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Front Sagit Info

% get variables from "Automatic detection" and main interface
axes(handles.axes3)
xdim = size(Front,2);
mrk_eos = [];
n_mrk_previous = length(handles.Table_SkinMrk.Data);
mrk_eos_mm = handles.Table_SkinMrk.Data;

px2mm = Info.Sagit.PixelSpacing (1);
r_cut = str2double(handles.r_cut.String); % add selection in GUI
cpt = 1;
subBand = [];
cond1_new = [];

% Are there missing (OR spurious) markers? no -> do nothing, yes -> next step     
cond1 = 'Yes';
    % 1 - Plot Frontal view with small black band on sides to see markers at edge
        % 1.1 - Add black band to see markers at the edge
        dimY = size(Front,1); 
        dx = 50;
        tmpIMG = [zeros(dimY,dx),Front,zeros(dimY,dx)];
        % 1.2 - Height and Width boundaries of image - for rectangle
        [HB,WB] = size(tmpIMG); 
        
    while strcmp(cond1,'Yes'); % ask question after each mrk. 'No' -> close fig1      
        % 1.3 update the main figure display
        % Clear Markers in Figure      
        axes(handles.axes3)
        h_tmp = findobj('type','line'); % Find Markers on plot
        delete(h_tmp(:));               % Delete Markers on plot
        
        
        % Add Markers of different colors
        
               
        if length (mrk_eos_mm) <6   &   length (mrk_eos_mm) >1   %1 color if < 6 markers
            x_newPlot = mrk_eos_mm(:,1)/px2mm;
            y_newPlot  = mrk_eos_mm(:,2)/px2mm;
            z_newPlot  = mrk_eos_mm(:,3)/px2mm;
            % Front view (X,Y)
                plot(x_newPlot ,y_newPlot , 'ro','MarkerSize', 8)          
            % Lateral view (Z,Y)
                plot(z_newPlot  + xdim, y_newPlot , 'ro','MarkerSize',8) 
                
        elseif  length (mrk_eos_mm) > 7                           % different colors if they are more markers
                for mrk_ligne= 1:length (mrk_eos_mm);
                    x_newPlot = mrk_eos_mm(mrk_ligne,1)/px2mm;
                    y_newPlot  = mrk_eos_mm(mrk_ligne,2)/px2mm;
                    z_newPlot  = mrk_eos_mm(mrk_ligne,3)/px2mm;  
                    
                    %set the color
                    if mrk_ligne/5 - fix (mrk_ligne/5) == 0
                            col_shape = 'ro';                
                    elseif (mrk_ligne+1)/5 - fix ((mrk_ligne+1)/5) == 0
                            col_shape = 'go';    
                    else
                        if (mrk_ligne+2)/5 - fix ((mrk_ligne+2)/5) == 0
                            col_shape = 'yo'; 
                        elseif (mrk_ligne+3)/5 - fix ((mrk_ligne+3)/5) == 0
                            col_shape = 'co'; 
                        else
                            col_shape = 'mo'; 
                        end
                    end
                    % Front view (X,Y)
                        plot(x_newPlot ,y_newPlot , col_shape,'MarkerSize', 8)        
                    % Lateral view (Z,Y)
                        plot(z_newPlot  + xdim, y_newPlot ,col_shape,'MarkerSize',8)   
                end
        else
        end
  
           
        % 1.3 - Plot New frontal view
        select_mrk = figure(1); imshow(tmpIMG); hold on;...
        scr_size = get(groot,'ScreenSize');                                                
        set(select_mrk,'units','normalized','outerposition',[0.05*scr_size(1) 0 0.37*scr_size(1) 1]);     
        % 1.4 - Plot markers identified
        mrk_eos_previous = mrk_eos_mm /px2mm;
        if mrk_eos_previous >0
            plot(mrk_eos_previous(:,1)+ dx, mrk_eos_previous(:,2),'+g','MarkerSize',5)
        else
        end
            title('Select Zone Around the Mrk')
        
        % 2 - Select unidentified (OR spurious) Marker on Frontal View
        % 2.1 - Manual ID of Rectangle around marker 
        clear mrk_tmp
        figure(select_mrk.Number);                             
        [subIMG,h,w] = f_subIMG(tmpIMG);
        %visualise selection on the image                                
        line([w, w+size(subIMG,2)],                 [h, h], 'Color','red')                      
        line([w, w+size(subIMG,2)],                 [h+size(subIMG,1), h+size(subIMG,1)], 'Color','red') 
        line([w, w],                                [h, h+size(subIMG,1)], 'Color','red') 
        line([w+size(subIMG,2), w+size(subIMG,2)],	[h, h+size(subIMG,1)], 'Color','red') 
     
        
        % 2.2 - ID mrk with threshold on sub image
        if size(subIMG, 1) < 15  |    size (subIMG, 2) < 15  % if the selection area is too small: avoid bug
                                                                
        else  
            r_cut2 = 0.9;    
            local_mrk = [];
            local_mrk(cpt,:) = f_EOS_mrkID_subT(subIMG,r_cut2);    
            newmrk_index = [] ; newmrk  = [];
            
                % >> TO DO -- Need to add mrk that were previously identified
                                    
                % 2.3.1 - Check visually if it worked  
               fig2 = figure(2); 
               fig2.Position = [scr_size(3)*3/5  scr_size(4)  3*size(subIMG,2) 3*size(subIMG,1)];
               imshow(subIMG); hold on;  
               % Successful? Y/N
               if  local_mrk(cpt,:) ~= local_mrk(cpt,:)  % to detect NaN (because NaN ~= NaN)
                   cond2 = 'No';
               else
                   plot(local_mrk(cpt,1),local_mrk(cpt,2),'*r');
                   
                   cond2 = questdlg('Was the marker identified properly?');
                   % 2.4 - Get Mrk X and Y Position in Global
                   mrk_tmp(cpt,1:2) = round([local_mrk(cpt,1) + round(w) - dx,...
                       local_mrk(cpt,2) + round(h)]); 
               end
               close;
               
            % 2.3 - Is this New Marker?
            % marker is not new if it is within a box of 10px in X and Y around other mrk  
         if length (mrk_eos_mm)>0
            if  local_mrk(cpt,:) ~= local_mrk(cpt,:)  | strcmp (cond2, 'No') |strcmp (cond2, 'Cancel')
            else
                x_remove = [mrk_tmp(cpt,1) - 10, mrk_tmp(cpt,1) + 10];
                y_remove = [mrk_tmp(cpt,2) - 10, mrk_tmp(cpt,2) + 10];

                newmrk_index = find(mrk_eos_mm(:,1)> x_remove(1)*px2mm & mrk_eos_mm(:,1)< x_remove(2)*px2mm  ...
                        & mrk_eos_mm(:,2)> y_remove(1)*px2mm & mrk_eos_mm(:,2)< y_remove(2)*px2mm);

                if isempty(newmrk_index) % New Marker   
                else
                    newmrk = mrk_eos_mm(newmrk_index(1), :)/ px2mm;
                    %plot in frontal(Figure 1) and lateral (Figure 2) views
                    axes(handles.axes3)
                    plot(newmrk(1,1),newmrk(1,2),'go','MarkerSize', 10); 
                    plot(newmrk(1,3) + xdim, newmrk(1,2),'go','MarkerSize',10);      
                    
                    %Question => 'Remove, Add, or 'Cancel'.
                    % => 'Cancel': end of the function. 'Yes': continue. 'No': remove marker from table
                    cond1_new = questdlg('This marker was already listed', '', 'Remove', 'Add another', 'Cancel', 'Cancel');
                    if strcmp(cond1_new,'Remove')
                        %Update and close the figure
                        mrk_eos_mm(newmrk_index(1), :) = [0, 0, 0];
                        set(handles.Table_SkinMrk,'Data',mrk_eos_mm);
                        close (select_mrk)
                    elseif strcmp(cond1_new,'Add another')
                    else % 'Cancel'
                        close (select_mrk)                   
                    end
                end
            end
         else
         end
        
        % 3.3 - Update Figures and close the function
        if strcmp(cond1_new,'Add another') | isempty(newmrk_index)
        else    
            %update the main figure display
            % Clear Markers in Figure      
            axes(handles.axes3)
            h_tmp = findobj('type','line'); % Find Markers on plot
            delete(h_tmp(:));               % Delete Markers on plot
            % Add Markers
                x_newPlot = mrk_eos_mm(:,1)/px2mm;
                y_newPlot  = mrk_eos_mm(:,2)/px2mm;
                z_newPlot  = mrk_eos_mm(:,3)/px2mm;
            % Front view (X,Y)
                plot(x_newPlot ,y_newPlot ,'ro','MarkerSize', 8)          
            % Lateral view (Z,Y)
                plot(z_newPlot  + xdim, y_newPlot ,'ro','MarkerSize',8) 
            break
        end
               
        
    % 3 - Get Marker Position on Lateral View (If Work)
            if strcmp(cond2,'Yes')             
                clear mrk_band
                % 3.1 - Try Band - Add Height constraint on Lat view
                [mrk_eos3,band] = f_EOS_mrkID_H(Sagit,mrk_tmp(cpt,:),'off');
                % Band dimension
                [hb,~] =  size(band);
                %[hb,~] =  10+size(band);

                % 3.1' - If Band did not work - Select Marker Manually
                if sum(mrk_eos3) == 0 % band did not work
                    fig3 = figure(3);                             
                    fig3.Position = [0 0.78*scr_size(4)  1.2*size(band,2) 3*size(band,1)]; 
                    imshow(band); title('Select Zone Around the Mrk');
                    % 3.1'.1 - Mrk Selection
                    [subBand,~,w2] = f_subIMG(band);
                    % 3.1'.2 -ID marker with Threshold
                    mrk_subBand = f_EOS_mrkID_subT(subBand,r_cut);
                   if size(subBand, 1) < 10  |    size (subBand, 2) < 10 % if the selection area is too small: avoid bug
                   else
                       mrk_band = [round(mrk_subBand(1) + w2) , round(mrk_subBand(2))];
                       % 3.1'.4 -Mrk in EOS
                       mrk_eos3 = [mrk_band(1) ,round((mrk_band(2) + mrk_tmp(cpt,2) - hb/2))];
                   end
                   
                else % Band did work - mrk in local for visualisation
                    mrk_band = round( [mrk_eos3(1), mrk_eos3(2) - mrk_tmp(cpt,2) + hb /2 ]);

                end

                
                % 3.2 - Check If marker ID is correct
                if size(subBand, 1) < 10  |    size (subBand, 2) < 10    % if the selection area is too small: avoid bug
                    cond3 = 'No';
                else
                    fig3 = figure(3);                                                 
                    fig3.Position = [0 0.78*scr_size(4)  1.2*size(band,2) 3*size(band,1)]; 
                    imshow(band); hold on;plot(mrk_band(:,1),mrk_band(:,2),'+r')
                    cond3 = questdlg('Was the marker identified properly?');
                    close
                end              
                
                if strcmp(cond3,'Yes') % marker identified on both views
                    % Get Position in EOS
                    x = mrk_tmp(cpt,1);
                    y = round((mrk_tmp(cpt,2) + mrk_eos3(2))/2);
                    z = round(mrk_eos3(1));
                    %
                    mrk_eos(1,:) = [x y z];
                    
                elseif strcmp(cond3,'Cancel')                             
                    
                else % Band worked but did not get the right mrk 
                    for j = 1:4             %enables 4 trials
                        fig3 = figure(3);                    
                        fig3.Position = [0 0.78*scr_size(4)  1.2*size(band,2) 3*size(band,1)]; 
                        imshow(band); hold on;
                        % Select zone around marker
                        [subBand,~,w2] = f_subIMG(band);
                        if size(subBand, 1) < 10  |    size (subBand, 2) < 10   % if the selection area is too small: avoid bug
                        else
                            % 3.1'.2 - ID marker with Threshold
                            mrk_subBand = f_EOS_mrkID_subT(subBand,r_cut);
                            if mrk_subBand ~= mrk_subBand
                                break
                            else
                                mrk_band = [round(mrk_subBand(1) + w2), round(mrk_subBand(2))];
                                % 3.1'.4 - Mrk in EOS
                                mrk_eos3 = [mrk_band(1) ,round((mrk_band(2) + mrk_tmp(cpt,2) - hb/2))];
                                plot(mrk_band(:,1),mrk_band(:,2),'+r')
                                %
                                cond4 = questdlg('Was the marker identified properly?');
                                if strcmp(cond4,'Yes')
                                    close
                                    % Get Position in EOS
                                    x = mrk_tmp(cpt,1);
                                    y = round((mrk_tmp(cpt,2) + mrk_eos3(2))/2);
                                    z = round(mrk_eos3(1));
                                    mrk_eos(1,:) = [x y z];
                                    break
                                elseif strcmp(cond4,'Cancel')                          
                                    break
                                end
                            end
                        end
                    end
                end 
                
                % 3.3 - Update Figures & Table
                % Update Figure: mrk ID
                if isempty(mrk_eos(:,:)) 
                else
                    figure(select_mrk.Number); hold on
                    plot(mrk_eos(end,1) + dx,mrk_eos(end,2),'*r')
                % Update Figure GUI
                    axes(handles.axes3)      
                    plot(mrk_eos(end,1),mrk_eos(end,2),'co','MarkerSize',8);    
                    plot(mrk_eos(end,3) + xdim, mrk_eos(end,2),'co','MarkerSize',8);
                % Update Table
                    mrk_eos_mm(n_mrk_previous + cpt, :) = mrk_eos(1, :) * px2mm;
                    set(handles.Table_SkinMrk,'Data',mrk_eos_mm);
                    
                    cpt = cpt +1;                    
                end
            end    
        end
        
            cond1 = questdlg('Add / Remove other markers?');
            if strcmp(cond1,'No')   |  strcmp(cond1,'Cancel')
  %??              close(fig1)
                close(select_mrk)                
            end
            
                                                                                        
    end

end


%% Anatomical Points
% --- Executes on button press in Right GH joint.
function RightHip_Callback(hObject, eventdata, handles)                     %Hip or GH joint
% hObject    handle to Right Hip / GH joint(see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Front Sagit AnatPt Info
[r_HJC, r_R, y_hip_face] = f_EOS_anatID_Hip_v3(Front,Sagit,'right');


% Clear Markers in Figure 
axes(handles.axes3)
h_tmp = findobj('type','line'); % Find Markers on plot        
delete(h_tmp(:));               % Delete Markers on plot

% Plot On fig
xdim = size(Front,2);
axes(handles.axes3); hold on
trace_cercle(r_HJC(1),r_HJC(2),r_R,'c','-')
trace_cercle(r_HJC(3)+xdim,r_HJC(2),r_R,'c','-')
hold on; plot (r_HJC(1), y_hip_face, '.r')                                  %%AT : red point at the center of the 1st sphere fitting (frontal view) 

% Put in Table
px2mm = Info.Sagit.PixelSpacing (1);
AnatPt(1,1:4) = [r_HJC r_R] * px2mm;
set(handles.Table_AnatPt,'Data',AnatPt);
end


% --- Executes on button press in Left Hip / GH joint.
function LeftHip_Callback(hObject, eventdata, handles)
% hObject    handle to Left GH joint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Front Sagit AnatPt Info

[l_HJC, l_R] = f_EOS_anatID_Hip_v3(Front,Sagit,'left');

% Clear Markers in Figure 
axes(handles.axes3)
h_tmp = findobj('type','line'); % Find Markers on plot        
delete(h_tmp(:));               % Delete Markers on plot

% Plot On fig
xdim = size(Front,2);
axes(handles.axes3); hold on
trace_cercle(l_HJC(1),l_HJC(2),l_R,'c','--')
trace_cercle(l_HJC(3)+xdim,l_HJC(2),l_R,'c','--')

% Put in Table
px2mm = Info.Sagit.PixelSpacing (1);
AnatPt(2,1:4) = [l_HJC l_R] * px2mm;
set(handles.Table_AnatPt,'Data',AnatPt);
end






% --- Executes on button press in Vertebr_corner_1.                         
function Vertebr_corner_1_Callback(hObject, eventdata, handles)
% hObject    handle to Vertebr_corner_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Front Sagit AnatPt Info

%vertebrae naming
vertebrae_segment = 'C';
vertebrae_n = 7;
vertebrae_name = [];
for i =  1:vertebrae_n 
    vertebrae_name{i,1} = ['C', num2str(i),     '_upper'];   
end


[VerC] = f_EOS_anatID_Vert_corner(Sagit, vertebrae_name, vertebrae_segment, vertebrae_n);

% Put in Table    
px2mm = Info.Sagit.PixelSpacing (1);
AnatPt(3:length(VerC) + 2, 1:4) = zeros(length(VerC), 4);
AnatPt(3:length(VerC) + 2, 2:3) = [VerC(:,2) VerC(:,1)] * px2mm;
set(handles.Table_AnatPt,'Data',AnatPt);

% Plot fig
xdim = size(Front,2);
axes(handles.axes3); hold on
% Plot anatomical points On fig
plot (VerC(:,1) + xdim, VerC(:,2),'r.','MarkerSize', 5)  

end



% --- Executes on button press in Vertebr_corner_2.                          
function Vertebr_corner_2_Callback(hObject, eventdata, handles)
% hObject    handle to Vertebr_corner_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Front Sagit AnatPt Info

%vertebrae naming
vertebrae_segment = 'T';
vertebrae_n = 12;
vertebrae_name = [];
for i =  1:vertebrae_n 
    vertebrae_name{i,1} = ['T', num2str(i),     '_upper'];   
end


[VerC] = f_EOS_anatID_Vert_corner(Sagit, vertebrae_name, vertebrae_segment, vertebrae_n);

% Put in Table    
px2mm = Info.Sagit.PixelSpacing (1);
AnatPt(10:length(VerC) + 9, 1:4) = zeros(length(VerC), 4);
AnatPt(10:length(VerC) + 9, 2:3) = [VerC(:,2) VerC(:,1)] * px2mm;
set(handles.Table_AnatPt,'Data',AnatPt);

% Plot fig
xdim = size(Front,2);
axes(handles.axes3); hold on
% Plot anatomical points On fig
plot (VerC(:,1) + xdim, VerC(:,2),'g.','MarkerSize', 5)  

end


% --- Executes on button press in Vertebr_corner_3.                            
function Vertebr_corner_3_Callback(hObject, eventdata, handles)
% hObject    handle to Vertebr_corner_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Front Sagit AnatPt Info

%vertebrae naming
vertebrae_segment = 'L';
vertebrae_n = 6;
vertebrae_name = [];
for i =  1:vertebrae_n 
    if i == 6
        vertebrae_name{i,1} = ['S', num2str(i-5),     '_upper'];   
    else
        vertebrae_name{i,1} = ['L', num2str(i),     '_upper'];
    end
end


[VerC] = f_EOS_anatID_Vert_corner(Sagit, vertebrae_name, vertebrae_segment, vertebrae_n);

% Put in Table    
px2mm = Info.Sagit.PixelSpacing (1);
AnatPt(22:length(VerC) + 21, 1:4) = zeros(length(VerC), 4);
AnatPt(22:length(VerC) + 21, 2:3) = [VerC(:,2) VerC(:,1)] * px2mm;
set(handles.Table_AnatPt,'Data',AnatPt);

% Plot fig
xdim = size(Front,2);
axes(handles.axes3); hold on
% Plot anatomical points On fig
plot (VerC(:,1) + xdim, VerC(:,2),'r.','MarkerSize', 5)  
end



% --- Executes on button press in other_points.                            
function other_points_Callback(hObject, eventdata, handles)
% hObject    handle to other_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Front Sagit AnatPt Info

%identifies were to place the new point coordinates in the table, each time
%the "other points" button is pressed.
if length(handles.Table_AnatPt.Data) > 27
    indx = 1 + length(handles.Table_AnatPt.Data);
else
    indx = 28;
end

marker_name = {};
marker_name = inputdlg('marker name?');
Mrk_names = handles.Table_AnatPt.RowName;
if isempty(marker_name) 
    return
end

while length (marker_name{1}) ~= 0           %If no marker name: exit.
    %require an adequat label
    for mrk_i = 1:length(handles.Table_AnatPt.RowName)
        if strcmp (marker_name, handles.Table_AnatPt.RowName(mrk_i))
            marker_name = inputdlg('chose another marker name');
            if  strcmp (marker_name, '')
                return
            elseif strcmp (marker_name, handles.Table_AnatPt.RowName(mrk_i))
                return
            end
        end
    end
           
    %Main fuction
    [VerC] = f_EOS_anatID_Others(Sagit, Front);       

    % Put in Table    
    px2mm = Info.Sagit.PixelSpacing (1);
    AnatPt(indx, 1:4) = zeros(1, 4);
    AnatPt(indx, 1:3) = [VerC(:,1) VerC(:,2) VerC(:,3)] * px2mm;
    Mrk_names(indx, 1) = marker_name;
    set(handles.Table_AnatPt,'Data',AnatPt);
    set(handles.Table_AnatPt,'RowName',Mrk_names);

    % Plot fig
    xdim = size(Front,2);
    axes(handles.axes3); hold on
    % Plot anatomical points On fig
    plot (VerC(1, 1), VerC(1, 2),'r.','MarkerSize', 5)  
    plot (VerC(1, 3) + xdim, VerC(1, 2),'r.','MarkerSize', 5)  

    indx = indx + 1   ;
    marker_name = {};
    marker_name = inputdlg('marker name?');
    
    %require an adequate label
    if isempty(marker_name) | strcmp(marker_name, '') 
        return
    end
end
end



% --- Executes on button press in clear_fig.
function clear_fig_Callback(hObject, eventdata, handles)
% hObject    handle to clear_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Front Sagit AnatPt Info

% Clear Markers in Figure 
axes(handles.axes3)
h_tmp = findobj('type','line'); % Find Markers on plot        
delete(h_tmp(:));               % Delete Markers on plot
end




%% Labelling Skin Markers
% --- Executes on button press in Manual_Label.
function Manual_Label_Callback(hObject, eventdata, handles)
% hObject    handle to Manual_Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Front Info
px2mm = Info.Sagit.PixelSpacing (1);
% Get All points

xyz = handles.Table_SkinMrk.Data;
% Remove empty raw AND sort by height
xyz_NonEmpty = xyz(~all(xyz == 0, 2), :);
[~,id_x] = sort(xyz_NonEmpty(:,2));
xyz_s = xyz_NonEmpty(id_x,:);
% Identify from top to bottom
h = figure(4);

scr_size = get(groot,'ScreenSize');
h.Position = [scr_size(3)/12 1 scr_size(3)/3 1];                             
imshow(Front);hold on

% add left & right
text(10,100,'Right','Color','w','FontSize',14)
text(size(Front,2)-10,100,'Left','Color','w','FontSize',14,'HorizontalAlignment','Right')
% Put image on right part of screen
b = plot(xyz_s(1,1)/px2mm,xyz_s(1,2)/px2mm,'co');

SkinMrk = {'SkNA' 'SkOP' 'RSkM' 'LSkM' 'Jmen'...       
    'Cer4' 'Cer5' 'Cer6' 'Cer7'   'NoMarker1'...  
    'LAAc' 'RAAc' 'AcCl' 'aCM1' 'aCM2' 'TSca'...
    'AInf' 'DELT' 'EpiL' 'EpiM'...
    'InJU' 'StCL' 'MidS' 'PrXI'   'NoMarker2' ...
    'Tho1' 'Tho2' 'Tho3' 'Tho4' 'Tho5' 'Tho6' 'Tho7' 'Tho8' 'Tho9' 'Tho10'...
    'RASI' 'LASI' 'LPSI' 'RPSI'   'NoMarker3'...
    'Add1' 'Add2' 'NoMarker'};
      
                           
tmp = {1};
C{1} = tmp{1};
 
%first half of the markers
half = round(size(xyz_s,1)/2);
correct = 'No';
col ='g';
Font = 'normal';
delta_txt = 50;

for essai =  1:2                                         
    indx_ref = 1; 
    if strcmp(correct, 'Yes')                                        
        break
    else
        for i =1:half                                
            b.XData = xyz_s(i,1)/px2mm;
            b.YData = xyz_s(i,2)/px2mm;
            
            [indx,tf] = listdlg('ListString', SkinMrk, 'SelectionMode','single', 'InitialValue', indx_ref) ;      
            tmp = SkinMrk(indx);                                                
            for Sk_mrk_i = 1:length(C);
                if strcmp (C{Sk_mrk_i}, cellstr(tmp))
                    [indx,tf] = listdlg('ListString', SkinMrk, 'PromptString', 'Already chosen. Try another',...
                        'SelectionMode','single', 'InitialValue', indx_ref) ;  
                    tmp = SkinMrk(indx); 
                end
            end
            
            if isempty (tmp)
                close
                return
            end
            
            C{i} = tmp{1};    
            indx_ref = indx_ref  + 1;                                  
            
            %write the new label on the figure                        
            text  (delta_txt +(xyz_s(i,1)/px2mm),  xyz_s(i,2)/px2mm, tmp, 'color', col, 'FontWeight', Font);
            
        end
        if essai == 1
            correct = questdlg('Is this1st part of the labelling correct?','');
            col ='r'; Font = 'bold'; delta_txt = 150;
        else
        end
    end
end


%second half of the markers                                         
% TO DO : prevent the use of labels already given in the first part 
correct = 'No';
col ='g';
Font = 'normal';
delta_txt = 50;
for essai =  1:2                   
    indx_ref = 1 + half; 
    if strcmp(correct, 'Yes')    
        break           
    else
        for i = 1+half : size(xyz_s,1)             
            b.XData = xyz_s(i, 1)/px2mm;
            b.YData = xyz_s(i, 2)/px2mm;
      
            [indx,tf] = listdlg('ListString', SkinMrk, 'SelectionMode','single', 'InitialValue', indx_ref) ;     
            tmp = SkinMrk(indx);                                      
            for Sk_mrk_i = 1:length(C);
                if strcmp (C{Sk_mrk_i}, cellstr(tmp))
                    [indx,tf] = listdlg('ListString', SkinMrk, 'PromptString', 'Already chosen. Try another',...
                        'SelectionMode','single', 'InitialValue', indx_ref) ;  
                    tmp = SkinMrk(indx); 
                end
            end
            
            if isempty (tmp)
                break
            end
            
            C{i} = tmp{1};
            indx_ref = indx_ref  + 1;                                 
            
            %write the new label on the figure                       
            text  (delta_txt +(xyz_s(i,1)/px2mm),  xyz_s(i,2)/px2mm, tmp, 'color', col, 'FontWeight', Font);            
        end
        if essai == 1
            correct = questdlg('Is this 2nd part of the labelling correct?','');
            col ='r'; Font = 'bold'; delta_txt = 150;
        end
    end
end


set(handles.Table_SkinMrk,'RowName',C)
set(handles.Table_SkinMrk,'Data',xyz_s)

close
end





%% EXPORT
% --- Executes on button press in ExportMAT.
function ExportMAT_Callback(hObject, eventdata, handles)
% hObject    handle to ExportMAT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dir_path files

% 1 - Get Data
    % 1.1 - Skin Markers
    % Load from table
    data_tmp = handles.Table_SkinMrk.Data;
    row_tmp = handles.Table_SkinMrk.RowName;

    if ~isempty(data_tmp)
        % Structure form
        for i = 1:size(data_tmp,1)
            SkinMrk.([row_tmp{i}]) = data_tmp(i,:);
        end
        clear *_tmp
    end
    
    % 1.2 - Anatomical Points 
    % Load from table
    data_tmp = handles.Table_AnatPt.Data;
    row_tmp  = handles.Table_AnatPt.RowName;
    
    % Structure form
    if ~isempty(data_tmp)
        for i = 1:size(data_tmp,1)
            AnatPt.([row_tmp{i}]) = data_tmp(i,1:4);
        end
        clear *_tmp
    end
    
% 2 - Save File
    % 2.1 - File Name - Work if EOS files are saved as 'project_number_visit_*' 
        tmp1 = files{1};
        tmp2 = strfind(tmp1,'_');
    op = upper(handles.Operator.String); % Operator 
    file_name = tmp1(1:tmp2(3)-1); 
    % 2.2 - Is there an export file already?
    if isempty(op)
        tmp3 = dir([dir_path,files{1}(1:8),'*.mat']);
    else
        tmp3 = dir([dir_path,files{1}(1:8),'*',op,'*.mat']);
    end
    %
    if isempty(tmp3)
            idx = 1; 
    else
        for k=1:size(tmp3,1)
            tmp5 = strfind(tmp3(k).name,'_');
            tmp6 = strfind(tmp3(k).name,'.');
            tmp7(k) = str2num(tmp3(k).name(tmp5(end)+1:tmp6-1));
        end
        idx = max(tmp7) + 1; 
    end
    % save data to directory of DICOM files
    if isempty(op)
        out_name = [file_name,'_mrkEOS_',num2str(idx)];              
    else
        out_name = [file_name,'_mrkEOS_',op,'_',num2str(idx)];         
    end
    
    if exist('SkinMrk','var')
        if exist('AnatPt','var')
            save([dir_path,out_name],'SkinMrk','AnatPt')
            msgbox('Data was succesfully exported')
        else
            save([dir_path,out_name],'SkinMrk')
            msgbox('Data was succesfully exported')
        end
    else
        if exist('AnatPt')
            save([dir_path,out_name],'AnatPt')
            msgbox('Data was succesfully exported')
        else
            msgbox('No data to export')
        end
    end
end

% --- Executes on button press in ExportCSV.
function ExportCSV_Callback(hObject, eventdata, handles)
% hObject    handle to ExportCSV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dir_path files    
    
% 1 - Get Data    
    % 1.1 - Skin Markers
    % Load from table
    if ~isempty(handles.Table_SkinMrk.Data)
        data_tmp = handles.Table_SkinMrk.Data;
        row_tmp = handles.Table_SkinMrk.RowName;
        % Prepare Table form
        for i = 1:size(data_tmp,1)
            X(i,1) = data_tmp(i,1);
            Y(i,1) = data_tmp(i,2);
            Z(i,1) = data_tmp(i,3);
            R(i,1) = 0;
            row{i} = [row_tmp{i}];
        end
        clear *_tmp
    else 
        i = 0;
    end
    
    % 1.2 - Anatomical Points
    % Load from table
    if ~isempty(handles.Table_AnatPt.Data)
        data_tmp = handles.Table_AnatPt.Data;
        row_tmp = handles.Table_AnatPt.RowName;
        % Prepare Table form
        for j = 1:size(data_tmp,1)
            X(j+i,1) = data_tmp(j,1);
            Y(j+i,1) = data_tmp(j,2);
            Z(j+i,1) = data_tmp(j,3);
            R(j+i,1) = data_tmp(j,4);
            row{j+i} = row_tmp{j};
        end
        clear *_tmp
    end
    
    % Were there false positive in mrk detection?
    tmp = strcmp(row,'');
    if isempty(tmp) == 1  % Fake Mrk Identified
        row{strcmp(row,'')} = 'notMrk';
    end

    % Export
    if exist('Y','var')
        T = table(X,Y,Z,R,'RowNames',row);
        % File Name - Work if EOS files are saved as 'project_number_visit_*' 
            tmp1 = files{1};
            tmp2 = strfind(tmp1,'_');
            op = upper(handles.Operator.String); % Operator
        file_name = tmp1(1:tmp2(3)-1); 
        % Is there an export file already?
        if isempty(op)
            tmp3 = dir([dir_path,files{1}(1:8),'*.csv']);
        else
            tmp3 = dir([dir_path,files{1}(1:8),'*',op,'*.csv']);
        end
        %
        
        if isempty(tmp3)
            idx = 1; 
        else
            for k=1:size(tmp3,1)
                tmp5 = strfind(tmp3(k).name,'_');
                tmp6 = strfind(tmp3(k).name,'.');
                tmp7(k) = str2num(tmp3(k).name(tmp5(end)+1:tmp6-1));
            end
            idx = max(tmp7) + 1; 
        end
        % Save Data
        if isempty(op)
            out_name = [file_name,'_mrkEOS_',num2str(idx),'.csv'];
        else
            out_name = [file_name,'_mrkEOS_',op,'_',num2str(idx),'.csv'];       
        end
        writetable(T,[dir_path,out_name],'WriteRowNames',true)
        msgbox('Data was succesfully exported')
    else
        msgbox('No data to export')
    end
end


% --- Executes on button press in ExportXLS.
function ExportXLS_Callback(hObject, eventdata, handles)
% hObject    handle to ExportXLS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dir_path files    
    
% 1 - Get Data    
    % 1.1 - Skin Markers
    % Load from table
    data_tmp = handles.Table_SkinMrk.Data;
    row_tmp = handles.Table_SkinMrk.RowName;
    if ~isempty(data_tmp)
        % Prepare Table form
        for i = 1:size(data_tmp,1)
            X(i,1) = data_tmp(i,1);
            Y(i,1) = data_tmp(i,2);
            Z(i,1) = data_tmp(i,3);
            R(i,1) = 0;
            row{i} = [row_tmp{i}];
        end
        clear *_tmp
    else 
        i = 0;
    end 
    
    % 1.2 - Anatomical Points 
    % Load from table
    data_tmp = handles.Table_AnatPt.Data;
    row_tmp = handles.Table_AnatPt.RowName;
    if ~isempty(data_tmp)
        % Prepare Table form
        for j = 1:size(data_tmp,1)
            X(j+i,1) = data_tmp(j,1);
            Y(j+i,1) = data_tmp(j,2);
            Z(j+i,1) = data_tmp(j,3);
            R(j+i,1) = data_tmp(j,4);
            row{j+i} = row_tmp{j};
        end
        clear *_tmp
    end
    
    % Export
    if exist('X','var')
        T = table(X,Y,Z,R,'RowNames',row);
        % File Name - Work if EOS files are saved as 'project_number_visit_*' 
            tmp1 = files{1};
            tmp2 = strfind(tmp1,'_');
        op = upper(handles.Operator.String); % Operator
        file_name = [tmp1(1:tmp2(3)-1)]; 
        % Is there an export file already?
        if isempty(op)
            tmp3 = dir([dir_path,files{1}(1:8),'*.xls']);
        else
            tmp3 = dir([dir_path,files{1}(1:8),'*',op,'*.xls']);
        end
        %
        if isempty(tmp3)
            idx = 1; 
        else
            for k=1:size(tmp3,1)
                tmp5 = strfind(tmp3(k).name,'_');
                tmp6 = strfind(tmp3(k).name,'.');
                tmp7(k) = str2num(tmp3(k).name(tmp5(end)+1:tmp6-1));
            end
            idx = max(tmp7) + 1; 
        end
        
        % Export
        if isempty(op)
            out_name = [file_name,'_mrkEOS_',num2str(idx),'.xls'];
        else
            out_name = [file_name,'_mrkEOS_',op,'_',num2str(idx),'.xls'];       
        end
        writetable(T,[dir_path,out_name],'WriteRowNames',true)
        msgbox('Data was succesfully exported')
    else
        msgbox('No data to export')
    end
end



%% LOAD (.mat, .csv, .xls)
% --- Executes on button press in LoadProcessedData.
function LoadProcessedData_Callback(hObject, eventdata, handles)
% hObject    handle to LoadProcessedData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Info Front

% Load Data
[file,dir_path] = uigetfile('*.*','Select Processed Data');
ext = file(end-2:end);

switch ext
    case 'csv'
        csv = importdata([dir_path,file],',');
        % a - Anat Point
        % Index Anatomical Points 
        idx_anat = find(strcmp(csv.textdata,'RGHj')) - 1;
        % Fill table
        if isempty(idx_anat) ~= 1
            set(handles.Table_AnatPt,'data',csv.data(idx_anat:end,:))
        end
        % b - Skin Markers
        if idx_anat ~= 1 % are there anatomical points?
            set(handles.Table_SkinMrk,'data',csv.data(1:idx_anat-1,1:3))
            set(handles.Table_SkinMrk,'RowName',csv.textdata(2:idx_anat,1))
        end
        
    case 'mat'
        SkinMrk = []; AnatPt = [];
        load([dir_path,file])
        
        % Fill Tables
        % a - Skin Markers
        if isempty (SkinMrk)
        else
            f_sm = fieldnames(SkinMrk);                 
            for i = 1:size(f_sm,1)
                data_tmp(i,:) = SkinMrk.(f_sm{i});
                row_tmp{i,:} = f_sm{i};
            end
            set(handles.Table_SkinMrk,'data',data_tmp)
            set(handles.Table_SkinMrk,'RowName',row_tmp); clear *_tmp
        end

        % b - Anat Point
        if isempty (AnatPt)
        else
            f_ap = fieldnames(AnatPt);
            for i = 1:size(f_ap,1)
                data_tmp(i,:) = AnatPt.(f_ap{i});
                row_tmp{i,:} = f_ap{i};
            end
            set(handles.Table_AnatPt,'data',data_tmp)
            set(handles.Table_AnatPt,'RowName',row_tmp)
        end
        
        
    case 'xls'
        [NUM,TXT] = xlsread([dir_path,file]);
        % Fill Tables
        % a - Anat Point
        % Index Anatomical Points 
        idx_anat = find(strcmp(TXT,'RGHj')) - 1;
        % Fill table
        if isempty(idx_anat) ~= 1 % are there anatomical points?
            set(handles.Table_AnatPt,'data',NUM(idx_anat:end,:))
        end
        % b - Skin Markers
        if idx_anat ~= 1 % are there anatomical points?
            set(handles.Table_SkinMrk,'data',NUM(1:idx_anat-1,1:3))
            set(handles.Table_SkinMrk,'RowName',TXT(2:idx_anat,1))
        end
end

% Plot Data
px2mm = Info.Sagit.PixelSpacing(1); % from EOS - check PixelSpacing
xdim = size(Front,2);    % px size of frontal view
axes(handles.axes3);hold on

% - Anatomical points
am = handles.Table_AnatPt.Data / px2mm;
ar = handles.Table_AnatPt.RowName;

% There is a +1 in the plots
if isempty(am) == 0 
    for i=1:size(am,1)
        side = ar{i,1}(1);
        med  = ar{i,1}(2);
        switch side
            case 'R'
                line = '-';
            case 'L'
                line = '--';
        end
        switch med
            case 'M'
                c = 'g';
            otherwise
                c = 'w';
        end
        trace_cercle(am(i,1)+1, am(i,2)+1,am(i,4)+1,c,line)
        trace_cercle(am(i,3)+1+xdim,am(i,2)+1,am(i,4)+1,c,line)
    end
end
% - Skin Markers
sm = handles.Table_SkinMrk.Data / px2mm;
if isempty(sm) == 0 
plot(sm(:,1)+1,sm(:,2)+1,'*r')
plot(sm(:,3)+1+xdim,sm(:,2)+1,'*r')
end

end

%% other nothing interesting here
% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Directory_Callback(hObject, eventdata, handles)
% hObject    handle to Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Directory as text
%        str2double(get(hObject,'String')) returns contents of Directory as a double
end
% --- Executes during object creation, after setting all properties.
function Directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function FrontFile_Callback(hObject, eventdata, handles)
% hObject    handle to FrontFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrontFile as text
%        str2double(get(hObject,'String')) returns contents of FrontFile as a double
end

% --- Executes during object creation, after setting all properties.
function FrontFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrontFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function SagittalFile_Callback(hObject, eventdata, handles)
% hObject    handle to SagittalFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SagittalFile as text
%        str2double(get(hObject,'String')) returns contents of SagittalFile as a double
end

% --- Executes during object creation, after setting all properties.
function SagittalFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SagittalFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function r_cut_Callback(hObject, eventdata, handles)
% hObject    handle to r_cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r_cut as text
%        str2double(get(hObject,'String')) returns contents of r_cut as a double
end

% --- Executes during object creation, after setting all properties.
function r_cut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Operator_Callback(hObject, eventdata, handles)
% hObject    handle to Operator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Operator as text
%        str2double(get(hObject,'String')) returns contents of Operator as a double
end

% --- Executes during object creation, after setting all properties.
function Operator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Operator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes when entered data in editable cell(s) in Table_AnatPt.
function Table_AnatPt_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Table_AnatPt (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
end
