classdef Infiltration <Simulator.Shadow
    %INFILTRATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        autobuff=0;
    end
    
    methods
        function obj=Infiltration(z)
            if(nargin<1)
                z='Assassin';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Shadow'))
                    LoadAbilities(obj,'json/Infiltration.json')
                else
                    LoadAbilities(obj,'json/Infiltration.json')
                end
            end
            obj.autocrit_abilities = {'Spinning Strike','Shadow Strike'};
            obj.raid_armor_pen=0.2;
            obj.armor_pen=0.1;
        end
        
      function [isCast,CDLeft]=UseSaberStrike(obj)
          [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.ss);
      end
      function [isCast,CDLeft]=UseSpinningStrike(obj)
          %need to add 30% check AND proc check
          [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.sps);
      end
      function [isCast,CDLeft]=UseClairvoyantStrike(obj)
          if(obj.autocrit_last_proc+60/(1+obj.stats.Alacrity)<obj.nextCast || obj.autocrit_last_proc<0)
               obj.autocrit_last_proc=obj.nextCast;
               obj.autocrit_proc_duration=30;
               obj.autocrit_charges=1;
               %fprintf('autocrit procced %0.2f\n',obj.nextCast);
           end
          [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.cls); 
      end
      function [isCast,CDLeft]=UsePsychokineticBlast(obj)
           [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.psy);
      end
      function [isCast,CDLeft]=UseShadowStrike(obj)
           [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.shs);
      end
      function [isCast,CDLeft]=UseForceBreach(obj)
          [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.fb); 
      end
      function PSYCallback(obj,t,~)
           if(obj.stats.pc2 &&(t>=(obj.procs.PC2.Available) ...
                   || obj.procs.PC2.LastProc<0))
               obj.procs.PC2.LastProc=t;
               obj.procs.PC2.Available=t+obj.procs.PC2.CD/(1+obj.stats.Alacrity)*0.99;
           end
           
       end
      function [bd, bc,bs,bm]=CalculateBonus(obj,t,it,mhh,ohh)
          [bd, bc,bs,bm]=CalculateBonus@Simulator.Shadow(obj,t,it,mhh,ohh);
          if(it.w==1 && obj.procs.FS.LastProc+obj.procs.FS.Dur>t)  %Force Synergy Bonus Dmg
              bc=bc+0.05; 
           end
          if(strcmp(it.id,'force_breach'))
              if(obj.autobuff)
                bm=bm*3;
              else
                bm=bm*(obj.buffs.BS.Charges);  
              end
          end
          if(strcmp(it.id,'shadow_strike') && (obj.autobuff || (obj.procs.IT.LastProc+obj.procs.IT.Dur>t && obj.procs.IT.LastProc>0)))
              bm=bm*1.2;
          end
      end

      function AddDamageCB(obj,t,dmg,it)
          %"CallBack" (not) called right before the damage is applied
          %A good time to either proc on hit abilities (force technique)
          %or on hit procs (force synergy)
          if(it.w==1)
              %Force Technique
              %fprintf('%s procced force technique',dmg{2})
              BRU=obj.buffs.BR.LastUsed>=0 && t<=obj.buffs.BR.Dur+obj.buffs.BR.LastUsed;
              r=rand();
              if((obj.procs.ST.Available<t && r<0.5)|| (BRU && r<0.75))
                  [mhd,mhh,mhc]=obj.CalculateDamage(t,obj.abilities.sht);
                  AddDamage(obj,{t,obj.abilities.sht.name,mhd,mhc,mhh},obj.abilities.sht);
                  if(BRU)
                      tn=t;
                  else
                      tn=t+obj.procs.ST.CD/(1+obj.stats.Alacrity)*0.9;
                  end
                  obj.procs.ST.Available=tn;%+obj.procs.FT.CD/(1+obj.stats.Alacrity);
              end
          elseif(strcmp(it.id,'psychokinetic_blast'))
              if(rand()<0.5)
                 [mhd,mhh,mhc]=obj.CalculateDamage(t,obj.abilities.psyu);
                 AddDamage(obj,{t,obj.abilities.psyu.name,mhd,mhc,mhh},obj.abilities.psyu); 
              end
              [mhd,mhh,mhc]=obj.CalculateDamage(t,obj.abilities.sht);
              AddDamage(obj,{t,obj.abilities.sht.name,mhd,mhc,mhh},obj.abilities.sht);
          end
          if(strcmp(it.id,'clairvoyant_strike'))
              if(obj.stats.pc2 &&(t>=(obj.procs.PC2.Available) ...
                      || obj.procs.PC2.LastProc<0))
                  obj.procs.PC2.LastProc=t;
                  obj.procs.PC2.Available=t+obj.procs.PC2.CD/(1+obj.stats.Alacrity)*0.99;
              end
          end
          if(it.w==0 && dmg{5}==1 && dmg{4}==1)
                %Proc Force Synergy
                obj.procs.FS.LastProc=t;
          end
      end
    end
    
end

