# Grass Renderer - Unity project #
## An exploration of HLSL geometry shaders in Unity 2017.2 ##
**TLDR:**

An exercise into geometry shaders and point mesh generation, this shader instantiates three-planar grass meshes that cast and receive shadows and react to wind. Because the bulk of the work is done on the GPU, over 60,000 instances of a grass can be easily generated per one mesh and drawn with no real effect on the FPS (easily hitting 70 FPS with 120,000 instances of grass in the near vicinity of a player on a mid-tier hardware). This can lead to some very dense grass, meadows, fields or similar realistic nature landscapes.

----------

This project was my personal exercise and exploration into geometry shaders and the way instancing works in Unity. It allows for seamless generation of many simple meshes onto a vertex cloud. I used it for spawning over 60000 tufts of grass per one vertex cloud (because of the mesh vertex limit in Unity 2017).

The grass receives and casts shadows and sways in the wind (not connected with a Unity windzone yet, just a simple swaying motion, but it is possible to do). 

The project comes set up with the default scene that contains everything necessary.

Since the instancing is done on the gpu, all that grass is still quite performance friendly and has minimal impact on the overall performance.