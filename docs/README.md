# Time layering/tagging free plugin for SketchUp

Display or hide SketchUp layers/tags depending on time (dates or hours). Create and assign simultaneously a layer/tag to an entity via context menu. Export time layers/tags to a MP4 or GIF animation. Export and import time layers/tags in JSON format. Now, your favorite 3D modeling software understands seasons concept.

Demo & Screen
-------------

![SketchUp Layers/Tags In Time Plugin Demo](https://github.com/SamuelTS/SketchUp-Layers-Tags-In-Time-Plugin/raw/main/docs/sketchup-layers-tags-in-time-plugin-demo.gif)

![SketchUp Layers/Tags In Time Plugin Screen](https://github.com/SamuelTS/SketchUp-Layers-Tags-In-Time-Plugin/raw/main/docs/sketchup-layers-tags-in-time-plugin-screen-v101.png)

Documentation
-------------

### How to install this plugin?

1. Be sure to have SketchUp 2017 or newer.
2. Download latest Layers/Tags In Time plugin from the [SketchUcation PluginStore](https://sketchucation.com/plugin/2376-layers_tags_in_time).
3. Install plugin following this [guide](https://www.youtube.com/watch?v=tyM5f81eRno).

Now, you should have in SketchUp a "Layers/Tags In Time" menu in "Extensions" menu and a "Layers/Tags In Time" toolbar.

### How to use this plugin?

Say we have a SketchUp model containing a terrain, an oak tree, a snowy terrain, a snowy oak tree and a deer. All these entities are visible and already grouped conveniently. Ok? Now, let's follow these steps:

1. Right click on "Terrain And Oak Tree" group in viewport or in "Outliner" panel. Select "Assign to layer" then "New layer...". Enter this layer name: Spring-Summer-Autumn. (Note that as of SketchUp 2020 "Layers" are called "Tags".)

2. Right click on "Snowy Terrain And Snowy Oak Tree" group in viewport or in "Outliner" panel. Select "Assign to layer" then "New layer...". Enter this layer name: Winter. (Of course, you can still use "Layers" and "Entity Info" panels to accomplish this.)

3. If you need it: assign "Deer" entity to a layer. Whatever... It doesn't concern us since, in our model, time has no effect on deer.

4. Open "Extensions > Layers In Time > Open Layers Editor". Input these dates for "Spring-Summer-Autumn" layer: 03/20 - 12/20. Input these dates for "Winter" layer: 12/21 - 03/19. (By the way, this plugin handles overlap on two years or two days.) Save changes.

5. Open "Extensions > Layers In Time > Play animation". Customize settings then press "OK" to preview animation. Repeat this step until you are satisfied.

6. Open "Extensions > Layers In Time > Export to an animation...". Customize settings then press "OK" to export animation. SketchUp can become unresponsive during this operation. Don't close SketchUp. Be patient ;)

7. Enjoy result:

![SketchUp Layers/Tags In Time Plugin Demo](https://github.com/SamuelTS/SketchUp-Layers-Tags-In-Time-Plugin/raw/main/docs/sketchup-layers-tags-in-time-plugin-demo.gif)

### In UI of this plugin, February 29 isn't a valid date. Why?

For sake of standardization between leap years and normal years: leap days aren't supported... This plugin sees February 28 and 29 as same day. (It's not a bug.)

Thanks
------

Layers/Tags In Time plugin relies on [imaskjs](https://github.com/uNmAnNeR/imaskjs), [List.js](https://github.com/javve/list.js) and [FFmpeg](https://ffmpeg.org/). Thanks to imaskjs's, List.js's and FFmpeg's contributors. Thanks also to Simon Joubert for this plugin's original idea. Toolbar icons of this plugin were made by [Linector](https://www.flaticon.com/authors/linector) and [Freepik](https://www.freepik.com) from [Flaticon](https://www.flaticon.com/).

Copyright
---------

© 2021 Samuel Tallet
