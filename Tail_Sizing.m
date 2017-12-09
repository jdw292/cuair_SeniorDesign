c = 0.403;    %MAC
b = 3.625;    %wingspan
S = 1.46;    %wing area
V = 18.4; %[m/s]
rho = 1.225; %[kg/m^3]
g = 9.81; %[m/s^2]
m = 16; %[kg]
C_L =  (m*g)/(0.5*rho*V^2*S) %coefficient of lift
l_f = 2.3;  %fuselage length


%% Horizontal Tail

l_h = 0.6*l_f %Horizontal tail moment arm
V_h = 0.45;   %HT volume coefficient, typically between 0.30 . . . 0.60
AR_h = 6;     %From Raymer page 76
% horizontal tail taper ratio = 1 (no taper)


S_h = V_h*S*c/l_h %HT Area
b_h = sqrt(AR_h*S_h)    %HT Span
c_h = S_h/b_h     %HT chord

%% Vertical Tail

l_v = l_h;     %assume vertical and horizontal tail moment arms are the same due to airframe configuration
V_v = 0.045;   %VT volume coefficient, typically between 0.02 . . . 0.05
AR_v = 1.4;    %From Raymer page 76
lambda_v = 0.7; %From Raymer page 76

S_v = V_v*S*b/l_v %VT Area
S_v_each = S_v/2
b_v = sqrt(AR_v*S_v_each)    %VT Span
c_v = S_v_each/b_v     %VT MAC
c_v_root = c_v*(2-lambda_v)
c_v_tip = c_v*(lambda_v)

%% Spiral Stability Parameter, B
Gamma = 3; %dihedral angle of wing
Gamma2 = Gamma + 2; %to account for high wing, from Raymer pg 60
% NOTE: Raymer suggests a dihedral of 0 . . . 2 for High Wing


B = l_v*Gamma2/(b*C_L) %where Gamma is dihedral angle in degrees
% B should be greater than 5, but a B around 3 or 4 isn't too bad, and is
% OK for an experienced pilot. 



%% Roll Authority

RA = V_v*B %should be in the range of 0.10 . . . 0.20



%% Aileron Sizing