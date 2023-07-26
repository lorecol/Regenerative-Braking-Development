function [figure1, figure2] = IVplot(ICC, VCC, ICV, VCV, numReadings)

% Plot voltage and current measured in CC mode
figure1 = figure;
subplot(1, 2, 1)
plot(1:numReadings, ICC);
title('Current in CC charging mode');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(1:numReadings, VCC);
title('Voltage in CC charging mode');
xlabel('time [s]');
ylabel('Voltage [V]');

% Plot voltage and current measured in CV mode
figure2 = figure;
subplot(1, 2, 1)
plot(1:numReadings, ICV);
title('Current in CV charging mode');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(1:numReadings, VCV);
title('Voltage in CV charging mode');
xlabel('time [s]');
ylabel('Voltage [V]');

end