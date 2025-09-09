function [systemOutputs] = writeCSV_SysModel()
% extractModelDataToCSV is used to simulate the system level model and save the result artifacts as
% CSV, so others can understand the expected baseline behavior of  the
% system.

    % Get handle to project
    prj = matlab.project.currentProject;
    disp(' ')
    disp("Project: " + prj.Name)

    % Create folder to save CSVs
    fldrName = fullfile(prj.RootFolder,'GeneratedArtifacts','TestResults','BaselineCSVs');
    if isfolder(fldrName)
    else
        mkdir(fldrName)
    end

    % Open Test Harness and setup for the 3 scenarios
    mdl = 'EV_ControlSystem_Architecture_Harness1';
    load_system(mdl)
    in = Simulink.SimulationInput(mdl);    
    valueSet = {'normalMode','normalToSportMode','sportMode'};
        blk1 = 'EV_ControlSystem_Architecture_Harness1/BatteryDetails';
        blk2 = 'EV_ControlSystem_Architecture_Harness1/Vehicle Emulator/VehicleDetaiils';
        blk3 = 'EV_ControlSystem_Architecture_Harness1/driverInput';
        blk4 = 'EV_ControlSystem_Architecture_Harness1/Subsystem/Scenario';
    
     % Simulate system and collect logs
    for i = 1:3
        value = valueSet{i};
        set_param(blk1,'ActiveScenario',value);
        set_param(blk2,'ActiveScenario',value);
        sltest.testsequence.activateScenario(blk3,value);
        set_param(blk4,'MaskDisplay',['disp("Active Scenario: ' value '")']);
        disp(['Simulating Scenario: ' value])
        out{i} = sim(in);
    end
    close_system(mdl,0)
    
    % Save info into CSVs
    for i = 1:3
        AccelPdl            = timeseries2timetable(out{1,i}.sysInputs.AccelPdl);
        BcuBrkPrsCmd        = timeseries2timetable(out{1,i}.sysInputs.BcuBrkPrsCmd);
        VehSpd              = timeseries2timetable(out{1,i}.sysInputs.VehSpd);
        EMSpd               = timeseries2timetable(out{1,i}.sysInputs.EMSpd);
        driverMode          = timeseries2timetable(out{1,i}.sysInputs.driverMode);
        Batt_Cell_Voltages  = timeseries2timetable(out{1,i}.sysInputs.BatterySensors.Cell_Voltages);
        Batt_Pack_Voltage   = timeseries2timetable(out{1,i}.sysInputs.BatterySensors.Pack_Voltage);
        Pack_Current        = timeseries2timetable(out{1,i}.sysInputs.BatterySensors.Pack_Current);
        Batt_Cell_Temperatures = timeseries2timetable(out{1,i}.sysInputs.BatterySensors.Cell_Temperatures);
        Batt_Vout_Chgr      = timeseries2timetable(out{1,i}.sysInputs.BatterySensors.Vout_Chgr);
        Batt_Vout_Invtr     = timeseries2timetable(out{1,i}.sysInputs.BatterySensors.Vout_Invtr);
    
        numRows = 401;
        a = VehSpd;
        a = addvars(a,zeros(numRows,3),'NewVariableNames','pqr');
        a = addvars(a,zeros(numRows,1),'NewVariableNames','SteerCmd');
        a = addvars(a,zeros(numRows,1),'NewVariableNames','SteerWhlAng1');
        a = addvars(a,zeros(numRows,1),'NewVariableNames','SteerWhlAng2');
        a = addvars(a,zeros(numRows,1),'NewVariableNames','SteerWhlAng3');
        a = addvars(a,zeros(numRows,1),'NewVariableNames','SteerWhlAng4');
        a = addvars(a,zeros(numRows,1),'NewVariableNames','TransGear');
        a.VehSpd = [];
    
        systemInputs = [AccelPdl BcuBrkPrsCmd VehSpd EMSpd driverMode a...
            Batt_Cell_Voltages Batt_Pack_Voltage Pack_Current ...
            Batt_Cell_Temperatures Batt_Vout_Chgr Batt_Vout_Invtr];
    
        filename = ['Scenario_Inputs_' valueSet{i} '.csv'];
        disp(['Saving Scenario Inputs for' valueSet{i}]);
        writetimetable(systemInputs,fullfile(fldrName,filename))
    
        VCU_EngTrqCmd           = timeseries2timetable(out{1,i}.sysOutputs.VCU_Commands.EngTrqCmd);
        VCU_EMTrqCmd            = timeseries2timetable(out{1,i}.sysOutputs.VCU_Commands.EMTrqCmd);
        VCU_BrkCmd              = timeseries2timetable(out{1,i}.sysOutputs.VCU_Commands.BrkCmd);
        VCU_Cltch1Cmd           = timeseries2timetable(out{1,i}.sysOutputs.VCU_Commands.Cltch1Cmd);
        VCU_Neutral             = timeseries2timetable(out{1,i}.sysOutputs.VCU_Commands.Neutral);
        VCU_FuelCellCurrCmd     = timeseries2timetable(out{1,i}.sysOutputs.VCU_Commands.FuelCellCurrCmd);
        VCU_FuelCellTempCmd     = timeseries2timetable(out{1,i}.sysOutputs.VCU_Commands.FuelCellTempCmd);
    
        BMS_SOC                 =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.SOC);
        BMS_ChargeCurrentReq    =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.ChargeCurrentReq);
        BMS_State               =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.BMS_State);
        BMS_ChargeMode          =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.ChargeMode);
        BMS_BalCmd              =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.BalCmd);
        BMS_DischargeCurrentLim =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.CurrentLimits.DischargeCurrentLimit);
        BMS_ChargeCurrentLim    =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.CurrentLimits.ChargeCurrentLimit);
        BMS_CntCmd_PosCntctChgrCmd      =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.CntctCmd.PosCntctChgrCmd);
        BMS_CntCmd_PreChrgRelayChgrCmd  =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.CntctCmd.PreChrgRelayChgrCmd);
        BMS_CntCmd_NegCntctChgrCmd      =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.CntctCmd.NegCntctChgrCmd);
        BMS_CntCmd_PosCntctInvtrCmd     =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.CntctCmd.PosCntctInvtrCmd);
        BMS_CntCmd_PreChrgRelayInvtrCmd = timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.CntctCmd.PreChrgRelayInvtrCmd);
        BMS_CntCmd_NegCntctInvtrCmd     =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.CntctCmd.NegCntctInvtrCmd);
        BMS_Faults_PackOverCurrFlt      =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.Faults.PackOverCurrFlt);
        BMS_Faults_CellHighTempFlt      =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.Faults.CellHighTempFlt);
        BMS_Faults_CellLowTempFlt       =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.Faults.CellLowTempFlt);
        BMS_Faults_VoltSensorFlt        =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.Faults.VoltSensorFlt);
        BMS_Faults_CellOverVoltFlt      =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.Faults.CellOverVoltFlt);
        BMS_Faults_CellUnderVoltFlt     =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.Faults.CellUnderVoltFlt);
        BMS_Faults_ChrgCntctFlt         =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.Faults.ChrgCntctFlt);
        BMS_Faults_InvtrCntctFlt        =  timeseries2timetable(out{1,i}.sysOutputs.BMS_Commands.Faults.InvtrCntctFlt);
    
        systemOutputs_VCU = [VCU_EngTrqCmd VCU_EMTrqCmd VCU_BrkCmd VCU_Cltch1Cmd ...
            VCU_Neutral VCU_FuelCellCurrCmd VCU_FuelCellTempCmd];
        systemOutputs_BMS = [BMS_SOC BMS_ChargeCurrentReq BMS_State BMS_ChargeMode ...
            BMS_BalCmd BMS_DischargeCurrentLim BMS_ChargeCurrentLim...
            BMS_CntCmd_PosCntctChgrCmd BMS_CntCmd_PreChrgRelayChgrCmd BMS_CntCmd_NegCntctChgrCmd ...
            BMS_CntCmd_PosCntctInvtrCmd BMS_CntCmd_PreChrgRelayInvtrCmd BMS_CntCmd_NegCntctInvtrCmd...
            BMS_Faults_PackOverCurrFlt BMS_Faults_CellHighTempFlt ...
            BMS_Faults_CellLowTempFlt BMS_Faults_VoltSensorFlt ...
            BMS_Faults_CellOverVoltFlt BMS_Faults_CellUnderVoltFlt ...
            BMS_Faults_ChrgCntctFlt BMS_Faults_InvtrCntctFlt];
        systemOutputs = [systemOutputs_VCU systemOutputs_BMS];

        filename = ['Scenario_Outputs_' valueSet{i} '.csv'];
        disp(['Saving Scenario Output for' valueSet{i}]);
        writetimetable(systemInputs,fullfile(fldrName,filename))
    end
end