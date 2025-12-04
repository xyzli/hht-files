clear
clc

mz='prefourier_00';    %%%%  fill in the name of the file (make sure the number of zero is the same)
qi=235;                 %%% this is the start number (different for each dataset)

As=1365;
zhen=120;
I1=zeros(1024,As,zhen);
I2=I1;
I3=I1;
I4=I1;

II1=zeros(1024,As,zhen);
II2=II1;
II3=II1;
II4=II1;

for i=0:119
    
if (qi+i)>9999
    mz='prefourier_';
elseif (qi+i)>999
     mz='prefourier_0';
elseif (qi+i)>99
     mz='prefourier_00';
elseif (qi+i)>9
     mz='prefourier_000';
end
     
name=[mz,num2str(qi+i),'_swipe_0'];
load(name)
name=[mz,num2str(qi+i),'_swipe_1'];
load(name)

    name1=[mz,num2str(qi+i),'_swipe_0_channel_0'];
    name2=[mz,num2str(qi+i),'_swipe_0_channel_1'];
    name3=[mz,num2str(qi+i),'_swipe_0_channel_2'];
    name4=[mz,num2str(qi+i),'_swipe_0_channel_3'];
    I1(:,:,i+1)=eval(name1);
    I2(:,:,i+1)=eval(name2);
    I3(:,:,i+1)=eval(name3);
    I4(:,:,i+1)=eval(name4);
    clear(name1)
    clear(name2)
    clear(name3)
    clear(name4)
    name=[mz,num2str(qi+i),'_swipe_0_timestamp'];
    clear(name)
    
    name1=[mz,num2str(qi+i),'_swipe_1_channel_0'];
    name2=[mz,num2str(qi+i),'_swipe_1_channel_1'];
    name3=[mz,num2str(qi+i),'_swipe_1_channel_2'];
    name4=[mz,num2str(qi+i),'_swipe_1_channel_3'];
    II1(:,:,i+1)=eval(name1);
    II2(:,:,i+1)=eval(name2);
    II3(:,:,i+1)=eval(name3);
    II4(:,:,i+1)=eval(name4);
    clear(name1)
    clear(name2)
    clear(name3)
    clear(name4)
    name=[mz,num2str(qi+i),'_swipe_1_timestamp'];
    clear(name)
end
        
In1=[I1;II1];
clear II1
clear I1
In2=[I2;II2];
clear II2
clear I2
In3=[I3;II3];
clear II3
clear I3
In4=[I4;II4];
clear I4
clear II4

x=1:1024;
gao=exp(-(x-1024/2-20).^2/(83886));  %%%Gaussian window


%%%test one frame first   choose a better image 
i=60;                   
    Bt=In1(1:1024,:,i);
    Bft=abs(fft(Bt.*gao'));
    z=Bft(11:410,:);
    figure
    imagesc(log(z))
    colormap(gray)
    
    Bt=In4(1:1024,:,i);
    Bft=abs(fft(Bt.*gao'));
    z=Bft(11:410,:);
   figure
    imagesc(log(z))
    colormap(gray)
    
       
%%%%%%   FFT  
str=zeros(400,As, 240, 4);

for i=1:120
    Bt=In1(1:1024,:,i);        
    Bft=abs(fft(Bt.*gao'));
    str(:,:,i,1)=Bft(11:410,:);
    Bt=In1(1025:end,:,i);
    Bft=abs(fft(Bt.*gao'));
    str(:,:,i+120,1)=Bft(11:410,:);
    
        Bt=In2(1:1024,:,i);        
    Bft=abs(fft(Bt.*gao'));
    str(:,:,i,2)=Bft(11:410,:);
    Bt=In2(1025:end,:,i);
    Bft=abs(fft(Bt.*gao'));
    str(:,:,i+120,2)=Bft(11:410,:);
    
        Bt=In3(1:1024,:,i);        
    Bft=abs(fft(Bt.*gao'));
    str(:,:,i,3)=Bft(11:410,:);
    Bt=In3(1025:end,:,i);
    Bft=abs(fft(Bt.*gao'));
    str(:,:,i+120,3)=Bft(11:410,:);
    
        Bt=In4(1:1024,:,i);        
    Bft=abs(fft(Bt.*gao'));
    str(:,:,i,4)=Bft(11:410,:);
    Bt=In4(1025:end,:,i);
    Bft=abs(fft(Bt.*gao'));
    str(:,:,i+120,4)=Bft(11:410,:);
  
    
end

str=single(str);
for i=1:4
z=log((str(:,:,49,i)));
figure
imagesc(medfilt2(z))
colormap(gray)
saveas(gcf, strcat('cstr', num2str(i), '.tif')); %save the channel images

end

save('str','str','-v7.3')  %%%%  save the structural iamges. 


