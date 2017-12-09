function foilSpec = XFoilTextReader( fileName )
%XFoilTextReader takes in a fileName of an XFoil .csv file from
%Airfoiltools.com and outputs the name, and the CL,CD,CDp,CM at various
%angles of attack

%.csv file must only contain numbers, so delete everything above the table
%from the file that you download from Airfoiltools

FoilData = csvread(fileName);%puts the .csv data into a matrix

foilSpec.nombre = fileName; %name of the airfoil
foilSpec.AoA = FoilData(:,1); %array of angle of attacks
foilSpec.CL = FoilData(:,2); %array of coefficient of lifts
foilSpec.CD = FoilData(:,3); %array of coefficient of drags
foilSpec.CDp = FoilData(:,4); %array of coefficient of parasitic drags? not exactly sure what this is but I dont need it
foilSpec.CM = FoilData(:,5); %array of coefficient of moments

[foilSpec.CLmax(1),foilSpec.CLmax(2)]=max(foilSpec.CL); %max coefficient of lift
[foilSpec.CDmin(1),foilSpec.CDmin(2)]=min(foilSpec.CD); %min coefficient of drag
[foilSpec.CL_CDmax(1),foilSpec.CL_CDmax(2)]=max(foilSpec.CL./foilSpec.CD); %max lift to drag ratio
%foilSpec.CLmax(2)=foilSpec.AoA(CLmaxI); %angle of attack corresponding to max lift
%foilSpec.CDmin(2)=foilSpec.AoA(CDminI); %angle of attack corresponding to min drag
%foilSpec.CL_CDmax(2)=foilSpec.AoA(CL_CDmaxI); %angle of attack corresponding to max lift to drag

end