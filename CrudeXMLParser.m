function [ d,out] = CrudeXMLParser( XMLData,ability )
%CRUDEXMLPARSER Summary of this function goes here
%   Detailed explanation goes here
a=strfind(XMLData,ability);
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


end

function r=parseToken(tok,s)
    r=struct();
    r.name=s.Name;
    if(strcmp(tok.ablDescriptionTokenType,'ablDescriptionTokenTypeDamage'))
        actions=tok.ablCoefficients.Action;
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
        r.long_id=s.Fqn;
        ss=strsplit(s.Fqn,'.');
        r.id=ss{end};
    end

end

