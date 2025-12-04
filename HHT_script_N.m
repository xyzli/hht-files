% This is a loop of the data_read.m function
% Can probably get file names more efficiently without fileDatastore fxn
% may need to change the file names depending on how they're named
clc;
close all;
clearvars;
%%
im_w=1024; % Dimensions obtained manually
im_h=1365;
slice_num=120;
str=zeros(400,im_h, 240, 4);

I_reset=zeros(im_w,im_h,slice_num);
I_temp=I_reset;
II_temp=I_reset;
I_0=I_reset;
II_0=I_reset;
I_cat=[I_0;II_0];

x=1:im_w;
gao=exp(-(x-1024/2-20).^2/(83886));  % Gaussian window

cd(''); % Change this to folder where scans are stored
fds_folder=fileDatastore('scan*', 'ReadFcn', @importdata); % each entry started with "scan" in its folder name
master_folder_list=fds_folder.Folders;
num_folders = length(master_folder_list);
%%
for h=1:num_folders
    temp_folder=strcat(master_folder_list{34},'\DataDump'); % Change index as needed
    cd(temp_folder);
    fds_c0=fileDatastore('prefourier*swipe_0.mat', 'ReadFcn', @importdata); % single, each file started and ended with prefourier ... swipe_x.mat
    fds_c1=fileDatastore('prefourier*swipe_1.mat', 'ReadFcn', @importdata); % single
    full_file_names_c0=fds_c0.Files;
    full_file_names_c1=fds_c1.Files;
    disp(strcat(['Beginning folder path:'], {' '},temp_folder,'.'));
    clearvars temp_folder;
    for i=0:3
        for j=0:slice_num-1
            I_temp=load(full_file_names_c0{j+1,1},strcat('*channel_',num2str(i)));
            II_temp=load(full_file_names_c1{j+1,1},strcat('*channel_',num2str(i)));
            I_0(:,:,j+1)=I_temp.(subsref(fieldnames(I_temp),substruct('{}',{1})));
            II_0(:,:,j+1)=II_temp.(subsref(fieldnames(II_temp),substruct('{}',{1})));
            clearvars I_temp II_temp;        
        end

        I_cat=[I_0;II_0];
        I_0=I_reset;
        II_0=I_reset;

        for k=1:slice_num
            Bt=I_cat(1:1024,:,k);
            Bft=abs(fft(Bt.*gao'));
            str(:,:,k,i+1)=Bft(11:410,:);
            Bt=I_cat(1025:end,:,k);
            Bft=abs(fft(Bt.*gao'));
            str(:,:,k+120,i+1)=Bft(11:410,:);
        end

        I_cat=[I_reset;I_reset];
        disp(strcat(['Finished channel'], {' '},num2str(i),'.')); % Check
    end

    str=single(str);
    for i=1:4
        z=log((str(:,:,60,i))); % we used 49 previously
        figure
        imagesc(medfilt2(z))
        colormap(gray)
        saveas(gcf, strcat('cstr', num2str(i), '.tif')); % Save the channel images
    end

    save('str','str','-v7.3')
    close all
    clearvars str Bt Bft z fds_c0 fds_c1 full_file_names_c0 full_file_names_c1;
end
