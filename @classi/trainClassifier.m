function trainClassifier(classif)


% first format data for training procedure and save to disk

prompt='If you have not yet formatted groundtruth dataset for training, you need to do it first. Do it (y/n) (Default: n): ';
fmt= input(prompt,'s');
if numel(fmt)==0
    fmt='n';
end


if strcmp(fmt,'y')
    disp('OK, the ground truth dataset will be formatted before launching the training');
end


% set parameters
classif.setTrainingParam;

% first format data for training procedure and save to disk

if strcmp(fmt,'y')
    classif.formatDataForTraining;
end

% launch the classification-specific training procedure

trainingFun=classif.trainingFun;

path=classif.path;
name=classif.strid;

disp(['Launching training procedure with ' trainingFun]);

feval(trainingFun,path,name); % launch the training function for classification

            
