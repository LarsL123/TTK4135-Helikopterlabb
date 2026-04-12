close all

% Common styling settings
fontSize = 12;
lineWidth = 1.8;

%% -------- Travel Plot --------
figure(1); clf; hold on; box on; grid on;

% Theoretical
timeTravel = x1_timeseries.Time;
valuesTravel = x1_timeseries.Data;

% Experimental
fileTravel = load('data002\log_travel.mat');
dataArray = fileTravel.travel;
timeVec = dataArray(1,:);

% Plot
plot(timeVec, dataArray(2,:), 'b', 'LineWidth', lineWidth);
plot(timeTravel, valuesTravel, '--r', 'LineWidth', lineWidth);

% Labels and title
xlabel('Time (s)', 'FontSize', fontSize);
ylabel('Travel Angle (rad)', 'FontSize', fontSize);
%title('Travel: Experimental vs Theoretical', 'FontSize', fontSize);

% Legend
legend({'Experimental', 'Optimal Path'}, ...
    'Location', 'best', 'FontSize', fontSize);

% Axes styling
set(gca, 'FontSize', fontSize, 'LineWidth', 1);
exportgraphics(gca, 'travel_lab4.pdf', ...
    'ContentType', 'vector');

hold off;


%% -------- Elevation Plot --------
figure(2); clf; hold on; box on; grid on;

% Theoretical
timeElev = x5_timeseries.Time;
valuesElev = x5_timeseries.Data;

% Experimental
fileElev = load('data002\log_elevation.mat');
dataArray = fileElev.elevation;
timeVec = dataArray(1,:);

% Plot
plot(timeVec, dataArray(2,:), 'b', 'LineWidth', lineWidth);
plot(timeElev, valuesElev, '--r', 'LineWidth', lineWidth);

% Labels and title
xlabel('Time (s)', 'FontSize', fontSize);
ylabel('Elevation Angle (rad)', 'FontSize', fontSize);
%title('Elevation: Experimental vs Theoretical', 'FontSize', fontSize);

% Legend
legend({'Experimental', 'Optimal Path'}, ...
    'Location', 'best', 'FontSize', fontSize);

% Axes styling
set(gca, 'FontSize', fontSize, 'LineWidth', 1);
exportgraphics(gca, 'elevation_lab4.pdf', ...
    'ContentType', 'vector');

hold off;