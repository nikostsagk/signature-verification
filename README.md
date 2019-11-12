# Feature extraction of off-line signatures for verification using Convolutional Neural Networks

This repository contains the report and the files of the final's-year coursework, for the requirements of the B.Sc in Physics from the University of Patras.


## Abstract
This B.Sc. thesis focuses on the research of off-line signature verification with the use of convolutional neural networks. Specifically, features were extracted from a pre-trained CNN and then classified in original-forgeries through SVMs.

Off-line signature verification has been researched over the last few decades using techniques from multiple areas like digital signal processing, graphology, computer vision and more. Taking advantage the great results of classifiers we trained a CNN which extracts features from genuine and forged signatures.
Our approach was through the creation of a convolutional neural network with two classes, and trained on a training set D. Then we extracted features based on genuine and forgeries signatures (writer independent). Continuing, based on a second training set E, we extracted features through the first CNN and we trained a writer dependent classifier.
To this end, from the testing set E we used new samples for feature extracting targeting the verification from the writer dependent classifier. We obtained a mean EER for 10 writers equal to 13,54% based on skill forgeries.

## Dataset
[CEDAR signature database](https://cedar.buffalo.edu/signature/) (available [here](https://github.com/nikostsagk/signature-verification/releases/download/cedar/cedar_dataset.zip)) consists of signatures from 55 writers. For each writer correspond 24 original signatures and 24 skilled forgeries. The dataset contains two folders: `full_org` contains the original signatures, while `full_forg` the skilled forgeries.

## Methodology
The approach for the signature verification is based on the method of [Hafemann et. al. (2016)](https://ieeexplore.ieee.org/abstract/document/7727521). 
<p align="center">
  <img src="https://github.com/nikostsagk/signature-verification/blob/master/image_1.gif" width="720">
</p>

The offline signature verification is based on the training of two models: a writer independent CNN model for the feature extraction task and on the training of writer dependent SVMs for the verification task.

At first, a CNN is getting trained on a development set (D) in order to discriminate between `original` and `forged` signatures. The development dataset is composed by the original + forged signatures of 45 writers (45*(24+24)=2160 signatures in total). The reason of training such a CNN is to get suitable feature vectors that contain information about the originality of a signature.

Secondly, to verify the originality of an enrolled to the system writer's signature, writer dependent SVMs are trained on signature features. For this task an exploitation set (E) is developed, with features from the signatures of the rest 10 writers from the CEDAR dataset. Finally, for each writer, a separate SVM is trained. 

Specifically the exploitation set is splitted in a `train` and in a `test` set for each user. These sets consist of:

  * `train`: 14 original signatures as original | 14 random forgeries* as forgeries
  * `test` : 10 original signatures as original | 24 skilled forgeries as forgeries
  
  *By random forgeries we mean random signatures drawn from the development set to simulate the realistic scenario because a skilled forgery is hard to get. 

## Instructions
1) Download, install and compile the MatConvNet toolbox following the instructions [here](http://www.vlfeat.org/matconvnet/install/).
2) Navigate in the `<MatConvNet>` directory and clone the repo in that directory.
3) Then download and unzip the CEDAR dataset in the repo's data folder by:
```
cd data
wget https://github.com/nikostsagk/signature-verification/releases/download/cedar/cedar_dataset.zip
unzip cedar_dataset.zip
```
Normally a `full_org` and a `full_forg` folder will be created.

4) Run the `cropping.m` script to obtain a .mat file with thinned, centered signatures exempted from excess information.

5) Run the `data_preparation.m` script to get the D and E sets as `data/D_set.mat` and `data/E_set.mat` files.

6) Run the `cnn_signature_independent.m` script to train the CNN.

7) You can check the progress of the CNN training by navigating to the <MatConvNet>/data/CEDAR folder.
  
8) Run `feature_extraction.m` to update the `E_set.mat` set with the extracted features.

9) Run the `svm.m` script to train the writer dependent SVMs and test on the testing dataset.

## Cite
```
@thesis{tsagkopoulos2016,
  title={Feature extraction of off-line signatures for verification using Convolutional Neural Networks},
  author={Tsagkopoulos N.},
  year={2016},
  organization={University of Patras}
}
```
