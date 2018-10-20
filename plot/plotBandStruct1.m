function plotBandStruct1(yMax,yMin,nPtsBri,omega,geom,nFiber,r,numBands,minBands,maxBands,KP,KL,kzs,plotKzIndex)
	%PLOTBANDSTRUCT2 Plots the band structure for an interactive slider for
	%pwem3DIterKz
	global lastKz;
	
	yLimits = get(gca,'YLim');
	if(lastKz == 0)
		yLimits = [yMin,yMax];
	end
	if(plotKzIndex ~= lastKz)
		plot(1:nPtsBri,real(squeeze(omega(plotKzIndex,1:floor(numBands/2),:))),'.-'); %Only plot some of the bands for faster refresh
		
		hold on;
		plot(1:nPtsBri,real(squeeze(omega(plotKzIndex,1:floor(numBands/2),:))),'r.-');
		if(~isempty(minBands(1:floor(numBands/2),plotKzIndex)))
			fill([1;nPtsBri;nPtsBri;1], ...
				 transpose([minBands(1:floor(numBands/2),plotKzIndex), minBands(1:floor(numBands/2),plotKzIndex),  ...
							maxBands(1:floor(numBands/2),plotKzIndex), maxBands(1:floor(numBands/2),plotKzIndex)]),...
				 'r','LineStyle','none');
		end
		hold off;
		alpha(0.2);
		title(sprintf('%s, $k_z = %g \\cdot 2\\pi / a$, $r = %g a$, $n_{fiber} = %g$',geom,kzs(plotKzIndex),r,nFiber),'Interpreter','latex');
		xlabel('$k_\perp$','Interpreter','latex');
		ylabel('$\omega a / 2\pi c$','Interpreter','latex');
		set(gca,'XTick',KP,'XTickLabel',KL,'TickLabelInterpreter','latex');
		for n = 1 : length(KP)
			line(KP(n)*[1, 1],[yLimits],'Color','k','LineStyle',':');
		end
		xlim([1 nPtsBri]);
		ylim(yLimits);
		
		lastKz = plotKzIndex;
	end
end