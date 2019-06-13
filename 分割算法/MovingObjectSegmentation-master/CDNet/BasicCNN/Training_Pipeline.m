method = 'manual';  % random, uniform, manual
frames = 200;       % 50 100 150 200 

regular_training('baseline/highway', method, frames);
regular_training('baseline/office', method, frames);
regular_training('baseline/pedestrians', method, frames);
regular_training('baseline/PETS2006', method, frames);

regular_training('badWeather/blizzard', method, frames);
regular_training('badWeather/skating', method, frames);
regular_training('badWeather/snowFall', method, frames); 
regular_training('badWeather/wetSnow', method, frames);

regular_training('cameraJitter/badminton', method, frames);
regular_training('cameraJitter/boulevard', method, frames);
regular_training('cameraJitter/sidewalk', method, frames);
regular_training('cameraJitter/traffic', method, frames);

regular_training('dynamicBackground/boats', method, frames);
regular_training('dynamicBackground/canoe', method, frames);
regular_training('dynamicBackground/fall', method, frames);
regular_training('dynamicBackground/fountain01', method, frames);
regular_training('dynamicBackground/fountain02', method, frames);
regular_training('dynamicBackground/overpass', method, frames);

regular_training('intermittentObjectMotion/abandonedBox', method, frames);
regular_training('intermittentObjectMotion/parking', method, frames);
regular_training('intermittentObjectMotion/sofa', method, frames);
regular_training('intermittentObjectMotion/streetLight', method, frames);
regular_training('intermittentObjectMotion/tramstop', method, frames);
regular_training('intermittentObjectMotion/winterDriveway', method, frames);

regular_training('lowFramerate/port_0_17fps', method, frames);
regular_training('lowFramerate/tramCrossroad_1fps', method, frames);
regular_training('lowFramerate/tunnelExit_0_35fps', method, frames);
regular_training('lowFramerate/turnpike_0_5fps', method, frames);

regular_training('nightVideos/bridgeEntry', method, frames);
regular_training('nightVideos/busyBoulvard', method, frames);
regular_training('nightVideos/fluidHighway', method, frames);
regular_training('nightVideos/streetCornerAtNight', method, frames);
regular_training('nightVideos/tramStation', method, frames);
regular_training('nightVideos/winterStreet', method, frames);

regular_training('PTZ/continuousPan', method, frames);
regular_training('PTZ/intermittentPan', method, frames);
regular_training('PTZ/twoPositionPTZCam', method, frames);
regular_training('PTZ/zoomInZoomOut', method, frames);

regular_training('shadow/backdoor', method, frames);
regular_training('shadow/bungalows', method, frames);
regular_training('shadow/busStation', method, frames);
regular_training('shadow/copyMachine', method, frames);
regular_training('shadow/cubicle', method, frames);
regular_training('shadow/peopleInShade', method, frames);

regular_training('thermal/corridor', method, frames);
regular_training('thermal/diningRoom', method, frames);
regular_training('thermal/lakeSide', method, frames);
regular_training('thermal/library', method, frames);
regular_training('thermal/park', method, frames);

regular_training('turbulence/turbulence0', method, frames);
regular_training('turbulence/turbulence1', method, frames);
regular_training('turbulence/turbulence2', method, frames);
regular_training('turbulence/turbulence3', method, frames);
