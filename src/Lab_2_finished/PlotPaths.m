clc;

%% ---------------- USER SETTINGS ----------------
q_values = [0.12, 1.2, 12];

vars_to_plot = {'x1'}; 

x_crop = [20 100];   % [start end], or [] for full range

%% ---------------- FIGURE SETUP (PUBLICATION STYLE) ----------------
figure('Color','w');   % white background
hold on;

set(gca, ...
    'FontSize', 14, ...
    'LineWidth', 1.2, ...
    'TickLabelInterpreter', 'latex');

xlabel('Index', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Value', 'Interpreter', 'latex', 'FontSize', 16);
%title('Comparison of pitch reference for different $q$ values', ...
  %  'Interpreter', 'latex', 'FontSize', 16);

box on;
grid on;
grid minor;

%% ---------------- COLOR SETUP ----------------
base_colors = lines(length(vars_to_plot));
nQ = length(q_values);
shade_factor = linspace(0.4, 1, nQ);

legend_entries = {};

%% ---------------- MAIN LOOP ----------------
for v = 1:length(vars_to_plot)
    var_name = vars_to_plot{v};
    base_color = base_colors(v,:);

    for i = 1:length(q_values)
        q = q_values(i);

        filename = sprintf('optimal_path_q%g.mat', q);
        data = load(filename);

        if isfield(data, var_name)

            y = data.(var_name);
            x = 1:length(y);

            % cropping
            if ~isempty(x_crop)
                idx = x >= x_crop(1) & x <= x_crop(2);
                x_plot = x(idx);
                y_plot = y(idx);
            else
                x_plot = x;
                y_plot = y;
            end

            % color shading per q
            color = base_color * shade_factor(i);

            % plot (thicker for print)
            plot(x_plot, y_plot, ...
                'Color', color, ...
                'LineWidth', 2.2);

            legend_entries{end+1} = sprintf('$q = %.2f$', q);

        else
            warning('Variable "%s" not found in %s', var_name, filename);
        end
    end
end

%% ---------------- LEGEND ----------------
legend(legend_entries, ...
    'Location', 'best', ...
    'Interpreter', 'latex', ...
    'FontSize', 13);

hold off;

%% ---------------- EXPORT (HIGH QUALITY) ----------------
set(gcf, 'Renderer', 'painters'); % vector-friendly rendering

% Save as vector PDF (BEST for papers)
exportgraphics(gcf, 'figure_x1_q_comparison.pdf', 'ContentType', 'vector');

% Optional: high-res PNG backup
%exportgraphics(gcf, 'figure_x4_q_comparison.png', 'Resolution', 600);