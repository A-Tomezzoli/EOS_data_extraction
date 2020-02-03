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
% Description:   Identify markers position on one view of EOS based on the 
%                height of the markers identified on the other view         
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function [mrk_out, l] = f_EOS_mrkID_H(IMG,mrk_in,test_fig)

mrk_out = [];

n_mrk = size(mrk_in,1);
dy2 = 15; % band size

[hIMG, wIMG] = size(IMG); % Height & Width IMG

% Filter
F_IMG = wiener2(IMG,[10 10]);

for i = 1:n_mrk
    % b. Band Selection 
    % take +/- dy2 around height of mrk in frontal view
    y_mrk = mrk_in(i,2)-dy2 : mrk_in(i,2)+dy2;
    % is y_mrk out of bound?
    if y_mrk(end) > hIMG % Too High
        y_mrk = y_mrk(1):hIMG;
    end
    if y_mrk(1) < 1 % Too Low
       y_mrk = 1:y_mrk(end);
    end
    l     = F_IMG(y_mrk,:); 
    % c. Image Processing
    el   = edge(l);             
    fel  = imfill(el,'holes');  
    ofel = bwareaopen(fel,180); 
    
    % d. test fig
    switch test_fig
        case 'on'
        figure;
        subplot(4,1,1);imshow(l);    title('l') 
        subplot(4,1,2);imshow(el);   title('el')
        subplot(4,1,3);imshow(fel);  title('fel')
        subplot(4,1,4);imshow(ofel); title('ofel')
    end
        
    % e. Mrk Identification
        % e.1 - Region properties
        rp =  regionprops(ofel);
        % e.2 - Is there Marker?
        n_mrk = size(rp,1);
        switch n_mrk 
            case 0    % No Marker
                mrk_out(i,:) = [0 0];
                % e.3 - Get local marker
            case 1    % One Marker
                mrk(i,:) = rp.Centroid;                                    % Local
                mrk_out(i,:) = [mrk(i,1) mrk(i,2)+y_mrk(1)];               % EOS Coordinate System
                switch test_fig
                    case 'on'
                     subplot(4,1,1);hold on; plot(mrk(i,1),mrk(i,2),'+r');
                     subplot(4,1,4);hold on; plot(mrk(i,1),mrk(i,2),'+r');
                end
                
            otherwise % More than one marker
                % Get marker closer to the center
                % Put y position in a vector

                for i = 1:n_mrk
                    tmp(i) = rp(i).Centroid(2) - dy2;
                    bboxY(i) = rp(i).BoundingBox(2);
                    bboxH(i) = rp(i).BoundingBox(4);
                end
                % Centre of the box
                tmp2 = [bboxY; bboxY + bboxH];
                tmp3 = mean(tmp2,1) - 15;
                % Distance between top image and top box should be close to
                % bottom image and bottom box, that means the shape of mrk
                % is roughly centered
                    tmp_a = bboxY;
                    tmp_b = 2*dy2 - (bboxY + bboxH);
                    tmp_c = abs(tmp_a - tmp_b);
                [~,id] = min(tmp);
                [~,id] = min(tmp3);
                mrk(i,:) = rp(id).Centroid;
                
                mrk_out(i,:) = [mrk(i,1) mrk(i,2)+y_mrk(1)];
                switch test_fig
                    case 'on'
                        subplot(4,1,1);hold on; plot(mrk(i,1),mrk(i,2),'+r');
                        subplot(4,1,4);hold on; plot(mrk(i,1),mrk(i,2),'+r');
                end
        end
end
