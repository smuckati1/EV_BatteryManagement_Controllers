function diff_push(modifiedFiles,lastpush)
% Function to produce the diff reports as DOC files between the latest version
% of the master branch, and the previous version of the master branch. 
% This function takes the names of SLX files identified when running git diff.

% To run This function, you should first run a git diff
% $diffM= git diff --name-only --diff-filter=M $previousCommit $latestCommit -- **/*.slx

    proj = currentProject;

    % List out names of all SLX files within Repo that were modified
    if isempty(modifiedFiles)
        disp('No modified models to compare.')
        return
    else
        modifiedFiles = split(modifiedFiles,[" ","\","/"]);
        idx = contains(modifiedFiles,".slx");
        modifiedFiles = modifiedFiles(idx);

        disp('List of Modified SLX Files:')
        disp(modifiedFiles)
    end
    
    % Create a temporary folder to store the ancestors of the modified models
    % If you have models with the same name in different folders, consider
    % creating multiple folders to prevent overwriting temporary models
    disp('Creating a local folder called "modelscopy" to hold the previous version of the file')
    disp('A copy of the previous committed version of the slx will be added into this folder for diffs')
    tempdir = fullfile(proj.RootFolder, "modelscopy");
    mkdir(tempdir)
    disp('Folder Created!')
    
    % Generate a comparison report for every modified model file
    for i = 1:numel(modifiedFiles)
        filePath = which(modifiedFiles{i});
        filePath = erase(filePath,fullfile(proj.RootFolder,'/'));
        disp(['Creating report for ' filePath])
        [reportHtml,reportDoc] = diffToAncestor(tempdir,string(filePath),lastpush);
        disp(['Report creation complete for ' filePath])
    end
    
    % Delete the temporary folder
    disp('Removing the "modelscopy" folder')
    rmdir modelscopy s

    disp('ReportGen Complete!')

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function [reportHtml,reportDoc] = diffToAncestor(tempdir,fileName,lastpush)
        disp("    Getting the ancestor version of the file")
        disp(strcat("    File Name = ", fileName, "; lastpush = " ,lastpush))
        ancestor = getAncestor(tempdir,fileName,lastpush);
    
        % Compare models and publish results in a printable report
        % Specify the format using 'pdf', 'html', or 'docx'
            disp(strcat("Load the models to be compared: ", fileName))
            load_system(fileName)
            load_system(ancestor)
    
            disp('    Run the "visdiff" command')
            comp= visdiff(ancestor, fileName);
            filter(comp, "default");
            options = struct('Format','html',...
                'OutputFolder',fullfile(proj.RootFolder,'GeneratedArtifacts','DiffReports'));
            options2 = struct('Format','doc',...
                'OutputFolder',fullfile(proj.RootFolder,'GeneratedArtifacts','DiffReports'));
            
            disp('    Save the "visdiff" output as html')
            reportHtml = publish(comp,options);
            disp('    Save the "visdiff" output as a doc')
            reportDoc = publish(comp,options2);

            close_system(fileName,0)
            close_system(ancestor,0)
    
        function ancestor = getAncestor(tempdir,fileName,lastpush)
            
            [relpath, name, ext] = fileparts(fileName);
            ancestor = fullfile(tempdir, name);
            
            % Replace seperators to work with Git and create ancestor file name
            fileName = strrep(fileName, '\', '/');
            ancestor = strrep(sprintf('%s%s%s',ancestor, "_ancestor", ext), '\', '/');
            
            % Build git command to get ancestor
            % git show lastpush:models/modelname.slx > modelscopy/modelname_ancestor.slx
            gitCommand = sprintf('git show %s:"%s" > "%s"', lastpush, fileName, ancestor);
            
            [status, result] = system(gitCommand);
            assert(status==0, result);
        
        end
    end
end
       
%   Copyright 2023 The MathWorks, Inc.