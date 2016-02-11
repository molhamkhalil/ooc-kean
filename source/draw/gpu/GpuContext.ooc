/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use base
use collections
use concurrent
import DrawContext
import GpuImage, GpuCanvas, GpuMap, GpuFence, GpuYuv420Semiplanar, GpuMesh

version(!gpuOff) {
_ToRasterFuture: class extends Future<RasterImage> {
	_result: RasterImage
	init: func (=_result) {
		super()
		this _result referenceCount increase()
	}
	free: override func {
		this _result referenceCount decrease()
		super()
	}
	wait: override func -> Bool { true }
	wait: override func ~timeout (time: TimeSpan) -> Bool { true }
	getResult: override final func (defaultValue: RasterImage) -> RasterImage {
		this _result referenceCount increase()
		this _result
	}
}
GpuContext: abstract class extends DrawContext {
	defaultMap ::= null as GpuMap
	init: func
	createMonochrome: abstract func (size: IntVector2D) -> GpuImage
	createBgr: abstract func (size: IntVector2D) -> GpuImage
	createBgra: abstract func (size: IntVector2D) -> GpuImage
	createUv: abstract func (size: IntVector2D) -> GpuImage
	createImage: abstract func (rasterImage: RasterImage) -> GpuImage
	createFence: abstract func -> GpuFence
	createYuv420Semiplanar: override func (size: IntVector2D) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(size, this) }
	createYuv420Semiplanar: override func ~fromImages (y, uv: Image) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(y as GpuImage, uv as GpuImage, this) }
	createYuv420Semiplanar: override func ~fromRaster (raster: RasterYuv420Semiplanar) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(raster, this) }
	createMesh: abstract func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) -> GpuMesh

	update: abstract func
	packToRgba: abstract func (source: GpuImage, target: GpuImage, viewport: IntBox2D, padding := 0)
	finish: func { this createFence() sync() . wait() . free() }

	toRaster: virtual func (source: GpuImage) -> RasterImage { source toRasterDefault() }
	toRaster: virtual func ~target (source: GpuImage, target: RasterImage) -> Promise {
		source toRasterDefault(target)
		Promise empty
	}
	toRasterAsync: virtual func (source: GpuImage) -> Future<RasterImage> { raise("toRasterAsync unimplemented") }
}
}
