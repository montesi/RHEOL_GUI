function s=calc_stress(rh,e,T,P,g);%(B,n,m,p,Q,e,T,P)
%function s=calc_stress(rh,e,T,P,g);%(B,n,m,p,Q,e,T,P)
fwscale=1;
switch rh.type
    case 1; % Power law, depends on T (K)
        s=rh.s(e,T);
    case 2; %Wet power law, depends on T and water fugacity fw (Pa)
        load water_fugacity;
        fw=P.*interp2(P_H2O,T_H2O,gamma_coef,P,T,'spline')/fwscale;
        s=rh.s(e,T,fw);
    case 3; %Grain-size dependent power law (T, g in m)
        if ~exist('g')
            g=input('Grain size (in m)');
        end
        s=rh.s(e,T,g);
    case 4; %Grain-size dependent power law, wet (T, g, fw)
        if ~exist('g')
            g=input('Grain size (in m)');
        end
        load water_fugacity;
        fw=P.*interp2(P_H2O,T_H2O,gamma_coef,P,T,'spline')/fwscale;
        s=rh.s(e,T,g,fw);
    case 5; %Power law, depends on T (K) and P (Pa)
        s=rh.s(e,T,P);
    case 6; % Wet power law, depends on T, P and water fugacity fw (Pa)
        load water_fugacity;
        fw=P.*interp2(P_H2O,T_H2O,gamma_coef,P,T,'spline')/fwscale;
        s=rh.s(e,T,P,fw);
    case 7; % Grain-size dependent power law (T, P, g in m)
        if ~exist('g')
            g=input('Grain size (in m)');
        end
        s=rh.s(e,T,P,g);
    case 8; %Grain-size dependent power law, wet (T, P, g, fw)
        load water_fugacity;
        fw=P.*interp2(P_H2O,T_H2O,gamma_coef,P,T,'spline')/fwscale;
        if ~exist('g')
            g=input('Grain size (in m)');
        end
        s=rh.s(e,T,P,g,fw);
end