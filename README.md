# Vector0 | Retro FPS Engine

First Person Shooter Developed in **Godot 4**, **Func Godot,** & **Trenchbroom**

I figured I would open the code to this FPS I have been developing in Godot 4. I found a very nifty open-source plugin for Godot 4 called FuncGodot allowing you to create maps and brush work in Trenchbroo similar to how retro fps games like Quake, and Half Life developed maps & levels.

Discord: https://discord.gg/ZwwYMr6BDn

# Engine Properties

**Texture Format**: PNG\
**Texture Size :** Powers of 2 (Suggested Max 256 x 256) \
**Map Suggested Unit Size**: 32 or 64 grid\
**Door Size**: 32w x 96h\
**Vent Size**: 32w x 32h\
**Audio Format**: .OGG

This engine looks to replicate most features a classic first person shooter would have with all the movement and chonky graphics & textures.

# Getting Started

The engine is pretty straight forward! \
There is a Godot project called "project.godot" in the root folder of this repo. You can open this in your Godot 4 Engine.

Once in there the Scene World will contain the level.\
For example you can open up the Level 1 Scene and view all the entities, and objects instantiated by trenchbroom.

In this engine we dont directly add objects or items to the game in Godot, this is done through Trenchbroom.\
Notice the Build Icon when on the Root of the FuncGodotMap Node, this is the button you will press when you have saved changes to your map in Trenchbroom.

You will need to learn the ins and outs of FuncGodot to make this process easier.

# Mapping

To get started with mapping first open up the addons folder inside the Godot Engine FileSystem, and look for 

```
func_godot_local_config.tres
```

You will need to update the Trenchbroom Game Config Folder to your trenchbroom Vector0 folder. \
Example:

```
C:/Users/your_name/Documents/Trenchboom/games/Vec0
```

You will also need to update your Map Editor Game Path to the path of the Godot Repo you cloned.\
Example:

```
C:/Users/user_name/Documents/github/Vector0
```

Once in Trenchbroom make sure to go into Entity, click Settings and select the custom FGD file located in this repo to get correct Entities.

You will need to download Ericwtools, this contains qbsp.exe that we can use with trenchbroom to compile our maps to .BSP

Click Run > Compile Map...
Create a new Profile
Name it Godot or whatever
Make sure it's working directory is: 
```
${MAP_DIR_PATH}
```

Next add a new Run Tool
in the Tool Path, select the qbsp.exe in your ericwtools folder
Add this code to your Parameters field:
```
-nolog -nocolor -nosubdivide ${MAP_BASE_NAME}
```

Make sure Parameters, and Stop on Nonzero Error Code are checked.
When you press compile it will make a bsp of the map now.

You may also need to go in to the Texture Browser, and make sure the textures folder is on the right hand side under Enabled.

// old
When done creating a map, create a new Godot Scene with a FuncGodotMap Node, and then attach your .map file to the node, and click **"Build".**
