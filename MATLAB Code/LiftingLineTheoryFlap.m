function CL_TO = LiftingLineTheoryFlap(S,AR,alpha_twist,lambda,i_w,a_2d,a_0,a_0_fd,bf_b)

N = 9; % (number of segments-1)
b = sqrt(AR*S); % wing span
MAC = S/b; % Mean Aerodynamic Chord
Croot = (1.5*(1+lambda)*MAC)/(1+lambda+lambda^2); % root chord
theta = pi/(2*N):pi/(2*N):pi/2;
alpha=linspace(i_w+alpha_twist,i_w,N); % segment's angle of attack
for i=1:N
    if (i/N)>(1-bf_b)
        alpha_0(i)=a_0_fd; %flap down zero lift AOA
    else
        alpha_0(i)=a_0; %flap up zero lift AOA
    end
end
z = (b/2)*cos(theta);
c = Croot * (1 - (1-lambda)*cos(theta)); % MAC at each segment
mu = c * a_2d / (4 * b);
LHS = mu .* (alpha-alpha_0)/57.3; % Left Hand Side
% Solving N equations to find coefficients A(i):
for i=1:N
    for j=1:N
        B(i,j) = sin((2*j-1) * theta(i)) * (1 + (mu(i) * (2*j-1)) / sin(theta(i)));
    end
end
A=B\transpose(LHS);
for i = 1:N
    sum1(i) = 0;
    sum2(i) = 0;
    for j = 1 : N
        sum1(i) = sum1(i) + (2*j-1) * A(j)*sin((2*j-1)*theta(i));
        sum2(i) = sum2(i) + A(j)*sin((2*j-1)*theta(i));
    end
end
CL_TO = pi * AR * A(1);
end
