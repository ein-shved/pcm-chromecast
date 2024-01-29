from flask import Flask, Response, abort
import ffmpeg

app = Flask(__name__)
app.config.from_prefixed_env()

RATE = 44100
CHANK = 16

@app.route('/')
def audio_unlim():
    """Audio streaming generator"""
    proc = (ffmpeg
            .input("hw:1", format="alsa", ar=RATE)
            .output("pipe:", format="wav")
            .global_args("-re", "-nostdin")
            .run_async(pipe_stdout=True, quiet=True, overwrite_output=True)
    )
    header = proc.stdout.read(44)
    if proc.poll() is not None:
        abort(503)
    def sound():
        yield header
        try:
            while proc.poll() is None:
                yield proc.stdout.read(CHANK)
        finally:
            proc.kill()
            proc.wait()

    return Response(sound(), mimetype="audio/x-wav")
