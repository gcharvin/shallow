function classifyImageGoogleNetFun(roiobj,classif,classifier)

% this function can be used to classify any roi object, by providing the
% classi object and the classifier 

if numel(classifier)==0 % loading the classifier // not recommende because it takes time 
    path=classif.path;
    name=classif.strid;
    str=[path '/' name '.mat'];
    load(str); % load classifier 
end
% classify new images 

net=classifier; 
inputSize = net.Layers(1).InputSize;
classNames = net.Layers(end).ClassNames;
numClasses = numel(classNames);
    
    if numel(roiobj.image)==0
    roiobj.load;
    end
    
    pix=find(roiobj.channelid==classif.channel); % find channels corresponding to trained data
    gfp=roiobj.image(:,:,pix,:);
    
    if numel(pix)==1
    gfp=formatImage(gfp);
    end
    
    gfp = imresize(gfp,inputSize(1:2));
     
  %   class(gfp)
  %   trm=gfp(:,:,:,fr);
  %   max(trm(:))
    % BEWARE : rather use formatted image in lstm .mat variable
    % need to distinguish between formating for training versus validation
    % function --> formatfordeepclassification
    
    [label,scores] = classify(net,gfp);
    
    for i=1:numel(classif.classes)
        
    pix=label==classif.classes{i};
    
    roiobj.results(pix)=i;
    end
    




function im=formatImage(gfp)

    
    totphc=gfp;
    meanphc=0.5*double(mean(totphc(:)));
    maxphc=double(meanphc+0.7*(max(totphc(:))-meanphc));
    
    im=zeros(size(gfp,1),size(gfp,2),3,size(gfp,4));
    
    for j=1:size(gfp,4)
    fprintf('.');   
    
    a=gfp(:,:,1,:);
    
    a = double(imadjust(a,[meanphc/65535 maxphc/65535],[0 1]))/256;
    a= repmat(a,[1 1 3]);
    
   % im(:,:,1,j)=a;im(:,:,2,j)=b;im(:,:,3,j)=c;
    im(:,:,1,j)=uint8(a);
    end

    fprintf('\n');
    