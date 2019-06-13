classdef AnnotationMC
    % ANNOTATIONMC
    %  Annotation class used by all Datasets
    %  Stores information about the labels etc.
    %
    % Copyright by Holger Caesar, 2014
    
    properties        
        name;
        annotationFolder;
        metaFolder = 'Meta';
        imageCount = [];
        labelIdx = [];
        
        labelExt = '.mat';
        labelFormat = 'mat-labelMap';
        
        labelImageExt = '.mat';
        labelImageFormat = 'mat-labelList';
        
        hasPixelLabels = true;
        hasPixelLabelsOnlyTst = false;
        hasImageLabels = false;
        
        labelFolder;
        labelImageFolder;
        labelCount = [];
        imageListFunc = @(varargin) getImageListAll(varargin{:});
        namesFile = 'labelNames.mat';
        active = false;
        hasStuffThingLabels = false;
        labelOneIsBg = false;

        cmap = @jet;
    end
    
    methods
        % Constructor
        function[obj] = AnnotationMC(name)
            % [obj] = AnnotationMC(name)
            %
            % Annotation constructor
            
            if ~exist('name', 'var'),
                name = 'Original';
            end;
            
            obj.name = name;
            obj.annotationFolder = fullfile('Annotations', name);
            obj.labelFolder = fullfile(obj.annotationFolder, 'PixelLabels');
            obj.labelImageFolder = fullfile(obj.annotationFolder, 'ImageLabels');
        end
    end
end