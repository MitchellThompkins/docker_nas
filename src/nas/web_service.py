from flask import Flask, jsonify
import psutil

app = Flask(__name__)

@app.route('/')
def status():
    disk_usage = psutil.disk_usage('/mnt/raid')
    return jsonify({
        'total': disk_usage.total,
        'used': disk_usage.used,
        'free': disk_usage.free
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)

