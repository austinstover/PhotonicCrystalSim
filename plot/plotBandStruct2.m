function plotBandStruct2(yMax,yMin,nPtsBri,omega,geom,nb,rs,plotRIndex,numBands,minBands,maxBands,KP,KL,kzs,plotKzIndex)
	%PLOTBANDSTRUCT2 Plots the band structure for an interactive slider for
	%pwem3DIterKzR
	
	global lastKz;
	global lastR1;
	yLimits = get(gca,'YLim');
	xLimits = get(gca,'XLim');
	if(lastKz == 0 && lastR1 == 0)
		yLimits = [yMin yMax];
		xLimits = [1 nPtsBri];
	end
	if(plotKzIndex ~= lastKz || plotRIndex ~= lastR1)
		plot(1:nPtsBri,real(squeeze(omega(plotRIndex,plotKzIndex,1:floor(numBands/2),:))),'.-'); %Only plot some of the bands for faster refresh
		
		hold on;
		plot(1:nPtsBri,real(squeeze(omega(plotRIndex,plotKzIndex,1:floor(numBands/2),:))),'r.-');
		if(~isempty(minBands(1:floor(numBands/2),plotKzIndex,plotRIndex)))
			fill([1;nPtsBri;nPtsBri;1], ...
				 transpose([minBands(1:floor(numBands/2),plotKzIndex,plotRIndex), minBands(1:floor(numBands/2),plotKzIndex,plotRIndex),  ...
							maxBands(1:floor(numBands/2),plotKzIndex,plotRIndex), maxBands(1:floor(numBands/2),plotKzIndex,plotRIndex)]),...
				 'r','LineStyle','none');
		end
		hold off;
		alpha(0.2);
		title(sprintf('%s, $k_z = %g \\cdot 2\\pi / a$, $r = %g a$, $n_{fiber} = %g$', ...
					  geom,kzs(plotKzIndex),rs(plotRIndex),nb),'Interpreter','latex');
		xlabel('$k_\perp$','Interpreter','latex');
		ylabel('$\omega a / 2\pi c$','Interpreter','latex');
		set(gca,'XTick',KP,'XTickLabel',KL,'TickLabelInterpreter','latex');
		for n = 1 : length(KP)
			line(KP(n)*[1, 1],[yMin, yMax],'Color','k','LineStyle',':');
		end
		xlim(xLimits);
		ylim(yLimits);
		
		lastKz = plotKzIndex;
		lastR1 = plotRIndex;
	end
end