from pathlib import Path
import subprocess
import shutil


INPUT_DIR = Path("input")
OUTPUT_DIR = Path("webm")


def main():
    # Check FFmpeg
    if shutil.which("ffmpeg") is None:
        print("ERROR: FFmpeg was not found.")
        print("Run: ffmpeg -version")
        return

    # Check input folder
    if not INPUT_DIR.exists():
        print("ERROR: input folder does not exist.")
        return

    gif_files = sorted(INPUT_DIR.glob("*.gif"))

    if not gif_files:
        print("No GIF files found in input/")
        return

    OUTPUT_DIR.mkdir(exist_ok=True)

    print(f"Found {len(gif_files)} GIF files.\n")

    successful = 0

    for gif in gif_files:
        output = OUTPUT_DIR / f"{gif.stem}.webm"

        print(f"Converting: {gif.name}")

        command = [
            "ffmpeg",
            "-y",
            "-i",
            str(gif),

            # WebM / VP9
            "-c:v",
            "libvpx-vp9",

            # Quality
            "-crf",
            "20",
            "-b:v",
            "0",

            # Keep the original frame rate
            "-vsync",
            "0",

            str(output),
        ]

        result = subprocess.run(
            command,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
        )

        if result.returncode == 0:
            print(f"  ✓ {output}")
            successful += 1
        else:
            print(f"  ✗ Failed: {gif.name}")
            print(result.stderr)

    print("\n" + "=" * 50)
    print(f"Finished: {successful}/{len(gif_files)}")
    print(f"WebM files: {OUTPUT_DIR.resolve()}")
    print("=" * 50)


if __name__ == "__main__":
    main()