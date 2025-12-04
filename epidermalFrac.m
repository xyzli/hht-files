function [ frac ] = epidermalFrac( cstr )

%cstr is an image
%get two distances, first one is the non-lesion epidermis and the second is
%where the dermis is thinner


% distance between pixels is 6e-6 - real depth needs to divide by refractive
% index of 1.5 
% dont need this cuz its a fraction

figure
imshow(cstr);
[x,y] = getpts;

epidermis=norm([x(2);y(2)]-[x(1);y(1)]);
minimum=norm([x(4);y(4)]-[x(3);y(3)]);

close all;

frac = minimum/epidermis;
end

