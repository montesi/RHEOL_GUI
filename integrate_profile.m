function Stotal=integrate_profile(model,e);

% initialize
nstep=100;
Stotal=0;
% calc_strength %
% Calculate strength profile for a given model
for il=1:numel(model);
    for im=1:model(il).nrock
        for is=1:model(il).rock(im).nstr;
%             in=in+1;
            z=linspace(model(il).rock(im).str(is).ztop,model(il).rock(im).str(is).zbot,nstep);
            
            if isa(model(il).rock(im).gs,'function_handle');
                %can't use vector for z
                stress=z*0;
                grain=stress;
                for iz=1:numel(z)
                    stress(iz)=model(il).rock(im).str(is).s(z(iz),e);
                    grain(iz)=model(il).rock(im).gs(stress(iz));
                end
            else %use vector for z
                stress=model(il).rock(im).str(is).s(z,e);
                grain=model(il).rock(im).gs;
            end
            Stotal=Stotal+sum((stress(1:end-1)+stress(2:end)).*diff(z)/2);
        end
    end
end
return