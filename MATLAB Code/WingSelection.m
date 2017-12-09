function WingDim = WingSelection(Sin,mTot,Vc,Vto)
%WingSelection takes in various inputs and calculates a general layout for
%the wings using steps outlined in a paper somewhere
%Sin - expected wing surface area (can be modified inside program potentially
%mTot - expected mass of the plane
%Vc - desired cruise velocity
%Vto - takeoff velocity (calculated from catapult launch)
rho = 1.225; %SSL density

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1. Number of wings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%We are using a single wing, though a biplane configuration could be
%considered

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2. Wing vertical location
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%High wing location is best for our application, see analysis in report

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3. Initial wing configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anhedral = -5; %degrees (-5 is recommended for high wing, subsonic)
SweepAngle = 0; %degrees (sweep not important below M=.3)
TaperRatio = 1; %Ctip/Croot (set as 1 initially, adjust later)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%4. Define cruise weight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Wc = mTot*9.81; %typically defined as average of inital and final weights (does not vary for electric)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%5. Calculate ideal cruise lift coefficient Clci
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Clc = 2*Wc/rho/Sin/Vc^2; %lift equation
Clcw = Clc/.95; %Wing lift coefficient: other components account for some lift (.95 recommended to start)
Clci = Clcw/.9; %Ideal lift coefficient: accounts for wing not being ideal (.9 recommended to start)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%6. Calculate takeoff lift coefficient Clto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Clto = .85*2*Wc/rho/Sin/Vto^2; %.85 because at incline angle, engine will provide some component of lift
Cltow = Clto/.95; %other components create lift
Cltoi = Cltow/.9; %wing is not ideal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%7/8. Select high lift device (HLD) and location
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%We're going to start with a single plain flap (keep it simple)

dCl = .8; %change in lift provided by single plain flap

%Also side note, we may not need HLD because our desired Vc isn't much
%higher than our Vto. Something to keep in mind

bf_b = .5; %proportion of wing span with a flap, .7 was recommended for start, but seemed high for our use
Cf_c = .2; %proportion of chord with flap, .2 was recommended for start
dfmax = 40; %max deflection of the flap, 20 recommended for takeoff, 40 for landing

Clmax = Cltoi - dCl/2 %lift required from wings during takeoff, flaps are half deployed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%9. Select airfoil
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%this process can be incredibly complex, for a general approach, a few
%required factors must be kept in mind to determine possible airfoils. 
%From there more desired factors and optimizations can be considered
%Clci is in airfoil optimal region (often looks like a "bucket" on a polar)
%Clmax is met by the airfoil (hopefully not right at the stall Cl)
foilDir = dir('*.csv'); %get all files in directory that end in .csv
foilName = {foilDir.name}; %get the file names

for i=1:length(foilName) %go through all the files
    foil(i)=XFoilTextReader(foilName{i}); %get airfoil data from XFoilTextReader
end

potCount=1;%keep track of how many potential airfoils there are
for i=1:length(foil)%go through all the airfoils
    if foil(i).CLmax(1) >= Clmax && abs(foil(i).CL(foil(i).CL_CDmax(2))-Cltoi)<2 %check that airfoil meets max lift, and that ideal lift coefficient is close to max lift to drag
       potFoils(potCount)=i; %potFoils is an array of indices which can be used to access foils()
       potCount=potCount+1; %increase potCount
%        max(foil(i).CL.^1.5./foil(i).CD)
%        disp(foil(i).nombre)
%        disp(foil(i).CLmax(1))
%        disp(foil(i).CDmin(1))
%        disp(foil(i).CL_CDmax(1))
    end
    
end

figure(1); clf();
hold on;
for i=1:potCount-1 %go through all potFoils and plot CD against CL
   subplot(potCount-1,1,i);
   plot(foil(potFoils(i)).CL,foil(potFoils(i)).CD); 
   title(foil(potFoils(i)).nombre);
   xlabel('C_L');
   ylabel('C_D');
end

figure(2); clf();
for i=1:potCount-1 %plot CL vs AoA
   subplot(potCount-1,1,i);
   plot(foil(potFoils(i)).AoA,foil(potFoils(i)).CL); 
   title(foil(potFoils(i)).nombre);
   xlabel('\alpha');
   ylabel('C_L');
end

figure(3); clf();
for i=1:potCount-1 %plot lift to drag vs AoA
   subplot(potCount-1,1,i);
   plot(foil(potFoils(i)).AoA,foil(potFoils(i)).CL./foil(potFoils(i)).CD); 
   title(foil(potFoils(i)).nombre);
   xlabel('\alpha');
   ylabel('C_L/C_D');
end

optFoil=foil(potFoils(input('Which airfoil::'))); %1 selects first airfoil out of potFoils, 2 selects the second...
figure(4); clf();
plot(optFoil.AoA,optFoil.CL.^1.5./optFoil.CD)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%10-16. Define wing characteristics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wingIncidence = optFoil.AoA(optFoil.CL_CDmax(2)) %natural angle of attack, chosen to be optimal lift to drag

cont=1;
while cont==1 %ask user if they want to continue iterating
    %ask for parameters
   AR = input('AR::');
   washout = input('Washout::');
   taper = input('Taper ratio::');
   wingIncidence = input('Wing Incidence(root)::');
   Sin = input('S::');
   Clc = 2*Wc/rho/Sin/Vc^2; %lift equation
   Clcw = Clc/.95; %Wing lift coefficient: other components account for some lift (.95 recommended to start)
   Clci = Clcw/.9; %Ideal lift coefficient: accounts for wing not being ideal (.9 recommended to start)
   liftCurveSlope = (optFoil.CL(optFoil.CL_CDmax(2)+5)-optFoil.CL(optFoil.CL_CDmax(2)-5))/ ...
       (optFoil.AoA(optFoil.CL_CDmax(2)+5)-optFoil.AoA(optFoil.CL_CDmax(2)-5))*180/pi

   [noLift,noLiftI] = min(abs(optFoil.CL)); %#ok<ASGLU>
   alpha_0 = optFoil.AoA(noLiftI);
   CLact = LiftingLineTheory(Sin,AR,washout,taper,wingIncidence,liftCurveSlope,alpha_0)
   Clci
   cont=input('Continue?(1)::');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 17. Calculate wing lift at takeoff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cont=1;
while cont==1
    Vto = input('Vto::');
    Clto = 2*mTot*9.8/rho/Sin/Vto^2;
    AoAstall = optFoil.AoA(optFoil.CLmax(2));
    fspanR = input('Flap span ratio::');
    fchordR = input('Flap chord ratio::');
    AOAto = AoAstall-3;
    deltaf = input('Flap Deflection::');
    deltaA0 = -1.15*fchordR*deltaf;
    Clto
    CL_toact = LiftingLineTheoryFlap(Sin,AR,washout,taper,AOAto,liftCurveSlope,alpha_0,alpha_0+deltaA0,fspanR)
    
    cont=input('Continue?(1)::');
end

Cdw = optFoil.CD(optFoil.CL_CDmax(2));
Dwing = .5*Cdw*rho*Sin*Vc^2;
e=.8;
Cx0 = .03;
Cx = Cx0 + CLact^2/e/AR/pi;
DragTot = .5*Cx*rho*Sin*Vc^2;

end

