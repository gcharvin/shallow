function roiout=classifyPixelDeeplabNetFun(roiobj,classif,classifier)

% this function can be used to classify any roi object, by providing the
% classi object and the classifier

roiout=roiobj;

if numel(classifier)==0 % loading the classifier // not recommende because it takes time
    path=classif.path;
    name=classif.strid;
    str=[path '/' name '.mat'];
    load(str); % load classifier
end
% classify new images

net=classifier;

inputSize = net.Layers(1).InputSize;
% classNames = net.Layers(end).ClassNames;
% numClasses = numel(classNames);

%if numel(roiobj.image)==0 % load stored image in any case
    roiobj.load;
%end

pix=find(roiobj.channelid==classif.channel(1)); % find channels corresponding to trained data
gfp=roiobj.image(:,:,pix,:);

if numel(pix)==1
    gfp=formatImage(gfp);
end

 %figure, imshow(gfp(:,:,:,1));
% return;

%size(gfp)

%size(gfp)

% BEWARE : rather use formatted image in lstm .mat variable
% need to distinguish between formating for training versus validation
% function --> formatfordeepclassification

pixresults=findChannelID(roiobj,['results_' classif.strid]);

% pixe = strfind(roiobj.display.channel, ['results_' classif.strid]);
%         cc=[];
%         for j=1:numel(pixe)
%             if numel(pixe{j})~=0
%                 cc=j;
%                 break
%             end
%         end           

%if numel(cc)>0   

if numel(pixresults)>0 
    
%pixresults=find(roiobj.channelid==cc); % find channels corresponding to trained data
roiobj.image(:,:,pixresults,:)=uint16(zeros(size(gfp,1),size(gfp,2),1,size(gfp,4)));
else
   % add channel is necessary 
   matrix=uint16(zeros(size(gfp,1),size(gfp,2),1,size(gfp,4)));
   rgb=[1 1 1];
   intensity=[0 0 0];
   pixresults=size(roiobj.image,3)+1;
   roiobj.addChannel(matrix,['results_' classif.strid],rgb,intensity);
end

%pixresults
%roiobj
%return; 

for fr=1:size(gfp,4)
    fprintf('.');
    % fr
    tmp=gfp(:,:,:,fr);

    %figure, imshow(tmp);
    %return;
   
    %roiobj.image(:,:,pixresults,fr)=2;
    
    %mean(tmp(:))
   % pixresults
    
    %roiobj
    
    %figure, imshow(tmp);
    %return;
    
    if size(tmp,1)<inputSize(1) | size(tmp,2)<inputSize(2)
       tmp=imresize(tmp,inputSize(1:2)); 
    end
    
    %C = semanticseg(tmp, net); % this is no longer required if we extract the probabilities from the previous layer
    
%    if numel(gpuDeviceCount)==0
%     features = activations(net,tmp,'softmax-out'); % this is used to get the probabilities rather than the classification itself
%    else
%     features = activations(net,tmp,'softmax-out','Acceleration','mex');   
%    end

 [C,score,features]= semanticseg(tmp, net);%,'Acceleration','mex'); % this is no longer required if we extract the probabilities from the previous layer
    

    %size(features)
    
    if size(gfp,1)<inputSize(1) | size(gfp,2)<inputSize(2)
         features=imresize(features,size(gfp,1:2));
        C=imresize(C,size(gfp,1:2));
    end

     % mark as cell when probability is higher than 0.9

    % post processing --> watershed segmentation to be performed in a later
    % step 
    
    
    tmpout=uint16(zeros(size(roiobj.image(:,:,pixresults,fr))));
   
    for i=2:numel(classif.classes) % 1 st class is considered default class
       %if i>1
     BW=features(:,:,i)>0.9;   
     

     
    
       %  if sum(BW(:))>0
      %       'ok'
    %     end
  
     %  else
     %BW=features(:,:,2)>0.9;         
     %  end
       %end
     %BW=logical(C==string(classif.classes{i}));
     
       %   figure, imshow(BW,[]);
    %BW=logical(C==string(classif.classes{i}));
   % i
   % size(BW)
   % max(BW(:))
    %figure, imshow(BW,[]);

    res=uint16(uint8(BW)*(i));
    
    %pixresults
    %roiobj.image(:,:,pixresults,fr)=roiobj.image(:,:,pixresults,fr)+res;
    tmpout=tmpout+res;
    end
   % max(tmpout(:))
roiobj.image(:,:,pixresults,fr)=tmpout;

%     tm=roiobj.image(:,:,pixresults,fr); % assign 1 to defualt class
%     pix=roiobj.image(:,:,pixresults,fr)==0;
%     tm(pix)=1;
%     roiobj.image(:,:,pixresults,fr)=tm;
    
    %figure, imshow(roiobj.image(:,:,pixresults,fr),[]);
    
%     % TO DO add specific function to perform watershed don the result
% %     BW=~BW;
% %     
% %     imdist=bwdist(BW);
% %     imdist = imclose(imdist, strel('disk',2));
% %     imdist = imhmax(imdist,1);
% %     
% %     sous=- imdist;
% %     
% %     %figure, imshow(BW,[]);
% %     
% %     labels = double(watershed(sous,8)).* ~BW;% .* BW % .* param.mask; % watershed
% %     warning off all
% %     %tmp = imopen(labels > 0, strel('disk', 4));
% %     warning on all
% %     %tmp = bwareaopen(tmp, 50);
% %     
% %     newlabels = labels;% .* tmp; % remove small features
% %     newlabels = newlabels>0;
    
    %figure, imshow(newlabels,[]);
    %return
    
end

roiout=roiobj;
%roiobj.save;
%roiobj.clear;

fprintf('\n');


function im=formatImage(gfp)

totphc=gfp;
meanphc=0.5*double(mean(totphc(:)));
maxphc=double(meanphc+0.7*(max(totphc(:))-meanphc));

im=uint8(zeros(size(gfp,1),size(gfp,2),3,size(gfp,4)));

for j=1:size(gfp,4)
    fprintf('.');
    
    a=gfp(:,:,1,j);
    
    a = double(imadjust(a,[meanphc/65535 maxphc/65535],[0 1]))/256;
    a= repmat(a,[1 1 3]);
    
    % im(:,:,1,j)=a;im(:,:,2,j)=b;im(:,:,3,j)=c;
    im(:,:,:,j)=uint8(a);
end

fprintf('\n');


%
% function im=formatImage(gfp,phasechannel)
%
%     totphc=gfp(:,:,:,phasechannel);
%     meanphc=0.5*double(mean(totphc(:)));
%     maxphc=double(meanphc+0.7*(max(totphc(:))-meanphc));
%
%     im=zeros(size(gfp,1),size(gfp,2),3,size(gfp,3));
%
%     for j=1:size(gfp,3)
%     fprintf('.');
%
%     a=gfp(:,:,j,phasechannel);
%     b=gfp(:,:,j,phasechannel);
%     c=gfp(:,:,j,phasechannel);
%
%     a = double(imadjust(a,[meanphc/65535 maxphc/65535],[0 1]))/256;
%     b = a; %double(imadjust(b,[meanphc/65535 maxphc/65535],[0 1]))/65535;
%     c = a; %double(imadjust(c,[meanphc/65535 maxphc/65535],[0 1]))/65535;
%
%
%
%     im(:,:,1,j)=a;im(:,:,2,j)=b;im(:,:,3,j)=c;
%     im=uint8(im);
%     end
%
%     fprintf('\n');