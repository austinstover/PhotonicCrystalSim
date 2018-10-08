%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% diagonal matrices with elements (kx+Gx) si (ky+Gy); (kx,ky) are in the
%%% first Brillouin zone, (Gx,Gy) is a vector of the reciprocal lattice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [kGx, kGy, kGz] = kvect3D(kx,ky,kz,b1,b2,N1,N2)
N=N1*N2;
No1=(N1-1)/2; No2=(N2-1)/2;
kGx=zeros(N1,N2); kGy=zeros(N1,N2); kGz=zeros(N1,N2);
for l=1:N1
	for m=1:N2
		kGx(m,l)=kx+(l-1-No1)*b1(1)+(m-1-No2)*b2(1);
        kGy(m,l)=ky+(l-1-No1)*b1(2)+(m-1-No2)*b2(2);
		kGz(m,l)=kz;
	end
end
kGx = sparse(diag(reshape(kGx,1,N)));
kGy = sparse(diag(reshape(kGy,1,N)));
kGz = sparse(diag(reshape(kGz,1,N)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%