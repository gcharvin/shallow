function trainImageRegressionFun(path,name)

% gather all classification images in each class and performs the training and outputs and saves the trained net 
% load training data 

fprintf('Loading data repository...\n');
fprintf('------\n');

% load images at once

imfolder=fullfile(path, '/trainingdataset/images');
list=dir([imfolder '/*.mat']);


for i=1:numel(list)
% aa=   list(i)
    load(fullfile(imfolder,list(i).name));
    
    if i==1
        imstore=im;
    else
        imstore(:,:,:,end+1:end+size(im,4))=im;
    end
end

% load response at once

imfolder=fullfile(path, '/trainingdataset/response');
list=dir([imfolder '/*.mat']);

for i=1:numel(list)
% aa=   list(i)
    load(fullfile(imfolder,list(i).name));
    if i==1
       restore=response;
    else
        restore(1,end+1:end+size(response,2))=response;
    end
end
restore=restore';

% imds = imageDatastore(foldername, ...
%  %   'IncludeSubfolders',true, ...
%     'LabelSource','foldernames'); 

% calculate class frequency for each class 

%ntot=countcats(imds.Labels);
%weights = double(ntot)/double(sum(ntot));

%classWeights = 1./countcats(imds.Labels);
%classWeights = classWeights'/mean(classWeights);


fprintf('Loading training options...\n');
fprintf('------\n');

load([path '/trainingParam.mat']);

%[imdsTrain,imdsValidation] = splitEachLabel(imds,trainingParam.split);

numClasses = 1;%numel(categories(imdsTrain.Labels));

fprintf('Loading network...\n');
fprintf('------\n');

switch trainingParam.network
    case 'googlenet'
net = googlenet;
    case 'resnet18'
net=resnet18;
    case 'resnet50'
net=resnet50;
    case 'resnet101'
net=resnet101;
    case 'nasnetlarge'
net=nasnetlarge;
    case 'inceptionresnetv2'
net=inceptionresnetv2;
   case 'efficientnetb0'
net=efficientnetb0;
    otherwise
fprintf('User selected custom CNN...\n');
eval(['net =' trainingParam.network]);        
end
%

inputSize = net.Layers(1).InputSize;

% adjusting data size to network 

imstore=imresize(imstore,inputSize(1:2));

fprintf('Reformatting net for transfer learning...\n');
fprintf('------\n');

% formatting the net for transferred learning
% extract the layer graph from the trained network 
if isa(net,'SeriesNetwork') 
  lgraph = layerGraph(net.Layers); 
else
  lgraph = layerGraph(net);
end

[learnableLayer,classLayer] = findLayersToReplace(lgraph);

%numClasses = numel(categories(imdsTrain.Labels));

%numClasses=1;

% adjust the final layers of the net
if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
    newLearnableLayer = fullyConnectedLayer(numClasses, ...
        'Name','new_fc', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
    
elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
    newLearnableLayer = convolution2dLayer(1,numClasses, ...
        'Name','new_conv', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
end

lgraph = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);

% removes softmax layer

for i=1:numel(lgraph.Layers)
if isa(lgraph.Layers(i),'nnet.cnn.layer.SoftmaxLayer')
    remLayerName=lgraph.Layers(i).Name; 
    break;
end
end

lgraph=removeLayers(lgraph, remLayerName);


%Change here to put or not class weighting
%newClassLayer = classificationLayer('Name','new_classoutput');

%newClassLayer = weightedClassificationLayer(classWeights,'new_classoutput');

newRegLayer = regressionLayer('Name','new_regoutput'); % creates reg layer
lgraph = replaceLayer(lgraph,classLayer.Name,newRegLayer); % replace classif layer by regresison layer
 lgraph = connectLayers(lgraph,"new_fc","new_regoutput"); % connect fc to reg layer
 
%fprintf('Freezing layers...\n');

% freezing layers
if strcmp(trainingParam.freeze,'y')
layers = lgraph.Layers;
connections = lgraph.Connections;

 layers(1:10) = freezeWeights(layers(1:10)); % only googlenet
 lgraph = createLgraphUsingConnections(layers,connections); % onlygooglnet
end

fprintf('Training network...\n');
fprintf('------\n');

% training network
% augment dataset

%pixelRange = trainingParam.translateAugmentation;
%rotation=trainingParam.rotateAugmentation;

% imageAugmenter = imageDataAugmenter( ...
%     'RandXReflection',true, ...
%     'RandYReflection',true, ...
%     'RandXTranslation',pixelRange, ...
%     'RandRotation',rotation, ...
%     'RandYTranslation',pixelRange, ...
%     'RandXScale',scaleRange, ...
%     'RandYScale',scaleRange);

% imageAugmenter = imageDataAugmenter( ...
%     'RandXReflection',true, ...
%     'RandYReflection',true, ...
%     'RandXTranslation',pixelRange, ...
%     'RandYTranslation',pixelRange, ...
%      'RandRotation',rotation);% , ...

  %  'RandXScale',scaleRange, ...
  %  'RandYScale',scaleRange);

% augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
%     'DataAugmentation',imageAugmenter);

%augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

miniBatchSize = trainingParam.MiniBatchSize; %8
valFrequency = 10; %floor(numel(augimdsTrain.Files)/miniBatchSize);

% if gpuDeviceCount>0
% disp('Using GPUs and multiple workers');
options = trainingOptions(trainingParam.method, ...
    'MiniBatchSize', trainingParam.MiniBatchSize, ...
    'MaxEpochs',trainingParam.MaxEpochs, ...
    'InitialLearnRate',trainingParam.InitialLearnRate, ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',10,...
    'LearnRateDropFactor',0.9,...
    'GradientThreshold',0.5, ...
    'L2Regularization',trainingParam.regularization, ...
    'Shuffle',trainingParam.Shuffle, ...
    'ValidationFrequency',valFrequency, ...
    'VerboseFrequency',10,...
    'Plots','training-progress',...
    'ExecutionEnvironment',trainingParam.ExecutionEnvironment);
  
 %   'ValidationData',augimdsValidation, ...
 
% else
%     disp('Using CPUs or whatever is available');
%    options = trainingOptions('sgdm', ...
%     'MiniBatchSize',miniBatchSize, ...
%     'MaxEpochs',6, ...
%     'InitialLearnRate',3e-4, ... % 3e-4
%     'Shuffle','every-epoch', ...
%     'ValidationData',augimdsValidation, ...
%     'ValidationFrequency',valFrequency, ...
%      'VerboseFrequency',2,...
%     'Plots','training-progress',...%     'ExecutionEnvironment','auto');
%  
% end

%size(imstore), size(restore)
%return;

classifier = trainNetwork(imstore,restore,lgraph,options);

fprintf('Training is done...\n');
fprintf('Saving image classifier ...\n');
fprintf('------\n');

%[path '/' name '.mat']

save([path '/' name '.mat'],'classifier');
CNNOptions=struct(options);

CNNOptions.ValidationData=[];
save([path '/TrainingValidation/' 'CNNOptions' '.mat'],'CNNOptions');
save([path '/TrainingValidation/' 'tmpoptions' '.mat'],'options');

% layers = freezeWeights(layers) sets the learning rates of all the
% parameters of the layers in the layer array |layers| to zero.
 saveTrainingPlot(path,'CNNTraining');
 
function layers = freezeWeights(layers)

for ii = 1:size(layers,1)
    props = properties(layers(ii));
    for p = 1:numel(props)
        propName = props{p};
        if ~isempty(regexp(propName, 'LearnRateFactor$', 'once'))
            layers(ii).(propName) = 0;
        end
    end
end

% lgraph = createLgraphUsingConnections(layers,connections) creates a layer
% graph with the layers in the layer array |layers| connected by the
% connections in |connections|.
        
function lgraph = createLgraphUsingConnections(layers,connections)

lgraph = layerGraph();
for i = 1:numel(layers)
    lgraph = addLayers(lgraph,layers(i));
end

for c = 1:size(connections,1)
    lgraph = connectLayers(lgraph,connections.Source{c},connections.Destination{c});
end

