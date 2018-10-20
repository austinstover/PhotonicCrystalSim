function plotAlpha(yMax,yMin,geom,nb,na,fs,rs,plotRIndex,minBands,maxBands,kzs)
	%PLOTALPHA Plots frequency vs. alpha_eff for a slider interactive plot
	%using ipanel
	yLimits = get(gca,'YLim');
	xLimits = get(gca, 'XLim');
	global lastR2;
	if(lastR2 == 0)
		yLimits = [yMin,yMax];
		xLimits = [0,90];
	end
	if(plotRIndex ~= lastR2)
		
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

		%BAND GAPS OVER ALPHA_EFF PLOT
		lin4 = plot(90 - aEffMaxVect(aEffMaxVRlInd),maxBandsVect(aEffMaxVRlInd),'r.');
		hold on;
		lin5 = plot(90 - aEffMinVect(aEffMinVRlInd),minBandsVect(aEffMinVRlInd),'b.');
		
		%Plot beta_max/k0, or n_avg of the PCF cladding
		lin0 = plot(90 - (asin( (nRms.*smallKz + kzs./real(omegaL).*~smallKz)./nb ).*(360/(2*pi))),omegaL,'k.-');
		alpha(0.5);
				
		%Plot asymptotic critical angles
		lin1 = line(90 - [thetaCrit1; thetaCrit1], [yMin; plotMax]); lin1.LineStyle = '-'; lin1.Color = 'g';
		lin2 = line(90 - [thetaCrit2; thetaCrit2], [yMin; plotMax]); lin2.LineStyle = '-'; lin2.Color = 'b';
		lin3 = line(90 - [thetaCrit3; thetaCrit3], [yMin; plotMax]); lin2.LineStyle = '-'; lin2.Color = 'r';
		
		plot(90 - divLineAVect(divLineARlInd),divLineOVect(divLineARlInd),'k:'); %Plot dividing line btwn small and large kz
		hold off;
		title(sprintf('%s, $r = %g a$, $f = %g$, $n_{fiber} = %g$',geom,rs(plotRIndex),fs(plotRIndex),nb),'Interpreter','latex'); 
		xlabel('$\theta_{eff}$ [deg]','Interpreter','latex');
		ylabel('$a / \lambda_0$','Interpreter','latex');
		set(gca,'TickLabelInterpreter','latex');
		
		leg = legend([lin4,lin5,lin0,lin3,lin2,lin1],{'Upper Bounds','Lower Bounds','\theta_{crit,PS/nEff}','\theta_{crit,PS/PMMA}', ...
			'\theta_{crit,PS/nRMS}','\theta_{crit,PS/Air}'},'Location','Best');
		set(lin0,'LineWidth',1.2);
		ylim(yLimits);
		xlim(xLimits);
		set(leg, 'FontName', 'CMU Serif')
		
		lastR2 = plotRIndex;
	end
end