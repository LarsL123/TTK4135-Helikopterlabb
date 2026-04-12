clc;

%% ---------------- USER SETTINGS ----------------
vars_to_plot = {'x1'};
selectedExpVars = {'travel'};

q_values = [0.12, 1.2, 12];

folders = dir('data*');
latest_folder = 'data003';

t_crop_exp = [5, 18];   % experimental time crop

%% ---------------- FIGURE SETUP ----------------
figure('Color','w'); hold on;

set(gca, ...
    'FontSize', 14, ...
    'LineWidth', 1.2, ...
    'TickLabelInterpreter', 'latex');

xlabel('Time', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Value', 'Interpreter', 'latex', 'FontSize', 16);

box on;
grid on;
grid minor;

%% ---------------- COLORS ----------------
base_colors = lines(length(vars_to_plot));
legend_entries = {};

%% ============================================================
%% ---------------- EXPERIMENTAL DATA FIRST -------------------
%% (needed for time reference)
%% ============================================================
matfiles = dir(fullfile(latest_folder, '*.mat'));

% Store experimental time (assume first file is reference)
exp_time_ref = [];

for k = 1:length(matfiles)

    data = load(fullfile(latest_folder, matfiles(k).name));
    varNames = fieldnames(data);

    for v = 1:length(selectedExpVars)
        var_name = selectedExpVars{v};

        if ~ismember(var_name, varNames)
            continue;
        end

        dataArray = data.(var_name);

        if size(dataArray,1) < 2
            continue;
        end

        timeVec = dataArray(1,:);

                %% ---------------- CROPPING ----------------
        if ~isempty(t_crop_exp)
            idx = timeVec >= t_crop_exp(1) & timeVec <= t_crop_exp(2);
            t_plot = timeVec(idx);
        else
            t_plot = timeVec;
        end

        exp_time_ref = t_plot;   % store reference time
    end
end

if isempty(exp_time_ref)
    error('No experimental time found.');
end

%% ============================================================
%% ---------------- THEORETICAL DATA --------------------------
%% ============================================================
nQ = length(q_values);
shade_factor = linspace(0.4, 1, nQ);

for v = 1:length(vars_to_plot)

    var_name = vars_to_plot{v};
    base_color = base_colors(v,:);

    for i = 1:nQ

        q = q_values(i);
        filename = sprintf('optimal_path_q%g.mat', q);

        if ~isfile(filename)
            warning('Missing file: %s', filename);
            continue;
        end

        data = load(filename);

        if ~isfield(data, var_name)
            continue;
        end

        y = data.(var_name);

        %% ---------------- ALIGN THEORY TO EXP TIME ----------------
        t_theory = linspace(exp_time_ref(1), exp_time_ref(end), length(y));

        y_interp = interp1(t_theory, y, exp_time_ref, 'linear', 'extrap');

        %% ---------------- PLOTTING ----------------
        color = base_color * shade_factor(i);

        plot(exp_time_ref, y_interp, ...
            'Color', color, ...
            'LineWidth', 2.5);

        legend_entries{end+1} = sprintf('$%s$ theory ($q=%.2f$)', var_name, q);
    end
end

%% ============================================================
%% ---------------- EXPERIMENTAL DATA --------------------------
%% ============================================================
for k = 1:length(matfiles)

    data = load(fullfile(latest_folder, matfiles(k).name));
    varNames = fieldnames(data);

    for v = 1:length(selectedExpVars)

        var_name = selectedExpVars{v};

        if ~ismember(var_name, varNames)
            continue;
        end

        dataArray = data.(var_name);

        if size(dataArray,1) < 2
            continue;
        end

        timeVec = dataArray(1,:);
        signals = dataArray(2:end,:);

        for r = 1:size(signals,1)

            y = signals(r,:)*2*pi/360;

            %% ---------------- CROPPING ----------------
            if ~isempty(t_crop_exp)
                idx = timeVec >= t_crop_exp(1) & timeVec <= t_crop_exp(2);

                t_plot = timeVec(idx);
                y = y(idx);
            else
                t_plot = timeVec;
            end

            plot(t_plot, y, ...
                '--', ...
                'Color', base_colors(v,:), ...
                'LineWidth', 1.5);
        end

        legend_entries{end+1} = sprintf('$%s$ experiment', var_name);
    end
end

%% ---------------- LEGEND ----------------
legend(legend_entries, ...
    'Interpreter', 'latex', ...
    'FontSize', 12, ...
    'Location', 'best');

%% ---------------- EXPORT ----------------
set(gcf, 'Renderer', 'painters');

exportgraphics(gcf, 'comparison_plot.pdf', ...
    'ContentType', 'vector');