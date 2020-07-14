const std = @import("std");
usingnamespace @cImport({
    @cInclude("include/c/sk_canvas.h");
    @cInclude("include/c/sk_data.h");
    @cInclude("include/c/sk_image.h");
    @cInclude("include/c/sk_imageinfo.h");
    @cInclude("include/c/sk_paint.h");
    @cInclude("include/c/sk_path.h");
    @cInclude("include/c/sk_surface.h");
});

fn make_surface(w: i32, h: i32) *sk_surface_t {
    const info = sk_imageinfo_new(w, h, .RGBA_8888_SK_COLORTYPE, .PREMUL_SK_ALPHATYPE, null);
    defer sk_imageinfo_delete(info);

    const result = sk_surface_new_raster(info, null).?;
    return result;
}

fn emit_png(path: []const u8, surface: *sk_surface_t) !void {
    const image = sk_surface_new_image_snapshot(surface);
    defer sk_image_unref(image);

    const data = sk_image_encode(image);
    defer sk_data_unref(data);

    try std.fs.cwd().writeFile(path, @ptrCast([*c]const u8, sk_data_get_data(data).?)[0..sk_data_get_size(data)]);
}

fn draw(canvas: *sk_canvas_t) void {
    const fill = sk_paint_new();
    defer sk_paint_delete(fill);
    sk_paint_set_color(fill, sk_color_set_argb(0xFF, 0x00, 0x00, 0xFF));
    sk_canvas_draw_paint(canvas, fill);

    sk_paint_set_color(fill, sk_color_set_argb(0xFF, 0x00, 0xFF, 0xFF));
    const rect = sk_rect_t{ .left = 100, .top = 100, .right = 540, .bottom = 380 };
    sk_canvas_draw_rect(canvas, &rect, fill);

    const stroke = sk_paint_new();
    defer sk_paint_delete(stroke);
    sk_paint_set_color(stroke, sk_color_set_argb(0xFF, 0xFF, 0x00, 0x00));
    sk_paint_set_antialias(stroke, true);
    sk_paint_set_stroke(stroke, true);
    sk_paint_set_stroke_width(stroke, 5.0);

    const path = sk_path_new();
    defer sk_path_delete(path);
    sk_path_move_to(path, 50.0, 50.0);
    sk_path_line_to(path, 590.0, 50.0);
    sk_path_cubic_to(path, -490.0, 50.0, 1130.0, 430.0, 50.0, 430.0);
    sk_path_line_to(path, 590.0, 430.0);
    sk_canvas_draw_path(canvas, path, stroke);

    sk_paint_set_color(fill, sk_color_set_argb(0x80, 0x00, 0xFF, 0x00));
    const rect2 = sk_rect_t{ .left = 120.0, .top = 120.0, .right = 520.0, .bottom = 360.0 };
    sk_canvas_draw_oval(canvas, &rect2, fill);
}

pub fn main() !void {
    const surface = make_surface(640, 480);
    defer sk_surface_unref(surface);

    const canvas = sk_surface_get_canvas(surface).?;

    draw(canvas);
    try emit_png("skia-c-example.png", surface);
}
