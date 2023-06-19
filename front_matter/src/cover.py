"""
    Title: Cover art
    Notes:
        - Description: Script to create cover art
        - Updated: 2022-12-08
        - Updated by: dcr
        - Output: ../../assets/cover.jpeg
"""

# Import packages
import matplotlib.pyplot as plt # for plots
from samila import GenerativeImage # for generating image
from samila import Projection # for transformation of vector

    #* User-defined
from helper import f1, f2 # import f1 and f2 from cover_fun module

# Create plot
colorArray = [
    "#E81B23",
    "#5d090c",
    "#ed454b",
    "#00aef3",
    "#00121a",
    "#66d4ff",
]

g = GenerativeImage(f1, f2)
g.generate(seed=1018273)
g.plot(cmap=colorArray, bgcolor="white", color = g.data2, projection=Projection.POLAR, size = (15,20))
g.save_image("assets/cover.jpeg", depth = 5)