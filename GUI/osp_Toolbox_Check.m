function [hasSPM] = osp_Toolbox_Check (Module,ToolChecked)
%% [hasSPM] = osp_Toolbox_Check (Module,ToolChecked)
%   This function checks the availabilty of the required MATLAB toolboxes
%   and SPM versions
%
%   USAGE:
%      [hasSPM] = osp_Toolbox_Check (Module,ToolChecked)
%
%   INPUTS:
%       Module     = String with the Module name
%                    Options:  OspreyGUI
%                              OspreyProcess
%                              OspreyFit
%                              OspreyCoreg
%                              OspreySeg
%      ToolChecked = Flag wether Toolboxes have been checked before. 
%
%   OUTPUTS:
%       hasSPM     = SPM flag.
%
%   AUTHOR:
%       Helge Zoellner (Johns Hopkins University, 2020-05-15)
%       hzoelln2@jhmi.edu
%
%   CREDITS:
%       This code is based on numerous functions from the FID-A toolbox by
%       Dr. Jamie Near (McGill University)
%       https://github.com/CIC-methods/FID-A
%       Simpson et al., Magn Reson Med 77:23-33 (2017)
%
%   HISTORY:
%       2020-05-15: First version of the code.
%%
%%% 1. GET SPMPATH AND TOOLBOXES%%%

addons = matlab.addons.installedAddons;
available = cellstr(table2cell(addons(:,1)));
enabled = table2cell(addons(:,3));

[settingsFolder,~,~] = fileparts(which('OspreySettings.m'));
allFolders      = strsplit(settingsFolder, filesep);
ospFolder       = strjoin(allFolders(1:end-1), filesep); % parent folder (= Osprey folder)
 
% SPM
if isfile(fullfile(ospFolder,'GUI','SPMpath.mat'))
    load(fullfile(ospFolder,'GUI','SPMpath.mat'),'SPMpath')
    spmversion = SPMpath;
else
    spmversion = uipickfiles('FilterSpec',ospFolder,'REFilter', '\','NumFiles',1,'Prompt','Select your SPM-folder (Will be saved in SPMpath.mat file in the GUI folder)');
    spmversion = spmversion{1};
    SPMpath = gui.folder.spmversion;
    save(fullfile(ospFolder,'GUI','SPMpath.mat'),'SPMpath');
end
% Check if SPM12 is installed
if isempty(spmversion)
    hasSPM = 0;
elseif strcmpi(spmversion(end-3:end),'spm8')
    available{end+1} = 'SPM8';
    hasSPM = 0;
else
    available{end+1} = 'SPM12';
    hasSPM = 1;
end 

available(find(cellfun(@(a)~isempty(a)&&a<1,enabled)), :) = [];

%%% 2. CHECK AVAILABILTY %%%
switch Module
    case 'OspreyGUI'
        ModuleString = 'fully run Osprey';
        neededGlobal = {'Optimization Toolbox', 'Statistics and Machine Learning Toolbox','SPM12'};
        neededSpecific = {'Widgets Toolbox', 'GUI Layout Toolbox'};
    case 'OspreyProcess'
        ModuleString = 'run OspreyProcess';
        neededGlobal = {'Optimization Toolbox', 'Statistics and Machine Learning Toolbox','SPM12'};
        neededSpecific = {'Optimization Toolbox', 'Statistics and Machine Learning Toolbox'}; 
    case 'OspreyFit'
        ModuleString = 'run OspreyFit';
        neededGlobal = {'Optimization Toolbox', 'Statistics and Machine Learning Toolbox','SPM12'};
        neededSpecific = {'Optimization Toolbox', 'Statistics and Machine Learning Toolbox'};
    case 'OspreyCoreg'
        ModuleString = 'run OspreyCoreg';
        neededGlobal = {'Optimization Toolbox', 'Statistics and Machine Learning Toolbox','SPM12'};
        neededSpecific = {'SPM12'};
    case 'OspreySeg'
        ModuleString = 'run OspreySeg';
        neededGlobal = {'Optimization Toolbox', 'Statistics and Machine Learning Toolbox','SPM12'};
        neededSpecific = {'SPM12'};        
    otherwise
        ModuleString = ['run ' Module];
        neededSpecific = cellstr({});
end

missingSpecific = setdiff(neededSpecific,available);
missing = setdiff(neededGlobal,available); 

%%% 3. CREATE WARNING MESSAGES %%%
if ~ToolChecked
    warning = cellstr({});
    warning_count = 1;
    if ~isempty(missing) || ~isempty(missingSpecific)
        opts.Interpreter = 'tex';
        opts.WindowStyle = 'modal';
        warning{1} = ['The following toolboxes are missing to ' ModuleString ':'];
        for i = 1 : length(missing)
            warning{i+1} = missing{i};
        end
        warning_count = warning_count +i + 1;
        warning{warning_count} = ['Please install them to ' ModuleString];
        warning_count = warning_count + 1;
        if ~isempty(missingSpecific)
            warning{warning_count} = ['The following toolboxes are missing to run ' Module ':']; 
            warningc = ['Please install and include the following toolboxes to use ' Module ':'];
            for i = 1 : length(missingSpecific)
                warning{warning_count + i} = missingSpecific{i};
                warningc = [warningc ' ' missingSpecific{i}];
            end
            warning{warning_count + i + 1} = ['Please install them to use ' Module];
            warndlg(warning,'Missing Toolboxes',opts);
            error(warningc);
        end    
        warndlg(warning,'Missing Toolboxes',opts);
    end
end

end