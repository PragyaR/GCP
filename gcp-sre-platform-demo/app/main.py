from flask import Flask, jsonify, request
import time
import random
import logging
import os

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

@app.route("/")
def health():
    start = time.time()

    # simulate occasional failure
    if random.random() < float(os.getenv("ERROR_RATE", "0.02")):
        logging.error({
            "service": "demo-api",
            "endpoint": "/",
            "status": 500,
            "message": "simulated error"
        })
        return jsonify({"error": "internal error"}), 500

    latency = int((time.time() - start) * 1000)
    logging.info({
        "service": "demo-api",
        "endpoint": "/",
        "status": 200,
        "latency_ms": latency
    })

    return jsonify({"status": "ok", "latency_ms": latency})
