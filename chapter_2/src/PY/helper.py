"""
Title: Functions for dissertation

Notes:
    - Description: Script containing all the functions used in dissertation
    - Updated: 2023-03-10
    - Updated by: dcr

Importing dependencies
"""
import numpy as np # for array management
import cv2 # for image detection


# Study 2
#* Dealing with names
def names(col):
    """
    names

    Description
    ----
    Function to extract last names of candidate

    Parameters
    ----
    df(pd.DataFrame)

    Depends on
    ----
    - pandas
    - re
    """
    Name = col.str.replace(r"Jr\.|Sr\.|Jr|Sr|JR|SR|III|\sIV|\sVI", "")
    Stripped = Name.str.rstrip()
    lastName = Stripped.str.split(" ").list.get(-1)
    return lastName

#* image pre-processing
def preProcess(img,inter,size=[224,224]):
    """
    preProcess

    Description
    ----
    Function to do the resizing of the images
    
    Parameters
    ----
    - img: source image
    - inter: interpolate pixels
    - size(tuple): size of resized image

    Depends on
    ----
    cv2
    """
    resized = cv2.resize(img,size,inter)
    return resized
    
#** Color detection
def colorDetector(img,color_upper=[255,255,255],color_lower=[255,255,255]):
    """
    colorDetector

    Description
    ----
    Function that preprocesses the image and calculates the percentage of a particular color in it.
    
    Parameters
    ----
    img:Original img
    color_upper(tuple): RBG upper value. Default to white
    color_lower(tuple): RGB lower value. Default to white
    
    Depends on
    ----
    - helper.preProcess
    - cv2
    """
    # create boundaries 
    boundaries = [(
        [color_lower[2], color_lower[1], color_lower[0]],
        [color_upper[2], color_upper[1], color_upper[0]])]
    # Transform image
    img_transformed = preProcess(img=img,inter=cv2.INTER_AREA)
    # calculate scale
    #scale = ((img_transformed.shape[0]/img.shape[0]) + (img_transformed.shape[1]/img.shape[1]))/2
    for (lower, upper) in boundaries:
    # adjust color_upper and color_lower to specific type
        lower = np.array(lower, dtype = np.uint8)
        upper = np.array(upper, dtype = np.uint8)
    # take all values within color range and make it white; everything else black
        mask = cv2.inRange(img_transformed, lower, upper)
        # take all white values and put it on original image. keep black pixels black
        result = cv2.bitwise_and(img_transformed, img_transformed, mask = mask)
    # get ratio of non-black pixels
        ratio = cv2.countNonZero(mask)/(mask.size)
        #/(img_transformed.size)
    # calculate percentage of non-black pixels
        percent = (ratio * 100)
        # return percentage, img_transformed, and result
        return percent, img_transformed, result