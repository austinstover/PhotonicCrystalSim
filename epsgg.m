%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% calculation of the 'epsgg' matrix for circular holes using
%%% analytical expression; the matrix is symmetric, i.e E'=E
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% f = filling factor, ratio between the area occupied by the cylinders and area of the unit cell
% r = hole radius
% na, nb = rIndex of holes, fiber
% b1, b2 = primitive vectors of reciprocal lattice cell (define the brillouin zone)
% N1, N2 = Number of reciprocal cells to iterate over in each direction?
% returns:
%   epsi = A matrix of the fourier coefficients for each G||-G||' 
function epsi=epsgg(r, na, nb, b1, b2, N1, N2, f)
N = N1*N2;
epsilon=zeros(N1,N2); 
epsi=zeros(N,N);

for  l=1:N1
      for m=1:N2
          for  n=1:N1
              for p=1:N2
                  GGx=(l-n)*b1(1)+(m-p)*b2(1);
                  GGy=(l-n)*b1(2)+(m-p)*b2(2);	%GGx and GGy define our current cell in reciprocal space
                  GG=sqrt(GGx^2+GGy^2); x=2*pi*GG;
                  %%% GG is a scalar which changes with iteration and goes into Bessel function argument	
                  if (GG~=0)
                      epsilon(p,n)=2*f*(na^2-nb^2)*besselj(1,x*r)/(x*r);
                  else
                      epsilon(p,n)=f*na^2+(1-f)*nb^2;
                  end  
              end
          end
           u=(l-1)*N2+m; %%% this is the line index
           epsi(u,:)=reshape(epsilon,1,N);
      end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%