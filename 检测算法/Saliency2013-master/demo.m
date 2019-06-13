% detect salient object in a hyperspectral scene
scene = importdata('scene.mat');

[rgb, iCM, cCM, oCM, Sm, HSI_group,HSI_spectralED, HSI_spectralSAD, ...
Sm_HSI_IOC, Sm_HSI_IOG, Sm_HSI_IOE, Sm_HSI_IOA, Sm_HSI_EOG, Sm_HSI_EOA, Sm_HSI_GEA]...
      = HSI_Saliency(scene,1);
  
rect = genbinarymap(rgb, Sm_HSI_IOC); 
rect = genbinarymap(rgb, Sm_HSI_IOG); 
rect = genbinarymap(rgb, Sm_HSI_IOE); 
rect = genbinarymap(rgb, Sm_HSI_IOA); 
rect = genbinarymap(rgb, Sm_HSI_EOG); 
rect = genbinarymap(rgb, Sm_HSI_EOA); 
rect = genbinarymap(rgb, Sm_HSI_GEA); 