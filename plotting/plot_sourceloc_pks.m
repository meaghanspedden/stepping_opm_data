S=[];
S.brush=3;
S.colourbar = 1;
S.cmap = 'autumn';

pos=[16 0 52;
    50 -4 40;
    4 58 44];

X=[5.5;3.36;1.83];

figure
fig = spm_glass(X,pos,S)