function traj(obj,opt)

% calculate and display fluorescent traj based on track

 if numel(obj.gfp)==0
              obj.load;
 end
          
frames=1:size(obj.track,3);

calc=0;

if nargin==2
    calc=1;
end

if numel(obj.data.fluo)==0
    calc=1;
end

if calc==1 
   obj.computefluo; % calculate obj.fluo
end

x=1:size(obj.data.fluo,1);
xdiff=1:size(obj.data.fluo,1)-1; xdiff=xdiff+1;
fluo=obj.data.fluo(:,obj.gfpchannel);
%fluodiff=obj.data.fluodiff;

fluodiff=obj.data.fluo(1:end-1);

%dn=obj.data.nucldiff;

%figure, plot(fluo)
%figure, plot(fluodiff)


h=figure('Tag',['Traj' num2str(obj.id)],'Color','w','Position',[50 50 1000 500]);
set(gca,'FontSize',20);

hp(1)=subplot(2,1,1);

if numel(obj.div.deep)>0
    deep=obj.div.deep;
else
   deep=[]; 
end

if numel(obj.div.deepCNN)>0
    deepCNN=obj.div.deepCNN;
else
   deepCNN=[]; 
end

if numel(obj.div.deepLSTM)>0
    deepLSTM=obj.div.deepLSTM;
else
   deepLSTM=[]; 
end

str={};cc=1;
if numel(deep)>0
plot(x,deep,'Color','k','LineWidth',4);  hold on 
str{cc}='Ground truth';
cc=cc+1;
end


%plot(x,teste,'Color','k','LineWidth',2); hold on;  % distance to center
if numel(deepCNN)>0
    
plot(x,deepCNN,'Color','r','LineWidth',3); hold on
str{cc}='CNN';
cc=cc+1;
end

if numel(deepLSTM)>0
plot(x,deepLSTM,'Color','g','LineWidth',2);
str{cc}='LSTM';
cc=cc+1;
end

legend(str);
xlim([0 x(end)])
%plot(x(TF),fluo(TF),'r*');

ylabel('Budding state');
set(gca,'YTick',[0 1 2],'YTickLabel',{'unbbuded','small b','large b'})

 hp(2)=subplot(2,1,2);
 
 obj.plotrls('plot','handle',hp(2));
 xlim([0 x(end)])
 
% 
% %pix=find(fluo==0);
% 
% %fluo2=fluo(fluo~=0);
% %fluo(fluo==0)=mean(fluo2);
% 
% 
% f=(1+1*dn).*fluodiff;%./fluo(1:end-1);
% 
% 
% %find(obj.div.raw)
% 
% plot(xdiff,f,'Color','k','LineWidth',2); hold on; 
% %plot(xdiff,fluodiff,'Color','k','LineWidth',2); hold on; 
% 
% plot(xdiff(obj.div.raw),f(obj.div.raw),'ro','MarkerSize',15); hold on
% plot(xdiff(obj.div.classi),f(obj.div.classi),'go','MarkerSize',15); hold on % accepted division upon classification
% plot(xdiff(obj.div.dead),f(obj.div.dead),'ko','MarkerSize',15); hold on %classified dead divisions
% plot(xdiff(obj.div.reject==1),f(obj.div.reject==1),'b.','MarkerSize',25); hold on %rejected divisions during training
% plot(xdiff(obj.div.reject==2),f(obj.div.reject==2),'c.','MarkerSize',25); hold on %dead weird divisions during training
% 
% %plot(xdiff(obj.div.raw),fluodiff(obj.div.raw),'ro','MarkerSize',15); hold on
% % plot(xdiff(obj.div.classi),fluodiff(obj.div.classi),'go','MarkerSize',15); hold on % accepted division upon classification
% % plot(xdiff(obj.div.dead),fluodiff(obj.div.dead),'yo','MarkerSize',15); hold on %classified dead divisions
% % plot(xdiff(obj.div.reject==1),fluodiff(obj.div.reject==1),'b.','MarkerSize',15); hold on %rejected divisions during training
% % plot(xdiff(obj.div.reject==2),fluodiff(obj.div.reject==2),'c.','MarkerSize',15); hold on %dead weird divisions during training
% 
% xlim([0 x(end)])
% 
% %ylim([-1 2])
% 
% % if numel(xdiff(obj.div.reject))>0
% % hreject.Tag=['Rejectplot' num2str(obj.id)];
% % end
% 
% hl=line([obj.frame obj.frame],[min(f) max(f)],'Color','b','LineStyle','-','LineWidth',2);
% set(hl,'Tag',['Trajline' num2str(obj.id)]);
% 
% hs=line([obj.div.stop obj.div.stop],[min(f) max(f)],'Color','m','LineStyle','-','LineWidth',2);
% set(hs,'Tag',['Stopline' num2str(obj.id)]);
% 
% 
% %hl.YData
% 
% xlabel('Time (frames)');
% ylabel('Diff fluo (A.U.)');
% 
% title('Left click to display raw data, right click to mark as false division');
% 
% hp(3)=subplot(7,1,3);
% 
% xx=xdiff(obj.div.classi);
% 
% y=diff(xx);
% xx=xx(2:end);
% 
% plot(xx,y,'Color','k','LineWidth',2,'Marker','o'); hold on; 
% 
% xlabel('Time (frames)');
% ylabel('Division time (frames)');
% 
% xlim([0 x(end)])
% 
% hp(4)=subplot(7,1,4);
% 
% %plot(xdiff,de,'Color','k','LineWidth',2); hold on; 
% 
% %fluophase=obj.data.fluo(:,obj.phasechannel);
% %plot(x,fluophase,'Color','k','LineWidth',2); hold on; 
% 
% fluophase=obj.data.phc;
% 
%  for k=1:4
%      fluophase(:,k)=fluophase(:,k)./max(abs(fluophase(:,k)));
%  end
% 
% plot(x,fluophase(:,1),'Color','r','LineWidth',2); hold on; 
% plot(x,fluophase(:,2),'Color','b','LineWidth',2); hold on;
% plot(x,fluophase(:,3),'Color','g','LineWidth',2); hold on;
% plot(x,fluophase(:,4),'Color','m','LineWidth',2); hold on;
% 
% %plot(frames(1:end-1),dn.*,'Color','k','LineWidth',2); hold on; 
% 
% xlabel('Time (frames)');
% ylabel('Custom');
% xlim([0 x(end)])
% %ylim([-100000 100000])
% %ylim([0 1])
% 
% hp(5)=subplot(7,1,5);
% 
% 
% % g1=20;
% % g2=20;
% % xpat=0:g1+g2+2;
% % 
% % ypat=ones(size(xpat));
% % ypat(1:g1+1)=1;
% % ypat(g1+2:g1+g2+1)=1+(1:g2)./g2;
% % ypat(g1+g2+2)=1;
% % ypat(g1+g2+2+1)=1;
% % %ypat=ypat-1;
% % 
% % %figure, plot(xpat,ypat,'Marker','o');
% % %return;
% % 
% % test=normxcorr2(ypat,fluo);
% % 
% % plot(1:numel(test),test,'Color','k','LineWidth',2); hold on; 
% 
% % warning off all
% 
% motion= obj.data.motion;
% dn= obj.data.nucldiff;
% incavity=obj.data.incavity;
% 
% plot(xdiff,dn,'Color','r','LineWidth',2); hold on;
% plot(xdiff,motion,'Color','k','LineWidth',2); hold on; 
% plot(x,incavity,'Color','b','LineWidth',2); hold on; 
% 
% % warning on all
% 
% xlabel('Time (frames)');
% ylabel('Eccentricity');
% xlim([0 x(end)])
% 
% 
% hp(6)=subplot(7,1,6);
% 
% 
% plot(x(1:length(obj.data.cv)),obj.data.cv,'Color','g','LineWidth',2); hold on; 
% 
% plot(x,obj.data.dist,'Color','b','LineWidth',2); hold on; 
% 
% plot(x,obj.data.isfirst,'Color','r','LineWidth',2); hold on;
% %obj.plotrls(hp(6),1);
% 
% xlim([0 x(end)])
% ylim([0 5])
% 
% 
% hp(7)=subplot(7,1,7);
% obj.plotrls('plot','handle',hp(7));
% 
% xlim([0 x(end)])

set(h,'WindowButtonDownFcn',{@wbdcb,xdiff,fluodiff,obj.div.raw,obj.div.classi});

h.KeyPressFcn={@changeframe,obj};


function changeframe(handle,event,obj)

ok=0;

% if strcmp(event.Key,'uparrow')
% val=str2num(handle.Tag(5:end));
% han=findobj(0,'tag','movi')
% han.trap(val-1).view;
% delete(handle);
% end

if strcmp(event.Key,'rightarrow')
    if obj.frame+1>size(obj.gfp,3)
    return;
    end

    obj.view(obj.frame+1);
    hl=findobj('Tag',['Trajline' num2str(obj.id)]);
    if numel(hl)>0
    hl.XData=[obj.frame obj.frame];
    end
   % ok=1;
end

if strcmp(event.Key,'leftarrow')
    if obj.frame-1<1
    return;
    end

    obj.view(obj.frame-1);
    hl=findobj('Tag',['Trajline' num2str(obj.id)]);
    if numel(hl)>0
    hl.XData=[obj.frame obj.frame];
    end
    %ok=1;
end

if strcmp(event.Key,'l') % move left to previous division
     
    if numel(obj.div.raw)>0
    pix=find(obj.div.raw(1:obj.frame-2)==1,1,'last');
    
    if numel(pix)
        
        obj.frame=pix+1;
        
        obj.view(obj.frame);
    hl=findobj('Tag',['Trajline' num2str(obj.id)]);
    if numel(hl)>0
    hl.XData=[obj.frame obj.frame];
    end
    
    end
    
    ok=1;
    end
 end
 if strcmp(event.Key,'m') % move right to next division
     
    if numel(obj.div.raw)>0
    pix=find(obj.div.raw(obj.frame+1:end)==1,1,'first');
    
    if numel(pix)
        obj.frame=pix+obj.frame+1;
        
        obj.view(obj.frame);
    hl=findobj('Tag',['Trajline' num2str(obj.id)]);
    if numel(hl)>0
    hl.XData=[obj.frame obj.frame];
    end
    
    end
    
    ok=1;
    end
 end


    
%     if strcmp(event.Key,'r') % reject divisions
%     if obj.frame>1
%        % 'ok'
%         if obj.div.raw(obj.frame-1)==1 % putative division
%           %  'ok'
%             if obj.div.reject(obj.frame-1)==0 % frame is not rejected
%              %   'ok'
%                 obj.div.reject(obj.frame-1)=1;
%                 
% %                 hreject=findobj('Tag',['Rejectplot' num2str(obj.id)]);
% %                 hraw=findobj('Tag',['Rawplot' num2str(obj.id)]);
% %                 hreject.XData=[hreject.XData obj.frame-1];
% %                 hreject.YData=[hreject.YData hraw.YData(obj.frame-1)];
%             else
%                 obj.div.reject(obj.frame-1)=0;
%                 
%                 %hreject=findobj('Tag',['Rejectplot' num2str(obj.id)]);
%                 %hraw=findobj('Tag',['Rawplot' num2str(obj.id)]);
%                 
% %                 pix=find(hreject.XData==obj.frame-1);
% %                 
% %                 hreject.XData=hreject.XData( setxor(1:length(hreject.XData),pix));
% %                 hreject.YData=hreject.YData( setxor(1:length(hreject.YData),pix));
%             end
%             
%             hr=findobj('Tag',['Traj' num2str(obj.id)]);
%             if numel(hr)>0
%             delete(hr);
%             end
%             
%             obj.traj;
%            %  h=findobj('Tag',['Trap' num2str(obj.id)]);
%            % figure(h);
%         end
%     end
%     ok=1;
%     end
    
     if strcmp(event.Key,'r') || strcmp(event.Key,'d' ) % reject divisions
    if obj.frame>1
       % 'ok'
        if obj.div.raw(obj.frame-1)==1 % putative division
          %  'ok'
            if obj.div.reject(obj.frame-1)==0 % frame is not rejected
             %   'ok'
             
             if strcmp(event.Key,'r')
                obj.div.reject(obj.frame-1)=1;
             else
                obj.div.reject(obj.frame-1)=2; 
             end
                
%                 hreject=findobj('Tag',['Rejectplot' num2str(obj.id)]);
%                 hraw=findobj('Tag',['Rawplot' num2str(obj.id)]);
%                 hreject.XData=[hreject.XData obj.frame-1];
%                 hreject.YData=[hreject.YData hraw.YData(obj.frame-1)];
            else
                obj.div.reject(obj.frame-1)=0;
                
                %hreject=findobj('Tag',['Rejectplot' num2str(obj.id)]);
                %hraw=findobj('Tag',['Rawplot' num2str(obj.id)]);
                
%                 pix=find(hreject.XData==obj.frame-1);
%                 
%                 hreject.XData=hreject.XData( setxor(1:length(hreject.XData),pix));
%                 hreject.YData=hreject.YData( setxor(1:length(hreject.YData),pix));
            end
            
            hr=findobj('Tag',['Traj' num2str(obj.id)]);
            if numel(hr)>0
            delete(hr);
            end
            
            obj.traj;
           %  h=findobj('Tag',['Trap' num2str(obj.id)]);
           % figure(h);
        end
    end
    ok=1;
     end
     
     if strcmp(event.Key,'s') % stop training at given frame
        if obj.frame==obj.div.stop
            obj.div.stop=size(obj.gfp,3);
        else
            obj.div.stop=obj.frame;
        end
        
        hl=findobj('Tag',['Stopline' num2str(obj.id)]);
            if numel(hl)>0
                hl.XData=[obj.div.stop obj.div.stop];
            end
            
        ok=1;
     end
    
    
end


function wbdcb(src,callbackdata,x,y,TF,TC)
     seltype = src.SelectionType;
   
     tmp=x(TF);
     
     if strcmp(seltype,'normal')
       % src.Pointer = 'circle';
        cp = hp(2).CurrentPoint;
       
        xinit = cp(1,1);
       % x
        yinit = cp(1,2);
        
        [d,idx] = min(abs(tmp-xinit));
        
        if d<10
       
         
        obj.view(tmp(idx));
        
        hl=findobj('Tag',['Trajline' num2str(obj.id)]);
        if numel(hl)>0
        hl.XData=[obj.frame obj.frame];
        end
            
        %plot(hp(2),x(idx),y(idx),'g*');
        end
     end
     
     if strcmp(seltype,'alt')
       % src.Pointer = 'circle';
        cp = hp(2).CurrentPoint;
       
        xinit = cp(1,1);
       % x
        yinit = cp(1,2);
        
        [d,idx] = min(abs(tmp-xinit));

        if d<10 % cursor must be less than 10 frames away from division position 
            
           % tmp(idx)
        if obj.div.reject(tmp(idx))==1
            obj.div.reject(tmp(idx))=0;
        else
            obj.div.reject(tmp(idx))=1;
        end

       % class(TF), class(obj.div.reject)
        
        plot(hp(2),x(TF),y(TF),'r*'); hold on;
        plot(hp(2),x(TC),y(TC),'g*'); hold on;
        plot(hp(2),x(obj.div.reject==1),y(obj.div.reject==1),'b*');
        end
     end
     
 end
end
     
     






