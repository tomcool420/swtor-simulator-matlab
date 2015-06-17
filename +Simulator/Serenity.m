classdef Serenity < Simulator.Shadow
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
          if(obj.autocrit_last_proc+60/(1+obj.stats.Alacrity)<obj.nextCast || obj.autocrit_last_proc<0)
               obj.autocrit_last_proc=obj.nextCast;
               obj.autocrit_proc_duration=30;
               obj.autocrit_charges=1;
               %fprintf('autocrit procced %0.2f\n',obj.nextCast);
           end
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

      function [bd, bc, bs,bmult]=CalculateBonus(obj,t,it,mhh,ohh)
          %[bd, bc, bs,bmult]=CalculateBonus@Simulator.Shadow(obj,t,it,mhh,ohh);
          bd=0;bc=0;bs=0;bmult=1;
          if(obj.buffs.FP.Charges>0 && obj.buffs.FP.LastUsed+obj.buffs.FP.Dur>t )
              if(it.w==0 && (it.ctype==1 || it.ctype==2 || it.ctype==3))
                  bc=0.6;
                  obj.LastFPChargeUsed=t;
                  obj.buffs.FP.Charges=obj.buffs.FP.Charges-1;
              end
              
          end
           if(it.w==1 && obj.procs.FS.LastProc+obj.procs.FS.Dur>t)  %Force Synergy Bonus Dmg
              bc=bc+0.05; 
           end
           n=it.id;
           if(it.w==0 && obj.buffs.FiB.LastUsed>=0 && obj.buffs.FiB.Charges>0 &&...
              obj.buffs.FiB.Dur+obj.buffs.FiB.LastUsed>t)
                if(strcmp(it.id,'vanquishdot')||...
                   strcmp(it.id,'forcebreach')||...
                   strcmp(it.id,'severforce'))
                    bmult=bmult*1.1;
                    obj.buffs.FiB.Charges=obj.buffs.FiB.Charges-1;
                end
           end
           if(strcmp(it.id,'forcetech')&& ...
              obj.buffs.BR.LastUsed>=0 && t<obj.buffs.BR.Dur+obj.buffs.BR.LastUsed)
               bmult=bmult*1.25;
           end
           

      end
      
       function DOTCheckCB(obj,t,it,dot)
            %Callback right AFTER a dot has ticked and the damage is
            %applied (used for double tick dart in virulence)
            if(obj.procs.CS.Available < t)
                if(rand() < 0.3)
                    obj.procs.CS.Available=t+obj.procs.CS.CD/(1+obj.stats.Alacrity);
                    obj.procs.CS.LastProc=t;
                    obj.avail.sps=t;
                end
            end
       end
       function SESCallback(obj,t,~)
           if(obj.stats.pc2 &&(t>=(obj.procs.PC2.Available) ...
                   || obj.procs.PC2.LastProc<0))
               obj.procs.PC2.LastProc=t;
               obj.procs.PC2.Available=t+obj.procs.PC2.CD/(1+obj.stats.Alacrity)*0.99;
           end
           
       end
       function bonuspen = CalculateBonusPen(~,~,~)
            %Right before DR is calculated, check for bonus armor pen 
            %only use for cooldowns (illegal mods or target acquired
            bonuspen=0;
        end
        function AddDamageCB(obj,t,dmg,it)
            %"CallBack" (not) called right before the damage is applied
            %A good time to either proc on hit abilities (force technique) 
            %or on hit procs (force synergy)

            if(it.w==1)% && dmg{5}==1)
                r=rand();
                nm=it.name;
                
                BRU=obj.buffs.BR.LastUsed>=0 && t<=obj.buffs.BR.Dur+obj.buffs.BR.LastUsed;
                BRC=(r<0.75 && BRU);
                av=obj.procs.FT.Available;
                if((r<0.75 && t>=obj.procs.FT.Available)|| BRC)
                    %Force Technique
                    %fprintf('%s procced force technique',dmg{2});
                    [mhd,mhh,mhc]=obj.CalculateDamage(t,obj.abilities.ft);
                    AddDamage(obj,{t,obj.abilities.ft.name,mhd,mhc,mhh},obj.abilities.ft);
                    if(BRU)
                        tn=t;
                    else
                        tn=t+obj.procs.FT.CD/(1+obj.stats.Alacrity)*0.9;
                    end
                    obj.procs.FT.Available=tn;%+obj.procs.FT.CD/(1+obj.stats.Alacrity);
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
        end
        
        function bacc=CalculateBonusAccuracy(obj,t,it) 
            %Check if you have an accuracy debuff up;
            bacc=0;
        end

              
%Crush Spirit check goes into the dot check

      
    end
    
end

