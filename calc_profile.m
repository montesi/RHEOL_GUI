function model=calc_profile(model,did,e,rock);

% calc_strength %
% Calculate strength profile for a given model

nlayer=numel(model);

for il=1:nlayer
    rhog=model(il).rhog;
    nrock=model(il).nrock;
%     model(il).thid=thid;
%     model(il).Temperature=Temperature;
    %model(il).zbot=model(il).ztop+model(il).thick;
    Pressure=@(z)model(il).Ptop+(z-model(il).ztop)*model(il).rhog;
    model(il).Pressure=Pressure;
    %    model(il).str=[]; %initialize stratification;
    for im=1:nrock
        ztop=model(il).ztop;
        zbot=model(il).zbot;
        nrheol=model(il).rock(im).nrheol;
        model(il).rock(im).str=[];
        
        %% initialize laws 
        rh=[];
        for ir=1:nrheol
            irh(ir)=model(il).rock(im).irheol(ir);
            if irh(ir)<0 %brittle law
                [S(ir),f(ir),tag]=byerlee(did,-irh(ir));
                rh(ir).s=@(z,e)(S(ir)+f(ir)*Pressure(z))*model(il).rock(im).Wk;
                rh(ir).name=tag;
            else % ductile law
                if (model(il).rock(im).gdep(ir)==1)&isa(model(il).rock(im).gs,'function_handle');
                    % Grain size dependence is with piezometer relation: solve numerically for stress
                    rh(ir).s=@(z,e)StressPiezo(rock(model(il).irock(im)).rheol(irh(ir)),e,...
                        model(il).Temperature(z),Pressure(z),model(il).rock(im).gs);
                else %fixed grain size: analytical relations                    
                    rh(ir).s=@(z,e)RheolSimple(rock(model(il).irock(im)).rheol(irh(ir)),e,...
                        model(il).Temperature(z),Pressure(z),model(il).rock(im).gs);
                end
                rh(ir).name=rock(model(il).irock(im)).rheol(irh(ir)).name;
            end
        end
        % Define mechanical transitions; return
        %        model(il).str(im,is).law=irt;
        %        model(il).str(im,is).ztop=zn;
        %        model(il).str(im,is).zbot=zbot;
        [model(il).rock(im).str,model(il).rock(im).nstr]=...
            Define_Layers(rh,model(il).rock(im).irheol,...
            ztop,zbot,e,Pressure,model(il).Temperature);
%%
% Define_Layers
    end
    
    % %% combine flow laws
    %     icomb=1;scomb=[];
    %     scomb.laws=[model(il).str(:,1).law];
    %     scomb.ztop=model(il).ztop;
    %     scomb.zbot=zbot;
    %     zleft(1:model(il).nrock)=Inf;
    %     %zleft=[model(il).str(:,2:end).ztop];
    %     [znext,inext]=min(zleft);
    %     while znext<zbot;
    %         [imn,irn]=ind2sub(size(model(il).str),inext);
    %         icomb=icomb+1;
    %         scomb(icomb)=scomb(icomb-1);
    %         scomb(icomb).laws(imn(1))=model(il).str(imn,irn).law;
    %         scomb(icomb).ztop=znext;
    %         scomb(icomb-1).zbot=znext;
    %         zleft(inext)=+inf;
    %         [znext,inext]=min(zleft);
    %     end
    %     model(il).scomb=scomb;
    %     model(il).ncomb=length(scomb);
end