method = 'manual';  % random, uniform, manual
frames = 200;       % 50 100 150 200 

ms_regular_training('baseline/highway', method, frames);
ms_regular_training('baseline/office', method, frames);
ms_regular_training('baseline/pedestrians', method, frames);
ms_regular_training('baseline/PETS2006', method, frames);

ms_regular_training('badWeather/blizzard', method, frames);
ms_regular_training('badWeather/skating', method, frames);
ms_regular_training('badWeather/snowFall', method, frames); 
ms_regular_training('badWeather/wetSnow', method, frames);

ms_regular_training('cameraJitter/badminton', method, frames);
ms_regular_training('cameraJitter/boulevard', method, frames);
ms_regular_training('cameraJitter/sidewalk', method, frames); 
ms_regular_training('cameraJitter/traffic', method, frames);

ms_regular_training('dynamicBackground/boats', method, frames);
ms_regular_training('dynamicBackground/canoe', method, frames);
ms_regular_training('dynamicBackground/fall', method, frames);
ms_regular_training('dynamicBackground/fountain01', method, frames);
ms_regular_training('dynamicBackground/fountain02', method, frames);
ms_regular_training('dynamicBackground/overpass', method, frames);

ms_regular_training('intermittentObjectMotion/abandonedBox', method, frames);
ms_regular_training('intermittentObjectMotion/parking', method, frames);
ms_regular_training('intermittentObjectMotion/sofa', method, frames);
ms_regular_training('intermittentObjectMotion/streetLight', method, frames);
ms_regular_training('intermittentObjectMotion/tramstop', method, frames);
ms_regular_training('intermittentObjectMotion/winterDriveway', method, frames);

ms_regular_training('lowFramerate/port_0_17fps', method, frames);
ms_regular_training('lowFramerate/tramCrossroad_1fps', method, frames);
ms_regular_training('lowFramerate/tunnelExit_0_35fps', method, frames);
ms_regular_training('lowFramerate/turnpike_0_5fps', method, frames);

ms_regular_training('nightVideos/bridgeEntry', method, frames);
ms_regular_training('nightVideos/busyBoulvard', method, frames);
ms_regular_training('nightVideos/fluidHighway', method, frames);
ms_regular_training('nightVideos/streetCornerAtNight', method, frames);
ms_regular_training('nightVideos/tramStation', method, frames);
ms_regular_training('nightVideos/winterStreet', method, frames);

ms_regular_training('PTZ/continuousPan', method, frames);
ms_regular_training('PTZ/intermittentPan', method, frames);
ms_regular_training('PTZ/twoPositionPTZCam', method, frames);
ms_regular_training('PTZ/zoomInZoomOut', method, frames);

ms_regular_training('shadow/backdoor', method, frames);
ms_regular_training('shadow/bungalows', method, frames);
ms_regular_training('shadow/busStation', method, frames);
ms_regular_training('shadow/copyMachine', method, frames);
ms_regular_training('shadow/cubicle', method, frames);
ms_regular_training('shadow/peopleInShade', method, frames);

ms_regular_training('thermal/corridor', method, frames);
ms_regular_training('thermal/diningRoom', method, frames);
ms_regular_training('thermal/lakeSide', method, frames);
ms_regular_training('thermal/library', method, frames);
ms_regular_training('thermal/park', method, frames);

ms_regular_training('turbulence/turbulence0', method, frames);
ms_regular_training('turbulence/turbulence1', method, frames);
ms_regular_training('turbulence/turbulence2', method, frames);
ms_regular_training('turbulence/turbulence3', method, frames);
