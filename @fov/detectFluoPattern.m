function detectFluoPattern(obj,varargin)
%This function detects if a fluoThreshold has been reached for at least
%frameThreshold frames in obj.roi(r).results.classiid.fluo.methodf(c,t) for the 'Channels' c using the 'Method'.
%Stores the info in fov.flaggedROIs
%obj.extractFluo must have been run beforehand.

%Arguments:
%*'Method': 'maxPixels' check .fluo.maxf // 'mean' checks the fluo.meanf
%*'Channels'
%*'Frames'
%*'Rois'
%*'fluoThreshold'
%*'frameThreshold' number of frames to be above fluoThreshold

fluoThreshold=1500;
frameThreshold=5;
frames=1:numel(obj.srclist{1}); % take the number of frames from the image list 
rois=1:numel(obj.roi);
method='maxPixels';
channels=1:numel(obj.srcpath);
if numel(channels)>1
    channels=2:numel(obj.srcpath); %avoid channel 1 that is mostof the time not fluo
end

for i=1:numel(varargin)
    %Method
    if strcmp(varargin{i},'Method')
        method=varargin{i+1};
        if strcmp(method,'maxPixels') && strcmp(method,'mean')
            error('Please enter a valide method');
        end
    end
    %fluoThresold
    if strcmp(varargin{i},'fluoThreshold')
        fluoThreshold=varargin{i+1};
    end

    %timeThresold
    if strcmp(varargin{i},'frameThreshold')
        frameThreshold=varargin{i+1};
    end
    
    %Frames
    if strcmp(varargin{i},'Frames')
        frames=varargin{i+1};
    end
    
    %Rois
    if strcmp(varargin{i},'Rois')
        rois=varargin{i+1};
    end
    
    %Channels
    if strcmp(varargin{i},'Channels')
        channels=varargin{i+1};
    end
end

if numel(obj.roi(rois(1)).results)~=0
    classiid=fieldnames(obj.roi(rois(1)).results);
    str=[];
    for i=1:numel(classiid)
        str=[str num2str(i) ' - ' classiid{i} ';'];
    end
    prompt=['Choose which classi : ' str];
    classiidsNum=input(prompt);
    if numel(classiidsNum)==0
       classiidsNum=numel(classiid);
    end
    classiid=classiid{classiidsNum};
else
    error('You must extract the fluo of the ROI before running this method. See .extractFluo');
end

%%
if strcmp(method,'maxPixels')
    obj.flaggedROIs=[];
    for r=rois %to parfor
        for c=channels
            flagFluo=0;
            for t=frames
                if numel(obj.roi(r).results.(classiid).fluo.maxf)==0
                    error('You must extract the meanfluo of the ROI before running this method. See .extractFluo. At least one frame has not been extracted');
                elseif obj.roi(r).results.(classiid).fluo.maxf(c,t)>fluoThreshold
                    flagFluo=flagFluo+1;
                end
            end
            if flagFluo>frameThreshold
                if ~ismember(r,obj.flaggedROIs) % to avoid redundancy in case 2 channels are positive
                    obj.flaggedROIs=[obj.flaggedROIs r];
                end
                disp(['ROI' num2str(r) ' is positive for channel ' num2str(c)])
            else
                disp(['ROI' num2str(r) ' is negative for channel ' num2str(c)])
            end
        end
        fprintf('\n')
    end
end




if strcmp(method,'mean')
    obj.flaggedROIs=[];
    for r=rois %to parfor
        for c=channels
            flagFluo=0;
            for t=frames
                if numel(obj.roi(r).results.(classiid).fluo.meanf)==0
                    error('You must extract the meanfluo of the ROI before running this method. See .extractFluo. At least one frame has not been extracted');
                elseif obj.roi(r).results.(classiid).fluo.meanf(c,t)>fluoThreshold
                    flagFluo=flagFluo+1;
                end
            end
            if flagFluo>frameThreshold
                if ~ismember(r,obj.flaggedROIs) % to avoid redundancy in case 2 channels are positive
                    obj.flaggedROIs=[obj.flaggedROIs r];
                end
                disp(['ROI' num2str(r) ' is positive for channel ' num2str(c)])
            else
                disp(['ROI' num2str(r) ' is negative for channel ' num2str(c)])
            end
        end
        fprintf('\n')
    end
end