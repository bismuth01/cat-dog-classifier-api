FROM tensorflow/tensorflow:2.19.0

WORKDIR /app

RUN apt-get update && apt-get install -y libgl1-mesa-glx libglib2.0-0
RUN mkdir -p ./models/cat-dog-resnet50/ ./models/cat-dog-CNN/ ./models/CatDogANN/
RUN python -m venv /app/venv

COPY main.py ./main.py
COPY ./models/cat-dog-resnet50/CatDogResNet50.h5 ./models/cat-dog-resnet50/CatDogResNet50.h5
COPY ./models/cat-dog-CNN/CatDogCNN.h5 ./models/cat-dog-CNN/CatDogCNN.h5
COPY ./models/CatDogANN/CatDogANN.h5 ./models/CatDogANN/CatDogANN.h5

COPY requirements.txt ./requirements.txt

SHELL ["/bin/bash", "-c"]
RUN source /app/venv/bin/activate

RUN pip install --no-cache-dir -r requirements.txt

ENV PORT=8000

EXPOSE $PORT

CMD ["/bin/bash", "-c", "source /app/venv/bin/activate && uvicorn main:app --host 0.0.0.0 --port $PORT"]
