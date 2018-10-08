%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% this function solves the eigenvalue problem omega=f(epsi,kx,ky) for
%%% in-plane propagation (i.e. z=0) in a 2D-PhC; the problem can be
%%% separated in two orthogonal polarizations, E-pol & H-pol
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% kGx, kGy = Matrices with wave vector components for each reciprocal
%	lattice position: kGx=kx+Gx,kGy=ky+Gy or k+h
% epsi = A matrix of the fourier coefficients for each G||-G||'
% N = Total number of reciprocal unit cells to sum over
% bands = number of eigenvals to find
function [omega]=eigs3D(kGx,kGy,kGz,epsiBlk)
%%% define block matrices
Zs = zeros(size(kGx));
KCross = [ Zs ,-kGz , kGy ;
		   kGz, Zs  , -kGx;
		  -kGy, kGx ,  Zs ];
A=(KCross*KCross);
%%% calculate eigenvals (can't use eigs() for smallest eigenvals here since A is singular)
D=eig(full(A),full(epsiBlk));
%%% eigenvalues "omega" are put in a column vector and sorted in ascending order
omega=sqrt(real(sort(-D)));