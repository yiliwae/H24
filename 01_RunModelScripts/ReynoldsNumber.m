% Given values
density = 770; % density of the coolant in kg/m^3
diameter_cm = 5; % diameter of the pipe in cm
kinematic_viscosity = 1.5e-6; % kinematic viscosity in m^2/s

% Convert diameter to meters
diameter_m = diameter_cm / 100;

% Calculate dynamic viscosity
dynamic_viscosity = density * kinematic_viscosity; % in kg/(m·s)

% Assume a flow rate or calculate velocity
% For example, assume a flow rate of 1 L/min converted to m^3/s
flow_rate_L_min = [1:10:60]; % flow rate in L/min
flow_rate_m3_s = flow_rate_L_min / 1000 / 60; % converting L/min to m^3/s

% Calculate the velocity (v = Q / A)
area_m2 = pi * (diameter_m / 2)^2; % cross-sectional area of the pipe in m^2
velocity_m_s = flow_rate_m3_s / area_m2; % velocity in m/s

% Calculate Reynolds number
Reynolds_number = (density * velocity_m_s * diameter_m) / dynamic_viscosity;


figure;
plot(flow_rate_L_min, Reynolds_number, 'b-', 'LineWidth', 2);
hold on 
yline(2000)
yline(4000)
title('Coolant Flow Rate vs. Reynolds Number');
xlabel('Coolant Flow Rate (L/min)');
ylabel('Reynolds Number');
grid on;