#!/usr/bin/env python3

import time
import argparse
import pychromecast
from pychromecast import Chromecast

parser = argparse.ArgumentParser(description='Run audio player with chromcast for swyh')
parser.add_argument('--player', '-p', default=None,
                    help='Name of player to discover')
parser.add_argument('--port', '-r', default=5901,
                    help='Port of local server')
parser.add_argument('--path', '-t', default="stream/swyh.wav",
                    help='Path to stream')
args=parser.parse_args()

chromecasts : list [Chromecast] = []
while len(chromecasts) == 0:
    print("Searching casts")
    chromecasts, _ = pychromecast.get_listed_chromecasts(friendly_names=[ args.player ]) \
        if args.player else pychromecast.get_chromecasts()
    time.sleep(1)
cast = chromecasts[0]
print(f"Using cast {cast}")

cast.wait()
sock = cast.socket_client.get_socket()
selfaddr, _ = sock.getsockname()
url = f"http://{selfaddr}:{args.port}/{args.path}"
mc = cast.media_controller

state = None
while state != "PLAYING":
    mc.update_status()
    new_state = mc.status.player_state
    if state != new_state:
        state = new_state
        print(f"Cast state: {state}")
    if state not in ("BUFFERING", "PLAYING"):
        print(f"playing {url}")
        mc.play_media(url, "audio/wav", stream_type="LIVE")
    time.sleep(3)

print("Finished")
