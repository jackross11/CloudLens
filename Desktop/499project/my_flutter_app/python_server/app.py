from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)

#create a folder
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/upload', methods=['POST'])
def upload_image():
    if 'photo' not in request.files:
        return jsonify({'message': 'files not found'}), 400

    file = request.files['photo']

    if file.filename == '':
        return jsonify({'message': 'files not selected'}), 400

    filename = secure_filename(file.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)

    # save
    file.save(filepath)

    return jsonify({
        'message': 'successfully upload',
        'filePath': filepath  
    }), 200

if __name__ == '__main__':
    app.run(debug=True, port=5000)
