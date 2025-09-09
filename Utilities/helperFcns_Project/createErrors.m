function createErrors()
% This function is used to quickly update different branches of this
% project with model and test changes; in order to create a demo we can use
% to show to customers. The idea is to demo how different engineers can
% work on multiple branches.
    makeGitCommits = false;
    
    answer = questdlg('WARNING! This function will trigger git commits, that will trigger multiple CICD pipelines. These pipelines could take hours to run! Are you sure you would like to continue?', ...
	'WARNING', ...
	'Yes, Proceed','No thank you','No thank you');
    
    % Handle response
    switch answer
        case 'Yes, Proceed'
            makeGitCommits = true;
        case 'No thank you'
            makeGitCommits = false;
    end

    prj = currentProject;
    
    if makeGitCommits
        [~,cmdout] = system("git diff --name-only");
    
        if ~isempty(cmdout)
            error("ERROR: There are local changes in this repository that need" + ...
                " to be checked in first. Please check in all local changes, " + ...
                "and then run this function.")
        end
    
        %% set baseline
        disp('Checkout main')
            [~,cmdout] = system("git checkout main");
            disp(cmdout)
            [~,cmdout] = system("git pull");
            disp(cmdout)
        disp('Update BMS Models')
            updateBMSMdls(-10)
        disp('Update VCU Models')
            updateVCUMdls(5)
        disp('Update BMS Tests')
            updateBMSTests('baseline')
        disp('Update VCU Tests')
            updateVCUTests('baseline')
        disp('Committing all baseline setup models and tests to main')
            commitMessage = 'git commit -am "setup baseline with normal mode"';
            [~,cmdout] = system(commitMessage);
            disp(cmdout)
            [~,cmdout] = system("git push");
            disp(cmdout)
    
        %% setsportmode, BMStests not updated
        disp('Checkout bBattMgmt')
            [~,cmdout] = system("git checkout bBattMgmt");
            disp(cmdout)
            [~,cmdout] = system("git pull");
            disp(cmdout)
            [~,cmdout] = system("git merge main bBattMgmt");
            disp(cmdout)
        disp('Update BMS Models')
            updateBMSMdls(-17)
        disp('Dont Update BMS Tests')
            updateBMSTests('baseline')
        disp('Committing Battery sportMode setup models to bBattMgmt')
            commitMessage = 'git commit -am "setup bBattMgmt with sport mode"';
            [~,cmdout] = system(commitMessage);
            disp(cmdout)
            [~,cmdout] = system("git push");
            disp(cmdout)
        
        disp('Checkout bVCU')
            [~,cmdout] = system("git checkout bVCU");
            disp(cmdout)
            [~,cmdout] = system("git pull");
            disp(cmdout)
            [~,cmdout] = system("git merge main bVCU");
            disp(cmdout)
        disp('Update VCU Models')
            updateVCUMdls(2.5)
        disp('Update VCU Tests')
            updateVCUTests('sportMode')
        disp('Committing VCU sportMode setup models and tests to bVCU')
            commitMessage = 'git commit -am "setup bVCU with sport mode"';
            [~,cmdout] = system(commitMessage);
            disp(cmdout)
            [~,cmdout] = system("git push");
            disp(cmdout)
    
        %% Get back to main
            [~,cmdout] = system("git checkout main");
            disp(cmdout)
        disp('All commits complete!')
    end

%% Helper Functions

    function updateVCUMdls(RegenStrt)
    % This function modified the VCU model regen operation table, and saves it
    % in latest release and R2022b release
    
        % open the model and update the regen breakpoint limit.
        vcuMdl = 'EvPowertrainController2EM_r3';
        load_system(vcuMdl)
        blkname = ['EvPowertrainController2EM_r3/Energy Management/' ...
            'Control Domain /Series Regen Braking/RegenLimits/Constant'];
        set_param(blkname,"Value",num2str(RegenStrt));
    
        % Save the models
        save_system(vcuMdl)
        close_system(vcuMdl)
    end

    function updateBMSMdls(currentGain)
    % This function modified the BMS model regen operation table, and saves it
    
        % open the model and update the regen breakpoint limit.
        bmsMdl = 'BMS_Software';
        load_system(bmsMdl)
        blkname = 'BMS_Software/CurrPowerLimCalc/MaxDchrgCurrLim/Constant';
        set_param(blkname,"Value",num2str(currentGain));
    
        % Save the models
        save_system(bmsMdl)
        close_system(bmsMdl)
    end
    
    function updateBMSTests(carMode)
    % Update tests we run based on whether we are in sport mode or not
    
        tfObj   = sltest.testmanager.load('BMS_Tests.mldatx');
        tc      = tfObj.getTestSuiteByName('BMS_Software_PowerCalc');
        ts1     = tc.getTestCaseByName('BMS_Harness_PowerCalc_Baseline');
        ts2     = tc.getTestCaseByName('BMS_Harness_PowerCalc_SportMode');
        tc      = tfObj.getTestSuiteByName('BMS_Software_Whole');
        ts3     = tc.getTestCaseByName('BMS_Haeness_Full_ComfortMode');
        ts4     = tc.getTestCaseByName('BMS_Haeness_Full_SportMode');
        
        if strcmp(carMode,'baseline')
            ts1.Enabled = true;
            ts2.Enabled = false;
            ts3.Enabled = true;
            ts4.Enabled = false;
        else
            ts1.Enabled = false;
            ts2.Enabled = true;
            ts3.Enabled = false;
            ts4.Enabled = true;
        end
        
        tfObj.saveToFile
        close(tfObj)
    end

    function updateVCUTests(carMode)
    % Update tests we run based on whether we are in sport mode or not
    
        tfObj   = sltest.testmanager.load('EV2M_VCU_MiLtests');
        tc      = tfObj.getTestSuiteByName('VCU_2EMEV_ctrl_powertrain');
        ts1     = tc.getTestCaseByName('VCU_2EMEV_Harness_Baseline');
        ts2     = tc.getTestCaseByName('VCU_2EMEV_Harness_HighRegen');
        
        if strcmp(carMode,'baseline')
            ts1.Enabled = true;
            ts2.Enabled = false;
        else
            ts1.Enabled = false;
            ts2.Enabled = true;
        end
        
        tfObj.saveToFile
        close(tfObj)
    end
end