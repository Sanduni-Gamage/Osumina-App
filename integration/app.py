from email import message
import json
from flask_cors import CORS
from werkzeug.utils import secure_filename
from flask import Flask, Response, request , jsonify
import requests
import shutil
from inference import *
from bs4 import BeautifulSoup
import string, random
from flask import send_from_directory
import nltk, pickle


app = Flask(__name__)
CORS(app)

def listToString(s):
 
    strs = ""
    for ele in s:
        strs += ele
 
    return strs

@app.route('/visualization/<path:path>')
def send_report(path):
    return send_from_directory('visualization', path)

@app.route("/herbal", methods=["POST"])
def herbal():
    try:
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))

        print(request_data['url'])

        image_url = str(request_data['url'])
        filename = image_url.split("/")[-1]
        filename = filename.split("?alt=media&token")[0]
        filename = filename.split("-")[0]
        filename = filename.split("%")[1]+'.jpg'

        r = requests.get(image_url, stream = True)

        if r.status_code == 200:
            r.raw.decode_content = True
            
            with open('downloads/'+filename,'wb') as f:
                shutil.copyfileobj(r.raw, f)
                
            print('Image Downloaded: ','downloads/'+filename)

            herbal = predict_cnn('downloads/'+filename)
            diseases, treatments = predict_automl(herbal)

            json_dump = jsonify({"herbal":herbal,"diseases":str(listToString(diseases)),"treatments":str(listToString(treatments)),"success":"true"})

            return json_dump
        else:
            json_dump = jsonify({"herbal":"","diseases":"","treatments":"","success":"false"})

            return json_dump
    except:
        print("An exception occurred")
        json_dump = jsonify({"success":"false"})

        return json_dump

@app.route("/distribution", methods=["GET"])
def distribution():
    try:
        file = open(folium_map_path, "r")
        print(file.read())

        json_dump = jsonify({"html":str(file.read()),"success":"true"})

        return json_dump

    except Exception as e:
        return Response(
                    response=json.dumps({
                        "status": "Unscuccessful",
                        "error": str(e)
                    }),
                    status=500,
                    mimetype="application/json"
        )

@app.route("/recommndation", methods=["POST"])
def recommndation():
    try:
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))

        print(request_data['userid'])
        message = request_data
        userid = message['userid']
        postid = int(message['postid'])

        m1_json, m2_json = run_recommendation(userid, postid)

        json_dump = jsonify({"m1_json":str(m1_json),"m2_json":str(m2_json),"success":"true"})

        return json_dump


    except Exception as e:
        json_dump = jsonify({"m1_json":"","m2_json":"","success":"true"})

        return json_dump

intents_path = 'data/intents.json'
stem_path = 'data/stem_dict.txt'

max_length = 12
stem_path = 'data/stem_dict.txt'
intents_path = 'data/intents.json'
encoder_path = 'weights/ENCODER - BOT.pkl'
tokenizer_path = 'weights/TOKENIZER - BOT.pkl'
chatbot_weights = 'weights/DISEASE-BOT.h5'

with open(tokenizer_path, 'rb') as fp:
    bot_tokenizer = pickle.load(fp)

with open(encoder_path, 'rb') as fp:
    bot_encoder = pickle.load(fp)

with open(intents_path, encoding="utf8") as content:
    bot_intends = json.load(content)

with open(intents_path, encoding="utf8") as content:
    data1 = json.load(content)

bot_model = tf.keras.models.load_model(chatbot_weights)

bot_responses={}
for intent in data1["intents"]:
    bot_responses[intent['tag']]=intent['responses']

def make_stem_dict():
    lemma_dict = {}
    with open(stem_path, encoding="utf8") as f:
        for line in f:
            token, lemma = line.split('\t')
            lemma_dict[token.strip()] = lemma.strip()
    return lemma_dict 

def clean_str(review):
    review = ''.join([char for char in list(review) if (char not in string.punctuation)])
    return review.lower().strip()

def word_lemmatization(
                       review, 
                       lemma_dict=make_stem_dict()
                        ):
    review = review.split(' ')
    review = [token.strip() for token in review]
    review = [lemma_dict[token] if (token in lemma_dict) else token for token in  review]
    review = [token for token in review if len(token) > 0]
    review = ' '.join(review)
    return review

def preprocess_text(review):
    review = clean_str(review)
    review = word_lemmatization(review)
    return review

def bot_inference(user_input):
    prediction_input = preprocess_text(user_input)
    prediction_input = bot_tokenizer.texts_to_sequences([prediction_input])
    prediction_input = tf.keras.preprocessing.sequence.pad_sequences(
                                                                prediction_input, 
                                                                maxlen=max_length, 
                                                                padding='pre', 
                                                                truncating='pre'
                                                                )# Pad Train data
    
    #getting output from model
    output = bot_model.predict(prediction_input)
    output = output.argmax()
    
    #finding the right tag and predicting
    response_tag = bot_encoder.inverse_transform([output])[0]
    response = random.choice(bot_responses[response_tag])
    return response

@app.route("/bot", methods=["POST"])
def bot():
    try:
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))

        print(request_data['msg'])
        print(bot_inference(request_data['msg']))
        res = bot_inference(request_data['msg'])

        json_dump = jsonify({"reply":str(res),"success":"true"})

        return json_dump


    except Exception as e:
        json_dump = jsonify({"reply":"","success":"true"})

        return json_dump

if __name__ == '__main__':
    app.run(
            debug=True, 
            host='0.0.0.0', 
            port=5000
            )