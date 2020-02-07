function linescanViewer(scans)
% linescanViewer allows for the visualization of linescan data aquired by
% prarrieview 2-photon imaging systems

% 

lineScanUI = figure;

%% GUI Specification %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Panel specification
% Specifies name and location of panels that group related types of controls

panel_load = uipanel(...
    'units','normalized',...
    'position',[.825 .8 .15 .15]);

panel_imageOrPlot = uibuttongroup(...
    'units','normalized',...
    'position',[.825 .75 .15 .05],...
    'SelectionChangeFcn',@function_selectPlotOrImage);

panel_selectChannel = uibuttongroup(...
    'units','normalized',...
    'position',[.825 .6 .075 .15],...
    'SelectionChangeFcn',@function_selectChannel);

panel_selectContent = uibuttongroup(...
    'units','normalized',...
    'position',[.9 .6 .075 .15],...
    'SelectionChangeFcn',@function_selectgroupScanOrSweep);

panel_normalize = uibuttongroup(...
    'units','normalized',...
    'position',[.825 .4 .15 .2],...
    'SelectionChangeFcn',@function_selectNormalization);

panel_gsat = uipanel(...
    'units','normalized',...
    'position',[.825 .35 .15 0.05]);

panel_skip = uipanel(...
    'units','normalized',...
    'position',[.825 .3 .15 0.05]);

panel_smoothing = uipanel(...
    'units','normalized',...
    'position',[.825 .25 .15 .05]);

panel_imagingParams = uipanel(...
    'units','normalized',...
    'position',[.825 .1 .15 0.15]);

panel_changeScans = uipanel(...
    'visible','off',...
    'units','normalized',...
    'position',[.3 .9 .3 .05]);

panel_changeSweeps = uipanel(...
    'visible','off',...
    'units','normalized',...
    'position',[.3 .9 .3 .05]);

panel_axisLimits = uipanel(...
    'units','normalized',...
    'position',[0.025 0.35 .05 .2]);

%% Panel_axisLimits
% Controls for changing the y axis limits

edit_yMax = uicontrol('Style', 'edit',...
    'String', '2.5',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [0 .66 1 .33],...  
    'Callback', @function_changeYlim,...
    'parent',panel_axisLimits);

text_yLimit = uicontrol('Style', 'pushbutton',...
    'String', 'Auto',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [0 .33 1 .33],...
    'Callback', @function_autoYlim,...
    'parent',panel_axisLimits);


edit_yMin = uicontrol('Style', 'edit',...
    'String', '-0.5',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [0 0 1 .33],...  
    'Callback', @function_changeYlim,...
    'parent',panel_axisLimits);

%% panel_load
% panel that controls loading, changing, and saving of linescan
% folders and files
push_setPath = uicontrol('Style', 'pushbutton',...
    'String', 'Set Path',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [0 .66 .5 .33],...
    'Callback', @function_setPath,...
    'parent',panel_load);

push_load = uicontrol('Style', 'pushbutton',...
    'String', 'Load',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [.5 .66 .5 .33],...
    'Callback', @function_loadLinescans,...
    'parent',panel_load);

push_load = uicontrol('Style', 'pushbutton',...
    'String', 'Save',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [0 .33 1 .33],...
    'Callback', @function_saveLineScans,...
    'parent',panel_load);

push_export = uicontrol('Style', 'pushbutton',...
    'String', 'Export',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [0 0 1 .33],...
    'Callback', @function_exportFigure,...
    'parent',panel_load);

%% panel_selectChannel
% Controls for specifying which imaging channels are displayed

radio_green = uicontrol('Style', 'radiobutton',...
    'FontUnits','normalized',...
    'String', 'Green',...
    'Units','normalized',...
    'Position', [0.1 .66 1 .33],...
    'parent',panel_selectChannel);

radio_red = uicontrol('Style', 'radiobutton',...,...
    'FontUnits','normalized',...
    'String', 'Red',...
    'Units','normalized',...
    'Position', [0.1 .33 1 .33],...
    'parent',panel_selectChannel);

radio_GoR = uicontrol('Style', 'radiobutton',...,...
    'FontUnits','normalized',...
    'String', 'G/R',...
    'Units','normalized',...
    'Position', [0.1 0 1 .33],...
    'parent',panel_selectChannel);

%% panel_imageOrPlot
% Controls for switching from 
radio_plot = uicontrol('Style', 'radiobutton',...
    'FontUnits','normalized',...
    'String', 'Plot',...
    'Units','normalized',...
    'Position', [0.1 0 0.5 1],...
    'parent',panel_imageOrPlot);

radio_images = uicontrol('Style', 'radiobutton',...
    'FontUnits','normalized',...
    'String', 'Images',...
    'Units','normalized',...
    'Position', [0.5 0 0.5 1],...
    'parent',panel_imageOrPlot);

%panel_selectContent
radio_group = uicontrol('Style', 'radiobutton',...,...
    'FontUnits','normalized',...
    'String', 'Group',...
    'Units','normalized',...
    'Position', [0.1 .66 1 .33],...
    'parent',panel_selectContent);

radio_scans = uicontrol('Style', 'radiobutton',...,...
    'FontUnits','normalized',...
    'String', 'Scans',...
    'Units','normalized',...
    'Position', [0.1 .33 1 .33],...
    'parent',panel_selectContent);

radio_sweep = uicontrol('Style', 'radiobutton',...,...
    'FontUnits','normalized',...
    'String', 'Sweeps',...
    'Units','normalized',...
    'Position', [0.1 0 1 .33],...
    'parent',panel_selectContent);

%% panel_gsat
text_gsat = uicontrol('Style', 'text', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [0 0 0.3 1],...
    'string','G_sat',...
    'parent',panel_gsat);

edit_gsat = uicontrol('Style', 'edit', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.3 0 .7 1],...
    'string','',...
    'Callback', @function_setGsat,...
    'parent',panel_gsat);

%% panel_skip
text_skip = uicontrol('Style', 'text', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [0 0 0.3 1],...
    'string','Skip',...
    'parent',panel_skip);

edit_skip = uicontrol('Style', 'edit', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.3 0 .7 1],...
    'string','',...
    'Callback', @function_setSkips,...
    'parent',panel_skip);

%% panel_normalize
radio_normalize = uicontrol('Style', 'radiobutton',...,...
    'FontUnits','normalized',...
    'String', 'Normalized',...
    'Units','normalized',...
    'Position', [.1 .758 .9 .25],...
    'parent',panel_normalize);

radio_unnormalize = uicontrol('Style', 'radiobutton',...,...
    'FontUnits','normalized',...
    'String', 'Unnormalized',...
    'Units','normalized',...
    'Position', [.1 .5 .9 .25],...
    'parent',panel_normalize);

text_baselineStart = uicontrol('Style', 'text',...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.05 .25 .6 .25],...
    'string','Baseline start',...
    'parent',panel_normalize);

edit_baselineStart = uicontrol('Style', 'edit', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.7 .25 .3 .25],...
    'string',.1,...
    'Callback', @function_setBaselineStart,...
    'parent',panel_normalize);

text_baselineEnd = uicontrol('Style', 'text', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.05 0 .6 .25],...
    'string','Baseline end',...
    'parent',panel_normalize);

edit_baselineEnd = uicontrol('Style', 'edit', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.7 0 .3 .25],...
    'string',.2,...
    'Callback', @function_setBaselineEnd,...
    'parent',panel_normalize);

%% panel_smoothing
text_smoothing = uicontrol('Style', 'text', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.1 0 .4 1],...
    'string','Smooth',...
    'parent',panel_smoothing);

edit_smoothing = uicontrol('Style', 'edit', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.5 0 .5 1],...
    'string',1,...
    'Callback', @function_setSmoothing,...
    'parent',panel_smoothing);

%% panel_imagingParams

text_rig = uicontrol('Style', 'text', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.1 0.75 .9 .25],...
    'HorizontalAlignment','left',...
    'string','Rig: ',...
    'parent',panel_imagingParams);

text_greenPMT = uicontrol('Style', 'text', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.1 0.5 .9 .25],...
    'HorizontalAlignment','left',...
    'string','Green PMT: ',...
    'parent',panel_imagingParams);

text_redPMT = uicontrol('Style', 'text', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.1 0.25 .9 .25],...
    'HorizontalAlignment','left',...
    'string','Red PMT: ',...
    'parent',panel_imagingParams);

text_laser = uicontrol('Style', 'text', ...
    'FontUnits','normalized',...
    'Units','normalized',...
    'Position', [.1 0 .9 .25],...
    'HorizontalAlignment','left',...
    'string','Laser: ',...
    'parent',panel_imagingParams);

%% panel_changeScans
push_nextScan = uicontrol('Style', 'pushbutton',...
    'String', 'Next',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [.66 0 .33 1],...
    'Callback', @function_nextScan,...
    'parent',panel_changeScans);

push_prevScan = uicontrol('Style', 'pushbutton',...
    'String', 'Prev',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [0 0 .33 1],...
    'Callback', @function_prevScan,...
    'parent',panel_changeScans);

edit_goToScan = uicontrol('Style', 'edit', ...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [.33 0 .33 1],...
    'Callback', @function_goToScan,...
    'parent',panel_changeScans);

%% panel_changeSweeps
push_nextSweep = uicontrol('Style', 'pushbutton',...
    'String', 'Next',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [.66 0 .33 1],...
    'Callback', @function_nextSweep,...
    'parent',panel_changeSweeps);

push_prevSweep = uicontrol('Style', 'pushbutton',...
    'String', 'Prev',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [0 0 .33 1],...
    'Callback', @function_prevSweep,...
    'parent',panel_changeSweeps);

edit_goToSweep = uicontrol('Style', 'edit', ...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position', [.33 0 .33 1],...
    'Callback', @function_goToSweep,...
    'parent',panel_changeSweeps);

%% setThresh buttons
edit_greenThresh = uicontrol('Style', 'edit',...
    'visible','off',...
    'String', 'View Traces',...
    'Units','normalized',...
    'Units','normalized',...
    'Position', [.02 .7 .05 .05],...
    'string','300',...
    'Callback', @function_setGreenThresh);

edit_redThresh = uicontrol('Style', 'edit',...
    'visible','off',...
    'String', 'View Traces',...
    'Units','normalized',...
    'Units','normalized',...
    'Position', [.02 .3 .05 .05],...
    'string','300',...
    'Callback', @function_setRedThresh);

%% Axes
plot_ax = axes('position',[0.1,0.17,0.7,0.65]);
image_ax1 = axes('Position',[0.1, 0.1, 0.7, 0.3],'visible','off');
image_ax2 = axes('Position',[0.1, 0.5, 0.7, 0.3],'visible','off');
set(lineScanUI,'Units','normalized','position',[.1 .1 .8 .8]);

%% Backend %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Variable Initialization
channel = 2;
scan = 1;
sweep = 1;
groupScanOrSweep = 1;
plotOrImage = 1;
norm = 1;
displayFigures = 1;
set(lineScanUI,'currentaxes',plot_ax)
cla;
plot([0 1],[0 0],'k');
ylim([str2double(get(edit_yMin,'String')) str2double(get(edit_yMax,'String'))]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
            'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
            'XColor', 'k', 'YColor', 'k',  ...
            'LineWidth', 1,'FontName','arial','FontSize',12);
if nargin == 1
    update;
end

%% UI Control Functions

    function function_setGsat(source,callbackdata)
       gsat = eval(['[' get(source,'string') ']']);
       
       scans(scan).expParams.gsat =  gsat;
       if groupScanOrSweep == 1
           for i=1:length(scans)
               scans(i).expParams.gsat =  gsat;
           end
       else
           scans(scan).expParams.gsat =  gsat;
       end    
              
       update;
    end

    function function_changeYlim(source,callbackdata)
        ylim([str2double(get(edit_yMin,'String')) str2double(get(edit_yMax,'String'))]);
        update;
    end  

    function function_autoYlim(source,callbackdata)
        ylim('auto'); % set ylim to auto
        yl = ylim;  % get ylim in auto mode
        ylim(yl); % set ylim back to manual mode
        set(edit_yMin,'string',num2str(yl(1)));
        set(edit_yMax,'string',num2str(yl(2)));
        update;
    end  

    function function_setPath(source, callbackdata)        
        d = uigetdir('..');
        cd(d);
    end

    function function_loadLinescans(source, callbackdata)
        
        scans_temp = loadLineScans;
        
        if ~isempty(scans_temp)
            scans = scans_temp;
            scan = 1;
            sweep = 1;            
            if ~isempty(scans(1).green) && ~isempty(scans(1).red) %both
                channel = 1;
                set(radio_GoR,'Value',1);
            elseif isempty(scans(1).red) %green only
                channel = 2;
                set(radio_green,'Value',1);
            else isempty(scans(1).green) %red only
                channel = 3;
                set(radio_red,'Value',1);
            end

            update;
        end
        
    end

    function function_saveLineScans(source, callbackdata)
        PathName = uigetdir;
        
        if PathName ~= 0
            for i=1:length(scans)
                scans(i).saveLS(PathName)
            end
        end
    end

    function function_exportFigure(source, callbackdata)
        
        switch channel
            case 1
                channelName = 'GoR';
            case 2
                channelName = 'Green';
            case 3
                channelName = 'Red';
        end
        
        
        switch plotOrImage
            case 1
                modeType = 'plot';
            case 2
                modeType = 'image';
        end
        
        switch groupScanOrSweep
            case 1 %group
                [temp currentDir] = fileparts(pwd);
                FileName = [currentDir ' ' channelName ' ' modeType];
            case 2 %scan
                FileName = [scans(scan).name ' ' channelName ' ' modeType];
            case 3 %sweep             
                FileName = [scans(scan).name ' ' num2str(sweep) ' ' channelName ' ' modeType];
        end
        [FileName,PathName,FilterIndex] = uiputfile({'*.png';'*.fig';'*.eps'},'Save As',FileName);
        
        FileName = fullfile(PathName,FileName);
        
        set(panel_load,'visible','off')
        set(panel_selectChannel,'visible','off')
        set(panel_selectContent,'visible','off')
        set(panel_imageOrPlot,'visible','off')
        set(panel_skip,'visible','off')
        set(panel_imagingParams,'visible','off')
        set(panel_normalize,'visible','off')
        set(panel_smoothing,'visible','off')
        set(panel_changeScans,'visible','off')
        set(panel_changeSweeps,'visible','off')
        set(panel_axisLimits,'visible','off')
%         legend('location','southoutside')
        set(gcf,'PaperPositionMode','auto')
        
        % Handle response
        switch FilterIndex
            case 1
                %FileName = [FileName '.png'];
                print(FileName,'-dbmp16m','-noui')
            case 2
                saveas(gcf,FileName)
            case 3
                print(FileName,'-depsc','-noui')
        end
        set(panel_load,'visible','on')
        set(panel_selectChannel,'visible','on')
        set(panel_selectContent,'visible','on')
        set(panel_imageOrPlot,'visible','on')
        set(panel_skip,'visible','on')
        set(panel_imagingParams,'visible','on')
        set(panel_normalize,'visible','on')
        set(panel_smoothing,'visible','on')
        set(panel_changeScans,'visible','on')
        set(panel_changeSweeps,'visible','on')
%         legend('location','best')
        update;
    end

    function function_selectChannel(source,eventdata)
        switch get(eventdata.NewValue,'String')
            case 'G/R'
                if ~isempty(scans(scan).green) && ~isempty(scans(scan).red) %both                    
                    channel = 1;
                elseif isempty(scans(scan).green)
                    warndlg('Cannot Display G/R. There is no green channel');
                elseif isempty(scans(scan).red)
                    warndlg('Cannot Display G/R. There is no red channel');
                end
                                    
            case 'Green'
                 if isempty(scans(scan).green)
                     warndlg('There is no green channel');
                 else
                    channel = 2;
                 end
                 
            case 'Red'
                if isempty(scans(scan).red)
                     warndlg('There is no red channel');
                 else
                    channel = 3;
                end
        end
        update;
    end

    function function_selectgroupScanOrSweep(source,eventdata)
        switch get(eventdata.NewValue,'String')
            case 'Group'
                groupScanOrSweep = 1;
            case 'Scans'
                groupScanOrSweep = 2;
            case 'Sweeps'
                groupScanOrSweep = 3;
        end
        update;
    end

    function function_selectPlotOrImage(source,eventdata)
        
        switch get(eventdata.NewValue,'String')
            case 'Plot'
                plotOrImage = 1;
            case 'Images'
                plotOrImage = 2;
        end
        update;
    end

    function function_setSkips(source,eventdata)
        skips = eval(['[' get(source,'string') ']']);
        scans(scan) = scans(scan).skipSweeps(skips);
        update;
    end

    function function_selectNormalization(source,eventdata)
        switch get(eventdata.NewValue,'String')
            case 'Normalized'
                norm = 1;
            case 'Unnormalized'
                norm = 0;
        end
        update;
    end

    function function_setBaselineStart(source, callbackdata)
        
        if groupScanOrSweep == 1
            for i = 1:length(scans)
                scans(i).expParams.baselineStart = str2double(get(source,'string'));
            end
        else
            scans(scan).expParams.baselineStart = str2double(get(source,'string'));
        end
        update;
    end

    function function_setBaselineEnd(source, callbackdata)
        
        if groupScanOrSweep == 1
            for i = 1:length(scans)
                scans(i).expParams.baselineEnd = str2double(get(source,'string'));
            end
        else
            scans(scan).expParams.baselineEnd = str2double(get(source,'string'));
        end
        update;
        
    end

    function function_setSmoothing(source, callbackdata)
        update;
    end

    function function_goToScan(source,callbackdata)
        input = str2double(get(source,'string'));
        if input > length(scans)
            scan = numSwlength(scans);
        elseif input < 1
            scan = 1;
        else
            scan = input;
        end        
        update;
    end

    function function_prevScan(source,callbackdata)
        button_state = get(source, 'Value');
        if button_state == get(source, 'Max') && scan > 1
            scan = scan - 1;
        else
            scan = length(scans);
        end
        update;
    end

    function function_nextScan(source,callbackdata)
        button_state = get(source, 'Value');
        if button_state == get(source, 'Max') && scan < length(scans)
            scan = scan + 1;
        else
            scan = 1;
        end

        update;
    end

    function function_goToSweep(source,callbackdata)
        input = str2double(get(source,'string'));
        if input > length(scans(scan).green(:,1,1));
            sweep = numSwlength(scans);
        elseif input < 1
            sweep = 1;
        else
            sweep = input;
        end
        update;
    end

    function function_prevSweep(source,callbackdata)
        if sweep > 1
            sweep = sweep - 1;
        else
            sweep = length(scans(scan).green(:,1));
        end
        update;
    end

    function function_nextSweep(source,callbackdata)
        if sweep < length(scans(scan).green(:,1));
            sweep = sweep + 1;
        else
            sweep = 1;
        end
        update;
    end

    function function_setRedThresh(source, callbackdata)
        update;
    end

    function function_setGreenThresh(source, callbackdata)
        update;
    end

%% Application Functions
    
    function response = displayFiguresDialog
        choice = questdlg('Display Figures?', ...
        ' ', ...
        'Yes','No','Never','Yes');
        % Handle response
        switch choice
            case 'Yes'
                response = 1;
            case 'No'
                disp([choice ' coming right up.'])
                response = 0;
            case 'Never'
                response = -1;
        end
    end

    function exportAnalysisDataDialog(scans,data,fileName)
        choice = questdlg('Save data to .mat file?', ...
        ' ', ...       
        'Yes','Append','no','Yes');
        % Handle response
        switch choice
            case 'Yes'
                for i=1:length(scans)
                    dataTable{i,1} = scans(i).name;
                    dataTable{i,2} = data(i);
                end                

                [FileName,PathName,FilterIndex] = uiputfile({'*.mat'},'Save As',fileName);
                save(fullfile(PathName,FileName),'dataTable');
   
            case 'Append'
                [FileName,PathName] = uigetfile({'*.mat'},'Append to');
                load(FileName);
                
                for i=1:length(scans)                                        
                    dataTable{end+1,1} = scans(i).name;
                    dataTable{end,2} = data(i);                   
                end 
                save(fullfile(PathName,FileName),'dataTable');                            
            case 'No'
                
        end        
    end
    
    function update
        
        % Hide all of the axes
        set(allchild(plot_ax),'visible','off');
        set(plot_ax,'visible','off');
        legend('off');
        
        set(allchild(image_ax1),'visible','off');
        set(image_ax1,'visible','off');                       
        
        set(allchild(image_ax2),'visible','off');
        set(image_ax2,'visible','off');
        
        try %This only works in newer version of matlab
            set(image_ax1.Title,'visible','off')
            set(image_ax2.Title,'visible','off')
        catch
        end
        
        % Hide Context Dependent Fields
        set(text_rig,'string',['Rig: ' scans(scan).imagingParams.rig]);
        set(text_greenPMT,'visible','off');
        set(text_redPMT,'visible','off');
        set(text_laser,'visible','off');                
        set(edit_redThresh,'visible','off');
        set(edit_greenThresh,'visible','off');        
        set(panel_skip,'visible','off');
        set(panel_gsat,'visible','off');
        set(panel_axisLimits,'visible','off');
        
        % Update all dynamic text
        set(edit_goToScan,'string',num2str(scan));
        set(edit_goToSweep,'string',num2str(sweep));
        
        set(edit_skip,'string',mat2str(scans(scan).expParams.skip));
        
        set(edit_gsat,'string',num2str(scans(scan).expParams.gsat));
        if groupScanOrSweep == 1      
            temp = scans(1).expParams.gsat;
            for i =2:length(scans)
                if scans(i).expParams.gsat ~= temp
                    set(edit_gsat,'string','Multiple Values');
                end
            end     
        end
        
        
        set(edit_baselineStart,'string',num2str(scans(scan).expParams.baselineStart));
        set(edit_baselineEnd,'string',num2str(scans(scan).expParams.baselineEnd));        
        
        set(text_rig,'string',['Rig: ' scans(scan).imagingParams.rig]);
        set(text_greenPMT,'string',['Green PMTs: ' num2str(scans(scan).imagingParams.greenPMTGain)]);
        set(text_redPMT,'string',['Red PMTs: ' num2str(scans(scan).imagingParams.redPMTGain)]);
        set(text_laser,'string',['Laser: ' num2str(scans(scan).imagingParams.laserPower)]);
        
        switch plotOrImage
            case 1
                set(allchild(plot_ax),'visible','on');
                set(plot_ax,'visible','on');
                
                displayPlot;
                
            case 2
                displayImages;
                set(edit_redThresh,'visible','on');
                set(edit_greenThresh,'visible','on');
                set(panel_skip,'visible','on');
                set(text_greenPMT,'visible','on');
                set(text_redPMT,'visible','on');
                set(text_laser,'visible','on');
        end
        
        
        try
            jheapcl;
        catch
        end
  
    end

    function displayPlot
        set(panel_changeSweeps,'visible','off');
        set(panel_changeScans,'visible','off');
        set(panel_axisLimits,'visible','off');

        switch groupScanOrSweep
            case 1
                groupPlot;
                 set(panel_gsat,'visible','on');
            case 2
                scanPlot;
                set(panel_changeScans,'visible','on');
                set(panel_skip,'visible','on');
                set(text_greenPMT,'visible','on');
                set(text_redPMT,'visible','on');
                set(text_laser,'visible','on');
                set(panel_gsat,'visible','on');
            case 3
                sweepPlot;
                set(panel_changeSweeps,'visible','on');
                set(panel_skip,'visible','on');
                set(text_greenPMT,'visible','on');
                set(text_redPMT,'visible','on');
                set(text_laser,'visible','on');
                set(panel_gsat,'visible','on');
        end
        
    end

    function groupPlot
        set(lineScanUI,'currentaxes',plot_ax)
        cla;
        
        smoothing = str2double(get(edit_smoothing,'string'));
        
        [temp cellName] = fileparts(pwd);
        
        c = hsv(length(scans));
        
        counter = 1;
        hold on;
        for i=1:length(scans)
            
            if channel == 1 && norm == 0 %GoR unnormalized
                plot(scans(i).time,smooth(scans(i).GoR,smoothing),'color',c(i,:));                
                title([cellName ' G/R Raw'],'fontsize',14);
            elseif channel == 1 && norm == 1 %GoR normalized
                plot(scans(i).time,smooth(scans(i).normGoR,smoothing),'color',c(i,:));
                title([cellName ' G/R Norm'],'fontsize',14);
                set(panel_axisLimits,'visible','on');
            elseif channel == 2 && norm == 0 %Green unnormalized
                plot(scans(i).time,smooth(scans(i).meanGreen,smoothing),'color',c(i,:));
                title([cellName ' Green Raw'],'fontsize',14);
            elseif channel == 2 && norm == 1 %Green normalized
                plot(scans(i).time,smooth(scans(i).normGreen,smoothing),'color',c(i,:));
                title([cellName ' Green Norm'],'fontsize',14);
                set(panel_axisLimits,'visible','on');
            elseif channel == 3 && norm == 0 %Red unnormalized
                plot(scans(i).time,smooth(scans(i).meanRed,smoothing),'color',c(i,:));
                title([cellName ' Red Raw'],'fontsize',14);
            elseif channel == 3 && norm == 1 %Red normalized
                plot(scans(i).time,smooth(scans(i).normRed,smoothing),'color',c(i,:));
                title([cellName ' Red Norm'],'fontsize',14);
                set(panel_axisLimits,'visible','on');
            end
            
            time_axis(i) = floor(scans(i).time(end)*100)/100;
            
            legendnames{i} = scans(i).name;
        end
            xlabel('Time (s)','FontSize',14);
            
            
            xlim([0 max(time_axis)]);
            
            set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
                'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
                'XColor', 'k', 'YColor', 'k',  ...
                'LineWidth', 1,'FontName','arial','FontSize',12);
            
            legend(legendnames,'FontSize',10,'location','best');
            
            hold off;                                    
        
    end

    function scanPlot
        set(lineScanUI,'currentaxes',plot_ax)
        cla;
        
        smoothing = str2double(get(edit_smoothing,'string'));
        
        
        
        hold on;
        legend('off')
                        
        if channel == 1 && norm == 0 %GoR unnormalized
            scans(scan).plotGoverR(0,smoothing);            
        elseif channel == 1 && norm == 1 %GoR normalized
            scans(scan).plotGoverR(1,smoothing);       
                set(panel_axisLimits,'visible','on');
        elseif channel == 2 && norm == 0 %Green unnormalized
            scans(scan).plotGreen(0,smoothing);            
        elseif channel == 2 && norm == 1 %Green normalized
            scans(scan).plotGreen(1,smoothing);       
                set(panel_axisLimits,'visible','on');
        elseif channel == 3 && norm == 0 %Red unnormalized
            scans(scan).plotRed(0,smoothing);            
        elseif channel == 3 && norm == 1 %Red normalized
            scans(scan).plotRed(1,smoothing);      
                set(panel_axisLimits,'visible','on');
        end
        
        xlabel('Time (s)','FontSize',14);
        xlim([0 floor(scans(scan).time(end)*100)/100]);
        set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
            'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
            'XColor', 'k', 'YColor', 'k',  ...
            'LineWidth', 1,'FontName','arial','FontSize',12);
 
        hold off                        
        
    end

    function sweepPlot
        set(lineScanUI,'currentaxes',plot_ax)
        cla;
        
        smoothing = str2double(get(edit_smoothing,'string'));
        
        legend('off')
        
        obj = scans(scan);
        switch channel 
            case 1
                if ~isempty(scans(scan).red) && ~isempty(scans(scan).green)
                    
                    channelName = 'G/R';
                    
                    if norm == 1
                        gtraces = scans(scan).green;
                        rtraces = scans(scan).red;
                        
                        for j=1:length(gtraces(:,1))
                            traces(j,:) = baseline_subtraction(obj,gtraces(j,:))./rtraces(j,:);
                            if ~isnan(scans(scan).expParams.gsat)
                                traces(j,:) = traces(j,:)./scans(scan).expParams.gsat;
                            end                                
                        end
                        title([scans(scan).name ' sweep ' num2str(sweep) ' ' channelName ' Norm'],'FontSize',14);
                        ylabel('dG/G','FontSize',14);
                        set(panel_axisLimits,'visible','on');
                    elseif norm == 0
                        traces = scans(scan).green./ scans(scan).red;
                        title([scans(scan).name ' sweep ' num2str(sweep) ' ' channelName ' Raw'],'FontSize',14);
                        ylabel('Fluorescence','FontSize',14);
                    end
                    
                    
                end
                
            case 2
                if ~isempty(scans(scan).green)
                    traces = scans(scan).green;
                    channelName = 'Green';
                    if norm == 1
                        for j=1:length(traces(:,1))
                            traces(j,:) = normalize(obj,traces(j,:));
                        end
                        title([scans(scan).name ' sweep ' num2str(sweep) ' ' channelName ' Norm'],'FontSize',14);
                        ylabel('dF/F','FontSize',14);
                        set(panel_axisLimits,'visible','on');
                    elseif norm == 0
                        title([scans(scan).name ' sweep ' num2str(sweep) ' ' channelName ' Raw'],'FontSize',14);
                        ylabel('Fluorescence','FontSize',14);
                    end
                end
                
            case 3
                if ~isempty(scans(scan).red)
                    traces = scans(scan).red;
                    channelName = 'Red';
                    if norm == 1
                        for j=1:length(traces(:,1))
                            traces(j,:) = normalize(obj,traces(j,:));
                        end
                        title([scans(scan).name ' sweep ' num2str(sweep) ' ' channelName ' Norm'],'FontSize',14);
                        ylabel('dF/F','FontSize',14);
                        set(panel_axisLimits,'visible','on');
                    elseif norm == 0
                        title([scans(scan).name ' sweep ' num2str(sweep) ' ' channelName ' Raw'],'FontSize',14);
                        ylabel('Fluorescence','FontSize',14);
                    end
                end
        end
        
        hold on;
        
        for j=1:length(traces(:,1))
            plot(obj.time,smooth(traces(j,:),smoothing),'color',[.8,.8,.8]);
        end
        
        plot(obj.time,smooth(traces(sweep,:),smoothing),'color',[0 0 0]);
        hold off;
        
        set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
            'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
            'XColor', 'k', 'YColor', 'k',  ...
            'LineWidth', 1,'FontName','arial','FontSize',12);
    end
    
    function displayImages
        set(panel_changeSweeps,'visible','off');
        switch groupScanOrSweep
            case 1
                averageImage;
                set(panel_changeScans,'visible','on');                
            case 2
                averageImage;
                set(panel_changeScans,'visible','on');
            case 3
                singleImage;
                set(panel_changeSweeps,'visible','on');
        end
    end

    function averageImage
        obj = scans(scan);  
        
        
        if ~isfield(scans(scan).expParams,'mask')
            imgDim = size(squeeze(mean(scans(scan).raw.green)));
            scans(scan).expParams.mask = zeros(imgDim);            
            scans(scan).expParams.maskCoord = [0 1 imgDim(1)+1 imgDim(2)-1];
        end                                                
        
        set(lineScanUI,'currentaxes',ancestor(image_ax1, 'axes'))
        cla;
        if ~isempty(scans(scan).red)
            redThresh = str2num(get(edit_redThresh,'string'));
            
            imshow(uint16(squeeze(mean(obj.raw.red))'),[0 redThresh]);
            title(['Red Channel ' scans(scan).name],'fontsize',16);
            
            %Create Interactive UI for selecting line scans regions
            imgDim = size(squeeze(mean(obj.raw.red)));
            redMask = imrect(gca,scans(scan).expParams.maskCoord);
            setColor(redMask,'r')
            fcn = makeConstrainToRectFcn('imrect',[0 imgDim(1)+1], [1 imgDim(2)]);
            setPositionConstraintFcn(redMask,fcn);
            scans(scan) = updateLineScan(scans(scan));
        end
        
        set(lineScanUI,'currentaxes',ancestor(image_ax2, 'axes'))
        cla;
        if ~isempty(scans(scan).green)
            greenThresh = str2num(get(edit_greenThresh,'string'));
            
            imshow(uint16(squeeze(mean(obj.raw.green))'),[0 greenThresh]);
            title(['Green Channel ' scans(scan).name],'fontsize',16);
            
            %Create Interactive UI for selecting line scans regions
            imgDim = size(squeeze(mean(obj.raw.green)));
            greenMask = imrect(gca,scans(scan).expParams.maskCoord);
            setColor(greenMask,'r')
            fcn = makeConstrainToRectFcn('imrect',[0 imgDim(1)+1], [1 imgDim(2)]);
            setPositionConstraintFcn(greenMask,fcn);
            scans(scan) = updateLineScan(scans(scan));
        end
             
        if ~isempty(scans(scan).green) && ~isempty(scans(scan).red)
            %Modify the position of the mask in both axes simultaneously
            greenMask.addNewPositionCallback(@(pos)updateMaskGreen(pos,redMask,greenMask));
            redMask.addNewPositionCallback(@(pos)updateMaskRed(pos,greenMask,redMask));
        elseif ~isempty(scans(scan).green)
            greenMask.addNewPositionCallback(@(pos)updateMask(pos,greenMask));
        elseif ~isempty(scans(scan).red)
            redMask.addNewPositionCallback(@(pos)updateMask(pos,redMask));
        end

    end
    
    function updateMaskGreen(pos,redMask,greenMask)
        setPosition(redMask,getPosition(greenMask));  
        scans(scan).expParams.mask = createMask(greenMask)';
        scans(scan).expParams.maskCoord = getPosition(greenMask);
        scans(scan) = updateLineScan(scans(scan));
    end
    
    function updateMaskRed(pos,greenMask,redMask)
        setPosition(greenMask,getPosition(redMask));     
        scans(scan).expParams.mask = createMask(greenMask)';
        scans(scan).expParams.maskCoord = getPosition(greenMask);
        scans(scan) = updateLineScan(scans(scan));
    end

    function updateMask(pos,mask)
        scans(scan).expParams.mask = createMask(mask)';
        scans(scan).expParams.maskCoord = getPosition(mask);
        scans(scan) = updateLineScan(scans(scan));        
    end
        
    function singleImage
        obj = scans(scan);  
        
        if ~isfield(scans(scan).expParams,'mask')
            imgDim = size(squeeze(mean(scans(scan).raw.green)));
            scans(scan).expParams.mask = zeros(imgDim);            
            scans(scan).expParams.maskCoord = [0 1 imgDim(1)+1 imgDim(2)-1];
        end                                            
        
        greenThresh = str2num(get(edit_greenThresh,'string'));
        redThresh = str2num(get(edit_redThresh,'string'));
        hold on;
        
        set(lineScanUI,'currentaxes',ancestor(image_ax1, 'axes'))
        cla;
        
        if ~isempty(scans(scan).red)
            imshow(uint16(squeeze(obj.raw.red(sweep,:,:))'),[0 redThresh]);
            title(['Red Channel ' scans(scan).name ' sweep ' num2str(sweep)],'fontsize',16);
            
            imgDim = size(squeeze(mean(obj.raw.red)));
            redMask = imrect(gca,scans(scan).expParams.maskCoord);
            setColor(redMask,'r')
            setResizable(redMask,0);
        end
        
        set(lineScanUI,'currentaxes',ancestor(image_ax2, 'axes'))
        cla;
        
        if ~isempty(scans(scan).green)
            
            imshow(uint16(squeeze(obj.raw.green(sweep,:,:))'),[0 greenThresh]);
            title(['Green Channel ' scans(scan).name ' sweep ' num2str(sweep)],'fontsize',16);
            
            imgDim = size(squeeze(mean(obj.raw.green)));
            greenMask = imrect(gca,scans(scan).expParams.maskCoord);
            setColor(greenMask,'r')
            setResizable(greenMask,0);
        end
        hold off;
        
        
    end

end


