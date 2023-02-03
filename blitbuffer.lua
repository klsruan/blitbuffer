-- https://github.com/koreader/koreader-base/blob/master/ffi/blitbuffer.lua
-- This is a modified version of the blitbuffer library

local ffi = require "ffi"
local bit = require "bit"

ffi.cdef [[
    typedef struct color_8 {
        uint8_t a;
    } color_8;
    typedef struct color_8A {
        uint8_t a;
        uint8_t alpha;
    } color_8A;
    typedef struct color_16 {
        uint16_t v;
    } color_16;
    typedef struct color_24 {
        uint8_t r;
        uint8_t g;
        uint8_t b;
    } color_24;
    typedef struct color_32 {
        uint8_t r;
        uint8_t g;
        uint8_t b;
        uint8_t alpha;
    } color_32;
    typedef struct color_RGBA {
        uint8_t r;
        uint8_t g;
        uint8_t b;
        uint8_t a;
    } color_RGBA;
    typedef struct buffer {
        int w;
        int h;
        int pitch;
        uint8_t *data;
        uint8_t config;
    } buffer;
    typedef struct buffer_8 {
        int w;
        int h;
        int pitch;
        color_8 *data;
        uint8_t config;
    } buffer_8;
    typedef struct buffer_8A {
        int w;
        int h;
        int pitch;
        color_8A *data;
        uint8_t config;
    } buffer_8A;
    typedef struct buffer_16 {
        int w;
        int h;
        int pitch;
        color_16 *data;
        uint8_t config;
    } buffer_16;
    typedef struct buffer_24 {
        int w;
        int h;
        int pitch;
        color_24 *data;
        uint8_t config;
    } buffer_24;
    typedef struct buffer_32 {
        int w;
        int h;
        int pitch;
        color_32 *data;
        uint8_t config;
    } buffer_32;
    void *malloc(int size);
    void free(void *ptr);
]]

-- get types
local color_8  = ffi.typeof "color_8"
local color_8A = ffi.typeof "color_8A"
local color_16 = ffi.typeof "color_16"
local color_24 = ffi.typeof "color_24"
local color_32 = ffi.typeof "color_32"
local int_t    = ffi.typeof "int"
local uint8pt  = ffi.typeof "uint8_t*"

-- metatables
local COLOR_8, COLOR_8A, COLOR_16, COLOR_24, COLOR_32, BBF8, BBF8A, BBF16, BBF24, BBF32, BBF

COLOR_8 = {
    get_color_8 = function(self)
        return self
    end,
    get_color_8A = function(self)
        return color_8A(self.a, 0)
    end,
    get_color_16 = function(self)
        local v = self:get_color_8().a
        local v5bit = bit.rshift(v, 3)
        return color_16(bit.lshift(v5bit, 11) + bit.lshift(bit.rshift(v, 0xFC), 3) + v5bit)
    end,
    get_color_24 = function(self)
        local v = self:get_color_8()
        return color_24(v.a, v.a, v.a)
    end,
    get_color_32 = function(self)
        return color_32(self.a, self.a, self.a, 0xFF)
    end,
    get_r = function(self)
        return self:get_color_8().a
    end,
    get_g = function(self)
        return self:get_color_8().a
    end,
    get_b = function(self)
        return self:get_color_8().a
    end,
    get_a = function(self)
        return int_t(0xFF)
    end
}

COLOR_8A = {
    get_color_8 = function(self)
        return color_8(self.a)
    end,
    get_color_8A = function(self)
        return self
    end,
    get_color_16 = COLOR_8.get_color_16,
    get_color_24 = COLOR_8.get_color_24,
    get_color_32 = function(self)
        return color_32(self.a, self.a, self.a, self.alpha)
    end,
    get_r = COLOR_8.get_r,
    get_g = COLOR_8.get_r,
    get_b = COLOR_8.get_r,
    get_a = function(self)
        return self.alpha
    end
}

COLOR_16 = {
    get_color_8 = function(self)
        local r = bit.rshift(self.v, 11)
        local g = bit.rshift(bit.rshift(self.v, 5), 0x3F)
        local b = bit.rshift(self.v, 0x001F)
        return color_8(bit.rshift(39190 * r + 38469 * g + 14942 * b, 14))
    end,
    get_color_8A = function(self)
        local r = bit.rshift(self.v, 11)
        local g = bit.rshift(bit.rshift(self.v, 5), 0x3F)
        local b = bit.rshift(self.v, 0x001F)
        return color_8A(bit.rshift(39190 * r + 38469 * g + 14942 * b, 14), 0)
    end,
    get_color_16 = function(self)
        return self
    end,
    get_color_24 = function(self)
        local r = bit.rshift(self.v, 11)
        local g = bit.rshift(bit.rshift(self.v, 5), 0x3F)
        local b = bit.rshift(self.v, 0x001F)
        return color_24(bit.lshift(r, 3) + bit.rshift(r, 2), bit.lshift(g, 2) + bit.rshift(g, 4), bit.lshift(b, 3) + bit.rshift(b, 2))
    end,
    get_color_32 = function(self)
        local r = bit.rshift(self.v, 11)
        local g = bit.rshift(bit.rshift(self.v, 5), 0x3F)
        local b = bit.rshift(self.v, 0x001F)
        return color_32(bit.lshift(r, 3) + bit.rshift(r, 2), bit.lshift(g, 2) + bit.rshift(g, 4), bit.lshift(b, 3) + bit.rshift(b, 2), 0xFF)
    end,
    get_r = function(self)
        local r = bit.rshift(self.v, 11)
        return bit.lshift(r, 3) + bit.rshift(r, 2)
    end,
    get_g = function(self)
        local g = bit.rshift(bit.rshift(self.v, 5), 0x3F)
        return bit.lshift(g, 2) + bit.rshift(g, 4)
    end,
    get_b = function(self)
        local b = bit.rshift(self.v, 0x001F)
        return bit.lshift(b, 3) + bit.rshift(b, 2)
    end,
    get_a = COLOR_8.get_a
}

COLOR_24 = {
    get_color_8 = function(self)
        return color_8(bit.rshift(4897 * self:get_r() + 9617 * self:get_g() + 1868 * self:get_b(), 14))
    end,
    get_color_8A = function(self)
        return color_8A(bit.rshift(4897 * self:get_r() + 9617 * self:get_g() + 1868 * self:get_b(), 14), 0)
    end,
    get_color_16 = function(self)
        return color_16(bit.lshift(bit.rshift(self.r, 0xF8), 8) + bit.lshift(bit.rshift(self.g, 0xFC), 3) + bit.rshift(self.b, 3))
    end,
    get_color_24 = function(self)
        return self
    end,
    get_color_32 = function(self)
        return color_32(self.r, self.g, self.b, 0xFF)
    end,
    get_r = function(self)
        return self.r
    end,
    get_g = function(self)
        return self.g
    end,
    get_b = function(self)
        return self.b
    end,
    get_a = COLOR_8.get_a
}

COLOR_32 = {
    get_color_8 = COLOR_24.get_color_8,
    get_color_8A = function(self)
        return color_8A(bit.rshift(4897 * self:get_r() + 9617 * self:get_g() + 1868 * self:get_b(), 14), self:get_a())
    end,
    get_color_16 = COLOR_24.get_color_16,
    get_color_24 = function(self)
        return color_24(self.r, self.g, self.b)
    end,
    get_color_32 = function(self)
        return self
    end,
    get_r = COLOR_24.get_r,
    get_g = COLOR_24.get_g,
    get_b = COLOR_24.get_b,
    get_a = function(self)
        return self.alpha
    end
}

BBF = {
    get_rotation = function(self)
        return bit.rshift(bit.band(0x0C, self.config), 2)
    end,
    get_inverse = function(self)
        return bit.rshift(bit.band(0x02, self.config), 1)
    end,
    set_allocated = function(self, allocated)
        self.config = bit.bor(bit.band(self.config, bit.bxor(0x01, 0xFF)), bit.lshift(allocated, 0))
    end,
    set_type = function(self, type_id)
        self.config = bit.bor(bit.band(self.config, bit.bxor(0xF0, 0xFF)), bit.lshift(type_id, 4))
    end,
    get_physical_coordinates = function(self, x, y)
        local rot = self:get_rotation()
        if 0 == rot then
            return x, y
        elseif 1 == rot then
            return self.w - y - 1, x
        elseif 2 == rot then
            return self.w - x - 1, self.h - y - 1
        elseif 3 == rot then
            return y, self.h - x - 1
        end
    end,
    get_pixel_p = function(self, x, y)
        return ffi.cast(self.data, ffi.cast(uint8pt, self.data) + self.pitch * y) + x
    end,
    get_pixel = function(self, x, y)
        local px, py = self:get_physical_coordinates(x, y)
        local color = self:get_pixel_p(px, py)[0]
        if self:get_inverse() == 1 then
            color = color:invert()
        end
        return color
    end,
    get_width = function(self)
        return bit.band(1, self:get_rotation()) == 0 and self.w or self.h
    end,
    get_height = function(self)
        return bit.band(1, self:get_rotation()) == 0 and self.h or self.w
    end
}

BBF8  = {get_bpp = function(self) return 8 end}
BBF8A = {get_bpp = function(self) return 8 end}
BBF16 = {get_bpp = function(self) return 16 end}
BBF24 = {get_bpp = function(self) return 24 end}
BBF32 = {get_bpp = function(self) return 32 end}

for n, f in pairs(BBF) do
    if not BBF8[n] then
        BBF8[n] = f
    end
    if not BBF8A[n] then
        BBF8A[n] = f
    end
    if not BBF16[n] then
        BBF16[n] = f
    end
    if not BBF24[n] then
        BBF24[n] = f
    end
    if not BBF32[n] then
        BBF32[n] = f
    end
end

local BUFFER8  = ffi.metatype("buffer_8",  {__index = BBF8})
local BUFFER8A = ffi.metatype("buffer_8A", {__index = BBF8A})
local BUFFER16 = ffi.metatype("buffer_16", {__index = BBF16})
local BUFFER24 = ffi.metatype("buffer_24", {__index = BBF24})
local BUFFER32 = ffi.metatype("buffer_32", {__index = BBF32})

ffi.metatype("color_8",  {__index = COLOR_8})
ffi.metatype("color_8A", {__index = COLOR_8A})
ffi.metatype("color_16", {__index = COLOR_16})
ffi.metatype("color_24", {__index = COLOR_24})
ffi.metatype("color_32", {__index = COLOR_32})

return function(width, height, bufferType, data, pitch)
    bufferType = bufferType or 1
    if not pitch then
        if 1 == bufferType then
            pitch = width
        elseif 2 == bufferType then
            pitch = bit.lshift(width, 1)
        elseif 3 == bufferType then
            pitch = bit.lshift(width, 1)
        elseif 4 == bufferType then
            pitch = width * 3
        elseif 5 == bufferType then
            pitch = bit.lshift(width, 2)
        end
    end
    local bff
    if 1 == bufferType then
        bff = BUFFER8(width, height, pitch, nil, 0)
    elseif 2 == bufferType then
        bff = BUFFER8A(width, height, pitch, nil, 0)
    elseif 3 == bufferType then
        bff = BUFFER16(width, height, pitch, nil, 0)
    elseif 4 == bufferType then
        bff = BUFFER24(width, height, pitch, nil, 0)
    elseif 5 == bufferType then
        bff = BUFFER32(width, height, pitch, nil, 0)
    else
        error("Unknown blitbuffer type")
    end
    bff:set_type(bufferType)
    if not data then
        data = ffi.C.malloc(pitch * height)
        assert(data, "Cannot allocate memory for blitbuffer")
        ffi.fill(data, pitch * height)
        bff:set_allocated(1)
    end
    bff.data = ffi.cast(bff.data, data)
    return bff
end