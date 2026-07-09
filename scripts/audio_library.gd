extends RefCounted

static func make_tone(frequency: float, duration: float, volume: float) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	var sample_rate: int = 22050
	var sample_count: int = int(float(sample_rate) * duration)
	var fade_samples: int = maxi(1, int(float(sample_rate) * 0.015))
	var bytes: PackedByteArray = PackedByteArray()
	for i in sample_count:
		var t: float = float(i) / float(sample_rate)
		var fade: float = 1.0
		if i < fade_samples:
			fade = float(i) / float(fade_samples)
		elif i > sample_count - fade_samples:
			fade = float(sample_count - i) / float(fade_samples)
		var wave: float = sin(TAU * frequency * t)
		var sample_value: int = int(clampf(wave * volume * fade, -1.0, 1.0) * 32767.0)
		if sample_value < 0:
			sample_value = 65536 + sample_value
		bytes.append(sample_value % 256)
		bytes.append(int(floor(float(sample_value) / 256.0)) % 256)
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream

