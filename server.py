from flask import Flask, Response
import ffmpeg

app = Flask(__name__)

RATE = 44100

@app.route('/')
def audio_unlim():
    """Audio streaming generator"""
    print ("Running proc!")
    proc = (ffmpeg
            .input("hw:1", format="alsa", ar=RATE)
            .output("pipe:", format="wav")
            .global_args("-re")
            .run_async(pipe_stdout=True, quiet=True, overwrite_output=True)
    )
    def sound():
        yield proc.stdout.read(44)
        try:
            while True:
                yield proc.stdout.read(16)
        finally:
            proc.kill()
            proc.wait()

    return Response(sound(), mimetype="audio/x-wav")

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True, threaded=False, port=5000, use_reloader=False)
