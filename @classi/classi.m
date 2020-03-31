classdef classi < handle
    properties
        id=[] % number that identifies the classification algo
        
        typeid=1; % default category for classification found the classilist.mat file in the classification folde
        trainingset=[]; % % list of ROI ids used for training
        path='' %  path where 
        strid='';
        description='';
        category='';
        roi=roi('',[]); 
        channel=1;
        classes={}; % names of the classes
    end
    methods
        function obj = classi(path,name,id)
            
            if nargin<1
               path='';
               name=''; 
               id=1;
            end
            obj.path=path;
            obj.id=id;
            obj.strid=[name '_' num2str(id)];
            
            if numel(path)>0
            mkdir(path,'classification');
            obj.path=[path '/classification'];
            mkdir(obj.path,obj.strid);
            obj.path=[obj.path '/' obj.strid];
            end
        end
        
        function addTrainingData(obj,list)
           % list is provdided as a an array  FOVid // ROIs : [1 1 1 1; 1 2
           % 3 4 ]
           % HERE add training data 

           obj.trainingset=[obj.trainingset list];

           % copy files and ROI objects to training folder
           
           % update GUI to include classification capabilities
        end
        
    end
end
    