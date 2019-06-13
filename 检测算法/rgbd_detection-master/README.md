# Object detection using RGB-D data

This was a research and development project done as part of Masters curriculum.
 
In this project, object detection was performed on open source datasets which containe the RGB-D images captured from Kinect in cluttered scenes. Object detection was performed as a combination of object proposal generation (locating object) and object classification (recognizing object) steps.  

Here, Object Proposal generation was based on Structured Random Forests (SRF) in Edge Boxes and Object Classification was based on the state-of-the- art Convolutional Neural Networks (CNNs). 

The performance of the combined pipeline was evaluated on the Berkeley 3-D Object Dataset (B3DO) indoor objects dataset. Object detection compared favorably against a state-of- the-art method: You Only Look Once (YOLO) by ∼7 % points. 

In addition,  the contribution of various imaging modalities on object detection was explored by evaluating the influence of additional depth data on both object proposal and classification stages. 

While additional depth information improves the proposals stage at parsimonious operating points, it results in a modest improvement on the classification stage.

This figure shows our pipeline:
![](https://github.com/priyankavokuda/rgbd_detection/blob/master/images/pipeline.png)


The extracts of the program files are shared here.

This figure shows results generated using YOLO for B3DO dataset.
![](https://github.com/priyankavokuda/rgbd_detection/blob/master/images/result.png)


