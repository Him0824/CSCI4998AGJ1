# from mpl_toolkits.mplot3d import Axes3D
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt # plotting
import matplotlib.image as mpimg
import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)
import os # accessing directory structure

DATASET_PATH = "./fashion-dataset/"


df = pd.read_csv(DATASET_PATH + "styles.csv", nrows=5000)
df['image'] = df.apply(lambda row: str(row['id']) + ".jpg", axis=1)
df = df.reset_index(drop=True)
df.head(10)

import cv2
def plot_figures(figures, nrows = 1, ncols=1,figsize=(8, 8)):
    """Plot a dictionary of figures.

    Parameters
    ----------
    figures : <title, figure> dictionary
    ncols : number of columns of subplots wanted in the display
    nrows : number of rows of subplots wanted in the figure
    """

    fig, axeslist = plt.subplots(ncols=ncols, nrows=nrows,figsize=figsize)
    for ind,title in enumerate(figures):
        axeslist.ravel()[ind].imshow(cv2.cvtColor(figures[title], cv2.COLOR_BGR2RGB))
        axeslist.ravel()[ind].set_title(title)
        axeslist.ravel()[ind].set_axis_off()
    
def img_path(img):
    return DATASET_PATH+"/images/"+img

import tensorflow as tf
import keras
from keras import Model
from keras.applications.resnet50 import ResNet50
from keras.preprocessing import image
from keras.applications.resnet50 import preprocess_input, decode_predictions
from keras.layers import GlobalMaxPooling2D
tf.__version__

# Input Shape
img_width, img_height, _ = 224, 224, 3 #load_image(df.iloc[0].image).shape

# Pre-Trained Model
base_model = ResNet50(weights='imagenet', 
                      include_top=False, 
                      input_shape = (img_width, img_height, 3))
base_model.trainable = False

# Add Layer Embedding
model = keras.Sequential([
    base_model,
    GlobalMaxPooling2D()
])



def get_embedding(model, img_name):
    # Reshape
    img = image.load_img(img_path(img_name), target_size=(img_width, img_height))
    # img to Array
    x   = image.img_to_array(img)
    # Expand Dim (1, w, h)
    x   = np.expand_dims(x, axis=0)
    # Pre process Input
    x   = preprocess_input(x)
    return model.predict(x).reshape(-1)


#import swifter
import os
import pickle

# Parallel apply
df_embs = None

file_path = 'df_embs.pkl'

if os.path.exists(file_path):
    with open(file_path, 'rb') as file:
        df_embs = pickle.load(file)
else:
    df_sample      = df#.sample(100)
    map_embeddings = df_sample['image'].apply(lambda img: get_embedding(model, img))
    df_embs        = map_embeddings.apply(pd.Series)
    with open(file_path, 'wb') as file:
        pickle.dump(df_embs, file)

df_embs.head()

# https://scikit-learn.org/stable/modules/generated/sklearn.metrics.pairwise_distances.html
from sklearn.metrics.pairwise import pairwise_distances

# Calcule DIstance Matriz
cosine_sim = 1-pairwise_distances(df_embs, metric='cosine')
cosine_sim[:4, :4]

df.iloc[2993]

indices = pd.Series(range(len(df)), index=df.index)
indices

from PIL import Image
import base64
import io

def get_recommend_by_image_name(base64_image):
    global df_embs
    df_embs = df_embs.drop(9999, errors='ignore')
    if base64_image.startswith("data:image/"):
        base64_image = base64_image.split(",")[1]
    image_bytes = base64.b64decode(base64_image)
    img = Image.open(io.BytesIO(image_bytes))
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis=0)
    x = preprocess_input(x)
    target_embing = model.predict(x).reshape(-1)
    target_embing.shape
    df_embs.loc[9999] = target_embing
    new_cosine_sim = 1-pairwise_distances(df_embs, metric='cosine')

    indices = pd.Series(range(len(df_embs)), index=df_embs.index)
    sim_idx    = indices[9999]
    sim_scores = list(enumerate(new_cosine_sim[sim_idx]))
    sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)
    idx_rec    = [i[0] for i in sim_scores]
    idx_sim    = [i[1] for i in sim_scores]
    idx_rec, idx_sim = indices.iloc[idx_rec].index, idx_sim

    filtered_idx_rec = []
    filtered_idx_sim = []
    for i, x in enumerate(idx_rec):
        if x in df.index:
            filtered_idx_rec.append(x)
            filtered_idx_sim.append(idx_sim[i])
            
    filtered_idx_rec = filtered_idx_rec[:6]
    filtered_idx_sim = filtered_idx_sim[:6]

    result = [x for x in df.loc[filtered_idx_rec[:6]]["image"]] 
    return result

def get_recommend_by_image_tag(base64_image):
    global df_embs
    df_embs = df_embs.drop(9999, errors='ignore')
    if base64_image.startswith("data:image/"):
        base64_image = base64_image.split(",")[1]
    image_bytes = base64.b64decode(base64_image)
    img = Image.open(io.BytesIO(image_bytes))
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis=0)
    x = preprocess_input(x)
    target_embing = model.predict(x).reshape(-1)
    target_embing.shape
    df_embs.loc[9999] = target_embing
    new_cosine_sim = 1-pairwise_distances(df_embs, metric='cosine')

    indices = pd.Series(range(len(df_embs)), index=df_embs.index)
    sim_idx    = indices[9999]
    sim_scores = list(enumerate(new_cosine_sim[sim_idx]))
    sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)
    idx_rec    = [i[0] for i in sim_scores]
    idx_sim    = [i[1] for i in sim_scores]
    idx_rec, idx_sim = indices.iloc[idx_rec].index, idx_sim

    filtered_idx_rec = []
    filtered_idx_sim = []
    for i, x in enumerate(idx_rec):
        if x in df.index:
            filtered_idx_rec.append(x)
            filtered_idx_sim.append(idx_sim[i])
            
    filtered_idx_rec = filtered_idx_rec[:6]
    filtered_idx_sim = filtered_idx_sim[:6]

    result = [x for x in df.loc[filtered_idx_rec[:6]]["productDisplayName"]] 
    return result



import json

def imageEncode(name , tag):
    path = "./fashion-dataset/images/"
    image_list = []
    x = 0
    for i in name[:6]:
        with open(path + str(i),'rb') as imagefile:
            base64_image = base64.b64encode(imagefile.read()).decode('utf-8')
            temp = {
                'name' : str(i),
                'data' : base64_image,
                'tag ' : tag[x]
            }
            image_list.append(temp)
            x += 1
    result = {'result': image_list}
    print(json.dumps(result)) 
   


input_img_path = './1.webp'
x = get_recommend_by_image_name(input_img_path)
y = get_recommend_by_image_tag(input_img_path)
imageEncode(x,y)

