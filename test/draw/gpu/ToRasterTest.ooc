/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use unit
use draw
use draw-gpu
use base
use opengl

ToRasterTest: class extends Fixture {
	toRasterTestFunction: func (sourceImage: RasterImage) {
		gpuImage := context createImage(sourceImage)
		raster := gpuImage toRaster()
		expect(raster distance(sourceImage), is equal to(0.0f))
		sourceImage free()
		gpuImage free()
		raster free()
	}
	init: func {
		super("ToRaster")
		this add("toRaster bgra", || this toRasterTestFunction(RasterBgra open("test/draw/gpu/input/Flower.png")))
		this add("toRaster monochrome", || this toRasterTestFunction(RasterMonochrome open("test/draw/gpu/input/Flower.png")))
		this add("toRaster yuv", || this toRasterTestFunction(RasterYuv420Semiplanar open("test/draw/gpu/input/Flower.png")))
	}
}

context := OpenGLContext new()
ToRasterTest new() run() . free()
context free()