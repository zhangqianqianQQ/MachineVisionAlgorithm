<b>ImageSeg</b> <br><br>
It segments an image at pixel level by reversing the data flow of a pre-trained Faster-RCNN network to calculate the pixel level contribution to a certain type of object. The code is now configured to detect human.<br>
<br>
Usage:<br>
1. Download the weights of pretrained VGG network here: https://github.com/smallcorgi/Faster-RCNN_TF <br>
2. Run ckpt_to_mat.py to convert it into .mat file. Name that file "net_weights.mat" <br>
3. Install matconvnet here: http://www.vlfeat.org/matconvnet/ <br>
4. Modify line 8 of "run_gradient_ascent.m" to specify the image you want to segment. <br>
5. Run "run_gradient_ascent.m" <br>
