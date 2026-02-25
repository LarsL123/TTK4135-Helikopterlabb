clc
clear

load('travel.mat')
load('elev.mat')

[elevation, travel] = synchronize(elevation,travel,'union')

Ts_sync = [elevation,travel]

save("combined_timeseries.mat","Ts_sync")