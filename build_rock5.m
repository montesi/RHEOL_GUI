%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build_rock
%
% Contruct array of rock data
% Laurent Montesi, 09-30-2002
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rock
%     |_ .name
%     |_ .density
%     |_ .rheol
%              |_ .name
%              |_ .ref   %original reference
%              |_ .type  %code for rheology formula
%                        % 1: Power law, depends on T (K)
%                        % 2: Wet power law, depends on T and water
%                        fugacity fw (Pa)
%                        % 3: Grain-size depedent power law (T, g in m)
%                        % 4: Grain-size depedent power law, wet (T, g, fw)
%                        % 5: Power law, depends on T (K) and P (Pa)
%                        % 6: Wet power law, depends on T, P and water
%                        fugacity fw (Pa)
%                        % 7: Grain-size depedent power law (T, P, g in m)
%                        % 8: Grain-size depedent power law, wet (T, P, g, fw)
%              |_ .s     %function stress(strain rate); stress in Pa
%              |_ .r     %function strain rate(stress); rate in 1/s
%     |_.thermal
%              |_ .alpha %Thermal expansivity
%              |_ .Cp    %capacity
%              |_ .k     %conductivity
%              |_ .kappa %Diffusivity
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% unit conversion
RG=8.314510; %J.mol^(-1).K^(-1)
% 
% % Initialize water fugacity function
% load water_fugacity
% fw=@(P,T)P*interp2(P_H2O,T_H2O,gamma_coef,P,T,'spline');


%initialize with default values
id=0;
ir=0;
clear rock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Olivine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
ir=0;
rock(id).name='olivine';
rock(id).density=3320;
rock(id).thermal(1).alpha=2.4e-5;
rock(id).thermal(1).k=3.5;
% ;
%     'rheol',struct(...
%         rock(id).rheol(ir).name',{};
%         rock(id).rheol(ir).ref',{};
%         'var',{};
%         's',{};
%         'r',{});
%     'thermal',struct(...
%         'alpha',{};
%         'Cp',{};
%         'k',{};
%         'kappa',{}))
ip=0;
%piezometers
% ip=ip+1;
% rock(id).piezo(ip).geq=@(s)K*b*(s/mu).^(-1.18)
ip=ip+1;
rock(id).piezo(ip).geq=@(s)0.015*(s/1e6)^(-1.33);
rock(id).piezo(ip).ref='van der Wal et al., 1993';
ip=ip+1
rock(id).piezo(ip).geq=@(s)7287e-6*(s/1e6)^(-1.2);
rock(id).piezo(ip).ref='Karato and Wu, 1993';
ip=ip+1;
rock(id).piezo(ip).geq=@(s)8.3e-3*(s/1e6).^(-1.18)
rock(id).piezo(ip).ref='Karato et al., 1980'
ip=ip+1;
rock(id).piezo(ip).geq=@(s)(s/603e6).^(-1/0.68)*1e-6;
rock(id).piezo(ip).ref='Twiss 1977';

%Hirth and Kohlstedt, 2003, dry olivine, dislocation creep
ir=ir+1;
n=3.5;
Q=530*1000;
V=18*1e-6;
A=1.1e5*(1e-6)^n;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='HK03dd';
rock(id).rheol(ir).ref='Hirth and Kohlstedt, 2003, dry olivine, dislocation creep';
rock(id).rheol(ir).type=5;
rock(id).rheol(ir).r=@(s,T,P)(s/B).^n.*exp(-(Q+P*V)./(RG*T));
rock(id).rheol(ir).s=@(r,T,P)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

%Hirth and Kohlstedt, 2003, wet olivine, dislocation creep
ir=ir+1;
n=3.5;
p=1.2;
Q=520*1000;
V=22*1e-6;
A=1600*(1e-6)^(n+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='HK03dw';
rock(id).rheol(ir).ref='Hirth and Kohlstedt, 2003, wet olivine, dislocation creep';
rock(id).rheol(ir).type=6;
rock(id).rheol(ir).r=@(s,T,P,fw)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*fw.^p;
rock(id).rheol(ir).s=@(r,T,P,fw)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

%Hirth and Kohlstedt, 2003, dry olivine, diffusion creep
ir=ir+1;
n=1;
m=3;
Q=375*1000;
V=10*1e-6;
A=1.5e9*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='HK03gd';
rock(id).rheol(ir).ref='Hirth and Kohlstedt, 2003, dry olivine, diffusion creep';
rock(id).rheol(ir).type=7;
rock(id).rheol(ir).r=@(s,T,P,g)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,P,g)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

%Hirth and Kohlstedt, 2003, wet olivine, diffusion creep
ir=ir+1;
n=1;
m=3;
p=1;
% Q=520*1000;
% A=4.9e6*(1e-6)^(n+m+p);
% Copied from Burgmann and Dresen, AREPS 2008
Q=375*1000;
V=20*1e-6;
A=10^(7.4)*(1e-6)^(n+m+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='HK03gw';
rock(id).rheol(ir).ref='Hirth and Kohlstedt, 2003, wet olivine, diffusion creep';
rock(id).rheol(ir).type=8;
rock(id).rheol(ir).r=@(s,T,P,g,fw)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*g.^(-m).*fw.^p;
rock(id).rheol(ir).s=@(r,T,P,g,fw)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*g.^(m/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

%Hirth and Kohlstedt, 2003, disGBS
ir=ir+1;
n=3.5;
m=2;
Q=400*1000;
V=0*1e-6;
A=6.5e3*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='HK03disGBS';
rock(id).rheol(ir).ref='Hirth and Kohlstedt, 2003, dry olivine, dis-GBS';
rock(id).rheol(ir).type=7;
rock(id).rheol(ir).r=@(s,T,P,g)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,P,g)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

%Hansen, Zimmerman, and Kohlstedt, 2011, dry olivine, dis-GBS
ir=ir+1;
n=2.9;
m=0.7;
Q=445*1000;
V=0*1e-6;
A=6.31e4*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='HZK11disGBS';
rock(id).rheol(ir).ref='Hansen, Zimmerman, and Kohlstedt, 2011, dry olivine, dis-GBS';
rock(id).rheol(ir).type=7;
rock(id).rheol(ir).r=@(s,T,P,g)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,P,g)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

%Mei and Kohlstedt, 2000, wet olivine, dislocation creep
ir=ir+1;
n=3;
p=0.98;
Q=470*1000;
V=20*1e-6;
A=(10^3.2)*(1e-6)^(n+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='MK00dw';
rock(id).rheol(ir).ref='Mei and Kohlstedt, 2000, wet olivine, dislocation creep';
rock(id).rheol(ir).type=6;
rock(id).rheol(ir).r=@(s,T,P,fw)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*fw.^p;
rock(id).rheol(ir).s=@(r,T,P,fw)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

%Mei and Kohlstedt, 2000, wet olivine, diffusion creep
ir=ir+1;
n=1;
m=3;
p=1;
Q=295*1000;
V=20*1e-6;
A=10^(4.7)*(1e-6)^(n+m+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='MK00gw';
rock(id).rheol(ir).ref='Mei and Kohlstedt, 2000, wet olivine, diffusion creep';
rock(id).rheol(ir).type=8;
rock(id).rheol(ir).r=@(s,T,P,g,fw)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*g.^(-m).*fw.^p;
rock(id).rheol(ir).s=@(r,T,P,g,fw)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*g.^(m/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;


%Faul and Jackson, 2006, dry olivine, diffusion creep
ir=ir+1;
n=1.4;
m=3;
Q=484*1000;
A=(10^10.3)*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='FJ06';
rock(id).rheol(ir).ref='Faul and Jackson, dry olivine, diffusion creep';
rock(id).rheol(ir).type=3;
rock(id).rheol(ir).r=@(s,T,g)(s/B).^n.*exp(-Q./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,g)B.*exp(Q./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;


%Karato and Jung, 2003, dry olivine, dislocation creep
ir=ir+1;
n=3;
Q=5100*1000;
V=14*1e-6;
A=10^(6.1)*(1e-6)^n;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='KJ03d';
rock(id).rheol(ir).ref='Karato and Jung, dry olivine, dislocation creep';
rock(id).rheol(ir).type=5;
rock(id).rheol(ir).r=@(s,T,P)(s/B).^n.*exp(-(Q+P*V)./(RG*T));
rock(id).rheol(ir).s=@(r,T,P)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Karato and Jung, 2003, wet olivine, dislocation creep
ir=ir+1;
n=3;
p=1.2;
Q=470*1000;
V=24*1e-6;
A=(10^2.9)*(1e-6)^(n+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='KJ03w';
rock(id).rheol(ir).ref='Karato and Jung, wet olivine, dislocation creep';
rock(id).rheol(ir).type=6;
rock(id).rheol(ir).r=@(s,T,P,fw)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*fw.^p;
rock(id).rheol(ir).s=@(r,T,P,fw)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Karato et al., 1986, dry olivine
ir=ir+1;
n=3.5;
Q=540*1000;
A=240000*(1e-6)^n;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Kd';
rock(id).rheol(ir).ref='Karato et al., 1986, dry olivine, dislocation creep';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Chen and Morgan
ir=ir+1;
n=3;
Q=520*1000;
A=1000*(1e-6)^n;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='CM';
rock(id).rheol(ir).ref='Chen and Morgan, 1990';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Goetze (1978) dislocation
ir=ir+1;
n=3;
Q=520*1000;
A=70000*(1e-6)^n;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Go';
rock(id).rheol(ir).ref='Goetze (1978) dislocation';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

%Goetze (1978) exponential
ir=ir+1;
n=2;
Q=535*1000;
A=5.7e11 % 1/s;
P=8500e6; %peierls stress (Pa)
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='GoEXP';
rock(id).rheol(ir).ref='Goetze (1978) exponential';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)A.*exp(-(Q./(RG*T)).*((1-s./P).^n));
rock(id).rheol(ir).s=@(r,T)P.*(1-((-(RG.*T./Q).*log(r./A)).^(1./n)));
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=P;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

%Demouchy et al. (2013) exponential
ir=ir+1;
p=0.5;
q=2
Q=450*1000; %J/mol
A=1e6 % 1/s;
s0=15e9; %peierls stress (Pa)
rock(id).rheol(ir).name='Demouchy';
rock(id).rheol(ir).ref='Demouchy et al. (2013) exponential';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)A.*exp(-(Q./(RG*T)).*((1-(s./s0).^p).^q))
rock(id).rheol(ir).s=@(r,T)s0.*((1-((RG*T/Q).*log(A./r)).^(1./q)).^(1/p));
rock(id).rheol(ir).n=q;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=s0;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

%Idrissi et al. (2016) exponential
ir=ir+1;
p=0.5;
q=2
Q=566*1000; %J/mol
A=1e6 % 1/s;
s0=3.8e9; %peierls stress (Pa)
rock(id).rheol(ir).name='Idrissi';
rock(id).rheol(ir).ref='Idrissi et al. (2016) exponential';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)A.*exp(-(Q./(RG*T)).*((1-(s./s0).^p).^q))
rock(id).rheol(ir).s=@(r,T)s0.*((1-((RG*T/Q).*log(A./r)).^(1./q)).^(1/p));
rock(id).rheol(ir).n=q;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=s0;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

%Idrissi w/ limit (2016) exponential
ir=ir+1;
p=0.5;
q=2
Q=566*1000; %J/mol
A=1e6 % 1/s;
s0=3.8e9; %peierls stress (Pa)
rl=1e-18; %limiting strain rate
rock(id).rheol(ir).name='I+L';
rock(id).rheol(ir).ref='Idrissi et al. (2016) exponential with limit';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)1./(1./(A.*exp(-(Q./(RG*T)).*((1-(s./s0).^p).^q)))+1./rl)
rock(id).rheol(ir).s=@(r,T)s0.*((1-((RG*T/Q).*log(A.*(1./r-1./rl))).^(1./q)).^(1/p));
rock(id).rheol(ir).n=q;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=s0;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quartz and quartzite %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
ir=0;
rock(id).name='quartz';
rock(id).density=2660;
rock(id).thermal(1).alpha=2.4e-5;
rock(id).thermal(1).k=3.5;

ip=0;
%piezometers
ip=ip+1;
rock(id).piezo(ip).geq=@(s)max(...
    (3631e-6).*(s/1e6)^(-1.26),...
    (78e-6).*(s/1e6)^(-0.61));
rock(id).piezo(ip).ref='Stipp and Tullis 2003 combined regime';
ip=ip+1;
rock(id).piezo(ip).geq=@(s)(3631e-6).*(s/1e6).^(-1.26);
rock(id).piezo(ip).ref='Stipp and Tullis 2003 regime 2-3';
ip=ip+1;
rock(id).piezo(ip).geq=@(s)(78e-6).*(s/1e6).^(-0.61);
rock(id).piezo(ip).ref='Stipp and Tullis 2003 regime 1';
% ip=ip+1
% rock(id).piezo(ip).geq=@(s)12266e-6*(s/1e6)^(-1.47);
% rock(id).piezo(ip).ref='Twiss 1977';
ip=ip+1
rock(id).piezo(ip).geq=@(s)1793e-6*(s/1e6).^(-0.9);
rock(id).piezo(ip).ref='Ord and Christie 1984, wet'
ip=ip+1
rock(id).piezo(ip).geq=@(s)325e-6*(s/1e6).^(-0.7);
rock(id).piezo(ip).ref='Ord and Christie 1984, dry';
ip=ip+1;
rock(id).piezo(ip).geq=@(s)(s/603e6).^(-1/0.68)*1e-6;
rock(id).piezo(ip).ref='Twiss 1977';

%Hirth, Teyssier and Dunlap, 2001, quartzite
ir=ir+1;
n=4;
Q=135*1000;
p=1;
A=10^(-11.2)*(1e-6)^(n+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='HTD01';
rock(id).rheol(ir).ref='Hirth, Teyssier and Dunlap, 2001, quartzite';
rock(id).rheol(ir).type=2;
rock(id).rheol(ir).r=@(s,T,fw)(s/B).^n.*exp(-Q./(RG*T)).*fw.^p;
rock(id).rheol(ir).s=@(r,T,fw)B.*exp(Q./(n*RG*T)).*r.^(1/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Rutter and Brodie, 2004, wet quartzite, dislocation creep
ir=ir+1;
n=3;
Q=242*1000;
p=1;
A=10^(-4.9)*(1e-6)^(n+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='RB04wd';
rock(id).rheol(ir).ref='Rutter and Brodie, 2004, wet quartzite, dislocation creep';
rock(id).rheol(ir).type=2;
rock(id).rheol(ir).r=@(s,T,fw)(s/B).^n.*exp(-Q./(RG*T)).*fw.^p;
rock(id).rheol(ir).s=@(r,T,fw)B.*exp(Q./(n*RG*T)).*r.^(1/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Rutter and Brodie, 2004, wet quartzite, diffusion creep
ir=ir+1;
n=1;
m=2;
Q=220*1000;
A=(10^-0.4)*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='RB04wg';
rock(id).rheol(ir).ref='Rutter and Brodie, 2004, wet quartzite, diffusion creep';
rock(id).rheol(ir).type=3;
rock(id).rheol(ir).r=@(s,T,g)(s/B).^n.*exp(-Q./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,g)B.*exp(Q./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;


%Paterson and Luan, 1992, quartzite
ir=ir+1;
n=3.1;
Q=135*1000;
A=(6.5e-8)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='PT92';
rock(id).rheol(ir).ref='Paterson and Luan, 1992, quartzite';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Wang, Hobbs, Ord Shimamoto and Toriumi, 1994, quartzite in Harper-Dorn creep
ir=ir+1;
n=.99;
Q=131.5*1000;
A=1.57e-3*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='WHOST94HP';
rock(id).rheol(ir).ref='Wang, Hobbs, Ord Shimamoto and Toriumi, 1994, quartzite in Harper-Dorn creep';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Wang, Hobbs, Ord Shimamoto and Toriumi, 1994, quartzite in Dislocation creep regime
ir=ir+1;
n=2.4;
Q=101.3*1000;
A=9.14e-8*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='WHOST94DC';
rock(id).rheol(ir).ref='Wang, Hobbs, Ord Shimamoto and Toriumi, 1994, quartzite in dislocation creep';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Gleason and Tullis, 1995, quartzite
ir=ir+1;
n=2.8;
Q=223*1000;
A=1.1e-4*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='GT';
rock(id).rheol(ir).ref='Gleason and Tullis, 1995, quartzite';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Gleason and Tullis, 1995, quartzite with melt
ir=ir+1;
n=2.8;
Q=137*1000;
A=1.8e-8*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Gm';
rock(id).rheol(ir).ref='Gleason and Tullis, 1995, quartzite with melt';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Jaoul et al., 1984, dry quartzite
ir=ir+1;
n=2.8;
Q=184*1000;
A=3.85e-6*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Jd';
rock(id).rheol(ir).ref='Jaoul et al., 1984, dry quartzite';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%Jaoul et al., 1984, wet quartzite
ir=ir+1;
n=2.8;
Q=163*1000;
A=9.0e-6*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Jw';
rock(id).rheol(ir).ref='Jaoul et al., 1984, wet quartzite';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calcite: limestone and marble %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
ir=0;
rock(id).name='calcite';
rock(id).density=2500;
rock(id).thermal(1).alpha=2.4e-5;
rock(id).thermal(1).k=3.5;

ip=0;
%piezometers
ip=ip+1;
rock(id).piezo(ip).geq=@(s)(5.12e-6).*(ss(iT)/1e6)^(-1.0);
rock(id).piezo(ip).ref='Schmid et al., 1980, Cararra Marble';
ip=ip+1;
rock(id).piezo(ip).geq=@(s)(s/603e6).^(-1/0.68)*1e-6;
rock(id).piezo(ip).ref='Twiss 1977';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% felspar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
ir=0;
rock(id).name='feldspar';
rock(id).density=2750;
rock(id).thermal(1).alpha=2.4e-5;
rock(id).thermal(1).k=3.5;

ip=0;
%piezometers
ip=ip+1;
rock(id).piezo(ip).geq=@(s)(54.3e-6).*(s/1e6).^(-0.66);
rock(id).piezo(ip).ref='Post and Tullis, 1999, dry Albite Regime 1';
ip=ip+1;
rock(id).piezo(ip).geq=@(s)(s/603e6).^(-1/0.68)*1e-6;
rock(id).piezo(ip).ref='Twiss 1977';

% Rybacki and Dresen 2006, dry An100 in dislocation creep
ir=ir+1;
n=3.0;
Q=641*1000;
V=24*1e-6;
A=10^(12.7)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='RD06Dd';
rock(id).rheol(ir).ref='Rybacki and Dresen 2006, dry An100 in dislocation creep';
rock(id).rheol(ir).type=5;
rock(id).rheol(ir).r=@(s,T,P)(s/B).^n.*exp(-(Q+P*V)./(RG*T));
rock(id).rheol(ir).s=@(r,T,P)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


% Rybacki and Dresen 2006, wet An100 in dislocation creep
ir=ir+1;
n=3;
p=1;
Q=345*1000;
V=38*1e-6;
A=(10^0.2)*(1e-6)^(n+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='RD06Wd';
rock(id).rheol(ir).ref='Rybacki and Dresen 2006, wet An100 in dislocation creep';
rock(id).rheol(ir).type=6;
rock(id).rheol(ir).r=@(s,T,P,fw)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*fw.^p;
rock(id).rheol(ir).s=@(r,T,P,fw)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


% Rybacki and Dresen 2000, An100 in dislocation creep, 0.004wt%H20
ir=ir+1;
n=3.0;
Q=648*1000;
A=10^(12.7)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='RD00Dd';
rock(id).rheol(ir).ref='Rybacki and Dresen 2000, An100 in dislocation creep, 0.004wt%H20';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


% Rybacki and Dresen 2000, An100 in dislocation creep, 0.07wt%H20
ir=ir+1;
n=3.0;
Q=356*1000;
A=10^(2.6)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='RD00Wd';
rock(id).rheol(ir).ref='Rybacki and Dresen 2000, An100 in dislocation creep, 0.07wt%H20';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


% Offerhaus et al. 2001, Ab100 in dislocation creep, 0.2wt%H20
ir=ir+1;
n=3.0;
Q=332*1000;
A=10^(3.4)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Off01d';
rock(id).rheol(ir).ref='Offerhaus et al. 2001, Ab100 in dislocation creep, 0.2wt%H20';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


% Rybacki and Dresen 2006, dry An100 in diffusion creep
ir=ir+1;
n=1;
m=3;
Q=460*1000;
V=24*1e-6;
A=(10^12.1)*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='RD06Dg';
rock(id).rheol(ir).ref='Rybacki and Dresen 2006, dry An100 in diffusion creep';
rock(id).rheol(ir).type=7;
rock(id).rheol(ir).r=@(s,T,P,g)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,P,g)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;


%Rybacki and Dresen 2006, wet An100 in diffusion creep
ir=ir+1;
n=1;
m=3;
p=1;
Q=159*1000;
V=38*1e-6;
A=(10^-0.7)*(1e-6)^(n+m+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='RD06Wg';
rock(id).rheol(ir).ref='Rybacki and Dresen 2006, wet An100 in diffusion creep';
rock(id).rheol(ir).type=8;
rock(id).rheol(ir).r=@(s,T,P,g,fw)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*g.^(-m).*fw.^p;
rock(id).rheol(ir).s=@(r,T,P,g,fw)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*g.^(m/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;


% Rybacki and Dresen 2000, An100 in diffusion creep, 0.004wt%H20
ir=ir+1;
n=1;
m=3;
Q=467*1000;
A=(10^12.1)*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='RD00Dg';
rock(id).rheol(ir).ref='Rybacki and Dresen 2000, An100 in diffusion creep, 0.004wt%H20';
rock(id).rheol(ir).type=3;
rock(id).rheol(ir).r=@(s,T,g)(s/B).^n.*exp(-Q./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,g)B.*exp(Q./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

% Rybacki and Dresen 2000, An100 in diffusion creep, 0.07wt%H20
ir=ir+1;
n=1;
m=3;
Q=170*1000;
A=(10^1.7)*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='RD00Wg';
rock(id).rheol(ir).ref='Rybacki and Dresen 2000, An100 in diffusion creep, 0.07wt%H20';
rock(id).rheol(ir).type=3;
rock(id).rheol(ir).r=@(s,T,g)(s/B).^n.*exp(-Q./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,g)B.*exp(Q./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

% Offerhaus et al. 2001, Ab100 in diffusion creep, 0.2wt%H20
ir=ir+1;
n=1;
m=3;
Q=193*1000;
A=(10^1.1)*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Off01g';
rock(id).rheol(ir).ref='Offerhaus et al. 2001, Ab100 in diffusion creep, 0.2wt%H20';
rock(id).rheol(ir).type=3;
rock(id).rheol(ir).r=@(s,T,g)(s/B).^n.*exp(-Q./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,g)B.*exp(Q./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basalt/diabase %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
ir=0;
rock(id).name='diabase';
rock(id).density=2900;
rock(id).thermal(1).alpha=2.4e-5;
rock(id).thermal(1).k=3.5;

% Caristan, 1982, diabase
ir=ir+1;
n=3.05;
Q=276*1000;
A=6.12e-2*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Ca';
rock(id).rheol(ir).ref='Caristan, 1982, diabase';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Caristan, 1982, diabase with mistake
ir=ir+1;
n=3;
Q=576*1000;
A=3.12e-2*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Cm';
rock(id).rheol(ir).ref='Caristan, 1982, diabase, mistake';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Shelton and Tullis, 1981, diabase
ir=ir+1;
n=3.4;
Q=260*1000;
A=100*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='ST';
rock(id).rheol(ir).ref='Shelton and Tullis, 1981, diabase';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Mackwell et al., 1995, dry Maryland diabase
ir=ir+1;
n=5.1;
Q=505*1000;
A=4.2*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Md';
rock(id).rheol(ir).ref='Mackwell et al., 1995, dry Maryland diabase';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;

% Mackwell et al., dry diabase, Ni/NiO buffer
ir=ir+1;
n=4.5;
Q=500*1000;
A=1900*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='MN';
rock(id).rheol(ir).ref='Mackwell et al., diabase, Ni/NiO buffer';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Mackwell et al., dry diabase, Fe/FeO buffer
ir=ir+1;
n=4.5;
Q=500*1000;
A=4900*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='MF';
rock(id).rheol(ir).ref='Mackwell et al., diabase, Fe/FeO buffer';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Mackwell et al., 1998, dry Columbia diabase
ir=ir+1;
n=4.7;
Q=485*1000;
A=195*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='MC';
rock(id).rheol(ir).ref='Mackwell et al., 1998, dry Columbia diabase';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Mackwell et al., 1998, dry Maryland diabase
ir=ir+1;
n=4.7;
Q=485*1000;
A=7.9*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='MM';
rock(id).rheol(ir).ref='Mackwell et al., 1998, dry Maryland diabase';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% mica %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
rock(id).name='mica';
rock(id).density=2900;
rock(id).thermal(1).alpha=18e-6; %McKinstry '65; %2.4e-5;
rock(id).thermal(1).k=3.5;
ir=0;

% Kronenberg et al., 1990, biotite
ir=ir+1;
n=18;
Q=51*1000;
A=(1e-30)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Kr90';
rock(id).rheol(ir).ref='Kronenberg et al., 1990, biotite dislocation creep';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% serpentine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
rock(id).name='serpentine';
rock(id).density=2600;
rock(id).thermal(1).alpha=10e-6; %McKinstry '65 2.4e-5;
rock(id).thermal(1).k=3.4; %Horai '71
ir=0;

% Hilairet
ir=ir+1;
n=3.8;
Q=8.9*1000;
V=3.2*1e-6;
A=(exp(-8.6*10))*(1e-0)^n;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Hil07ant';
rock(id).rheol(ir).ref='Hilairet et al., 2007, Antigorite power law';
rock(id).rheol(ir).type=5;
rock(id).rheol(ir).r=@(s,T,P)(s/B).^n.*exp(-(Q+P*V)./(RG*T));
rock(id).rheol(ir).s=@(r,T,P)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% pyroxene %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
rock(id).name='pyroxene';
rock(id).density=3300;
rock(id).thermal(1).alpha=2.4e-5;
rock(id).thermal(1).k=3.5;
ir=0;


ip=0;
%piezometers
ip=ip+1;
rock(id).piezo(ip).geq=@(s)(3818e-6).*(ss(iT)/1e6)^(-0.9);
rock(id).piezo(ip).ref='Ave Lallement 1978, dry diopside';
ip=ip+1;
rock(id).piezo(ip).geq=@(s)(s/603e6).^(-1/0.68)*1e-6;
rock(id).piezo(ip).ref='Twiss 1977';

% Dimanov and Dresen 2005, dry diopside, dislocation creep
ir=ir+1;
n=5.5;
Q=691*1000;
A=(10^5.3)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='DD05Dd';
rock(id).rheol(ir).ref='Dimanov and Dresen 2005, dry diopside, dislocation creep';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Dimanov and Dresen 2005, wet diopside, dislocation creep
ir=ir+1;
n=5.5;
Q=534*1000;
A=(10^0.8)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='DD05Dd';
rock(id).rheol(ir).ref='Dimanov and Dresen 2005, wet diopside, dislocation creep';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Dimanov and Dresen 2005, dry diopside, diffusion creep
ir=ir+1;
n=1;
m=3;
Q=528*1000;
A=(10^14)*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='DD05Dd';
rock(id).rheol(ir).ref='Dimanov and Dresen 2005, dry diopside, diffusion creep';
rock(id).rheol(ir).type=3;
rock(id).rheol(ir).r=@(s,T,g)(s/B).^n.*exp(-Q./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,g)B.*exp(Q./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

% Dimanov and Dresen 2005, wet diopside, diffusion creep
ir=ir+1;
n=1;
m=3;
Q=337*1000;
A=(10^8.1)*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='DD05Wd';
rock(id).rheol(ir).ref='Dimanov and Dresen 2005, wet diopside, diffusion creep';
rock(id).rheol(ir).type=3;
rock(id).rheol(ir).r=@(s,T,g)(s/B).^n.*exp(-Q./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,g)B.*exp(Q./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

% Bystricky and Mackwell 2001, dry cpx, dislocation creep
ir=ir+1;
n=4.7;
Q=760*1000;
A=(10^10.3)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='BW01Dd';
rock(id).rheol(ir).ref='Bystricky and Mackwell 2001, dry cpx, dislocation creep';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Bystricky and Mackwell 2001, dry cpx, diffusion creep
ir=ir+1;
n=1;
m=3;
Q=560*1000;
A=(10^15.1)*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='BW01Dg';
rock(id).rheol(ir).ref='Bystricky and Mackwell 2001, dry cpx, diffusion creep';
rock(id).rheol(ir).type=3;
rock(id).rheol(ir).r=@(s,T,g)(s/B).^n.*exp(-Q./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,g)B.*exp(Q./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

% Hier-Majumder et al. 2005, dry cpx, diffusion creep
ir=ir+1;
n=1;
m=3;
Q=760*1000;
A=(10^23.5)*(1e-6)^(n+m);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='HMMK05Dg';
rock(id).rheol(ir).ref='Hier-Majumder et al. 2005, dry cpx, diffusion creep';
rock(id).rheol(ir).type=3;
rock(id).rheol(ir).r=@(s,T,g)(s/B).^n.*exp(-Q./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,g)B.*exp(Q./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;


% Hier-Majumder et al. 2005, wet cpx, diffusion creep
ir=ir+1;
n=1;
m=3;
p=1.4;
Q=340*1000;
V=14*1e-6;
A=10^(6.1)*(1e-6)^(n+m+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='HMMK05Wg';
rock(id).rheol(ir).ref='Hier-Majumder et al. 2005, wet cpx, diffusion creep';
rock(id).rheol(ir).type=8;
rock(id).rheol(ir).r=@(s,T,P,g,fw)(s/B).^n.*exp(-(Q+P*V)./(RG*T)).*g.^(-m).*fw.^p;
rock(id).rheol(ir).s=@(r,T,P,g,fw)B.*exp((Q+P*V)./(n*RG*T)).*r.^(1/n).*g.^(m/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

% Chen et al. 2006, wet cpx, dislocation creep
ir=ir+1;
n=2.7;
p=3.0;
Q=670*1000;
A=(10^6.7)*(1e-6)^(n+p);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='CHK06Wd';
rock(id).rheol(ir).ref='Chen et al. 2006, wet cpx, dislocation creep';
rock(id).rheol(ir).type=2;
rock(id).rheol(ir).r=@(s,T,fw)(s/B).^n.*exp(-Q./(RG*T)).*fw.^p;
rock(id).rheol(ir).s=@(r,T,fw)B.*exp(Q./(n*RG*T)).*r.^(1/n).*fw.^(-p/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Zhang et al., 2006, dry omphacite
ir=ir+1;
n=3.5;
Q=310*1000;
A=(10^-2)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Z06omp';
rock(id).rheol(ir).ref='Zhang et al., 2006, dry omphacite';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Moghadam et al., 2010, omphacite (diopside)
ir=ir+1;
n=8.1;
Q=391*1000;
A=(10^-29.6)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Mog10dio';
rock(id).rheol(ir).ref='Moghadam et al., 2010,  omphacite (diopside)';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Moghadam et al., 2010, omphacite (jadeite)
ir=ir+1;
n=4.2;
Q=413*1000;
A=(10^3.5)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Mog10jad';
rock(id).rheol(ir).ref='Moghadam et al., 2010,  omphacite (jadeite)';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Orzol  2006, wet jadeite
ir=ir+1;
n=3.7;
Q=326*1000;
A=(10^-3.3)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='O06jad';
rock(id).rheol(ir).ref='Orzol  2006, wet jadeite';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Lower Crust %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
ir=0;
rock(id).name='Lower crust';
rock(id).density=3200;
rock(id).thermal(1).alpha=3e-5;
rock(id).thermal(1).k=3.0;

% HC90amp: Hacker and Christie, 1990, Amphibole
ir=ir+1;
n=3.7;
Q=244*1000;
A=(1.1e-4)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='HC90amp';
rock(id).rheol(ir).ref='Hacker and Christie, 1990, Amphibole';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% AL78web: Avé Lallemand 1978, Websterite
ir=ir+1;
n=4.3;
Q=326*1000;
A=(10^-6.4)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='AL78web';
rock(id).rheol(ir).ref='Avé Lallemand 1978, Websterite';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Jin01ecl: Jin et al., 2001 eclogite
ir=ir+1;
n=3.4;
Q=480*1000;
A=(10^3.3)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Jin01ecl';
rock(id).rheol(ir).ref='Jin et al., 2001 eclogite';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;


% ice %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
ir=0;
rock(id).name='ice';
rock(id).density=1000;
rock(id).thermal(1).alpha=2.4e-5;
rock(id).thermal(1).k=3.6;

% Goldsby and Kohlstedt, 2001, Ice dislocation creep T<253K
ir=ir+1;
n=4;
Q=60*1000;
A=(4e5)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='GK01D';
rock(id).rheol(ir).ref='Goldsby and Kohlstedt, 2001, Ice dislocation creep T<253K';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% Goldsby and Kohlstedt, 2001, Ice, basal slip T<255
%%%%%%%%%%% VERIFY COEFFICIENT A %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Was it for 1 meter?
ir=ir+1;
n=1.8;
m=1.4;
Q=49*1000;
A=(0.0039)*(1e-6)^(n+m);
% A=(0.0039)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='GK01s';
rock(id).rheol(ir).ref='Goldsby and Kohlstedt, 2001, Ice, basal slip T<255';
rock(id).rheol(ir).type=3;
rock(id).rheol(ir).r=@(s,T,g)(s/B).^n.*exp(-Q./(RG*T)).*g.^(-m);
rock(id).rheol(ir).s=@(r,T,g)B.*exp(Q./(n*RG*T)).*r.^(1/n).*g.^(m/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

% Goldsby and Kohlstedt, 2001, Ice, GBS
ir=ir+1;
n=2.4;
Q=60*1000;
A=(5.5e7)*(1e-6)^(n);
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='GK01G';
rock(id).rheol(ir).ref='Goldsby and Kohlstedt, 2001, Ice, GBS';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-Q./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp(Q./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=m;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Melt %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id=id+1;
ir=0;
rock(id).name='melt';
rock(id).density=2750;
rock(id).thermal(1).alpha=2.4e-5;
rock(id).thermal(1).k=3.5;

% viscosity of 100 Pa.s
ir=ir+1;
n=1.0;
Q=0*1000;
V=0;
A=1/100/2;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Melt_1e2';
rock(id).rheol(ir).ref='Estimate viscosity 100 Pa.s';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-(Q)./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp((Q)./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% viscosity of 1e4 Pa.s
ir=ir+1;
n=1.0;
Q=0*1000;
V=0;
A=1/1e4/2;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Melt_1e4';
rock(id).rheol(ir).ref='Estimate viscosity 1e4 Pa.s';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-(Q)./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp((Q)./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% viscosity of 1e8 Pa.s
ir=ir+1;
n=1.0;
Q=0*1000;
V=0;
A=1/1e8/2;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Melt_1e8';
rock(id).rheol(ir).ref='Estimate viscosity 1e8 Pa.s';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-(Q)./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp((Q)./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% viscosity of 1e12 Pa.s
ir=ir+1;
n=1.0;
Q=0*1000;
V=0;
A=1/1e12/2;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Melt_1e12';
rock(id).rheol(ir).ref='Estimate viscosity 1e12 Pa.s';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-(Q)./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp((Q)./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

% viscosity of 1e16 Pa.s
ir=ir+1;
n=1.0;
Q=0*1000;
V=0;
A=1/1e16/2;
B=2.^((1+(3/n))/2)*A.^(-1/n);
rock(id).rheol(ir).name='Melt_1e16';
rock(id).rheol(ir).ref='Estimate viscosity 1e16 Pa.s';
rock(id).rheol(ir).type=1;
rock(id).rheol(ir).r=@(s,T)(s/B).^n.*exp(-(Q)./(RG*T));
rock(id).rheol(ir).s=@(r,T)B.*exp((Q)./(n*RG*T)).*r.^(1/n);
rock(id).rheol(ir).n=n;rock(id).rheol(ir).Q=Q;
rock(id).rheol(ir).B=B;rock(id).rheol(ir).A=A;rock(id).rheol(ir).m=0;

nrock=size(rock,2);

for id=1:numel(rock);
    for ir=1:numel(rock(id).rheol);
        if ~isfield(rock(id).rheol(ir),'n'); rock(id).rheol(ir).n=0;
        elseif isempty(rock(id).rheol(ir).n); rock(id).rheol(ir).n=0;end
        if ~isfield(rock(id).rheol(ir),'m'); rock(id).rheol(ir).m=0;
        elseif isempty(rock(id).rheol(ir).m); rock(id).rheol(ir).m=0;end
        if ~isfield(rock(id).rheol(ir),'p'); rock(id).rheol(ir).p=0;
        elseif isempty(rock(id).rheol(ir).p); rock(id).rheol(ir).p=0;end
        if ~isfield(rock(id).rheol(ir),'Q'); rock(id).rheol(ir).Q=0;
        elseif isempty(rock(id).rheol(ir).Q); rock(id).rheol(ir).Q=0;end
    end
end



save 'rock' rock nrock
