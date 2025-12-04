close all;
clearvars;

load str
str=str(:,35:1335,:,4); %%% crop the first and end portion if there is poor image quality -- last numberis the channel to use- pick the best one
% use channel number 1 or 4. You want to pick based on those pictures that
% came out of datread.
str=log(str);
Anum=size(str,2);
Bnum=120;
%%%%%%%%%%%%%% surface
As=Anum;
surf=zeros(As,Bnum/10 );

for i=1:Bnum/10
    bft=str(21:end,:,1+(i-1)*10:10+(i-1)*10);
    bt=mean((bft),3);    %%%  modify
    bt = imgaussfilt(bt ,10);
    bt=bt-min(bt(:));  
    for j=1:As
    she=find(bt(:,j)>1*mean(bt(:,j)));
    bt(:,j)=0;
    bt(she,j)=1;
    end
% 
%     figure
%     imagesc(bt)
%     colormap(gray)
    
for j=1:As
    she=find(bt(:,j)==1);
    surf(j,i)=median(she);
end
    
end

x=1:12;
y=1:As;

[xData, yData, zData]=prepareSurfaceData(x,y,surf);
[fitresult, gof]=fit([xData,yData],zData,'poly33');
surfz=zeros(As,12);
for i=1:As
    for j=1: 12
        surfz (i, j) = fitresult.p00 + fitresult.p10*j + fitresult.p01*i+ fitresult.p20*j.^2 + fitresult.p11*j.*i + fitresult.p02*i.^2 ...
                         + fitresult.p30*j^3 + fitresult.p21*j^2*i + fitresult.p12*j*i^2 + fitresult.p03*i^3 ; %...
    %                     + fitresult.p40*j^4 + fitresult.p31*j^3*i + fitresult.p22*j^2*i^2 + fitresult.p13*j*i^3  ...
    %                     + fitresult.p04*i^4 + fitresult.p50*j^5 + fitresult.p41*j^4*i ... 
    %                     + fitresult.p32*j^3*i^2 + fitresult.p23*j^2*i^3 + fitresult.p14*j*i^4 + fitresult.p05*i^5;
    end
end

figure
mesh(surfz)
% 
for i=1:12      %  If the error occurs, come back to see if the surce calculated is fine. 
    z=str(:,:, i*5*2);
    figure
    imagesc( (z))
    colormap(gray)
    hold on 
    plot(surfz(:,i)-10, 'r')
end

surf3=zeros(As, Bnum);
x1=0:1/9.95:12;

for i=1:As
    surf3(i,:)=nearest(interp(surfz(i,:),10));
end
%%  vascular image output
close all
sup_range_input=input('Enter your superficial range (as num:num): ','s');
deep_range_input=input('Enter your deep range (as num:num): ','s');

for h=1:2
    if (h==1)
        range_arr=strsplit(sup_range_input,':');
        file_name_en = 'x_superficial_enface.tif';
        file_name_struct = 'x_superficial_struct.tif';
        range_input=str2double(range_arr{1}):str2double(range_arr{2});
    elseif (h==2)
        range_arr=strsplit(deep_range_input,':');
        file_name_en = 'x_deep_enface.tif';
        file_name_struct = 'x_deep_struct.tif';
        range_input=str2double(range_arr{1}):str2double(range_arr{2});
    end

    Idst1=str(:,:,1:120)-str(:,:,121:end);
  %%%%%  adjust the depth range by pixel number HHT depths 310-510um (52-85) and 510-690um (85-115)
    Idsdi=zeros(120, Anum);
    for i=1:120 % reduce the number "120" if you need to crop in the y direction.
        for j=1:Anum
            Idsdi(i,j)=std(Idst1(surf3(j,i)+range_input,j,i));
        end
    end

    zen=medfilt2( Idsdi,[2 10]);
    figure
     h=pcolor(flipud(zen));
    set(h,'edgecolor','none','facecolor','interp');
     set(gcf,'Colormap',hot)
     axis off
    %saveas(gcf, file_name_en);
    % structural image output
    Imst=str(:,:,1:120) +str(:,:,121:end);

    Ivs=zeros(As, Bnum);
        for i=1:Bnum
            for j=1:As
                Ivs(j,i)=std(Imst(surf3(j,i)+range_input, j,i));
            end
        end

        figure
        z=medfilt2(Ivs);
    h=pcolor(flipud(z));  %%
    set(h,'edgecolor','none','facecolor','interp');
    colormap(gca, gray)  %hot
    axis off
    %saveas(gcf, file_name_struct);
end




