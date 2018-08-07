function [str,nstr]=Define_Layers(rh,irheol,ztop,zbot,e,Pressure,Temperature)
nrheol=numel(rh);
% Define mechanical layers
is=0; goOn=1; zn=ztop;
irall=1:nrheol;
while goOn;
    Sn=[];Sbot=[];
    for ir=1:numel(irall); %initialize for remaining rheologies
        Sn(ir)=rh(irall(ir)).s(zn,e);
        Sbot(ir)=rh(irall(ir)).s(zbot,e);
    end
    [strBot,oBot]=sort(Sbot);
    [strN,oN]=sort(Sn);
    irt=irall(oN(1)); %top rheology
    is=is+1;
    str(is).law=irheol(irt);
    str(is).ztop=zn;
    str(is).s=rh(irt).s;
    str(is).name=rh(irt).name;
    %     model(il).rock(im).str(is).law=model(il).rock(im).irheol(irt);
    %     model(il).rock(im).str(is).ztop=zn;
    %     model(il).rock(im).str(is).s=rh(irt).s;
    if oBot(1)==oN(1); %no more transition
        %        model(il).rock(im).str(is).zbot=zbot;
        str(is).zbot=zbot;
        goOn=0;
    else %need a transition
        it=1; irn=irall(oBot(it)); %new rheology to test
        zt=[];
        while irn~=irt
            zt(it)=bisection(@(z)(rh(irt).s(z,e)-rh(irn).s(z,e)),[zn,zbot]);
            it=it+1; irn=irall(oBot(it)); %new rheology to test
        end
        [zn,in]=min(zt);
        %        model(il).rock(im).str(is).zbot=zn;
        str(is).zbot=zn;
        % remove the top rheology;
        irall=irall(find(irall~=irt));
        if isempty(irall); %no more rheologies; Should not need to do this!
            disp('cleanup layer; shouldn''t happen!')
            is=is+1;
            %             model(il).rock(im).str(is).law=model(il).rock(im).irheol(irt);
            %             model(il).rock(im).str(is).ztop=zn;
            %             model(il).rock(im).str(is).zbot=zbot;
            %             model(il).rock(im).str(is).s=rh(irt).s;
            str(is).law=irheol(irt);
            str(is).ztop=zn;
            str(is).zbot=zbot;
            str(is).s=rh(irt).s;
            str(is).name=rh(irt).name;
            goOn=0;
        end
    end
    %model(il).rock(im).nstr=is;
    nstr=is;
end