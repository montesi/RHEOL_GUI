function [model,mglobal]=parse_script(fname);
%parse script

if (~exist('fname') || isempty(fname));
    fname = 'Default.rhl';
end

fstring = fileread(fname);
fxxblx = regexp(fstring,'\n#xx','split');

initc = splitlines(fxxblx{1});  %initial codes
ki=1;
while ki <= size(initc,1)
    %%disp(fxblox{ki});
    if contains(initc{ki},'##')
        cmt = split(initc{ki},'##');
        initc{ki} = strtrim(cmt{1});
        %%fprintf('     COMMENT: ##%s \n',cmt{2:end});
    end
    initc{ki} = strtrim(initc{ki});
    if isempty(initc{ki})
        %%disp('     EMPTY LINE');
        initc = [initc(1:ki-1);initc(ki+1:end)];
    else
        ki = ki+1;
    end
end

load planet;
load rock;
Celsius=273.15;

iread=0;
%% read planet
iread=iread+1;
ip = str2num(initc{iread});
Ts=planet(ip).env.Ts;
Ti=planet(ip).env.Ti;
G=planet(ip).env.G;
P0=planet(ip).env.P0;
g=planet(ip).global.gravity;


%% read th
iread=iread+1;
anz = initc{iread};
if anz == "def"; thid=1;
else  thid = str2num(anz); 
end

if thid==3; % custom file, no info in input
    iread=iread+1;
        Tfile= initc{iread};
        ZT=load(Tfile);
        Temperature=@(z)interp1(ZT(:,1),ZT(:,2)+Celsius,z);
else % linear or error function, need more info
    %anz=input(sprintf('Default surface temperature is %gC; Enter chosen Ts: ',Ts-Celsius));
    iread=iread+1;
    anz = initc{iread}; %surface temp
    if anz ~= "def"
        Ts=str2num(anz)+Celsius;
    end
    
    %anz=input(sprintf('Default surface T gradient is %g K/km; Enter chosen G: ',G*1000));
    iread=iread+1;
    anz = initc{iread}; %surface temp gradient
    if anz ~= "def"
        G=str2num(anz)/1000;
    end
    
    iread=iread+1;
    anz = initc{iread};
    %anz=input(sprintf('Default adiabatic temperature is %gC; Enter chosen Ti: ',Ti-Celsius))+Celsius;
    
    if thid==2; %adiabatic temp
        if anz ~= "def"
            Ti=str2num(anz)+Celsius;
        end
    end
    del=2*(Ti-Ts)/(G*sqrt(pi));
    
    % % setup temperature
    % switch thid
    %     case 2
    %         Temperature=@(z)Ts+(Ti-Ts)*erf(z/del);
    %     otherwise
    %         Temperature=@(z)min(Ts+z*G,Ti);
    % end
    %% Define temperature
    switch thid
        case 1 %linear
            Temperature=@(z)min(Ts+z*G,Ti);
        case 2 %error funciton
            del=2*(Ti-Ts)/(G*sqrt(pi));
            Temperature=@(z)Ts+(Ti-Ts)*erf(z/del);
        otherwise %linear
            Temperature=@(z)min(Ts+z*G,Ti);
    end
end
%% read def
iread=iread+1;
did = str2num(initc{iread}); %deformation
% 1 - compression
% 2 - extension
% 3 - strike-slip
e=1e-15;
%anz=input(sprintf('Strain rate (default is %g/s): ',e));
iread=iread+1;
anz = initc{iread}; %strain rate
if anz ~= "def";
    e=str2num(anz);
end

% store global parameters
mglobal.ip = ip;
mglobal.thid = thid;
mglobal.did = did;
mglobal.e = e;

mglobal.Ts = Ts;
mglobal.Ti = Ti;
mglobal.G = G;
mglobal.P0 = P0;
mglobal.g = g;
mglobal.Celsius=Celsius;

%% read model
il=0;
Pbot=P0;ztop=0;zbot=0;

for il = 1:(length(fxxblx)-1)
    fxblox = splitlines(fxxblx{il+1});
    %%disp(fxblox);
    %% parse layer, remove comments
    ki=1;
    while ki <= size(fxblox,1)
        %%disp(fxblox{ki});
        if contains(fxblox{ki},'##')
            cmt = split(fxblox{ki},'##');
            fxblox{ki} = strtrim(cmt{1});
            %%fprintf('     COMMENT: ##%s \n',cmt{2:end});
        end
        fxblox{ki} = strtrim(fxblox{ki});
        if isempty(fxblox{ki})
            %%disp(ki); %disp('EMPTY');
            fxblox = [fxblox(1:ki-1);fxblox(ki+1:end)];
        else
            ki = ki+1;
        end
        
        if isempty(fxblox)
            %disp('---EMPTY BLOCK---');
            break;
        end
    end
    
    if isempty(fxblox)
        %disp('something is empty');
        break;
    end
    
    %% parse fxblox{}
    
    ki=1;
    
    %disp(sprintf('For layer %d: ',il));
    model(il).irock=1;
    %anz=input('Desired rock type (can be a vector): ');
    
    %% rock type
    
    anz = sscanf(fxblox{ki},'%i');
    %fprintf('rock type: %i / %s \n',anz,rock(anz).name);
    
    if ~isempty(anz)
        model(il).irock=anz;
    end
    model(il).nrock=length(model(il).irock);
    model(il).Ci=ones(1,model(il).nrock)/model(il).nrock; %Concentration initialize
    model(il).Temperature=Temperature; %store Temperature function in layer

    ki=ki+1;
    
    
    
    if model(il).nrock>1;
        anz=input('Enter the volume proportion of each rock type');
        if anz ~= "def"
            model(il).Ci=anz/sum(anz);
        end
    end
    
    %%disp('    x');
    if ~isempty(model(il).irock);
        
        %% thickness
        
        %model(il).thick=input('Layer thickness (in km): ')*1000;
        model(il).thick = sscanf(fxblox{ki},'%i');
        %fprintf('thickness: %g \n',model(il).thick);
        model(il).ztop=zbot;
        zbot=zbot+model(il).thick;
        model(il).zbot=zbot;
        
        ki = ki+1;
        
        ibrit=[];
        
        
        %%disp('  1: Byerlee, low P branch');
        %%disp('  2: Byerlee, high P branch');
        %%disp('  3: Tensile strength');
        %anz=input('Desired brittle rheology (can be a vector): ');
        
        %nrheol=size(rock(model(il).irock(im)).rheol,2);
        %for ir=1:nrheol
        %    %disp(sprintf('%4d: %s: %s',...
        %        ir,...
        %        rock(model(il).irock(im)).rheol(ir).name,...
        %        rock(model(il).irock(im)).rheol(ir).ref));
        %end
        %anz=input('Desired ductile rheology (can be a vector; enter 0 for brittle only): ');
        %anz = str2num(fxblox{ki}); %ductile rheology
        %ki=ki+1;
        %%disp(['ductile rheologies: ',sprintf('%i ',anz)]);
        %if ~isempty(anz)
        %    if anz==0;
        %        nduct=0;
        %        iduct=[];
        %    else
        %        nduct=length(anz);
        %        iduct=anz;
        %    end
        
        %% rheologies
        anz = str2num(fxblox{ki}); %RHEOLOGIES
        ki=ki+1;
        %disp(['rheologies: ',sprintf('%i ',anz)]);
        model(il).irheol=[];
        if ~isempty(anz)
            for im=1:model(il).nrock
                
                model(il).rock(im).nrheol=length(anz);
                model(il).rock(im).irheol=anz;
                model(il).rock(im).Wk=1;
                
                ibrit = []; iduct = []; nbrit = 0; nduct = 0;
                
                for ia = 1:model(il).rock(im).nrheol
                    rhla = model(il).rock(im).irheol(ia);
                    if (rhla < 0)
                        ibrit = [ibrit,-rhla];
                        nbrit = nbrit+1;
                    else
                        iduct = [iduct,rhla];
                        nduct = nduct+1;
                    end
                    
                end
            end % end im--nrock loop
        end
        
        %ibrit=[1,2];
        %if model(il).irock==10;
        %    anz=input('Serpentine detected: Is it lizardite (low F, default = no): ');
        %    if ~isempty(anz);
        %        if or(strncmpi(anz,'yes',1),anz==1);
        %            ibrit=[3,4];
        %        end
        %    end
        %end
        
        %% pore fluid pressure
        
        model(il).pf='p';
        %%disp('Default pore fluid pressure: hydrostatic');
        %anz=input('Enter pore fluid pressure: lambda or keep hydrostatic');
        anz = fxblox{ki};
        ki=ki+1;
        
        if anz ~= "def"
            if anz == 'p'
                model(il).pf = 'p';
            else
                model(il).pf = sscanf(anz,'%f');
            end
            %disp(anz);
        end
        %disp(['pore fluid pressure: ',anz]);%model(il).pf);
        
        model(il).Ptop=Pbot;
        rhoav=0;
        for im=1:model(il).nrock;
            rhoav=rhoav+rock(model(il).irock(im)).density*model(il).Ci(im);
        end
        if model(il).pf=='p'
            model(il).rhog=(rhoav-1e3)*...
                planet(ip).global.gravity;
        else
            model(il).rhog=rhoav*(1-model(il).pf)*...
                planet(ip).global.gravity;
        end
        Pbot=model(il).Ptop+model(il).thick*model(il).rhog;
        model(il).Pbot=Pbot;
        
        %% grain dependence
        
        for im=1:model(il).nrock
            %model(il).gs(im)=0;
            ginp = str2num(fxblox{ki});
            %disp(ginp);
            ki=ki+1;
            
            model(il).rock(im).gc = ginp(1);
            if ginp(1)==0; %Fixed grain size;            
                model(il).rock(im).gs=ginp(2);
            else % piezometer
                % imposes limits to 1 micron and 1 meter
                model(il).rock(im).gs=@(s)min(max(rock(model(il).irock(im)).piezo(ginp(1)).geq(s),1e-6),1);%model(il).gs(im)=anz;
%                 model(il).rock(im).gs=ginp(2);
            end
            model(il).rock(im).gdep=zeros([nrock,nduct+2]);
            for ir=1:nduct
                %%
                if (rock(model(il).irock(im)).rheol(iduct(ir)).m~=0);
                    model(il).rock(im).gdep(ir)=1;%(model(il).gs(im)==0);
%                     model(il).rock(im).gs=10e-3; %model(il).gs(im)=100e-6;
                    %                     if (rock(model(il).irock(im)).rheol(iduct(ir)).m~=0)&...
                    %                             (model(il).rock(im).gs==0);%(model(il).gs(im)==0);
                    %                         model(il).rock(im).gs=10e-3; %model(il).gs(im)=100e-6;
                end
            end
            
%             if model(il).rock(im).gs~=0;
%                 %%disp(sprintf('Detecting grain-size-dependent laws; default grain size: %g microns',model(il).rock(im).gs*1e6));
%                 %%disp(sprintf('Detecting grain-size-dependent laws\n default behavior: grain size fixed at %g microns',...
%                 %    model(il).rock(im).gs*1e6));
%                 
%                 npiez=numel(rock(model(il).irock(im)).piezo);
%                 %number of piezometers
%                 if npiez==0;
%                     %anz=input(sprintf(...
%                     %    'Enter new grain size for layer %d (in m):',il));
%                     anz = ginp(2); %no piezometers opt
%                     
%                     if ~isempty(anz);
%                         model(il).rock(im).gs=anz;%model(il).gs(im)=anz;
%                         %disp(['grain size is now   ',sprintf('%f',anz)]);
%                     end
%                 else
%                     %anz=input(sprintf(...
%                     %    'Enter 0 for choosing a piezometer or new grain size for layer %d (in m):',il));
%                     anz = ginp(1); % piezometer or grain size
%                     %disp(['gs code:  ', sprintf('%g',anz)]);
%                     if ~isempty(anz);
%                         if anz==0; %no piezometer: read piezometer directly
%                             model(il).rock(im).gs = ginp(2); %model(il).gs(im)=anz;
%                             %disp(['grain size is now = ',sprintf('%g',ginp(2)) ]);
%                         else % piezometer: read piezometer ID
%                             %for ipiez=1:npiez;
%                             %    %disp(sprintf('%2g: %s',ipiez,rock(model(il).irock(im)).piezo(ipiez).ref))
%                             %end
%                             %anz=input('Enter piezometer choice:');
%                             
%                             %disp(['now using piezometer: ',sprintf('%g',anz)]);
%                             
%                             if ~isempty(anz);
%                                 if (anz<=npiez)&(anz>0);
%                                     % imposes limits to 1 micron and 1 meter
%                                     model(il).rock(im).gs=@(s)min(max(rock(model(il).irock(im)).piezo(anz).geq(s),1e-6),1);%model(il).gs(im)=anz;
%                                 end                                
%                             end
%                             
%                         end %if anz~=0
%                     end %if ~isempty(anz)
%                 end %if npiez==0
%             end %if model(il).rock(im).gs~=0
            
            
            model(il).rock(im).Wk=1;
        end
        
        model(il).rock(im).Ty=NaN;
        if ~isempty(find(ibrit==0));
            %fprintf('Default tensile strength: Ty=%g MPa \n',model(il).rock(im).Ty);
            anz=input('Enter desired tensile strength (in MPa): ');
            if ~isempty(anz)
                model(il).rock(im).Ty=anz*1e6;
            end
        end
    end
    %newlayer=input('Do you want to add a new layer?');
    %fprintf('\n');
end
nlayer=size(model,2);
% model.nlayer=nlayer;

