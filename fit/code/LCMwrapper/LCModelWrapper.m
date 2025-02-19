function [MRSCont] = LCModelWrapper(MRSCont,kk,progressText)
%% [MRSCont] = LCModelWrapper(MRSCont)
%   This function performs spectral fitting in LCModel.
%
%   USAGE:
%       [MRSCont] = osp_fitUnEdited(MRSCont, basisSet);
%
%   INPUTS:
%       MRSCont     = Osprey MRS data container.
%       basisSet    = Osprey basis set container.
%
%   OUTPUTS:
%       MRSCont     = Osprey MRS data container.
%
%   AUTHOR:
%       Dr. Georg Oeltzschner (Johns Hopkins University, 2019-04-12)
%       goeltzs1@jhmi.edu
%
%   CREDITS:
%       This code is based on numerous functions from the FID-A toolbox by
%       Dr. Jamie Near (McGill University)
%       https://github.com/CIC-methods/FID-A
%       Simpson et al., Magn Reson Med 77:23-33 (2017)
%
%   HISTORY:
%       2023-07-12: First version of the code.

    [~] = printLog('OspreyFit',kk,1,MRSCont.nDatasets,progressText,MRSCont.flags.isGUI ,MRSCont.flags.isMRSI);

    % Put the scale to be 1 for now. Might have to adjust.
    MRSCont.fit.scale{kk} = 1;

    % Create the sub-folder where the LCModel results will be saved,
    % otherwise LCModel will throw 'FATAL ERROR MAIN 2'.
    if ~exist(fullfile(MRSCont.outputFolder, 'LCMoutput'), 'dir')
        mkdir(fullfile(MRSCont.outputFolder, 'LCMoutput'));
    end


    % Find the path to LCModel binary
    pathLCModelBinaryStruct = osp_platform('lcmodel');
    pathLCModelBinary = fullfile(MRSCont.ospFolder, 'libraries', 'LCModel',pathLCModelBinaryStruct.os,pathLCModelBinaryStruct.osver,['LCModel_' pathLCModelBinaryStruct.os,'_',pathLCModelBinaryStruct.osver]);
    switch  pathLCModelBinaryStruct.os
        case 'macos'
            bin = 'lcmodel';
        case 'unix'
            bin = 'lcmodel';
        case 'win'
            bin = 'LCModel.exe';
    end

    if ~exist([pathLCModelBinary filesep bin],'file') %Unzip binary
        unzip([pathLCModelBinary filesep bin '.zip'],[pathLCModelBinary filesep]);
    end

    if ~exist([pathLCModelBinary filesep bin],'file') %Binary is still missing
        error('ERROR: No LCModel binary found.  Aborting!!');
    else
        if ~(ismcc || isdeployed)
            addpath(which('libraries/LCModel'));
        end
    end

    callLCModel(MRSCont, MRSCont.opts.fit.lcmodel.controlfileA{kk},[pathLCModelBinary filesep bin]);

    % Save the parameters and information about the basis set

    MRSCont.fit.results.metab.fitParams{kk} = readLCMFitParams(MRSCont, 'A', kk);

    if MRSCont.flags.isMEGA
        callLCModel(MRSCont, MRSCont.opts.fit.lcmodel.controlfileDiff1{kk},[pathLCModelBinary filesep bin]);
    end
end