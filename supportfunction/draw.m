function [him hp]=draw(obj,h,classif)

% function used to draw ROIs
% obj is an roi , h is a figure handle n which to draw it
%this function is called by the roi view() method

% updates number of channel if userTraining mode is on.

if nargin<3
    classif=[];
    % refresh='full';
end
% if nargin<4
%     refresh='full';
% end

if numel(classif)>0
    if strcmp(classif.category{1},'Pixel') % display properties for pixel classification
        
        % first create a decidated channel in the image matrix for pixel
        % classification if it is not exisiting
        
        %pix=find(classif.roi(i).channelid==classif.channel);
        
        %[pth fle ex]=fileparts(obj.path); % get the name of the current classification process
        % change here to use the reference to the classif being used
        
%         pix = strfind(obj.display.channel, classif.strid);
%         
%         cc=[];
%         for i=1:numel(pix)
%             if numel(pix{i})~=0
%                 cc=i;
%                 
%                 break
%             end
%         end
%         
%         pixelchannel=i;
        
        cc=obj.findChannelID(classif.strid);
         
        if numel(cc)==0 % create new empty array for user training (painting)
            matrix=uint16(zeros(size(obj.image,1),size(obj.image,2),1,size(obj.image,4)));
            obj.addChannel(matrix,classif.strid,[1 1 1],[0 0 0]);
            
            pixelchannel=size(obj.image,3);
            %else
            
        else
            pixelchannel=cc;  
        end
        
        
        
    end
end


% create display menu %

handles=findobj('Tag','DisplayMenu');

if numel(handles)==0
    m = uimenu(h,'Text','Display','Tag','DisplayMenu');
    mitem=[];
    
    for i=1:numel(obj.display.channel)
        mitem(i) = uimenu(m,'Text',obj.display.channel{i},'Checked','on','Tag',['channel_' num2str(i)]);
        set(mitem(i),'MenuSelectedFcn',{@displayMenuFcn,obj,h,classif});
        
        if obj.display.selectedchannel(i)==1
            set(mitem(i),'Checked','on');
        else
            set(mitem(i),'Checked','off');
        end
    end
end

% find channel to be displayed
cd=0;
for i=1:numel(obj.display.channel)
    if obj.display.selectedchannel(i)==1
        cd=cd+1;
    end
end

% build display image object

im=buildimage(obj);

% display corresponding axes

cc=1;
him=[];
hp=[];

pos=h.Position;

if numel(classif)>0
    cmap=classif.colormap; % by defulat, 10 colors available
end

for i=1:numel(obj.display.channel)
    
    if obj.display.selectedchannel(i)==1
        figure(h);
        hp(cc)=subplot(1,cd,cc);
        
        dis=0;
        % pixelchannel
        if numel(classif)>0
            if strcmp(classif.category{1},'Pixel') % display user training and results
                % pixelchannel
                if i==pixelchannel
                    dis=1;
                end
            end
        end
        
        if sum(obj.display.intensity(i,:))==0 % A TESTER !!!
           dis=1;
           cmap=lines(10);
        end
        
        % dis
        
        if dis==0
            him.image(cc)=imshow(im(cc).data);
        else
            
            him.image(cc)=imshow(im(cc).data,cmap);
           % 'ok'
            %return;
        end
        
        set(hp(cc),'Tag',['AxeROI' num2str(cc)]);
        
        set(hp(cc),'UserData',obj.display.channel{i});
        
        %axis equal square
   %     tt=obj.display.intensity(i,:);
        
%         if numel(classif)==0
%             title(hp(cc),[obj.display.channel{i} ]); %' -Intensity:' num2str(tt)]);
%         end
        
        cc=cc+1;
    end
end

if cd>0
    linkaxes(hp);
end

h.Position(1:2)=pos(1:2);
h.Position(3)=800;
h.Position(4)=800;

h.UserData=him;

% reset mouse interaction function
h.WindowButtonDownFcn='';
h.Pointer = 'arrow';
h.WindowButtonMotionFcn = '';
h.WindowButtonUpFcn = '';


% add buttons and fcn to chanfe frame
keys={'a' 'z' 'e' 'r' 't' 'y' 'u' 'i' 'o' 'p'};
h.KeyPressFcn={@changeframe,obj,him,hp,keys,classif};

handles=findobj('Tag','frametexttitle');
if numel(handles)==0
    btnSetFrame = uicontrol('Style', 'text','FontSize',14, 'String', 'Enter frame number here, or use arrows <- ->',...
        'Position', [50 50 300 20],'HorizontalAlignment','left', ...
        'Tag','frametexttitle') ;
end

handles=findobj('Tag','frametext');
if numel(handles)==0
    btnSetFrame = uicontrol('Style', 'edit','FontSize',14, 'String', num2str(obj.display.frame),...
        'Position', [50 20 80 20],...
        'Callback', {@setframe,obj,him,hp,classif},'Tag','frametext') ;
else
    handles.Callback=  {@setframe,obj,him,hp,classif};
    handles.String=num2str(obj.display.frame);
end

% create training specific menus and graphics
% training classes menu

% display user classification status
if numel(classif)>0
    
    if strcmp(classif.category{1},'Image')  || strcmp(classif.category{1},'LSTM') % display user training and results
        if numel(obj.train)==0 % new roi , training not yet used
            obj.train.(classif.strid)=[];
            obj.train.(classif.strid).id=zeros(1,size(obj.image,4));
        end
        
%         if obj.train(obj.display.frame)==0 % user training
%             str='not classified';
%             colo=[0 0 0];
%             
%         else
%             str= obj.classes{obj.train(obj.display.frame)};
%             colo=cmap(obj.train(obj.display.frame),:);
%         end
        
        
%         cc=1;
%         for i=1:numel(obj.display.channel)
%             if obj.display.selectedchannel(i)==1
%                 tt=hp(cc).Title.String;
%                 hp(cc).Title.String=[tt ' - ' str ' (training)'];
%                 %title(hp(cc),str, 'Color',colo,'FontSize',20);
%                 cc=cc+1;
%             end
%         end
    end
    
    if strcmp(classif.category{1},'Pixel') % display the axis associated with user training to paint on the channel
        
%         pix = strfind(obj.display.channel, classif.strid);
%         cc=[];
%         for i=1:numel(pix)
%             if numel(pix{i})~=0
%                 cc=i;
%                 
%                 break
%             end
%         end
        
        cc=obj.findChannelID(classif.strid);
        
        if numel(cc)
            if obj.display.selectedchannel(i)==1
                cha1= classif.channel; % axes where to copy the new axes
                cha1pos=get(hp(cha1),'Position');
                hcopy=findobj(hp,'UserData',classif.strid);
                
                htmp = copyobj(hcopy,h);
                htmp.Position=cha1pos;
                set(htmp,'Tag',classif.strid);
                axes(htmp);
                alpha(0.7);
            end
        end
        
    end
    
    handles=findobj('Tag','TrainingClassesMenu');
    
    if numel(handles)~=0
        delete(handles)
    end
    
    m = uimenu(h,'Text',[classif.category{1} 'Training Classes'],'Tag','TrainingClassesMenu');
    mitem=[];
    
    for i=1:numel(obj.classes)
        mitem(i) = uimenu(m,'Text',obj.classes{i},'Checked','off','Tag',['classes_' num2str(i)],'ForegroundColor',cmap(i,:),'Accelerator',keys{i});
        
        if strcmp(classif.category{1},'Pixel') % only in pixel mode
            hpaint=findobj('Tag',classif.strid); % if the painting axe is displayed
            if numel(hpaint)~=0
                set(mitem(i),'MenuSelectedFcn',{@classesMenuFcn,h,obj,hpaint.Children(1),hcopy.Children(1),hpaint,classif});
                
            end
        end
        
        %     if obj.display.selectedchannel(i)==1
        %         set(mitem(i),'Checked','on');
        %     else
        %         set(mitem(i),'Checked','off');
        %     end
    end
    %end
    
end


% display results for image classification

 cc=1;
        for i=1:numel(obj.display.channel)
            if obj.display.selectedchannel(i)==1
                str=obj.display.channel{i};
                
                if numel(obj.train)>0
                   fields=fieldnames(obj.train);
                   
                    for k=1:numel(fields)
                        tt=obj.train.(fields{k}).id(obj.display.frame);
                        
                        if tt==0
                            tt='not classified';
                        else
                            tt=obj.classes{tt};  
                        end
                        str=[str ' - ' tt ' (training: ' fields{k} ')'];
                        
%                         if obj.train(obj.display.frame)==0
%                             str=[str ' - not classified'];
%                     %title(hp(cc),str, 'Color',[0 0 0],'FontSize',20);
%                         else
%                             str= [str ' - ' obj.classes{obj.train(obj.display.frame)} ' (training)'];
%                     %title(hp(cc),str, 'Color',cmap(obj.train(obj.display.frame),:),'FontSize',20);
%                         end
                    end
                
                end
                
               % str=hp(cc).Title.String;
               
                if numel(obj.results)>0
                pl = fieldnames(obj.results);
                %aa=obj.results
                for k = 1:length(pl)
                    tt=char(obj.results.(pl{k}).labels(obj.display.frame));
                    str=[str ' - ' tt ' (' pl{k} ')'];
                end
                end
                
                %test=get(hp(cc),'Parent')
                title(hp(cc),str,'FontSize',14,'interpreter','none');
                %title(hp(cc),str, 'Color',colo,'FontSize',20);
                cc=cc+1;
            end
            end
end



function classesMenuFcn(handles, event, h,obj,impaint1,impaint2,hpaint,classif)

if strcmp(handles.Checked,'off')
    
    for i=1:numel(classif.classes)
        ha=findobj('Tag',['classes_' num2str(i)]);
        
        if numel(ha)
            ha.Checked='off';
        end
    end
    
    handles.Checked='on';
    %aa=handles.Tag
    %str=replace(handles.Tag,'classes_','');
    %colo=str2num(str);
    
    
    % set pixel painting mode
    
    set(h,'WindowButtonDownFcn',@wbdcb);
    
    %ah = hp(1); %axes('SortMethod','childorder');
else
    
    handles.Checked='off';
    str=handles.Tag;
    
    h.WindowButtonDownFcn='';
    h.Pointer = 'arrow';
    h.WindowButtonMotionFcn = '';
    h.WindowButtonUpFcn = '';
    figure(h); % set focus
    
end

%[him hp]=draw(obj,h,classif);

% nested function, good luck ;-) ....
    function wbdcb(src,cbk)
        seltype = src.SelectionType;
        
        if strcmp(seltype,'normal')
            src.Pointer = 'circle';
            cp = hpaint.CurrentPoint;
            
            xinit = cp(1,1);
            yinit = cp(1,2);
            
            % hl = line('XData',xinit,'YData',yinit,...
            % 'Marker','p','color','b');
            src.WindowButtonMotionFcn = {@wbmcb,1};
            src.WindowButtonUpFcn = @wbucb;
            
        end
        if strcmp(seltype,'alt')
            src.Pointer = 'circle';
            cp = hpaint.CurrentPoint;
            xinit = cp(1,1);
            yinit = cp(1,2);
            % hl = line('XData',xinit,'YData',yinit,...
            % 'Marker','p','color','b');
            src.WindowButtonMotionFcn = {@wbmcb,2};
            src.WindowButtonUpFcn = @wbucb;
            
        end
        
        
        function wbmcb(src,event,bsize)
            cp = hpaint.CurrentPoint;
            % For R2014a and earlier:
            % cp = get(ah,'CurrentPoint');
            
            %xdat = [xinit,cp(1,1)]
            %ydat = [yinit,cp(1,2)]
            if bsize==1 % fine brush
                xdat = [cp(1,1) ];
                ydat = [cp(1,2) ];
            else % large brush
                
                
                xdat = [cp(1,1) cp(1,1)+1 cp(1,1)-1 cp(1,1)+1 cp(1,1)-1 cp(1,1) cp(1,1) cp(1,1)+1 cp(1,1)-1];
                ydat = [cp(1,2) cp(1,2)+1 cp(1,2)-1 cp(1,2)-1 cp(1,2)+1 cp(1,2)+1 cp(1,2)-1 cp(1,2) cp(1,2)];
            end
            
            % enlarge pixel size
            
            %hl.XData = xdat;
            %hl.YData = ydat;
            % For R2014a and earlier:
            % set(hl,'XData',xdat);
            % set(hl,'YData',ydat);
            
            % interpolate results
            
            finalX=round(xdat);
            finalY=round(ydat);
            
            % size(obj.image)
            
            in=finalX<=size(obj.image,2) & finalY<=size(obj.image,1) & finalX>0 & finalY>0;
            
            finalX=finalX(in);
            finalY=finalY(in);
            
            % finalX
            % finalY
            
            % find the right color
            hmenu = findobj('Tag','TrainingClassesMenu');
            hclass=findobj(hmenu,'Checked','on');
            strcolo=replace(hclass.Tag,'classes_','');
            colo=str2num(strcolo);
            
            if numel(finalX)>=0
                
                %imtemp=imobj.CData;
                
                sz=size(obj.image);
                sz=sz(1:2);
                
                % size(imtemp)
                % int32(finalY)
                % int32(finalX)
                %colortype*ones(1,length(finalX));
                
                linearInd = sub2ind(sz, int32(finalY), int32(finalX));%,1*ones(1,length(finalX)));
                impaint1.CData(linearInd)=colo-1;
                impaint2.CData(linearInd)=colo-1;
                
                
                % dave data in obj.image object
                
%                 pix = strfind(obj.display.channel, classif.strid);
%                 
%                 %                first find the right channel
%                 cc=[];
%                 for k=1:numel(pix)
%                     if numel(pix{k})~=0
%                         cc=k;
%                         
%                         break
%                     end
%                 end
                
                pixelchannel=obj.findChannelID(classif.strid);
                pix=find(obj.channelid==pixelchannel);
                
                obj.image(:,:,pix,obj.display.frame)=impaint2.CData;
                
                drawnow
            end
        end
        
        function wbucb(src,callbackdata)
            last_seltype = src.SelectionType;
            % For R2014a and earlier:
            % last_seltype = get(src,'SelectionType');
            %if strcmp(last_seltype,'alt')
            src.Pointer = 'arrow';
            src.WindowButtonMotionFcn = '';
            src.WindowButtonUpFcn = '';
            % For R2014a and earlier:
            % set(src,'Pointer','arrow');
            % set(src,'WindowButtonMotionFcn','');
            % set(src,'WindowButtonUpFcn','');
            % else
            %    return
            %end
        end
    end

end



function displayMenuFcn(handles, event, obj,h,classif)

if strcmp(handles.Checked,'off')
    handles.Checked='on';
    str=handles.Tag;
    i = str2num(replace(str,'channel_',''));
    obj.display.selectedchannel(i)=1;
    % aa=obj.display.selectedchannel(i)
else
    
    handles.Checked='off';
    str=handles.Tag;
    i = str2num(replace(str,'channel_',''));
    obj.display.selectedchannel(i)=0;
    %  bb=obj.display.selectedchannel(i)
end

[him hp]=draw(obj,h,classif);
end

function updatedisplay(obj,him,hp,classif)

% list=[];
% for i=1:numel(obj.display.settings)
%     handles=findobj('Tag',['channel_' num2str(i)]);
%     if strcmp(handles.Checked,'on')
%         list=[list i];
%     end
% end

im=buildimage(obj);

% need to update the painting window here hpaint.Children(1).CData...


cc=1;
for i=1:numel(obj.display.channel)
    if obj.display.selectedchannel(i)==1
        him.image(cc).CData=im(cc).data;
        
        % title(hp(i),['Channel ' num2str(i) ' -Intensity:' num2str(obj.display.intensity(i))]);
        %tt=obj.display.intensity(i,:);
        
        %title(hp(cc),[obj.display.channel{i} ' -Intensity:' num2str(tt)]);
        cc=cc+1;
    end
end



if numel(classif)>0
    cmap=classif.colormap;
    
    if strcmp(classif.category{1},'Pixel')
        htmp=findobj('Tag',classif.strid);
        hpt=findobj(hp,'UserData',classif.strid);
        
        if numel(htmp) && numel(hpt)
            htmp.Children(1).CData=hpt.Children(1).CData; % updates data on the painting window
        end
        
    end
    
%     if strcmp(classif.category{1},'Image') || strcmp(classif.category{1},'LSTM')
%         cc=1;
%         for i=1:numel(obj.display.channel)
%             if obj.display.selectedchannel(i)==1
%                 str='';
%                 if obj.train(obj.display.frame)==0
%                     str='not classified';
%                     title(hp(cc),str, 'Color',[0 0 0],'FontSize',20);
%                 else
%                     str= obj.classes{obj.train(obj.display.frame)};
%                     title(hp(cc),str, 'Color',cmap(obj.train(obj.display.frame),:),'FontSize',20);
%                 end
%                 
%                 cc=cc+1;
%             end
%         end
%     end
end

% display results for image classification

 cc=1;
        for i=1:numel(obj.display.channel)
            if obj.display.selectedchannel(i)==1
                str=obj.display.channel{i};
                
                                 if numel(obj.train)>0
                   fields=fieldnames(obj.train);
                   
                    for k=1:numel(fields)
                        tt=obj.train.(fields{k}).id(obj.display.frame);
                        
                        if tt==0
                            tt='not classified';
                        else
                            tt=obj.classes{tt};  
                        end
                        str=[str ' - ' tt ' (training: ' fields{k} ')'];
                        
%                         if obj.train(obj.display.frame)==0
%                             str=[str ' - not classified'];
%                     %title(hp(cc),str, 'Color',[0 0 0],'FontSize',20);
%                         else
%                             str= [str ' - ' obj.classes{obj.train(obj.display.frame)} ' (training)'];
%                     %title(hp(cc),str, 'Color',cmap(obj.train(obj.display.frame),:),'FontSize',20);
%                         end
                    end
                
                end
                
               % str=hp(cc).Title.String;
               
                if numel(obj.results)>0
                pl = fieldnames(obj.results);
                %aa=obj.results
                for k = 1:length(pl)
                    tt=char(obj.results.(pl{k}).labels(obj.display.frame));
                    str=[str ' - ' tt ' (' pl{k} ')'];
                end
                end
                
                title(hp(cc),str,'FontSize',14,'interpreter','none');
                %title(hp(cc),str, 'Color',colo,'FontSize',20);
                cc=cc+1;
            end
        end



htext=findobj('Tag','frametext');
htext.String=num2str(obj.display.frame);

% if classif result is displayed, then update the position of the cursor

htraj=findobj('Tag',['Traj' num2str(obj.id)]);
if numel(htraj)~=0
    hl=findobj(htraj,'Tag','track');
    if numel(hl)>0
    hl.XData=[obj.display.frame obj.display.frame];
    end
end

%return;
%axes(hp(1));

end

function im=buildimage(obj)

% outputs a structure containing all displayed images
im=[];
im.data=[];

frame=obj.display.frame;

cc=1;
for i=1:numel(obj.display.channel)
    
    if obj.display.selectedchannel(i)==1
        
        % get the righ data: there may be several matrices for one single
        % channel in case of RGB images
        
        pix=find(obj.channelid==i);
        src=obj.image;
        
        % for each channel perform normalization
        %pix
        if numel(pix)==1 % single channel to display
            %pix
            tmp=src(:,:,pix,:);
            meangfp=0.3*double(mean(tmp(:)));
            % pix,i
            it=mean(obj.display.intensity(i,:));
            
            maxgfp=double(meangfp+1*it*(max(tmp(:))-meangfp));
            
            if maxgfp==0
                maxgfp=1;
            end
            % frame
            % size(obj.image)
            imout=obj.image(:,:,pix,frame);
            
            if it~=0 % it=0 corresponds to binary or indexed images
                imout=imadjust(imout,[meangfp/65535 maxgfp/65535],[0 1]);
                
                
                % imout=mat2gray(imout,[meangfp maxgfp]);
                
                % imout =repmat(imout,[1 1 3]);
                % for k=1:3
                %     imout(:,:,k)=imout(:,:,k).*obj.display.rgb(i,k);
                % end
            end
            
            
        else
            %'ok'
            imout=uint16(zeros(size(obj.image,1),size(obj.image,2),3));
            
            % size(imout)
            %i
            
            for j=1:numel(pix)
                % i,j,pix(j)
                tmp=src(:,:,pix(j),:);
                meangfp=0.5*double(mean(tmp(:)));
                it=obj.display.intensity(i,j);
                maxgfp=double(meangfp+it*(max(tmp(:))-meangfp));
                if maxgfp==0
                    maxgfp=1;
                end
                imtemp=obj.image(:,:,pix(j),frame);
                %size(imtemp)
                if meangfp>0 && maxgfp>0
                    imtemp = imadjust(imtemp,[meangfp/65535 maxgfp/65535],[0 1]);
                end
                imout(:,:,j)=imtemp.*obj.display.rgb(i,j);
            end
        end
        im(cc).data=imout;
        cc=cc+1;
    end
    
    %   cc=cc+1;
end

end


function setframe(handle,event,obj,him,hp,classif )

frame=str2num(handle.String);

if frame<=size(obj.image,4) & frame > 0
    obj.display.frame=frame;
    updatedisplay(obj,him,hp,classif)
end
end


function changeframe(handle,event,obj,him,hp,keys,classif)

ok=0;
h=findobj('Tag',['ROI' obj.id]);

% if strcmp(event.Key,'uparrow')
% val=str2num(handle.Tag(5:end));
% han=findobj(0,'tag','movi')
% han.trap(val-1).view;
% delete(handle);
% end

if strcmp(event.Key,'rightarrow')
    if obj.display.frame+1>size(obj.image,4)
        return;
    end
    
    obj.display.frame=obj.display.frame+1;
    frame=obj.display.frame+1;
    ok=1;
end

if strcmp(event.Key,'leftarrow')
    if obj.display.frame-1<1
        return;
    end
    
    obj.display.frame=obj.display.frame-1;
    frame=obj.display.frame-1;
    ok=1;
end

if strcmp(event.Key,'uparrow') % TO BE IMPLEMENTED
    
    %obj.display.intensity(obj.display.selectedchannel)=max(0.01,obj.display.intensity(obj.display.selectedchannel)-0.01);
    ok=1;
end

if strcmp(event.Key,'downarrow') % TO BE IMPLEMENTED
    % obj.display.intensity(obj.display.selectedchannel)=min(1,obj.display.intensity(obj.display.selectedchannel)+0.01);
    ok=1;
end

for i=1:numel(keys) % display the selected class for the current image
    if i>numel(obj.classes)
        break
    end
    
    if strcmp(event.Key,keys{i})
        if  strcmp(classif.category{1},'Image') || strcmp(classif.category{1},'LSTM')% if image classification, assign class to keypress event
            obj.train.(classif.strid).id(obj.display.frame)=i;
            ok=1;
        end
        
        if strcmp(classif.category{1},'Pixel') % for pixel classification enable painting function for the given class
            
            for j=1:numel(classif.classes)
                ha=findobj('Tag',['classes_' num2str(j)]);
                if numel(ha)
                    if j~=i
                        ha.Checked='off';
                    else
                        ha.Checked='on';
                        %draw(obj,h);
                    end
                end
            end
        end
        
        
    end
    
    
    
    
end

if ok==1
    updatedisplay(obj,him,hp,classif)
end
end

