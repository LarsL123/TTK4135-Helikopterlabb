clear all;
close all;
clc;
%Endre på disse to:
init_file = "init.m";
model = 'helicopter';

% For å stoppe fra kommandolinjen:
% set_param(model, 'SimulationCommand','stop');

% This part has been moved to the stopfcn:
% % Get next test number and generate a new folder
% testfolders = dir('data*');
% testNumber = length(testfolders) + 1;
% testName = sprintf('data%03d',testNumber);
% mkdir(testName);

% Init, build and run:
run(init_file)
slbuild(model)
set_param(model, 'SimulationCommand','connect');
set_param(model, 'SimulationCommand','start');
disp("running")


% %This part has been moved to the stopfcn:
% %Move files to test folder
% files = dir('log_*.mat');
% for k = 1:length(files)
%     src = fullfile(files(k).folder, files(k).name);
%     dest = fullfile(testName);
%     movefile(src,dest);
% end
