function [] = Plot_Temperature(Time, Temp, Iterations, SurvivalMinTemp, SurvivalMaxTemp, ...
    OperationalMinTemp, OperationalMaxTemp, ScientificMinTemp, ScientificMaxTemp)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function plots the isothermal temperature of the satellite over the
% analysis time period.

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% Time: Vector of time in epoch seconds at each time step, [s]
% Temp: Vector of satellite temeprature at each time step, [K]
% Iterations: Total number of time steps
% SurvivalMinTemp: Absolute minimum temperature satellite should experience
% for survival, [K]
% SurvivalMaxTemp: Absolute maximum temperature satellite should experience
% for survival, [K]
% OperationalMinTemp: Minimum temperature for operations, [K]
% OperationalMaxTemp: Maximum temperature for operations, [K]
% ScientificMinTemp: Minimum temperature for specific science capabilites, [K] 
% ScientificMaxTemp: Maximum temperature for specific science capabilites, [K] 

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------


figure
TempC = Temp-273;
h = plot(Time, TempC);
title('Temperature vs Time')
xlabel('Time (s)');
ylabel('Temp (C)');
hold on
grid on
grid minor

try
    SurvivalMinLine = (SurvivalMinTemp-273)*ones(Iterations,1);
    SurvivalMaxLine = (SurvivalMaxTemp-273)*ones(Iterations,1);
    h1 = plot(Time, SurvivalMinLine, 'm');
    h11 = plot(Time, SurvivalMaxLine, 'm');
catch
end

try
    OperationalMinLine = (OperationalMinTemp-273)*ones(Iterations,1);
    OperationalMaxLine = (OperationalMaxTemp-273)*ones(Iterations,1);
    h2 = plot(Time, OperationalMinLine, 'r');
    h22 = plot(Time, OperationalMaxLine, 'r');
catch
end

try
    ScientificMinLine = (ScientificMinTemp-273)*ones(Iterations,1);
    ScientificMaxLine = (ScientificMaxTemp-273)*ones(Iterations,1);
    h3 = plot(Time, ScientificMinLine, 'y');
    h33 = plot(Time, ScientificMaxLine, 'y');
catch
end

try
    legend([h, h1, h2, h3], 'Temp', 'Survival', 'Operational', 'Scientific')
catch
    try
        legend([h, h1, h2], 'Temp', 'Survival', 'Operational')
    catch
        try
            legend([h, h1], 'Temp', 'Survival')
        catch
            try
                legend(h, 'Temp')
            catch
            end
        end
    end
end

end

