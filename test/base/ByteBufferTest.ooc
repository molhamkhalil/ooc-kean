/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit

ByteBufferTest: class extends Fixture {
	init: func {
		super("ByteBuffer")
		this add("set data", func {
			buffer := ByteBuffer new(1024)
			expect(buffer size, is equal to(1024))
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			for (i in 0 .. 1024 / 8)
				expect(buffer pointer[i] as Int, is equal to(i))
			buffer referenceCount decrease()
		})
		this add("zero", func {
			buffer := ByteBuffer new(1024)
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			buffer zero()
			for (i in 0 .. 1024 / 8)
				expect(buffer pointer[i] as Int, is equal to(0))
			buffer referenceCount decrease()
		})
		this add("copy and copyTo", func {
			buffer := ByteBuffer new(1024)
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			buffercopy := buffer copy()
			buffer free()
			for (i in 0 .. 1024 / 8)
				expect(buffercopy pointer[i] as Int, is equal to(buffer pointer[i] as Int))
			buffercopy referenceCount decrease()
		})
		this add("slice", func {
			buffer := ByteBuffer new(1024)
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			slice := buffer slice(10, 8)
			buffer referenceCount decrease()
			expect(slice size, is equal to(8))
			expect(slice pointer[0] as Int, is equal to(10))
			slice referenceCount decrease()
		})
		this add("slice 2", func {
			yuv := ByteBuffer new(30000)
			y := yuv slice(0, 20000)
			uv := yuv slice(20000, 10000)
			expect(yuv referenceCount _count, is equal to(2))
			y referenceCount decrease()
			expect(yuv referenceCount _count, is equal to(1))
			uv referenceCount decrease()
			yuv referenceCount decrease()
		})
	}
}

ByteBufferTest new() run() . free()
