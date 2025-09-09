function [] = writeCSV_VCU()
% WRITEVCUCSV is used to simulate the BMS and save the result artifacts as
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
    mdlName = 'VCU_Software_Harness1';
    disp('Loading VCU model and full system harness')
    load_system(mdlName)
    in = Simulink.SimulationInput(mdlName);
    in = in.setModelParameter("StopTime",num2str(600));
    disp('Simulate VCU model and full system harness')
    out = sim(in);

% Save info into CSVs
    disp('Save VCU model inputs as a CSV')

    AccelPdl        = timeseries2timetable(out.logsout.getElement('AccelPdl').Values);
    BcuBrkPrsCmd    = timeseries2timetable(out.logsout.getElement('BcuBrkPrsCmd').Values);
    VehSpdFdbk      = timeseries2timetable(out.logsout.getElement('VehSpdFdbk').Values);
    EMSpd           = timeseries2timetable(out.logsout.getElement('EMSpd').Values);
    TransGear       = timeseries2timetable(out.logsout.getElement('TransGear').Values);
    BMSSOC          = timeseries2timetable(out.logsout.getElement('BMSSOC').Values);
    BattPackVolt    = timeseries2timetable(out.logsout.getElement('BattPackVolt').Values);
    BMSDichrgCurrLmt= timeseries2timetable(out.logsout.getElement('BMSDichrgCurrLmt').Values);
    BMSChrgCurrLmt  = timeseries2timetable(out.logsout.getElement('BMSChrgCurrLmt').Values);
    pqr             = timeseries2timetable(out.logsout.getElement('pqr').Values);
    SteerWhlAng     = timeseries2timetable(out.logsout.getElement('SteerWhlAng').Values);
    SteerCmd        = timeseries2timetable(out.logsout.getElement('SteerCmd').Values);

    DriverMode      = AccelPdl;
    DriverMode      = addvars(DriverMode,ones(60001,1),'NewVariableNames','DriverMode');
    DriverMode.AccelPdl = [];
    
    VCU_Inputs = [AccelPdl BcuBrkPrsCmd VehSpdFdbk EMSpd TransGear BMSSOC...
        BattPackVolt BMSDichrgCurrLmt BMSChrgCurrLmt pqr SteerWhlAng SteerCmd DriverMode];
    writetimetable(VCU_Inputs,fullfile(fldrName,'VCU_Inputs.csv'))
    
    disp('Save VCU model outputs as a CSV')
    EngTrqCmd       = timeseries2timetable(out.logsout.getElement('EngTrqCmd').Values);
    EMTrqCmd        = timeseries2timetable(out.logsout.getElement('EMTrqCmd').Values);
    VcuBrkPrsCmd    = timeseries2timetable(out.logsout.getElement('VcuBrkPrsCmd').Values);
    Cltch1Cmd       = timeseries2timetable(out.logsout.getElement('Cltch1Cmd').Values);
    Neutral         = timeseries2timetable(out.logsout.getElement('Neutral').Values);
    FuelCellCurrCmd = timeseries2timetable(out.logsout.getElement('FuelCellCurrCmd').Values);
    FuelCellTempCmd = timeseries2timetable(out.logsout.getElement('FuelCellTempCmd').Values);
    VCU_Outputs = [EngTrqCmd EMTrqCmd VcuBrkPrsCmd Cltch1Cmd Neutral FuelCellCurrCmd FuelCellTempCmd];
    writetimetable(VCU_Outputs,fullfile(fldrName,'VCU_Outputs.csv'))

    disp('Cleanup and close!')
    close_system(mdlName)
end

