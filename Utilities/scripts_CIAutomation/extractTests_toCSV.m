function [] = extractTests_toCSV()
% extractTests_toCSV is used to simulate the BMs, VCU and system level test harnesses
% and save the result artifacts as CSVs, so others can take advantage of the
% baseline simulation results as a comparison point for real-world tests.

writeCSV_BMS()
writeCSV_VCU()
result = writeCSV_SysModel();