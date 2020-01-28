function scans = loadLineScans(scan_file_names)
% Last edit: Perry Spratt 01/10/2017

% Launch a file picker UI, load or import line scans, return as array of
% line scans
if nargin == 0
    dirs = {};
    dirs = uipickfiles();
    counter = 1;
    for i=1:length(dirs)

        if isdir(dirs{i}) == 1
            try
                scans(counter) = lineScan(dirs{i});
                counter = counter+1;
            catch
                disp(['Failed to import ' dirs{i}]);
            end
        else
            try
                load(dirs{i});
                %update lineScan objects
                scans(counter) = obj.updateLineScanXML;
                scans(counter) = updateLineScan(obj);

                [~, filename] = fileparts(dirs{i});
                scans(counter).name = filename;
                counter = counter+1;
            catch
                disp(['Failed to import ' dirs{i}]);
            end
        end
    end
else
    counter = 1;
    for i=1:length(scan_file_names)
        try
            load(scan_file_names{i});
            %update lineScan objects
            scans(counter) = obj.updateLineScanXML;
            scans(counter) = updateLineScan(obj);
            counter = counter+1;
        catch
            disp(['Failed to import ' scan_file_names{i}]);
        end
    end
end