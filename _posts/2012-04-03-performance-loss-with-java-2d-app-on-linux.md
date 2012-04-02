---
layout: post
tags: [java, java2d]
---
If you're experiencing significant performance loss when running Java 2D
based application on Linux platform try enabling **XRender-Based
Rendering Pipeline**. You can do this in Java 7 by setting system
property:

    -Dsun.java2d.xrender=true

In one of the applications I'm currently working on the new pipeline
gave about 20x boost. Rendering that used to take about 20ms now
takes ~1ms.
