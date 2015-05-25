classdef Serenity < Shadow
    %SERENITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
      function obj=Serenity(z)
            if(nargin<1)
                z='Assassin';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Shadow'))
                    LoadAbilities(obj,'json/Serenity.json')
                else
                    LoadAbilities(obj,'json/Serenity.json')
                end
            end
            obj.autocrit_abilities = {'Spinning Strike'};
            obj.raid_armor_pen=0.2;
      end
        
      function [isCast,CDLeft]=UseSaberStrike(obj)
          [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.sas);
      end
      function [isCast,CDLeft]=UseSpinningStrike(obj)
          %need to add 30% check AND proc check
          [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.sps);
      end
      function [isCast,CDLeft]=UseDoubleStrike(obj)
          [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.ds); 
      end
      function [isCast,CDLeft]=UseVanquish(obj)
          if(obj.procs.FoS.LastProc>0 &&...
             obj.procs.FoS.LastProc+obj.procs.FoS.Dur>obj.nextCast )%instantproc check here,apply vq dot in callback
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.vq);
          else 
            [isCast,CDLeft]=ApplyCastAbilities(obj,obj.abilities.vq); 
          end
          
      end
      function [isCast,CDLeft]=UseForceInBalance(obj)
           [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.fib);
      end
      function [isCast,CDLeft]=UseSeverForce(obj)
           [isCast,CDLeft]=ApplyDot(obj,'SF',obj.abilities.sf);
      end
      function [isCast,CDLeft]=UseForceBreach(obj)
          [isCast,CDLeft]=ApplyDot(obj,'FB',obj.abilities.fb);
      end
      function [isCast,CDLeft]=UseSerenityStrike(obj)
          [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.ses);
      end
      
      function VQCallback(obj,~,~)
         ApplyDot(obj,'VQ',obj.abilities.vqd,1); 
      end
      function FIBCallback(obj,t,~)
          obj.buffs.FiB.LastUsed=t;
          obj.buffs.FiB.Charges=15;
      end
      function DOTCheckCB(obj,t,~)
          if(obj.procs.CS.Available < t)
             if(rand() < 0.3)
                 obj.procs.CS.Available=t+obj.procs.CS.CD*(1-obj.stats.Alacrity)*0.99;
                 obj.procs.CS.LastProc=t;
                 obj.avail.sps=t;
             end
          end
      end
      function [bd, bc, bs, baac,bmult]=CalculateBonus(obj,t,it)
          bd=0;bc=0;bs=0;baac=0;bmult=1;
           if(it.w==1 && obj.procs.FS.LastProc+obj.procs.FS.Dur>t)  %Force Synergy Bonus Dmg
              bc=bc+0.05; 
           end
           n=it.id;
           if(it.w==0 && obj.buffs.FiB.LastUsed>=0 && obj.buffs.FiB.Charges>0 &&...
              obj.buffs.FiB.Dur+obj.buffs.FiB.LastUsed>t)
                if(strcmp(it.id,'vanquishdot')||...
                   strcmp(it.id,'forcebreach')||...
                   strcmp(it.id,'severforce'))
                    bmult=1.1;
                    obj.buffs.FiB.Charges=obj.buffs.FiB.Charges-1;
                end
           end
           

      end
      function AddDamage(obj,dmg,it)
          t=dmg{1};
          if(it.w==1 && dmg{5}==1)
              if(rand()<0.5)
                %Force Technique
                [mhd,mhh,mhc]=obj.CalculateDamage(t,obj.abilities.ft);
                AddDamage(obj,{t,obj.abilities.ft.name,mhd,mhc,mhh},it);
              end
              fos=obj.procs.FoS;
              if(t>=fos.Available);
                  fos.LastProc=t;
                  fos.Available=t+fos.CD*(1-obj.stats.Alacrity)*0.99;
                  obj.procs.FoS=fos;
                  obj.avail.vanquish=t;
              end
          end
          if(it.w==0 && dmg{5}==1 && dmg{4}==1)
              %Proc Force Synergy
              obj.procs.FS.LastProc=t;
          end
          if(it.dmg_type==3 )
          elseif(it.dmg_type==1||it.dmg_type==2)
              dmg{3}=dmg{3}*(1-CalculateBossDR(obj,it));
          end
          if(obj.total_damage<obj.total_HP)
              %if(true)
              if(dmg{4}>0)
                  obj.crits=obj.crits+1;
              end
              obj.dmg_effects=obj.dmg_effects+1;
              obj.total_damage=obj.total_damage+dmg{3};
              obj.damage{end+1}=dmg;
              AddToStats(obj,dmg);
          end
      end
        
              
%Crush Spirit check goes into the dot check

      
    end
    
end

