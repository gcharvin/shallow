function formatDataForTraining(obj,classiid) %mov,trapsid,option)
% saves user annotated data to disk- works for Image, Pixel and LSTM
% classification

disp('Saving user training to disk...\n');

classif=obj.processing.classification(classiid);
category=classif.category;
category=category{1};

% mk folder to store ground user trained data
foldername='trainingdataset';
if isfolder([classif.path '/' foldername])
    rmdir([classif.path '/' foldername], 's')
end
    mkdir(classif.path,foldername)


switch category
    case 'Image'
        for i=1:numel(classif.classes)
            if ~isfolder([classif.path '/' foldername '/' classif.classes{i}])
                mkdir([classif.path '/' foldername], classif.classes{i});
            end
        end
    case 'Pixel'
        mkdir([classif.path '/' foldername],'images')
        mkdir([classif.path '/' foldername],'labels')
        % in case of pixels, training data is a list of 3 channels from the
        % roi.image matrix with indexed colors
        
    case 'LSTM'
        for i=1:numel(classif.classes)
            if ~isfolder([classif.path '/' foldername '/' classif.classes{i}])
                mkdir([classif.path '/' foldername], classif.classes{i});
            end
        end
    otherwise
        
end

% look on all ROIs

for i=1:numel(classif.roi)
    disp(['Processing ROI: ' num2str(i) ' ...'])
    
    if numel(classif.roi(i).image)==0
        classif.roi(i).load; % load image sequence
    end
    
    % normalize intensity levels
    pix=find(classif.roi(i).channelid==classif.channel); % find channel
    im=classif.roi(i).image(:,:,pix,:);
    
    if numel(pix)==1
        totphc=im;
        meanphc=0.5*double(mean(totphc(:)));
        maxphc=double(meanphc+0.7*(max(totphc(:))-meanphc));
    end
    
    if strcmp(category,'LSTM')
        vid=uint8(zeros(size(classif.roi(i).image,1),size(classif.roi(i).image,2),3,size(classif.roi(i).image,4)));
        
        pix=find(classif.roi(i).train==0);
        
        if numel(pix)==0 % some images are not labeled, quitting ...
            disp('Error: some images are not labeled !');
            return;
        end
    end
    
    if strcmp(category,'Pixel') % get the training data for pixel classification
         pixtraining=find(classif.roi(i).channelid=='Pixel'); % channel must be labeled as 'Pixel'
         labels=classif.roi(i).image(:,:,pixtraining,:);
         
    end
    
    if strcmp(category,'Image')
        lab= categorical(classif.roi(i).train,1:numel(classif.classes),classif.classes); % creates labels for classification
    end
    
    reverseStr = '';
    for j=1:size(im,4)
        tmp=im(:,:,:,j);
        
        if numel(pix)==1
            tmp = double(imadjust(tmp,[meanphc/65535 maxphc/65535],[0 1]))/65535;
            tmp=repmat(tmp,[1 1 3]);
        end
        
        if strcmp(category,'Pixel')
        tmp=uint8(256*tmp);
        end
        
        if strcmp(category,'LSTM')
            vid(:,:,:,j)=uint8(256*tmp);
        end
        % figure, imshow(im,[])
        % return;
        
        tr=num2str(j);
            while numel(tr)<4
                tr=['0' tr];
            end
            
        if strcmp(category,'Image')
            if classif.roi(i).train(j)~=0 % young budding cells
               % if ~isfile([str '/unbudded/im_' mov.trap(i).id '_frame_' tr '.tif'])
                    imwrite(tmp,[classif.path '/' foldername '/' classif.classes{classif.roi(i).train(j)} '/' classif.roi(i).id '_frame_' tr '.tif']);
               % end
            end
           
        end
        
        if strcmp(category,'Pixel')
         if max(labels(:,:,:,j))>0 % test if image has been manually annotated
         imwrite(tmp,[classif.path '/' foldername '/images/' classif.roi(i).id '_frame_' tr '.tif']);
         imwrite(labels,[classif.path '/' foldername '/labels/' classif.roi(i).id '_frame_' tr '.tif']);
         end
        end
        
        msg = sprintf('Processing frame: %d / %d for ROI %s', j, size(im,4),classif.roi(i).id); %Don't forget this semicolon
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg)); 
    end
    fprintf('\n');
    
    if strcmp(category,'LSTM')
    deep=classif.roi(i).train;
    save([classif.path '/' foldername '/labeled_video_' mov.trap(i).id '.mat'],'deep','vid','lab');
    end
    
end

return;

% gfp=[];
% phasechannel=1;
%
%
% if nargin==2
%     option=0 ; % make videos for LSTM training or direct classification
% end

% if option==1 % build images for training
% foldername='deeptrainingset';
% if ~isfolder([mov.path '/' foldername])
% %rmdir([mov.path '/' foldername],'s');
% mkdir(mov.path,foldername)
%
% str=[mov.path '/' foldername];
%
% mkdir(str,'smallbudded')
% mkdir(str,'largebudded')
% mkdir(str,'unbudded')
% end
% str=[mov.path '/' foldername];
% end
% 
% for i=trapsid
%     %     fprintf(['Processing trap' num2str(i) ':\n']);
%     %     % generate an rgb image with previous and next frames as colors
%     %
%     %     if numel(mov.trap(i).gfp)==0
%     %         mov.trap(i).load;
%     %     end
%     
%     totphc=mov.trap(i).gfp(:,:,:,phasechannel);
%     meanphc=0.5*double(mean(totphc(:)));
%     maxphc=double(meanphc+0.7*(max(totphc(:))-meanphc));
%     
%     vid=uint8(zeros(size(mov.trap(i).gfp,1),size(mov.trap(i).gfp,2),3,size(mov.trap(i).gfp,4)));
%     
%     if ~isfield(mov.trap(i).div,'deep') % this is not a training set !
%         mov.trap(i).div.deep=[];
%         mov.trap(i).div.deepLSTM=[];
%         mov.trap(i).div.deepCNN=[];
%         lab=[];
%     else
%         
%         lab= categorical(mov.trap(i).div.deep,[0 1 2],{'unbudded','smallbudded','largebudded'});
%     end
%     
%     for j=1:size(mov.trap(i).gfp,3)
%         fprintf('.');
%         
%         a=mov.trap(i).gfp(:,:,j,phasechannel);
%         b=mov.trap(i).gfp(:,:,j,phasechannel);
%         c=mov.trap(i).gfp(:,:,j,phasechannel);
%         
%         a = double(imadjust(a,[meanphc/65535 maxphc/65535],[0 1]))/65535;
%         b = a; %double(imadjust(b,[meanphc/65535 maxphc/65535],[0 1]))/65535;
%         c = a; %double(imadjust(c,[meanphc/65535 maxphc/65535],[0 1]))/65535;
%         
%         im=double(zeros(size(a,1),size(a,2),3));
%         
%         im(:,:,1)=a;im(:,:,2)=b;im(:,:,3)=c;
%         vid(:,:,:,j)=uint8(256*im);
%         % figure, imshow(im,[])
%         
%         % return;
%         
%         if option==1
%             tr=num2str(j);
%             while numel(tr)<4
%                 tr=['0' tr];
%             end
%             
%             if mov.trap(i).div.deep(j)==0 % young budding cells
%                 if ~isfile([str '/unbudded/im_' mov.trap(i).id '_frame_' tr '.tif'])
%                     imwrite(im,[str '/unbudded/im_' mov.trap(i).id '_frame_' tr '.tif']);
%                 end
%             end
%             if mov.trap(i).div.deep(j)==1 % young budding cells
%                 if ~isfile([str '/smallbudded/im_' mov.trap(i).id '_frame_' tr '.tif'])
%                     imwrite(im,[str '/smallbudded/im_' mov.trap(i).id '_frame_' tr '.tif']);
%                 end
%             end
%             if mov.trap(i).div.deep(j)==2 % large budding cells
%                 if ~isfile([str '/largebudded/im_' mov.trap(i).id '_frame_' tr '.tif'])
%                     imwrite(im,[str '/largebudded/im_' mov.trap(i).id '_frame_' tr '.tif']);
%                 end
%             end
%         end
%         
%     end
%    fprintf('\n');
%    deep=mov.trap(i).div.deep;
%    save([mov.path '/labeled_video_' mov.trap(i).id '.mat'],'deep','vid','lab');
    
%end