from flask import Flask, Response, abort
import ffmpeg
import threading
import pychromecast
import time

app = Flask(__name__)
app.config.from_prefixed_env()

RATE = app.config.get("RATE", 44100)
CHANK = app.config.get("CHANK", 16)
DEVICE = app.config.get("DEVICE")
PLAYER = app.config.get("PLAYER")
if DEVICE is None:
    raise RuntimeError("Please configure FLASK_DEVICE value")

class cc_monitor(threading.Thread):
    def run(self):
        while True:
            self.connect_cast()

    def connect_cast(self):
        chromecasts = []
        while len(chromecasts) == 0:
            print(f"Searching casts")
            chromecasts, _ = pychromecast.get_listed_chromecasts(friendly_names=[ PLAYER ]) \
                if PLAYER else pychromecast.get_chromecasts()
            time.sleep(1)
        cast = chromecasts[0]
        print(f"Using cast {cast}")
        cast.wait()
        sock = cast.socket_client.get_socket()
        selfaddr, _ = sock.getsockname()
        mc = cast.media_controller
        print(f"playing http://{selfaddr}:5000")
        mc.play_media(f"http://{selfaddr}:5000", "audio/wav", stream_type="LIVE")
        state = None
        while state != "PLAYING":
            mc.update_status()
            new_state = mc.status.player_state
            if state != new_state:
                state = new_state
                print(f"Cast state: {state}")
            time.sleep(0.05)
        mc.seek(position=None)
        while True:
            mc.update_status()
            new_state = mc.status.player_state
            if state != new_state:
                state = new_state
                print(f"Cast state: {state}")
            time.sleep(1)

monitor = cc_monitor()
monitor.start()

@app.route('/')
def audio_unlim():
    """Audio streaming generator"""
    proc = (ffmpeg
            .input(DEVICE, format="alsa", ar=RATE)
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
