function model=recalc_model(mglobal,model,rock);
% Assign model properties to each layer

%% Extract required model parameters
thid = mglobal.thid;
Ts = mglobal.Ts;
Ti = mglobal.Ti;
G = mglobal.G;
P0 = mglobal.P0;
g = mglobal.g;

%% Define temperature
switch thid
    case 1 %linear
        Temperature=@(z)min(Ts+z*G,Ti);
    case 2 %error funciton
        del=2*(Ti-Ts)/(G*sqrt(pi));
        Temperature=@(z)Ts+(Ti-Ts)*erf(z/del);
    otherwise
        ZT=load(mglobal.Tfile);
        Temperature=@(z)interp1(ZT(:,1),ZT(:,2)+mglobal.Celsius,z);
end

%% build model
il=0;
Pbot=P0;ztop=0;zbot=0;

for il = 1:(size(model,2))
    %% parse fxblox{}
    
    ki=1;
    model(il).nrock=length(model(il).irock);
    model(il).Ci=ones(1,model(il).nrock)/model(il).nrock; % initialize Concentration
    model(il).Temperature=Temperature; %store Temperature function in layer
    
    if ~isempty(model(il).irock);
        %% thickness
        model(il).ztop=zbot;
        zbot=zbot+model(il).thick;
        model(il).zbot=zbot;
        
        ibrit=[];
        
%         %% rheologies
%         for im=1:model(il).nrock
%             model(il).rock(im).nrheol=length(model(il).rock(im).irheol);
%             model(il).rock(im).Wk=1;
%             ibrit = []; iduct = []; nbrit = 0; nduct = 0;
%             for ia = 1:model(il).rock(im).nrheol
%                 rhla = model(il).rock(im).irheol(ia);
%                 if (rhla < 0)
%                     ibrit = [ibrit,-rhla];
%                     nbrit = nbrit+1;
%                 else
%                     iduct = [iduct,rhla];
%                     nduct = nduct+1;
%                 end
%             end % end for(ia)
%         end % end im--nrock loop
        
        %% Pressure
        model(il).Ptop=Pbot;
        rhoav=0;
        for im=1:model(il).nrock;
            rhoav=rhoav+rock(model(il).irock(im)).density*model(il).Ci(im);
        end
        if model(il).pf=='p'
            model(il).rhog=(rhoav-1e3)*g;
        else
            model(il).rhog=rhoav*(1-model(il).pf)*g;
        end
        Pbot=model(il).Ptop+model(il).thick*model(il).rhog;
        model(il).Pbot=Pbot;
        
        %% grain size dependence
        for im=1:model(il).nrock
            model(il).rock(im).Wk=1; %weakening option, not implemented
%             model(il).rock(im).nrheol=length(model(il).rock(im).irheol);
            rh=model(il).rock(im).irheol;
            model(il).rock(im).nrheol=numel(rh);
            iduct=rh(find(rh>0));
            nduct=numel(iduct);
            model(il).rock(im).gdep=zeros([model(il).nrock,nduct+2]);
            for ir=1:nduct
                if (rock(model(il).irock(im)).rheol(iduct(ir)).m~=0);
                    model(il).rock(im).gdep(ir)=1;
                end
            end
            
            if model(il).rock(im).gc~=0; %use piezometer
                npiez=numel(rock(model(il).irock(im)).piezo);
                if model(il).rock(im).gc>npiez
                    %no piezometers opt
                    model(il).rock(im).gs=1e-2; %Default values
                    %disp(['grain size is now   ',sprintf('%f',model(il).rock(im).gs)]);
                else
                    % Store piezometer, with limits to 1 micron and 1 meter
                    model(il).rock(im).gs=@(s)min(max(rock(model(il).irock(im)).piezo(model(il).rock(im).gc).geq(s),1e-6),1);
                end
            end
        end
        
        %         model(il).rock(im).Ty=NaN;
        %         if ~isempty(find(ibrit==0));
        %             fprintf('Default tensile strength: Ty=%g MPa \n',model(il).rock(im).Ty);
        %             anz=input('Enter desired tensile strength (in MPa): ');
        %             if ~isempty(anz)
        %                 model(il).rock(im).Ty=anz*1e6;
        %             end
    end
end
end