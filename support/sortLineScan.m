function sortLineScan(rig,path2dir)

if nargin < 2
    path2dir = pwd;
end

if nargin < 1
    rig = ' ';
end

%Create relevant directories
if ~exist(fullfile(path2dir,'Alexa'),'dir')
    mkdir(fullfile(path2dir,'Alexa'));
end

if ~exist(fullfile(path2dir,'Fluo'),'dir')
    mkdir(fullfile(path2dir,'Fluo'));
end

if ~exist(fullfile(path2dir,'DIC'),'dir')
    mkdir(fullfile(path2dir,'DIC'));
end

if ~exist(fullfile(path2dir,'Reference_Images'),'dir')
    mkdir(fullfile(path2dir,'Reference_Images'));
end

if ~exist(fullfile(path2dir,'Source_Files'),'dir')
    mkdir(fullfile(path2dir,'Source_Files'));
end

% Start moving files
sourceFiles = dir(fullfile(path2dir,'*Source.tif'));
for i=1:length(sourceFiles)
    movefile(fullfile(path2dir,sourceFiles(i).name),fullfile(path2dir,'Source_Files'));
end

%Check what rig was used (channels are different between rigs)
if strcmp(rig,'bluefish')
    alexaFiles = dir(fullfile(path2dir,'*CurrentSettings_Ch1*'));
    for i=1:length(alexaFiles)
        movefile(fullfile(path2dir,alexaFiles(i).name),fullfile(path2dir,'Alexa'));
    end
    
    fluoFiles = dir(fullfile(path2dir,'*CurrentSettings_Ch2*'));
    for i=1:length(fluoFiles)
        movefile(fullfile(path2dir,fluoFiles(i).name),fullfile(path2dir,'Fluo'));
    end
    
    dicFiles = dir(fullfile(path2dir,'*CurrentSettings_Ch3*'));
    for i=1:length(dicFiles)
        movefile(fullfile(path2dir,dicFiles(i).name),fullfile(path2dir,'DIC'));
    end
end

if strcmp(rig,'Thing1')
    alexaFiles = dir(fullfile(path2dir,'*CurrentSettings_Ch1*'));
    for i=1:length(alexaFiles)
        movefile(fullfile(path2dir,alexaFiles(i).name),fullfile(path2dir,'Alexa'));
    end
    
    fluoFiles = dir(fullfile(path2dir,'*CurrentSettings_Ch3*'));
    for i=1:length(fluoFiles)
        movefile(fullfile(path2dir,fluoFiles(i).name),fullfile(path2dir,'Fluo'));
    end
    
    dicFiles = dir(fullfile(path2dir,'*CurrentSettings_Ch4*'));
    for i=1:length(dicFiles)
        movefile(fullfile(path2dir,dicFiles(i).name),fullfile(path2dir,'DIC'));
    end
end


if strcmp(rig,'Thing2')
    alexaFiles = dir(fullfile(path2dir,'*CurrentSettings_Ch1*'));
    for i=1:length(alexaFiles)
        movefile(fullfile(path2dir,alexaFiles(i).name),fullfile(path2dir,'Alexa'));
    end
    
    fluoFiles = dir(fullfile(path2dir,'*CurrentSettings_Ch2*'));
    for i=1:length(fluoFiles)
        movefile(fullfile(path2dir,fluoFiles(i).name),fullfile(path2dir,'Fluo'));
    end
    
    dicFiles = dir(fullfile(path2dir,'*CurrentSettings_Ch4*'));
    for i=1:length(dicFiles)
        movefile(fullfile(path2dir,dicFiles(i).name),fullfile(path2dir,'DIC'));
    end
end



%Clean up empty folders
folders = dir(path2dir);

for i=1:length(folders)
    if folders(i).isdir == 1 &&... %is a directory
            ~strcmp(folders(i).isdir,'.') &&...%not '.'
            ~strcmp(folders(i).isdir,'..') &&...%'not '..'
            length(dir(folders(i).name)) == 2%'has more that '.' and '..' as contents
        rmdir(folders(i).name);
    end
end
end