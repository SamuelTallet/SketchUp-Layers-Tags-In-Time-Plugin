# Time layering/tagging free plugin for SketchUp

Display or hide SketchUp layers/tags depending on time (dates or hours). Define as much time layers/tags you want: they combine. Create and assign simultaneously a layer/tag to an entity via context menu. Now, your favorite 3D modeling software understands seasons concept.

Demo & Screen
-------------

![SketchUp Layers/Tags In Time Plugin Demo](https://github.com/SamuelTS/SketchUp-Layers-Tags-In-Time-Plugin/raw/main/docs/sketchup-layers-tags-in-time-plugin-demo.gif)

![SketchUp Layers/Tags In Time Plugin Screen](https://github.com/SamuelTS/SketchUp-Layers-Tags-In-Time-Plugin/raw/main/docs/sketchup-layers-tags-in-time-plugin-screen.png)

Documentation
-------------

### How to install this plugin?

1. Be sure to have SketchUp 2017 or newer.
2. Download latest Layers/Tags In Time plugin from the SketchUcation PluginStore.
3. Install plugin following this [guide](https://www.youtube.com/watch?v=tyM5f81eRno).

Now, you should have in SketchUp a "Layers/Tags In Time" menu in "Extensions" menu.

### How to use this plugin?

Say we have a SketchUp model containing a terrain, an oak tree and a deer. All these entities are visible and already grouped conveniently. Ok? Now, let's follow these steps:

1. Right click on "Terrain And Oak Tree" group in viewport or in Outliner panel. Select "Assign to layer" then "New layer...". Enter this layer name: Spring-Summer-Autumn. (Note that as of SketchUp 2020 "Layers" are called "Tags".)

2. Right click on "Snow Terrain And Snow Oak Tree" group in viewport or in Outliner panel. Select "Assign to layer" then "New layer...". Enter this layer name: Winter. (Of course, you can still use "Layers" and "Entity Info" panels to accomplish this.)

3. If you need it: assign "Deer" entity to a layer. Whatever... It doesn't concern us since, in our model, time has no effect on deer.

4. Open "Extensions > Layers In Time". Input these dates for "Spring-Summer-Autumn" layer: 03/20 - 12/20. Input these dates for "Winter" layer: 12/21 - 03/19. (By the way, this plugin handles overlap on two years or two days.) Save changes.

5. Open "Shadows" panel. Move date cursor somewhere between March 20 and December 20. Create a scene. Move date cursor between December 21 and March 19. Create a scene.

6. Open "File > Export > Animation". Export to video.

7. Enjoy result!

### In UI of this plugin, February 29 isn't a valid date. Why?

For sake of standardization between leap years and normal years: leap days aren't supported... This plugin sees February 28 and 29 as same day. (It's not a bug.)

Thanks
------

Layers/Tags In Time plugin relies on [imaskjs](https://github.com/uNmAnNeR/imaskjs). Thanks to imaskjs's contributors. Thanks also to Simon Joubert for this plugin's original idea. 

Copyright
---------

© 2021 Samuel Tallet
