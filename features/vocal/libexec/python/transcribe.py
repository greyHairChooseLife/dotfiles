"""Local speech-to-text with faster-whisper (CTranslate2).

Usage: transcribe.py <audio_file> <model_name> <model_path>

Reads a 16 kHz mono 16-bit WAV and prints the text on stdout. Status and
errors go to stderr, so stdout stays clean for the caller.
"""
import sys
import wave
from pathlib import Path

import numpy as np

try:
    from faster_whisper import WhisperModel
except ImportError:
    print(
        "Error: faster-whisper not found in this interpreter. See features/vocal/README.md.",
        file=sys.stderr,
    )
    sys.exit(1)


def load_audio(audio_file: str) -> np.ndarray:
    """Decode the recording to float32 samples in [-1, 1].

    faster-whisper wants 16 kHz mono. PyAV is skipped on purpose: the only
    input is the wav that `vocal` just recorded, and the stdlib reader has no
    version coupling to PyAV/ffmpeg.
    """
    with wave.open(audio_file, "rb") as f:
        channels, width, rate = f.getnchannels(), f.getsampwidth(), f.getframerate()
        if channels != 1 or width != 2 or rate != 16000:
            raise ValueError(
                f"expected mono 16-bit 16000 Hz wav, got {channels}ch/{width * 8}bit/{rate}Hz"
            )
        frames = f.readframes(f.getnframes())
    return np.frombuffer(frames, dtype=np.int16).astype(np.float32) / 32768.0


def main() -> None:
    if len(sys.argv) != 4:
        print(
            "Usage: python transcribe.py <audio_file> <model_name> <model_path>",
            file=sys.stderr,
        )
        sys.exit(1)

    audio_file, model_name, model_path = sys.argv[1], sys.argv[2], sys.argv[3]
    try:
        audio = load_audio(audio_file)
        # int8: CPU에서 가장 빠르고 메모리도 적게 쓴다 (FP16은 CPU에서 지원 안 됨)
        model = WhisperModel(
            model_name,
            device="cpu",
            compute_type="int8",
            download_root=str(Path(model_path).expanduser()),
        )
        segments, _info = model.transcribe(audio, beam_size=5, vad_filter=True)
        print("".join(segment.text for segment in segments).strip())
    except Exception as e:
        print(f"Error during transcription: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
