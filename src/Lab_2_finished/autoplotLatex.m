clc;

%% ---------------- DATA SETUP ----------------
latest_test = 'data003';

matfiles = dir(fullfile(latest_test, '*.mat'));
dataStruct = struct();

vars = [];

for k = 1:length(matfiles)
    filePath = fullfile(latest_test, matfiles(k).name);
    value = load(filePath);

    fn = erase(matfiles(k).name, '.mat');
    dataStruct.(fn) = value;

    vars = [vars, fieldnames(value)];
end

%% ---------------- OUTPUT FOLDER ----------------
figFolder = fullfile(latest_test,'Figures');
if ~exist(figFolder, 'dir')
    mkdir(figFolder);
end

fields = fieldnames(dataStruct);

%% ---------------- PLOT STYLE (LaTeX READY) ----------------
set(groot, ...
    'defaultTextInterpreter','latex', ...
    'defaultAxesTickLabelInterpreter','latex', ...
    'defaultLegendInterpreter','latex');

%% ---------------- PLOTTING LOOP ----------------
for k = 1:length(fields)

    topName = fields{k};
    varName = vars{k};

    tsStruct = dataStruct.(topName);
    dataArray = tsStruct.(varName);

    timeVec = dataArray(1,:);
    signalRows = 2:size(dataArray,1);

    % -------- figure styling --------
    fig = figure('Color','w','Units','centimeters', ...
                 'Position',[5 5 14 9]);  % good for report

    hold on;

    colors = lines(length(signalRows));
    legendEntries = {};

    for r = signalRows

        % Convert degrees -> radians + offset
        y = dataArray(r,:) * 2*pi/360 + pi;

        plot(timeVec, y, ...
            'LineWidth', 2, ...
            'Color', colors(r-1,:));

        legendEntries{end+1} = sprintf('Travel', r-1);
    end

    hold off;

    %% ---------------- FORMATTING ----------------
    xlabel('Time (s)', 'FontSize', 14);
    ylabel('Angle (rad)', 'FontSize', 14);

    grid on;
    box on;

    legend(legendEntries, ...
        'Location','best', ...
        'FontSize',12);

    %% ---------------- EXPORT (LATEX BEST PRACTICE) ----------------
    set(gcf, 'Renderer', 'painters');

    exportgraphics(fig, ...
        fullfile(figFolder, [fields{k} '_' varName '.pdf']), ...
        'ContentType','vector');

    % Optional EPS fallback:
    % print(fig, fullfile(figFolder,[fields{k} '_' varName '.eps']), '-depsc');
end