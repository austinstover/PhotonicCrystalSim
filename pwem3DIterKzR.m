%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Authors:
%%% Austin Stover, 2018 (St. Louis, USA)
%%%		github.com/austinstover, austinsto@hotmail.com
%%% Cazimir-Gabriel Bostan, 2008 (Bucharest, Romania)
%%%		http://cgbostan.evonet.ro, cgbostan@yahoo.com
%%%
%%% Date: July - August 2018
%%%
%%% Description:
%%% This program calculates and plots photonic bands of a 2D photonic
%%% crystal with the Plane Wave Expansion method and estimates of the
%%% effective index of refraction from Sondergaard, IEEE Journal of Quantum
%%% Electronics 34 (12) 1998 535-542. The crystal consists of cylinders 
%%% with a circular cross sectionn and infinite height. The lattice
%%% arrangement depends upon whether the function 'bz_irr_tri' or
%%% 'bz_irr_sqr' is called. Here the fourier coefficients for the expansion
%%% of the dielectric function are calculated analytically. Materials
%%% considered are dielectric and dispersionless.
%%% 
%%% Once this program is run and the data collected in the workspace
%%% variables, the workspace may be saved and each section may be 
%%% individually run to recreate plots of the reloaded workspace.
%%%
%%% pwem3DIterKzR finds the band gap plots over a variety of hole radii r 
%%% and wave vector components along axis kz.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% the package contains the following programs:
%%%     pwem3DIterKzR.m - main program
%%%     epsgg.m - routine for calculating the matrix of Fourier
%%%					coefficients of dielectric function
%%%     bz_irr_sqr.m - routine for calculating the 'k-points' along the
%%%                 perimeter of irreducible Brillouin zone, with a 
%%%					square crystal
%%%		bz_irr_tri.m - routine for calculating 'k-points' with a 
%%%					triangular crystal
%%%     kvect2.m - routine for calculating diagonal matrices with elements
%%%                 (kx+Gx) and (ky+Gy), where G=(Gx,Gy) is a reciprocal
%%%                 lattice vector
%%%     eigsEH.m - routine for solving the eigenvalue problem
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all %#ok<CLALL>
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DASHBOARD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

na=1; nb=1.6; % refractive indices ('na' for cylinders-atoms, 'nb' for background medium/n_fiber)

rMin = 0.30; % radius of cylindrical holes (normalized w.r.t. lattice constant "a", rActual = r*a))
rMax = 0.50;
rNum = 40;
rs = linspace(rMin, rMax, rNum);

g = 1/(cos(2*pi/360 * 30)); %Normalized to 2*pi/a
kzMin = 0;
kzMax = 6*g; %3*g is nice
kzNum = 200; %100 is nice
kzs = linspace(kzMin, kzMax, kzNum);

yMax = 2.5; %The height limit of plots
yMin = 0.7;

%The number of spatial harmonics to calculate (No1 = P/2 = Q/2)
No1=4; %4 is nice

%The number of values on the first side of the irreducible brillouin zone
Nr = 20; %25 is nice

%%% discretization of Brillouin zone--bz_irr_tri for triangular lattice, bz_irr_sqr for square lattice
[nPtsBri,kx,ky,KP,KL,b1,b2,fs,geom] = feval('bz_irr_tri',Nr,rs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
No2=No1;
N1=2*No1+1; N2=2*No2+1;
N=N1*N2; % total number of plane waves used in Fourier expansions

%%% number of bands calculated
numBands = 3*N;

%%% matrices to store the eigenvalues, bandgap values
omega = zeros(length(rs),length(kzs), numBands, nPtsBri); %Preallocate array memory

minBands = zeros(numBands, length(kzs),length(rs));
maxBands = zeros(numBands, length(kzs),length(rs));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PERFORM PWEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Iterate over r
for rIndex = 1:length(rs)
	r = rs(rIndex);
	fprintf('r = %0.4f:\n',r);
	
	%%% matrix of Fourier coefficients
	eps = feval ('epsgg',r,na,nb,b1,b2,N1,N2,fs(rIndex));
	epsBlk = blkdiag(eps, eps, eps);

	%Iterate across kz
	for kzIndex = 1:length(kzs)
		kz = kzs(kzIndex);
		fprintf('\tKz = %0.4f:\n',kz);

		lastBZy = 0; %For printing out the eigenvals evaluated so far

		%Iterate across perimeter of irreducible Brillouin zone
		for j=1:nPtsBri
			%%% diagonal matrices with elements (kx+Gx) si (ky+Gy)
			[kGx, kGy, kGz] = feval('kvect3D',kx(j),ky(j),kz,b1,b2,N1,N2); %kGx, kGy diagonal matrices

			%%% get eigenvals
			omega(rIndex,kzIndex,:,j)=feval('eigs3D',kGx,kGy,kGz,epsBlk); %Row=Band, Column=BZy

			if(No1 > 5 && mod(j,5) == 0 || j == nPtsBri)
				fprintf("\t\tEigenvals calculated for pts k[%i - %i]\n", lastBZy+1, j);
				lastBZy = j;
			end
		end

		%Find bandgaps
		bandGapTolerance = 0.01;
		[minBandGaps, maxBandGaps] = feval('bandGaps', squeeze(omega(rIndex,kzIndex,:,:)), bandGapTolerance);
		minBands(1:length(minBandGaps),kzIndex,rIndex) = minBandGaps;
		maxBands(1:length(maxBandGaps),kzIndex,rIndex) = maxBandGaps;

		fprintf('\t\tBandgap %i: %d, %d\n', vertcat(1:size(minBandGaps), ...
							  transpose([minBandGaps, maxBandGaps])));

	end

end

timeElapsed = toc %#ok<NOPTS>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BAND STRUCTURE PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot at a desired kz, with band gaps filled

plotRIndex = 1; %R index at which to plot omega
plotKzIndex = 1; %Kz index at which to plot omega
figure; %Plot in new window
plot(1:nPtsBri,real(squeeze(omega(plotRIndex,plotKzIndex,:,:))),'r.-');
if(~isempty(minBands(:,plotKzIndex,plotRIndex)))
	hold on;
	fill([1;nPtsBri;nPtsBri;1], transpose([minBands(:,plotKzIndex,plotRIndex), minBands(:,plotKzIndex,plotRIndex), ...
										   maxBands(:,plotKzIndex,plotRIndex), maxBands(:,plotKzIndex,plotRIndex)]),...
								'r','LineStyle','none');
	hold off;
end
alpha(0.2);
title(sprintf('%s, $k_z = %g \\cdot 2\\pi / a$, $r = %g a$, $n_{fiber} = %g$', ...
			  geom,kzs(plotKzIndex),rs(plotRIndex),nb),'Interpreter','latex'); 
xlabel('$k_\perp$','Interpreter','latex');
ylabel('$\omega a / 2\pi c$','Interpreter','latex');
set(gca,'XTick',KP,'XTickLabel',KL,'TickLabelInterpreter','latex');
for n = 1 : length(KP)
	line(KP(n)*[1 1],[yMin yMax],'Color','k','LineStyle',':');
end
xlim([1 nPtsBri]);
ylim([yMin yMax]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BAND STRUCTURE SLIDER INTERACTIVE PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear lastKz; clear lastR1; global lastKz; global lastR1; 
figure; lastKz = 0; lastR1 = 0; %TODO: Save limits of each plot between iterations
ipanel(@(kzIndex,rIndex)plotBandStruct2(yMax,yMin,nPtsBri,omega,geom,nb,rs,floor(rIndex),numBands,minBands,maxBands,KP,KL,kzs,floor(kzIndex)), ...
	   {'slider','k_z Index',{1,length(kzs)+0.5,10}},{'slider','r Index',{1,length(rs)+0.5,10}}, ...
		'MinControlWidth',300,'LabelWidth',100);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BAND GAPS OVER KZ PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotRIndex = 30;
figure; %Plot in new window
hold on;
plot(reshape(meshgrid(kzs,1:numBands),1,[]),reshape(maxBands(:,:,plotRIndex),1,[]),'r.');
plot(reshape(meshgrid(kzs,1:numBands),1,[]),reshape(minBands(:,:,plotRIndex),1,[]),'b.');
ltlin = line([0;yMax],[0;yMax]); ltlin.LineStyle = '-'; ltlin.Color = 'k'; %Plot light line omega=c*kz
hold off;
title(sprintf('%s, $r = %g a$, $n_{fiber} = %g$',geom,rs(plotRIndex),nb),'Interpreter','latex'); 
xlabel('$k_z \cdot a / 2\pi$','Interpreter','latex');
ylabel('$a / \lambda_0$','Interpreter','latex');
set(gca,'TickLabelInterpreter','latex');
ylim([yMin yMax]);
xlim([kzs(1) kzs(end)])
legend('Upper Bounds','Lower Bounds','\omega = c k_z','Location','Best');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BAND GAPS OVER ALPHA_EFF PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%FIND ALPHA_EFF
plotRIndex = 15;
nRms = sqrt(fs(plotRIndex)*na^2 + (1-fs(plotRIndex))*nb^2);
omegaL = maxBands(1,:,plotRIndex); %Since omegaL is already normalized by c, it is also k0l
smallKz = kzs./omegaL < nRms | isnan(kzs./omegaL); %Condition to determine which alpha_eff approximation to use
divIndex = find(~smallKz,1,'first'); %Find the index of the 1st element not satisfying smallKz

%Find alpha_eff for all values in minBands, maxBands
alphaEffMin = (asin(1./(nRms*minBands(:,:,plotRIndex)).*kzs).*smallKz + asin(omegaL./minBands(:,:,plotRIndex)).*(~smallKz)).*(360/(2*pi));
alphaEffMax = (asin(1./(nRms*maxBands(:,:,plotRIndex)).*kzs).*smallKz + asin(omegaL./maxBands(:,:,plotRIndex)).*(~smallKz)).*(360/(2*pi));


divLineYStep = 0.01;
divLineOmega = yMin:divLineYStep:yMax;
divLineAlpha = asin((kzs(divIndex)/nRms)./divLineOmega).*(360/(2*pi));

% mesh = transpose(meshgrid(divLineOmega,1:length(kzs))); %mesh(omega,kz)
% alphaMesh2 = asin(omegaL./mesh)
% nEffs = kzs./omegaL;

aEffMaxVect = reshape(real(alphaEffMax),1,[]);		maxBandsVect = reshape(maxBands(:,:,plotRIndex),1,[]);
aEffMinVect = reshape(real(alphaEffMin),1,[]);		minBandsVect = reshape(minBands(:,:,plotRIndex),1,[]);
divLineAVect = reshape(real(divLineAlpha),1,[]);	divLineOVect = reshape(divLineOmega,1,[]);

aEffMaxVRlInd = aEffMaxVect ~= 90;
aEffMinVRlInd = aEffMinVect  ~= 90;
divLineARlInd = divLineAVect  ~= 90;

thetaCrit1 = 360/(2*pi) * asin(na/nb);
thetaCrit2 = 360/(2*pi) * asin(nRms/nb);
thetaCrit3 = 360/(2*pi) * asin(1.5/nb);
plotMax = max(yMax,max(maxBandsVect(aEffMaxVRlInd)));

%PLOT
figure('position', [400, 300, 700, 462.5]); %Plot in new window %560, 370


lin5 = plot(90 - aEffMinVect(aEffMinVRlInd),minBandsVect(aEffMinVRlInd),'b.'); %'b.'
hold on;
lin4 = plot(90 - aEffMaxVect(aEffMaxVRlInd),maxBandsVect(aEffMaxVRlInd),'r.'); %'r.'

%Plot beta_max/k0, or n_avg of the PCF cladding
lin0 = plot(90 - (asin( (nRms.*smallKz + kzs./real(omegaL).*~smallKz)./nb ).*(360/(2*pi))),maxBands(1,:,plotRIndex),'k.-');

%Plot asymptotic critical angles
lin3 = line(90 - [thetaCrit3; thetaCrit3], [yMin; plotMax]); lin3.LineStyle = '-'; lin3.Color = 'r'; %'r'
lin2 = line(90 - [thetaCrit2; thetaCrit2], [yMin; plotMax]); lin2.LineStyle = '-'; lin2.Color = 'b'; %'b'
lin1 = line(90 - [thetaCrit1; thetaCrit1], [yMin; plotMax]); lin1.LineStyle = '-'; lin1.Color = 'g'; %'g'

%lin6 = line([0; 90],[thetaBottomBg(9199);thetaBottomBg(9199)]); lin6.LineStyle = '-'; lin6.Color = 'y'; %For plotRIndex = 15, a = 1.233lambda0
%lin6 = line([0; 90],[thetaTopBg(8740);thetaTopBg(8740)]); lin6.LineStyle = '-'; lin6.Color = 'y'; %For plotRIndex = 15, a = 1.342lambda0

plot(90 - divLineAVect(divLineARlInd),divLineOVect(divLineARlInd),'k:'); %Plot dividing line btwn small and large kz
hold off;
%title(sprintf('%s, $r = %g a$, $n_{fiber} = %g$',geom,rs(plotRIndex),nb),'Interpreter','latex'); 
xlabel('Estimated Propagation Polar Angle, $\theta_{eff}$ [deg]','Interpreter','latex');
ylabel('Normalized Frequency, $a / \lambda_0$','Interpreter','latex');
set(gca,'TickLabelInterpreter','latex');
leg = legend('Bandgap Left Bound','Bandgap Right Bound','\theta_{crit,PS,nEff}','\theta_{crit,PS,PMMA}',...
	'\theta_{crit,PS,nRMS}','\theta_{crit,PS,Air}','Estimation Boundary','Location','southeast');
%set(lin0,'LineWidth',1.2);
ylim([yMin yMax]);
xlim([0 90]); %CHANGE THIS TO [0 90] AT SOME POINT
set(leg, 'FontName', 'CMU Serif')
set(gca,'fontsize', 13);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BAND GAPS OVER ALPHA_EFF SLIDER INTERACTIVE PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; clear lastR2; global lastR2; lastR2 = 0;
ipanel(@(rIndex)plotAlpha(yMax,yMin,geom,nb,na,fs,rs,floor(rIndex),minBands,maxBands,kzs), ...
	   {'slider','r Index',{1,length(rs)+0.5,1}},'MinControlWidth',300,'LabelWidth',100);