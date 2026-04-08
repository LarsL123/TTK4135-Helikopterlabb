folders = dir('data*');
last_folder = folders(end);
% Uncomment here to choose custom folder:
% last_folder = Experiment_data001
latest_test = last_folder.name;
filePattern = fullfile(pwd,latest_test);
matfiles = dir(fullfile(latest_test, '*.mat'));
dataStruct = struct();

vars = [];
for k = 1:length(matfiles)
    filePath = fullfile(latest_test, matfiles(k).name);
    value = load(filePath);
    fn = erase(matfiles(k).name, '.mat');
    dataStruct.(fn) = value;
    vars = [vars,fieldnames(value)];
end

figFolder = fullfile(latest_test,'Figures');
if ~exist(figFolder, 'dir')
    mkdir(figFolder);
end

fields = fieldnames(dataStruct);

for k = 1:length(fields)
    topName = fields{k};
    varName = vars{k};
    tsStruct = dataStruct.(topName);
    dataArray = tsStruct.(varName);
    timeVec = dataArray(1,:);
    signalRows = 2:size(dataArray,1);
    fig = figure(k);
    hold on
    for r = signalRows
        plot(timeVec,dataArray(r,:));
        % TODO: finne løsning med legends
    end
    hold off
    xlabel('Time (s)');
    ylabel('Signal');
    title([fields(k)]);
    saveas(fig,fullfile(figFolder,[fields{k} '_' varName '.eps']),'epsc')
end

