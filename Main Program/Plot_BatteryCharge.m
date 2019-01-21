function [] = Plot_BatteryCharge(Time, BatteryCharge, BatteryCapacity, BatteryChargeLowerLimit, Iterations)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% Plots the level of battery charge over a given analysis time period

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% Time: Vector containing the time in epoch-seconds at each time step
% during the time period to be plotted [s]
% BatteryCharge: Vector containing the charge of the battery at each time
% step during the time period to be plotted [W-hr]
% BatteryCapacity: Maximum capacity of the battery [W-hr]
% BatteryChargeLowerLimit: Minimum acceptable charge on the battery [W-hr]
% Iterations: Total number of time steps. Just to help make lines.

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------

% Plotting
figure
plot(Time, BatteryCharge)
title('Battery Charge vs Time')
xlabel('Time (s)');
ylabel('Charge (W hr)');
hold on
grid on
grid minor
BatteryCapacityLine = BatteryCapacity*ones(Iterations,1);
BatteryChargeLowerLimitLine = BatteryChargeLowerLimit*ones(Iterations,1);
plot(Time, BatteryCapacityLine, 'b', Time, BatteryChargeLowerLimitLine, 'r');
legend('Charge', 'Max Capacity', 'Min Charge')


end

