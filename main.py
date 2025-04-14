from typing import Union
from tensorflow.keras.models import load_model, Model
from tensorflow.keras.preprocessing import image
import cv2
import asyncio
from fastapi import FastAPI, File, UploadFile
import numpy as np

app = FastAPI()

IMG_SIZE = (128,128)

resnet = load_model('./models/cat-dog-resnet50/CatDogResNet50.h5')
cnn = load_model('./models/cat-dog-CNN/CatDogCNN.h5')
ann = load_model('./models/CatDogANN/CatDogANN.h5')

def preprocess_image(file_bytes: bytes, model_type: str):
    np_arr = np.frombuffer(file_bytes, np.uint8)
    if model_type == 'ann':
        image = cv2.imdecode(np_arr, cv2.IMREAD_GRAYSCALE) # ANN takes in only 1 greyscale channel
    else:
        image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    image = cv2.resize(image, IMG_SIZE) # Image size taken in by models
    image = image / 255.0 # Normalize image

    if model_type == 'ann':
        image = image.reshape((128, 128, 1))
    else:
        image = image.reshape((128,128, 3))

    image = np.expand_dims(image, axis=0)

    return image

async def predict(img: np.ndarray, model: Model, model_type: str):
    prediction = model.predict(img)[0]
    class_labels = ["Cat", "Dog"]

    # ResNet is categorical while CNN and ANN are binary
    if model_type == 'resnet':
        index = int(np.argmax(prediction))
        predicted_class = class_labels[index]
        confidence = float(prediction[index]) # convert to regular float for JSON serialization
    else:
        if prediction[0] > 0.5:
            predicted_class = "Dog"
            confidence = float(prediction[0])
        else:
            predicted_class = "Cat"
            confidence = float(1.0 - prediction[0])

    print(f"[LOG] Prediction from {model_type.upper()}: {prediction}")

    return {
        "class": predicted_class,
        "confidence": round(confidence, 4)
    }



@app.get("/status")
def read_root():
    return {"status": "Running"}

@app.post("/predict_image")
async def predict_image(file: UploadFile):
    file_bytes = await file.read()
    ann_img_array = preprocess_image(file_bytes, 'ann')
    cnn_img_array = preprocess_image(file_bytes, 'cnn')
    resnet_img_array = preprocess_image(file_bytes, 'resnet')

    tasks = [
        predict(resnet_img_array, resnet, 'resnet'),
        predict(cnn_img_array, cnn, 'cnn'),
        predict(ann_img_array, ann, 'ann')
    ]

    results = await asyncio.gather(*tasks)

    return {
        "ResNet": {"prediction": results[0]},
        "CNN": {"prediction": results[1]},
        "ANN": {"prediction": results[2]}
    }