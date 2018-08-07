function s=StressPiezo(rh,e,T,P,g);%(B,n,m,p,Q,e,T,P)
% to use when gs is a piezometric relation (g(s))

fwscale=1;
switch rh.type
    case 1; % Power law, depends on T (K)
        s=rh.s(e,T);
    case 2; %Wet power law, depends on T and water fugacity fw (Pa)
        load water_fugacity;
        fw=P.*interp2(P_H2O,T_H2O,gamma_coef,P,T,'spline')/fwscale;
        s=rh.s(e,T,fw);
    case 3; %Grain-size dependent power law (T, g in m)
%         if ~exist('g')
%             g=input('Grain size (in m)');
%         end
        s=SolveStress(@(s)1e20*(e-rh.r(s,T,g(s))));%,1e20);
    case 4; %Grain-size depedent power law, wet (T, g, fw)
%         if ~exist('g')
%             g=input('Grain size (in m)');
%         end
        load water_fugacity;
        fw=P*interp2(P_H2O,T_H2O,gamma_coef,P,T,'spline')/fwscale;
        s=SolveStress(@(s)1e20*(e-rh.r(s,T,g(s),fw')));%,1e20);
    case 5; %Power law, depends on T (K) and P (Pa)
        r=rh.r(e,T,P);
    case 6; % Wet power law, depends on T, P and water fugacity fw (Pa)
        load water_fugacity;
        fw=P*interp2(P_H2O,T_H2O,gamma_coef,P,T,'spline')/fwscale;
        r=rh.r(e,T,P,fw');
    case 7; % Grain-size dependent power law (T, P, g in m)
%         if ~exist('g')
%             g=input('Grain size (in m)');
%         end
        s=SolveStress(@(s)1e20*(e-rh.r(s,T,P,g(s))));%,1e20);
    case 8; %Grain-size dependent power law, wet (T, P, g, fw)
        load water_fugacity;
        fw=P*interp2(P_H2O,T_H2O,gamma_coef,P,T,'spline')/fwscale;
%         if ~exist('g')
%             g=input('Grain size (in m)');
%         end
        s=SolveStress(@(s)1e20*(e-rh.r(s,T,P,g(s),fw')));%,1e20);
end