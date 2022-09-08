from PIL import Image, ImageSequence
import os

def getStringFromNumber(number):
    if number == 0:
        return "NORMAL"
    if number == 1:
        return "RARE"
    if number == 2:
        return "SUPER_RARE"
    if number == 3:
        return "ULTRA_RARE"
    if number == 4:
        return "HYPER_RARE"
    if number == 5:
        return "LEGENDARY_RARE"


def createMaxRare(foreground, filename):
    transparent_foreground = foreground
    animated_gif1 = Image.open("animation.gif")
    animation_gif2 = Image.open("animation2.gif")
    border = Image.open("./borders/5.png")
    border2 = Image.open("./borders/4.png")

    frames = []
    for frame in ImageSequence.Iterator(animated_gif1):
        frame = frame.copy()
        frame = frame.convert("RGBA")
        frame.paste(transparent_foreground, transparent_foreground)
        frame.paste(border, border)
        frames.append(frame)
        
    frames[0].save("./results/" +  filename.split(".")[0] + "/" + filename.split(".")[0] + getStringFromNumber(5) +".gif", save_all=True, append_images=frames[1:])

    frames = []
    for frame in ImageSequence.Iterator(animation_gif2):
        frame = frame.copy()
        frame = frame.convert("RGBA")
        frame.paste(transparent_foreground, transparent_foreground)
        frame.paste(border2, border2)
        frames.append(frame)
        
    frames[0].save("./results/" +  filename.split(".")[0] + "/" + filename.split(".")[0] + getStringFromNumber(4) +".gif", save_all=True, append_images=frames[1:])

basePathBorder = "./borders"
basePathBGColor = "./backgrounds"

for filename in os.listdir("./images"):
    borderFileNames = [border for border in os.listdir(basePathBorder)]
    bgFileNames = [bg for bg in os.listdir(basePathBGColor)]

    dirForAllRarities = "./results/" + filename.split(".")[0]
    os.mkdir(dirForAllRarities)

    for i in range(len(borderFileNames)-2):
        background = Image.open(basePathBGColor + "/" + bgFileNames[i])
        middlePart = Image.open("./images/" + filename)
        foreGround = Image.open(basePathBorder + "/" + borderFileNames[i])

        background.paste(middlePart, (0, 0), middlePart)
        background.paste(foreGround, (0, 0), foreGround)

        background.save("./results/" +  filename.split(".")[0] + "/" + filename.split(".")[0] + getStringFromNumber(i) +".png")
    
    createMaxRare(middlePart, filename)


