/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use draw
use geometry
use unit

RasterRgbTest: class extends Fixture {
	sourceSpace := "test/draw/input/Space.png"
	sourceFlower := "test/draw/input/Flower.png"
	init: func {
		super("RasterRgbTest")
		this add("equals 1", func {
			image1 := RasterRgb open(this sourceFlower)
			image2 := RasterRgb open(this sourceSpace)
			expect(image1 equals(image1))
			expect(image1 equals(image2), is false)
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("equals 2", func {
			output := "test/draw/output/RasterRgb_test.png"
			image1 := RasterRgb open(this sourceSpace)
			image1 save(output)
			image2 := RasterRgb open(output)
			expect(image1 equals(image2))
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("distance, same image", func {
			image1 := RasterRgb open(this sourceSpace)
			image2 := RasterRgb open(this sourceSpace)
			expect(image1 distance(image1), is equal to(0.0f))
			expect(image1 distance(image2), is equal to(0.0f))
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("distance, convertFrom self", func {
			image1 := RasterRgb open(this sourceFlower)
			image2 := RasterRgb convertFrom(image1)
			expect(image1 distance(image2), is equal to(0.0f))
			expect(image1 equals(image2))
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("RGB to Monochrome", func {
			image1 := RasterRgb open(this sourceSpace)
			image2 := RasterMonochrome convertFrom(image1)
			image3 := RasterMonochrome open("test/draw/input/correct/Rgb-Monochrome-Space.png")
			expect(image2 distance(image3), is equal to(0.0f))
			image1 referenceCount decrease(); image2 referenceCount decrease(); image3 referenceCount decrease()
		})
		this add("swapped RB", func {
			output := "test/draw/output/rbswapped.png"
			image := RasterRgb open(this sourceFlower)
			image2 := RasterRgb open(this sourceFlower)
			image swapRedBlue()
			image save(output)
			for (row in 0 .. image height)
				for (column in 0 .. image width) {
					pixel1 := image[column, row]
					pixel2 := image2[column, row]
					expect(pixel1 red, is equal to(pixel2 blue))
					expect(pixel1 green, is equal to(pixel2 green))
					expect(pixel1 blue, is equal to(pixel2 red))
				}
			image referenceCount decrease()
			image2 referenceCount decrease()
			output free()
		})
		this add("resize", func {
			outputFast := "test/draw/output/RasterRgb_resized.png"
			image := RasterRgb open(this sourceSpace)
			image2 := image resizeTo(image size * 2)
			expect(image2 size == image size * 2)
			image2 save(outputFast)
			image referenceCount decrease()
			image2 referenceCount decrease()
			outputFast free()
		})
		this add("coordinate systems", func {
			image := RasterRgb open(this sourceSpace)
			image2 := image copy()

			image _coordinateSystem = CoordinateSystem YUpward
			image2 canvas draw(image)
			for (row in 0 .. image2 height)
				for (column in 0 .. image2 width)
					expect(image2[column, row] == image[column, image height - row - 1])

			image _coordinateSystem = CoordinateSystem Default
			image2 _coordinateSystem = CoordinateSystem XLeftward | CoordinateSystem YUpward
			image2 canvas draw(image)
			for (row in 0 .. image2 height)
				for (column in 0 .. image2 width)
					expect(image2[column, row] == image[image width - column - 1, image height - row - 1])

			image _coordinateSystem = CoordinateSystem XLeftward
			image2 _coordinateSystem = CoordinateSystem Default
			image2 canvas draw(image)
			for (row in 0 .. image2 height)
				for (column in 0 .. image2 width)
					expect(image2[column, row] == image[image width - column - 1, row])

			image _coordinateSystem = CoordinateSystem Default
			image2 _coordinateSystem = CoordinateSystem XRightward | CoordinateSystem YDownward
			image2 canvas draw(image)
			for (row in 0 .. image2 height)
				for (column in 0 .. image2 width)
					expect(image2[column, row] == image[column, row])

			image referenceCount decrease()
			image2 referenceCount decrease()
		})
	}
}

RasterRgbTest new() run() . free()
