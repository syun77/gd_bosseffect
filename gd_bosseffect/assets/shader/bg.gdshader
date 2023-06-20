shader_type canvas_item;

// ラスター用.
uniform float intensity:hint_range(0.0, 3.0) = 1.0;
uniform float time:hint_range(0.0, 1000.0) = 0.0;

// 2値化用.
uniform bool is_binarization = true;
uniform bool is_horizontal = true;
// しきい値
uniform float threshold:hint_range(0.0, 3.0) = 2.0;

// 2値化の色.
uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;

void fragment() {
	float t = time;
	//float t = TIME;
	float u = UV.x + intensity * sin(UV.y * t);
	vec2 uv = vec2(u, UV.y);
	if(is_horizontal == false) {
		float v = UV.y + intensity * sin(UV.x * t);
		uv = vec2(UV.x, v);
	}
	
	// 色を取得
    vec4 color = texture(TEXTURE, uv);
	
	if(is_binarization) {
	    // RGBの合計を求める
	    float sum = color.r + color.g + color.b;
	    if(sum > threshold) {
	        // しきい値を超えていたら色 color2 にする
	        color.rgba = color2;
	    }
	    else {
	        // そうでない場合は color1 にする
	        color.rgba = color1;
	    }
	}

	COLOR = color;
}
