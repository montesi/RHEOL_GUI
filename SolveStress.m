function fi=bisection(zm);%,f0);
% Solves zm(x)=0 using the bisection method. Starting guess: f0. Can be a
% singe value or a range.

%% step1
% initialize search interval
f1=1;f2=1e20;
z1=zm(f1); z2=zm(f2);
% 
% if numel(f0)==1;
%     f1=f0/2; f2=f0*2;
% else
%     f1=min(f0); f2=max(f0);
% end
% % f1=1; f2=1.1;
% z1=zm(f1); z2=zm(f2);
% i=0;
% % disp(sprintf('Step %i, iteration %i: Search interval x=[%g,%g] for z=[%g,%g]',...
% %     1,i,f1,f2,z1,z2));
% 
% % evaluate search interval
% zp=z1*z2;
% while (zp>0)&(i<10); %need to broaden the interval; limit 10 iterations;
%     i=i+1;
%     if abs(z2)<abs(z1);%z2>z1; % function increases: push z2 further
%         f2=f2*2;%10*f2-9*f1;
%         z2=zm(f2);
%     else; %function decreases: push z1 futher;
%         f1=f1/2;%10*f1-9*f2;
%         z1=zm(f1);
%     end
% %     disp(sprintf('Step %i, iteration %i: Search interval x=[%g,%g] for z=[%g,%g]',...
% %        1,i,f1,f2,z1,z2));
%     zp=z1*z2;
% end

%% step 2: narrow search interval
% Define precision
ez=1e-6; %requested residual
ef=1e-3; %precision on f
cv=0; %Assume it's not converged initially
i=0; %reset iteration number

fi=(f1+f2)/2;
zi=zm(fi);
% disp(sprintf('Step %i, iteration %i: Search interval x=[%g,%g] for z=[%g,%g]',...
%     2,i,f1,f2,z1,z2));
while (cv==0)&(i<100);
    i=i+1;
    if (zi*z1)<0; %solution between f1 and fi
        f2=fi;
        z2=zi;
    elseif (zi*z2)<0; %solution between fi and f2
        f1=fi;
        z1=zi;
    else break %big trouble
    end
    %update midpoint
    fi=(f1+f2)/2;
    zi=zm(fi);
%     disp(sprintf('Step %i, iteration %i: Search interval x=[%g,%g] for z=[%g,%g]',...
%        2,i,f1,f2,z1,z2));
    cv=(abs(zi)<ez)|(abs(f1-f2)<ef); %check for convergence
end
% disp(sprintf('\nFinal answer: x=%g, residual z=%g',fi,zi));
