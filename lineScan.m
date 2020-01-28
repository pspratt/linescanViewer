classdef lineScan
    % object for saving and manipulating line scan data
    
    properties
        name = [];
        date = [];
        xmlData = [];
        imagingParams = [];
        scan_image = [];
        
        % Parameters that vary between experiments
        expParams = [];
        
        % Imaging Data
        raw = []; %Raw data from each tiff file organized by channel
        red = [];
        green = [];
        time = [];
        
    end
    
    methods
        function obj = lineScan(path)
            % Initializes linescan file or folder designated by path
            
            if nargin < 1 % assume current directory if none specified
                path = pwd;
            end
            
            % Import Data that requires a line scan folder
            [~, obj.name] = fileparts(path);
            obj = importXmlData(obj,path);
            obj = importImagingData(obj,path);
            
            % Set standard values 
            obj.expParams.baselineStart = .1;
            obj.expParams.baselineEnd = .2;
            obj.expParams.skip = [];
            
            obj = updateLineScan(obj);
            obj = autoSetMaskCoords(obj);
            
        end
        
        function obj = skipSweeps(obj,skip)
            % updates expParams.spike with specified sweeps to skip
           
            obj.expParams.skip = skip;
            obj = updateLineScan(obj);
        end
        
        function obj = updateLineScan(obj)
            % Checks if various expParams are initialized and initializes
            % them if not to ensure backwarsd compatibility with older
            % versions of linescan objects
            % Red and Green are then recalculated from raw data based on
            % expParams
            
            % Should be split into two functions to separate expParam
            % checking and the updating of red and green
            
            obj.red = [];
            obj.green = [];
            
            if ~isfield(obj.expParams,'mask')
                if ~isempty(obj.raw.green)
                    imgDim = size(squeeze(obj.raw.green(1,:,:)));
                elseif ~isempty(obj.raw.red)
                    imgDim = size(squeeze(obj.raw.red(1,:,:)));
                end
                
                obj.expParams.mask = ones(imgDim);
                obj.expParams.maskCoord = [0 1 imgDim(1)+1 imgDim(2)-1];
            end
            
            if ~isfield(obj.expParams,'gsat')
                obj.expParams.gsat = NaN;
            end
            
            
            if ~isfield(obj.expParams,'skip')
                obj.expParams.skip = [];
            end
            
            if ~isfield(obj.expParams,'baselineStart')
                obj.expParams.baselineStart = 0.1;
            end
            
            if ~isfield(obj.expParams,'baselineEnd')
                obj.expParams.baselineEnd = 0.2;
            end
            
            if ~isempty(obj.raw.red)
                for i=1:length(obj.raw.red(:,1,1))
                    if ~ismember(i,obj.expParams.skip)
                        obj.red(i,:) = sum(squeeze(obj.raw.red(i,:,:)).*obj.expParams.mask,2)./length(find(obj.expParams.mask(1,:)));
                    else
                        obj.red(i,:) = NaN(1,length(obj.raw.red));
                    end
                end
                
            end
            
            if ~isempty(obj.raw.green)
                for i=1:length(obj.raw.green(:,1,1))
                    if ~ismember(i,obj.expParams.skip)
                        obj.green(i,:) = sum(squeeze(obj.raw.green(i,:,:)).*obj.expParams.mask,2)./length(find(obj.expParams.mask(1,:)));
                    else
                        obj.green(i,:) = NaN(1,length(obj.raw.green));
                    end
                end
            end
            
            if ~isfield(obj.expParams,'spikeTimes')
                
                obj.expParams.spikeTimes = [0.2 .22 .24];
            end
            
        end
        
        function obj = updateLineScanXML(obj)
            % This updates the imaging params based on the linescan XML
            % it is far too complex and should be simplieid
            try 
                if ~isempty(obj.imagingParams.complete_params) %is it a new import

                    if strcmp(obj.imagingParams.complete_params.praire_version,'5.0.32.100')
                        if strcmp(obj.imagingParams.complete_params.ch1,'red') ||...
                                strcmp(obj.imagingParams.complete_params.ch2,'green')
                            obj.imagingParams.rig = 'bluefish';
                        else
                            obj.imagingParams.rig = 'Thing1';
                        end
                    else
                        obj.imagingParams.rig = 'Thing2';
                    end
                    obj.imagingParams.greenPMTGain = [];
                    obj.imagingParams.redPMTGain = [];
                    obj.imagingParams.laserPower = [];
                    obj.imagingParams.numFrames = str2double(obj.imagingParams.complete_params.numFrames);
                    obj.imagingParams.pixelsPerLine = str2double(obj.imagingParams.complete_params.pixelsPerLine);
                    obj.imagingParams.linesPerFrame = str2double(obj.imagingParams.complete_params.linesPerFrame);
                    obj.imagingParams.scanlinePeriod = str2double(obj.imagingParams.complete_params.scanlinePeriod);
                    obj.imagingParams.micronPerPixelX = str2double(obj.imagingParams.complete_params.micronsPerPixel_XAxis);
                end
            catch                           
                try
                    if obj.xmlData.PVScan.Sequence{1, 1}.Frame.File{1, 2}.Attributes.channel == '3'
                        obj.imagingParams.rig = 'Thing1';
                    end
                catch
                end
                
                
                try
                    if obj.xmlData.PVScan.Sequence{1, 1}.Frame.File{1, 2}.Attributes.channel == '2' &&...
                            strcmp(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 5}.Attributes.key,'linesPerFrame')
                        obj.imagingParams.rig = 'Thing2';
                    end
                catch
                    
                end
                
                try
                    if obj.xmlData.PVScan.Sequence{1, 1}.Frame.File.Attributes.channel   == '1' &&...
                            strcmp(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 5}.Attributes.key,'linesPerFrame')
                        obj.imagingParams.rig = 'Thing2';
                    end
                catch
                end
                
                if strcmp(obj.imagingParams.rig,'bluefish')
                    obj.imagingParams.greenPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 23}.Attributes.value);
                    obj.imagingParams.redPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 25}.Attributes.value);
                    obj.imagingParams.laserPower = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 28}.Attributes.value);
                    obj.imagingParams.numFrames = length(obj.xmlData.PVScan.Sequence);
                    obj.imagingParams.pixelsPerLine = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 6}.Attributes.value);
                    obj.imagingParams.linesPerFrame = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 7}.Attributes.value);
                    obj.imagingParams.scanlinePeriod = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 12}.Attributes.value);
                    obj.imagingParams.micronPerPixelX = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 21}.Attributes.value);
                elseif strcmp(obj.imagingParams.rig,'Thing1')
                    obj.imagingParams.greenPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 28}.Attributes.value);
                    obj.imagingParams.redPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 23}.Attributes.value);
                    
                    %Because there are two lasers...
                    laser0 = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 29}.Attributes.value);
                    laser1 = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 30}.Attributes.value);
                    if laser0 > laser1
                        obj.imagingParams.laserPower = laser0;
                    else
                        obj.imagingParams.laserPower = laser1;
                    end
                    
                    obj.imagingParams.numFrames = length(obj.xmlData.PVScan.Sequence);
                    obj.imagingParams.pixelsPerLine = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 6}.Attributes.value);
                    obj.imagingParams.linesPerFrame = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 7}.Attributes.value);
                    obj.imagingParams.scanlinePeriod = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 12}.Attributes.value);
                    obj.imagingParams.micronPerPixelX = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 21}.Attributes.value);
                    
                elseif strcmp(obj.imagingParams.rig,'Thing2')
                    obj.imagingParams.greenPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 20}.Attributes.value);
                    obj.imagingParams.redPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 22}.Attributes.value);
                    obj.imagingParams.laserPower = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 24}.Attributes.value);
                    obj.imagingParams.numFrames = length(obj.xmlData.PVScan.Sequence);
                    obj.imagingParams.pixelsPerLine = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 4}.Attributes.value);
                    obj.imagingParams.linesPerFrame = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 5}.Attributes.value);
                    obj.imagingParams.scanlinePeriod = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 9}.Attributes.value);
                    obj.imagingParams.micronPerPixelX = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 12}.Attributes.value);
                end
            end
            
            obj.time = 0:obj.imagingParams.scanlinePeriod:obj.imagingParams.scanlinePeriod*(obj.imagingParams.linesPerFrame-1);
        end
        
        function saveLS(obj,path)
            % Saves linescan objects to mat files
            if nargin ==2
                save([path filesep obj.name '.mat'],'obj');
            else
                save([obj.name '.mat'],'obj');
            end
        end
        
        function trace = meanGreen(obj)
            % Returns the mean green values across sweeps
            % To do: Add errors if no green value is present
            
            [numScans, ~] = size(obj.green);
            if numScans > 1 % check if there is more than one scan
                trace = nanmean(obj.green);
            else
                trace = obj.green;
            end
        end
        
        function trace = meanRed(obj)
            % Returns the mean red values across sweeps
            % To do: Add errors if no red value is present
            
            [numScans, ~] = size(obj.red);
            if numScans > 1 % check if there is more than one scan
                trace = nanmean(obj.red);
            else
                trace = obj.red;
            end
        end
        
        function trace = GoR(obj)
            % Returns mean of the green/red signal of each sweep
            for i=1:length(obj.green(:,1))
                traces(i,:) = obj.green(i,:)./obj.red(i,:);
            end
            
            [numScans, ~] = size(traces);
            if numScans > 1 % check if there is more than one scan
                trace = traces;
            else
                trace = nanmean(traces);
            end
        end
        
        function trace = normGreen(obj)
            % returns the mean ?F/F of the green channel normalized to the
            % baseline interval
            
            for i=1:length(obj.green(:,1))
                normTraces(i,:) = obj.normalize(obj.green(i,:));
            end
            
            [numScans, ~] = size(normTraces);
            if numScans > 1 % check if there is more than one scan
                trace = nanmean(normTraces);
            else
                trace = normTraces;
            end
        end
        
        function trace = normRed(obj)
            % returns the mean ?F/F of the red channel normalized to the
            % baseline interval
            
            for i=1:length(obj.red(:,1))
                normTraces(i,:) = obj.normalize(obj.red(i,:));
            end
            
            [numScans, ~] = size(normTraces);
            if numScans > 1 % check if there is more than one scan
                trace = nanmean(normTraces);
            else
                trace = normTraces;
            end
        end
        
        function trace = normGoR(obj)
            % Returns the mean ?G/R values across sweeps
            
            for i=1:length(obj.green(:,1))
                if isnan(obj.expParams.gsat)
                    normTraces(i,:) = obj.baseline_subtraction(obj.green(i,:))./obj.red(i,:);
                else % if Gsat is specified, divide by Gsat
                    normTraces(i,:) = (obj.baseline_subtraction(obj.green(i,:))./obj.red(i,:))./obj.expParams.gsat;
                end
                
            end
            [numScans, ~] = size(normTraces);
            if numScans > 1
                trace = nanmean(normTraces);
            else
                trace = normTraces;
            end
        end
        
        function normalizedTrace = normalize(obj,trace)
            % returns the dF/F of a trace
            baseline  = getBaseline(obj,trace);
            normalizedTrace = (trace - baseline)/baseline;
            
        end
        
        function trace = baseline_subtraction(obj,trace)
            % returns baseline subtracted trace
            baseline  = getBaseline(obj,trace);
            trace = trace - baseline;
            
        end
        
        function baseline = getBaseline(obj,trace)
            % Returns mean value between baselineStart and baselineEnd of a
            % trace
            baseline = nanmean(trace(1,...
                floor(obj.expParams.baselineStart/obj.imagingParams.scanlinePeriod):...
                floor(obj.expParams.baselineEnd/obj.imagingParams.scanlinePeriod)));
        end
                
        function index = time2index(obj,time)
            % Returns the array index closest to a specified time 
            
            if time > obj.time(end)
                index = length(obj.time);
                warning('Time index requested is out of bounds');
            elseif time < 0
                index = 1;
                warning('Time index requested is out of bounds')
            else
                index = round(time./obj.imagingParams.scanlinePeriod)+1;% +1 accounts for the time array starting with index 1 not 0
            end
        end
        
        function time = index2time(obj,index)
            % Returns the time at a specified intex
            
            if index <= 0
                time = obj.time(1);
            elseif index > length(obj.time)
                time = obj.time(end);
            else
                time = obj.time(index);
            end
        end
        
        
        %% Ploting
        function h = showImage(obj)
            
            if ~isempty(obj.red)
                subplot(2,1,1)
                imshow(uint16(squeeze(nanmean(obj.red))),[]);
                title({['Red Channel '];[obj.name]},'fontsize',16);
                subplot(2,1,2)
                imshow(uint16(squeeze(nanmean(obj.green))),[]);
                title({['Green Channel '];[obj.name]},'fontsize',16);
            else
                imshow(uint16(squeeze(nanmean(obj.green))),[]);
                title(['Green Channel for ' obj.name]);
            end
            
            h = figure(length(findobj('type','figure')));
        end
        
        function ax = plotGreen(obj,norm,smoothing)
            if ~isempty(obj.green)
                %parse arguments
                if nargin == 1
                    norm = 0;
                    smoothing = 3;
                elseif nargin == 2
                    smoothing = 3;
                end
                
                cla;
                hold on;
                
                if norm == 1
                    for j=1:length(obj.green(:,1))
                        trace = obj.normalize(obj.green(j,:));
                        trace = smooth(trace, smoothing);
                        ax = plot(obj.time,trace,'color',[0.7,1,.7]);
                    end
                    plot(obj.time,smooth(obj.normGreen,smoothing),'k');
                    title([obj.name ' Norm Green'],'fontsize',14)
                else
                    for j=1:length(obj.green(:,1))
                        trace = obj.green(j,:);
                        trace = smooth(trace, smoothing);
                        ax = plot(obj.time,trace,'color',[0.7,1,.7]);
                    end
                    plot(obj.time,smooth(obj.meanGreen,smoothing),'k');
                    title([obj.name ' Green'],'fontsize',14)
                end
                
                xlabel('Time (s)','FontSize',14);
                xlim([0 floor(obj.time(end)*100)/100]);
                set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
                    'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
                    'XColor', 'k', 'YColor', 'k',  ...
                    'LineWidth', 1,'FontName','arial','FontSize',12);
                
            end
        end
        
        function ax = plotRed(obj,norm,smoothing)
            if ~isempty(obj.red)
                
                %parse arguments
                if nargin == 1
                    norm = 0;
                    smoothing = 3;
                elseif nargin == 2
                    smoothing = 3;
                end
                
                cla;
                hold on;
                
                if norm == 1
                    for j=1:length(obj.red(:,1))
                        trace = obj.normalize(obj.red(j,:));
                        trace = smooth(trace, smoothing);
                        ax = plot(obj.time,trace,'color',[1,.85,.85]);
                    end
                    plot(obj.time,smooth(obj.normRed,smoothing),'k');
                    title([obj.name ' Norm Red'],'fontsize',14)
                else
                    for j=1:length(obj.red(:,1))
                        trace = obj.red(j,:);
                        trace = smooth(trace, smoothing);
                        ax = plot(obj.time,trace,'color',[1,.85,.85]);
                    end
                    plot(obj.time,smooth(obj.meanRed,smoothing),'k');
                    title([obj.name ' Red'],'fontsize',14)
                end
                
                xlabel('Time (s)','FontSize',14);
                xlim([0 floor(obj.time(end)*100)/100]);
                set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
                    'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
                    'XColor', 'k', 'YColor', 'k',  ...
                    'LineWidth', 1,'FontName','arial','FontSize',12);
                
            end
        end
        
        function plotGoverR(obj,norm,smoothing)
            if ~isempty(obj.red) && ~isempty(obj.green)
                
                %parse arguments
                if nargin == 1
                    norm = 0;
                    smoothing = 3;
                elseif nargin == 2
                    smoothing = 3;
                end
                
                cla;
                hold on;
                
                if norm == 1
                    for j=1:length(obj.green(:,1))
                        %                         trace = obj.normalize(obj.green(j,:)./obj.red(j,:),obj.expParams.baselineStart,obj.expParams.baselineEnd
                        trace = obj.baseline_subtraction(obj.green(j,:))./obj.red(j,:);
                        trace = smooth(trace, smoothing);
                        
                        if ~isnan(obj.expParams.gsat)
                            trace = trace./obj.expParams.gsat;
                        end
                        ax = plot(obj.time,trace,'color',[.85,.85,1]);
                    end
                    
                    
                    plot(obj.time,smooth(obj.normGoR,smoothing),'k');
                    title([obj.name ' Norm G/R'],'fontsize',14)
                else
                    for j=1:length(obj.red(:,1))
                        trace = obj.green(j,:)./obj.red(j,:);
                        trace = smooth(trace, smoothing);
                        ax = plot(obj.time,trace,'color',[.85,.85,1]);
                    end
                    plot(obj.time,smooth(obj.GoR,smoothing),'k');
                    title([obj.name ' G/R'],'fontsize',14)
                end
                
                xlabel('Time (s)','FontSize',14);
                xlim([0 floor(obj.time(end)*100)/100]);
                set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
                    'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
                    'XColor', 'k', 'YColor', 'k',  ...
                    'LineWidth', 1,'FontName','arial','FontSize',12);
            end
            
            
        end
        
        function display_image(obj)
            for j=1:length(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key)
                if strcmp(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.key,'rotation')
                    angle  = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.value);
                end
            end
            
            try
                rotated_ls_im = imrotate(obj.scan_image(:,:,1:3),angle);
            catch
                rotated_ls_im = imrotate(obj.scan_image(:,:,1),angle);
            end
            imshow(rotated_ls_im);
        end
        
    end
    
    methods(Access = private)
        %Functions called to initialized the line scan
  
        function obj = importXmlData(obj,path2dir)
            %Imports the xml file into an xml object that is easy to parse
            %with matlab. Requires xml2struct
            try
                xmlFile = dir([path2dir filesep 'LineScan*.xml']);
                obj.xmlData = xml2struct([path2dir filesep xmlFile.name]);
                obj.date = obj.xmlData.PVScan.Attributes.date;
                obj.imagingParams.complete_params = parse_linescan_xml([path2dir filesep xmlFile.name]);
            catch
                error(['No xml file found for ' obj.name]);
            end
            
            obj = updateLineScanXML(obj);
            
        end
        
        function obj = importImagingData(obj,path)
            % collects data from line scan folder
            sortLineScan(obj.imagingParams.rig,path);
            
            % Import imaging data
            alexaFiles = dir([path '/Alexa/LineScan*.tif']);
            fluoFiles = dir([path '/Fluo/LineScan*.tif']);
            
            if ~isempty(alexaFiles)
                for i=1:length(alexaFiles)
                    obj.raw.red(i,:,:) = double(imread([path filesep 'Alexa' filesep alexaFiles(i).name]));
                end
            else
                obj.raw.red = [];
            end
            
            if ~isempty(fluoFiles)
                for i=1:length(fluoFiles)
                    obj.raw.green(i,:,:) = double(imread([path filesep 'Fluo' filesep fluoFiles(i).name]));
                end
            else
                obj.raw.green = [];
            end
            
            if strcmp(obj.imagingParams.rig,'bluefish')
                ls_img_filename = dir([path filesep 'References' filesep '*8bit-Reference.tif']);
            else
                ls_img_filename = dir([path filesep 'References' filesep '*Reference.tif']);
            end
            
            obj.scan_image = uint8(imread([path filesep 'References' filesep ls_img_filename(1).name]));
            
        end
        
        function obj = autoSetMaskCoords(obj)
            % Automatically estimates where along the linescan the object
            % of interest is by where the mean of the signal is larger than
            % the median
                if ~isempty(obj.red) % if red channel exists, use it
                    limits = find(mean(squeeze(mean(obj.raw.red))) > median(mean(squeeze(mean(obj.raw.red)))));
                    obj.expParams.maskCoord(2) = limits(1)  ;
                    obj.expParams.maskCoord(4) = limits(end)-limits(1);
                    obj = updateLineScan(obj);
                elseif ~isempty(obj.green) % otherwise use green channel
                    limits = find(mean(squeeze(mean(obj.raw.green))) > median(mean(squeeze(mean(obj.raw.green)))));
                    obj.expParams.maskCoord(2) = limits(1)  ;
                    obj.expParams.maskCoord(4) = limits(end)-limits(1);
                    obj = updateLineScan(obj);
                end
        end
    end
    
    
end





