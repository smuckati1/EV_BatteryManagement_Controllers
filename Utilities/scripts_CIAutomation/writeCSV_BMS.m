function [] = writeCSV_BMS()
% WRITEBMSCSV is used to simulate the BMS and save the result artifacts as
% CSV, so others can understand the expected baseline behavior of  the
% system.

% Get handle to project
    prj = matlab.project.currentProject;
    disp(' ')
    disp("Project: " + prj.Name)

% Create folder to save CSV
    fldrName = fullfile(prj.RootFolder,'GeneratedArtifacts','TestResults','BaselineCSVs');
    if isfolder(fldrName)
    else
        mkdir(fldrName)
    end

% Simulate system and collect logs
    mdlName = 'BMS_Harness_fullBMS';
    disp('Loading BMS model and full system harness')
    load_system(mdlName)
    disp('Simulate BMS model and full system harness')
    out = sim(mdlName,"StopTime","2000");

% Save info into CSVs
    disp('Save BMS model inputs as a CSV')
    sensorInput = out.logsOut.getElement('SensorInputs').Values;
    StateRequest = timeseries(repelem(SRE.Driving,20001)',sensorInput.Cell_Voltages.Time);
    StateRequest.Name = 'StateRequest';
    StateRequest = timeseries2timetable(StateRequest);
    sensorInput = timeseries2timetable(sensorInput.Cell_Temperatures,...
        sensorInput.Cell_Voltages, sensorInput.Pack_Current,...
        sensorInput.Pack_Voltage,sensorInput.Vout_Chgr,sensorInput.Vout_Invtr);
    BMS_Inputs = [StateRequest sensorInput];
    writetimetable(BMS_Inputs,fullfile(fldrName,'BMS_Inputs.csv'))
    
    disp('Save BMS model outputs as a CSV')
    balcmd          = timeseries2timetable(...
        out.logsOut.getElement('BalCmd').Values);
    SOC_Est         = timeseries2timetable(...
        out.logsOut.getElement('SOC_Est').Values);
    ChargeMode      = timeseries2timetable(...
        out.logsOut.getElement('ChargeMode').Values);
    BMS_State       = timeseries2timetable(...
        out.logsOut.getElement('BMS_State').Values);
    Faults          = out.logsOut.getElement('Faults').Values;
    Faults = timeseries2timetable(...
        Faults.CellHighTempFlt, Faults.CellLowTempFlt, Faults.CellOverVoltFlt,...
        Faults.CellUnderVoltFlt,Faults.ChrgCntctFlt, Faults.InvtrCntctFlt,...
        Faults.PackOverCurrFlt, Faults.VoltSensorFlt);
    CntctCmd        = out.logsOut.getElement('CntctCmd').Values;
    CntctCmd        = timeseries2timetable(...
        CntctCmd.NegCntctChgrCmd,CntctCmd.NegCntctInvtrCmd,...
        CntctCmd.PosCntctChgrCmd,CntctCmd.PosCntctInvtrCmd,...
        CntctCmd.PreChrgRelayChgrCmd,CntctCmd.PreChrgRelayInvtrCmd);
    ChargeCurrentReq = timeseries2timetable(...
        out.logsOut.getElement('ChargeCurrentReq').Values);
    CurrentLimits   = out.logsOut.getElement('CurrentLimits').Values;
    CurrentLimits = timeseries2timetable(...
        CurrentLimits.ChargeCurrentLimit,CurrentLimits.DischargeCurrentLimit);

    BMS_Outputs = [CurrentLimits,ChargeCurrentReq,CntctCmd,Faults,...
        BMS_State,ChargeMode,SOC_Est,balcmd];
    writetimetable(BMS_Outputs,fullfile(fldrName,'BMS_Outputs.csv'))

    disp('Cleanup and close!')
    close_system(mdlName)
end

