# Title: Helper functions for front matter

# Notes:
    #* Description:
        #** Helper functions for front matter
    #* Updated: 2023-03-10
        #** by: dcr

# Import modules

from random import uniform # to generate distributions
import math # for useful math operators

# COVER
    #* Defining vectors
def f1(x,y):
    """
        Description: To create the first vector for cover image

        Parameters: x,y

        Depends on: random, math
    """
    result = uniform(-100,100) * x**2  - math.sin(y**2) + abs(y-x)
    return result
def f2(x, y):
    """
        Description: To create the second vector for cover image
        
        Parameters: x,y

        Depends on: random, math
    """
    result = uniform(-1,1) * y**3 - math.cos(x**2) + 2*x
    return result
