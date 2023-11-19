from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/run-python-script', methods=['POST'])
def run_python_script():
    script_path = request.json.get('script_path')
    args = request.json.get('args', [])

    try:
        result = subprocess.check_output(['python3', script_path] + args)
        return jsonify({'result': result.decode('utf-8')})
    except subprocess.CalledProcessError as e:
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)