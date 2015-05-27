function [ d,out] = CrudeXMLParser( XMLData,ability )
%CRUDEXMLPARSER Summary of this function goes here
%   Detailed explanation goes here
a=strfind(XMLData,ability);
a=a(1);
b=strfind(XMLData,'<Ability');
b=max(b(b<a));
c=strfind(XMLData,'</Ability>');
c=min(c(c>a));
d=XMLData(b:c+9);
xml=xmltree(d);
s=convert(xml);
out={};
if(iscell(s.Tokens.Token))
    disp('cell array');
    for i=1:numel(s.Tokens.Token)
        r=parseToken(s.Tokens.Token{i},s);
        if(isfield(r,'id'))
            out{end+1}=r;
        end
    end
else
    r=parseToken(s.Tokens.Token,s);
    if(isfield(r,'id'))
        out{end+1}=r;
    end
    
end
for i = 1:numel(out)
    obj=out{i};
    fprintf('%s=struct(''c'',%.3f,''Sm'',%.3f,''Sx'',%.3f,''Am'',%.3f,''Sh'',3185,...\n',obj.id(1:3),obj.c,obj.Sm,obj.Sx,obj.am);
    fprintf('         ''w'',%.0f,''long_id'',''%s'',''id'',''%s'',''name'',''%s'',...\n',obj.w,obj.long_id,obj.id,obj.name);
    fprintf('         ''cb'',0.0,''sb'',0.0,''s30'',0.0,''dmg_type'',%.0f,''base_acc'',%.1f,''raid_mult'',1.0,...\n',obj.dmg_type,obj.base_acc);
    fprintf('         ''ctype'',0,''ct'',0.0,''mult'',1.0,''CD'',%f,...\n',obj.CD);
    fprintf('         ''raidAOE'',0,''raidIE'',%.0f,''raidKEFT'',1)\n',double(obj.dmg_type>=3));
end


end

function r=parseToken(tok,s)
    r=struct();
    r.name=s.Name;
    if(strcmp(tok.ablDescriptionTokenType,'ablDescriptionTokenTypeDamage'))
        actions=tok.ablCoefficients.Action;
        if(iscell(actions))
            actions=actions{1};
        end
        r.Sx=str2double(actions.effParam_StandardHealthPercentMax);
        r.Sm=str2double(actions.effParam_StandardHealthPercentMin);
        r.c=str2double(actions.effParam_Coefficient);
        r.am=str2double(actions.effParam_AmountModifierPercent);
        if(isfield(actions,'effParam_SpellType'))
            r.w=0;
            r.base_acc=1;
            r.dmg_type=str2double(actions.effParam_DamageType);
        else
            r.base_acc=strcmp(actions.effParam_IsSpecialAbility,'True')*0.1+0.9;
            r.w=1;
            r.dmg_type=1;
        end
        r.CD=0;
        if(isfield(s,'CooldownTime'))
            r.CD=str2double(s.CooldownTime);
        end
        r.long_id=s.Fqn;
        ss=strsplit(s.Fqn,'.');
        r.id=ss{end};
    end

end

