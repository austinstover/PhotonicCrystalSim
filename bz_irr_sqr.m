%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% discretization of irreducible Brillouin zone boundary (perimeter); here, example
%%% for square lattice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [nPtsBri,kx,ky,KP,KL,b1,b2,f,geom] = bz_irr_sqr(Nr,r)
geom = 'Square Lattice';

%Primitive vectors of reciprocal lattice for square crystal
%	(Normalized, so b1True = (2*pi/a)*b1)
b1 = [1;0];
b2 = [0;1];

% KEY POINTS OF SYMMETRY
G = [0;0]; %Gamma
X = 0.5*b1;
M = 0.5*b1 + 0.5*b2;

%%% filling factor, ratio between the area occupied by the cylinders and area of the unit cell
f = pi*r.^2;

% GENERATE LIST: Go from G to X to M to G
L1 = norm(X - G);
L2 = norm(M - X);
L3 = norm(G - M);

N1 = Nr; %Calc # pts for each side
N2 = round(N1*L2/L1);
N3 = round(N1*L3/L1);

BX = [ linspace(G(1),X(1),N1) , ... %List of x-component of bloch wave vector
	   linspace(X(1),M(1),N2) , ...
	   linspace(M(1),G(1),N3) ];

BY = [ linspace(G(2),X(2),N1) , ... %List of y-component of bloch wave vector
	   linspace(X(2),M(2),N2) , ...
	   linspace(M(2),G(2),N3) ];

BETA = [ BX ; BY ];
BETA(:,[ N1+1 , N1+N2+1]) = []; %Get rid of redundant pts at symmetry pts created in linspace lines

kx = BETA(1,:); ky = BETA(2,:); nPtsBri = length(ky);

% figure; plot(kx, ky,'.-'); daspect([1 1 1]); %Plot irreducible zone

KP = [ 1, N1, N1+N2-1, N1+N2+N3-2 ]; %Key pts of symmetry
KL = { '$\Gamma$' 'X' 'M' '$\Gamma$'};