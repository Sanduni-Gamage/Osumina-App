import os
import folium
import cv2 as cv
import numpy as np
import pandas as pd
import seaborn as sns
import tensorflow as tf
import pycaret.classification
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from folium.plugins import MarkerCluster


automl_model = pycaret.classification.load_model('weights/Final SVM Model')
herbal_csv_file = 'files/herbal.csv'

def predict_automl(herbal):
    df_herbal = pd.read_csv(herbal_csv_file)
    df_herbal = df_herbal[['pnse', 'diseases', 'Treatments']]

    predictions = pycaret.classification.predict_model(automl_model, data=df_herbal)
    predictions['Label'] = predictions['pnse'].values
    del predictions ['pnse']

    Pherbal = predictions[predictions['Label'] == herbal]
    Pherbal = Pherbal[['diseases', 'Treatments']]
    diseases = Pherbal['diseases'].values
    treatments = Pherbal['Treatments'].values
    return diseases, treatments

class_dict_cnn = {
                0: 'Adathoda',
                1: 'Araththa',
                2: 'Aththora',
                3: 'Edaru',
                4: 'Iguru Piyali',
                5: 'Nika'
            }
cnn_weights = 'weights/best_bottleneck_finetuned_model.hdf5'
cnn_model = tf.keras.models.load_model(cnn_weights)

def listToString(s):
 
    str1 = ""
    for ele in s:
        str1 += ele
 
    return str1

image = cv.imread('downloads/2F1668304302031218.jpg')
image = cv.resize(image, (224, 224))
image = image / 255.0
image = np.expand_dims(image, axis=0)
prediction = cnn_model.predict(image)
prediction = np.argmax(prediction)
print(class_dict_cnn[prediction])

diseases, treatments = predict_automl(class_dict_cnn[prediction])

print(listToString(diseases))
print(listToString(treatments))
