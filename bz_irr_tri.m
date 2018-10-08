%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% discretization of irreducible Brillouin zone boundary (perimeter); here, example
%%% for triangular lattice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [nPtsBri,kx,ky,KP,KL,b1,b2,f,geom]=bz_irr_tri(Nr,r)
geom = 'Triangular Lattice';

%%% primitive vectors of crystal lattice (normalized w.r.t. lattice constant "a")
% example considered here: triangular lattice
a1=[sqrt(3)/2, -1/2, 0]; a2=[sqrt(3)/2, 1/2, 0]; 
%%% area of primitive cell
ac=norm(cross(a1,a2)); 
%%% primitive vectors of reciprocal lattice (normalized w.r.t. lattice constant "2*pi/a"): b1=[1/sqrt(3),-1]; b2=[1/sqrt(3),1]; 
b1=(1/ac)*[a2(2),-a2(1)]; b2=(1/ac)*[-a1(2), a1(1)]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f = (2*pi/sqrt(3))*r.^2; % filling factor, ratio between the area occupied by the cylinders and area of the unit cell

% KEY POINTS OF SYMMETRY
G = [0; 0];
M = [-0.5/sqrt(3),0.5];
K = [0,2/3];

% GENERATE LIST: Go from G to M to K to G
% L1 = norm(M - G);
% L2 = norm(K - M);
% L3 = norm(G - K);

N1 = Nr; %Calc # pts for each side
N2 = round(Nr/2);%round(N1*L2/L1);
N3 = round(Nr*12/10);%round(N1*L3/L1);

BX = [ linspace(G(1),M(1),N1) , ... %List of x-component of bloch wave vector
	   linspace(M(1),K(1),N2) , ...
	   linspace(K(1),G(1),N3) ];
   
BY = [ linspace(G(2),M(2),N1) , ... %List of y-component of bloch wave vector 
	   linspace(M(2),K(2),N2) , ...
	   linspace(K(2),G(2),N3) ];

BETA = [ BX ; BY ];  
BETA(:,[ N1+1 , N1+N2+1]) = []; %Get rid of redundant pts at symmetry pts created in linspace lines

kx = BETA(1,:); ky = BETA(2,:); nPtsBri = length(ky);

%figure; plot(kx, ky,'.-'); daspect([1 1 1]); %Plot irreducible zone

KP = [ 1, N1, N1+N2-1, N1+N2+N3-2 ]; %Key pts of symmetry
KL = { '$\Gamma$' 'M' 'K' '$\Gamma$'};

