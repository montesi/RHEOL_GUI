function save_script(fileName,model,mglobal)
% ## planet number
% ## thermal id - 1: linear, 2: erf
% ## surface temp
% ## surface temp gradient
% ## adiabatic temp
% ## strain rate

% #xx

thid = mglobal.thid;
did = mglobal.did;
e = mglobal.e;
ip = mglobal.ip;
Ts = mglobal.Ts;
Ti = mglobal.Ti;
G = mglobal.G;
P0 = mglobal.P0;
g = mglobal.g;

%create file
if (exist('fileName')==0)
    fileName = 'Output.rhl';
end
fileID = fopen(fileName,'w');
comments = true;

fprintf(fileID,sprintf('## rheology script - %s\n\n',datetime));


if (comments)
    fprintf(fileID,'%i \t\t\t## planet number\n',mglobal.ip);
    fprintf(fileID,'%i \t\t\t## thermal id - 1: linear, 2: erf\n',mglobal.thid);
    fprintf(fileID,'%5.3f  \t\t## surface temp\n',mglobal.Ts-mglobal.Celsius);
    fprintf(fileID,'%5.3f  \t\t## temp gradient\n',mglobal.G*1000);
    fprintf(fileID,'%5.3f  \t\t## adiabatic temp\n',mglobal.Ti-mglobal.Celsius);
    fprintf(fileID,'%i  \t\t\t## deformation type\n',mglobal.did);
    fprintf(fileID,'%d  \t\t## strain rate\n',mglobal.e);

    for il = 1:size(model,2)
        fprintf(fileID,'\n#xx \n');
        for ki = 1:model(il).nrock
            fprintf(fileID,'%i   ',model(il).irock(ki));
        end
        fprintf(fileID,'\t\t ## rock id\n');
        fprintf(fileID,'%d \t\t##  thickness\n',model(il).thick);
        fprintf(fileID,'%i ',model(il).rock.irheol);
        fprintf(fileID,'\t## [iduct,-ibrit]\n');
        fprintf(fileID,'%s \t\t\t## pore pressure\n',num2str(model(il).pf));
        
        gcode = model(il).rock.gc;
        fprintf(fileID,'%i \t',gcode);
        if (gcode == 0)
            fprintf(fileID,'%d \t## [0, grain size]\n',model(il).rock.gs);
        else
            fprintf(fileID,'0 \t\t## [grain code, 0]\n');
        end
        
        
    end
    
else
    fprintf(fileID,'%i \n',mglobal.ip);
    fprintf(fileID,'%i \n',mglobal.thid);
    fprintf(fileID,'%d \n',mglobal.Ts-mglobal.Celsius);
    fprintf(fileID,'%d \n',mglobal.G*1000);
    fprintf(fileID,'%d \n',mglobal.Ti-mglobal.Celsius);
    fprintf(fileID,'%i \n',mglobal.did);
    fprintf(fileID,'%d \n',mglobal.e);
    
    for il = 1:size(model,2)
        fprintf(fileID,'\n#xx\n');
        for ki = 1:model(il).nrock
            fprintf(fileID,'%i ',model(il).irock(ki));
        end
        fprintf(fileID,'\n');
        fprintf(fileID,'%d \n',model(il).thick);
        fprintf(fileID,'%i ',model(il).rock.irheol);
        fprintf(fileID,'\n');
        fprintf(fileID,'%s \n',num2str(model(il).pf));
        
        gcode = model(il).rock.gc;
        fprintf(fileID,'%i \t',gcode);
        if (gcode == 0)
            fprintf(fileID,'%d \n',model(il).rock.gs);
        else
            fprintf(fileID,'0 \n');
        end
        
        
    end
end

fclose(fileID);




