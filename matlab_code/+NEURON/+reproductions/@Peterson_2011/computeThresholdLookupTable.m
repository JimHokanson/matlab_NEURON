function computeThresholdLookupTable(obj,pulse_width,fiber_diameter,method)
%
%
%   p.computeThresholdLookupTable(0.5,10,1)

if method == 1
    temp = obj.mdf1;
elseif method == 2
    temp = obj.mdf2;
else
    error('Invalid option, only 1 & 2 supported')
end

I = find(temp.diameters == fiber_diameter,1);
J = find(temp.pulse_widths == pulse_width,1);

%v (Ve) is x axis in paper
%m (MDF) is y axis in paper
v = temp.ve{I,J};
m = temp.mdf{I,J};

% %Let's simplify the points for later intersection mapping
wtf = sigp.dpsimplify([v(:) m(:)],eps);
v = wtf(:,1);
m = wtf(:,2);

[v,I] = sort(v);
m = m(I);


%Let's extend m 

v_all = 0.2:0.2:max(v);
m_all = 0.2:0.2:max(m);

%We need to extend the line at the end so that
%we have intersections at all places ...
v_last_val = 1e6; %
m_last_val = interp1(v,m,v_last_val,'linear','extrap');

v = [v; v_last_val];
m = [m; m_last_val];



%???? - how to get max range of Ve??????
%-----------------------------------------------

thresholds = zeros(length(v_all),length(m_all));




%Started working on finer scales ...

v_all = 0.01:0.01:5;
m_all = v_all;

%For each point in v,m space, this creates
%a line that we will try to use to find the intersection with the curve
%of precomputed data ...
x_all = [-1*v_all(:) 100000*v_all(:)];
y_all = [-1*m_all(:) 100000*m_all(:)];

v_test_line = 0.01:0.01:100;

thresh_v = zeros(1,length(v_test_line));

for iV = 1:length(v_test_line)
    %
    %   Use m = 0.01 for all of these values ....
    %
    %[x0,y0] = sigp.intersections(x_all(iV,:),y_all(iM,:),v,m,false); 
end

%Repeat test along m

%This tells us what v we would need to use to get these thresholds
%if m = 0.01, they provide a good basis for our box ...
%v_test_final = interp1(thresh_v,v_test_line,500:-1:1);
%m_test_final = 

%Below use v_test_final and m_test_final instead of v_all and m_all
%Make sure to update 



tic
for iV = 1:length(v_all)
    for iM = 1:length(m_all)
       %Not sure if this is the fastest method ...
       
       
       %Try fast approach first, then do slow ...
       %this approach may fail if our 2 point line goes through
       %a vertex of the curve ...
       [x0,y0] = sigp.intersections(x_all(iV,:),y_all(iM,:),v,m,false);
       
       if isempty(x0)
           %slower approach (robust = true), 
          [x0,y0] = sigp.intersections(x_all(iV,:),y_all(iM,:),v,m,true); 
       end
       
       %But apparently both approaches can sometimes fail!
       if isempty(x0)
%            %Temp fix
%            %[x0,y0] = sigp.intersections(x_all(iV,:),y_all(iM,:),v+0.0001,m+0.0001,false);
%            if isempty(x0)
           plot(x_all(iV,:),y_all(iM,:),'r-o')
           hold all
           plot(v,m,'b-o')
           hold off
           error('wtf')
%            end
       end
       
%        plot([iV x0(1)],[iM y0(1)],'r')
%         hold all
%         plot(v,m,'b')
%         axis equal
       
        %********************************
        thresholds(iV,iM) = x0(1)/v_all(iV);
       

       %thresholds(iV,iM) = 
       
    end
end
toc

end