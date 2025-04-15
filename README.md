# Cat Dog Classifier API

Contains code to query 3 models trained on the Cats VS Dogs dataset to classify between images of Cats and Dogs.
The types of models are : ResNet50 (categorical), CNN (binary) and ANN (binary)

## Installation

### Using docker image
Pull the docker image using `docker pull b1smuth/cat-dog-classifier-api:1.0.0`.

To run the image using `docker run b1smuth/cat-dog-classifier-api:1.0.0`

### Using source code
First clone the repository with all the submodules

`git clone --recurse-submodules https://github.com/bismuth01/cat-dog-classifier-api.git`

This might take a while since the .h5 files are large.
In the root directory of the repository, install all necessary pip packages by using the command
`pip install -r requirements.txt`

Then to start the API server
`fastapi dev main.py`

## How to use

To check if it's running, try a GET request on the `/status` endpoint.

Send a your image at `/predict_image` endpoint with key value `file` to get the prediction response.

## Sample response

```
{
    "ResNet":{
        "prediction":{
            "class":"Cat",
            "confidence":0.9368
            }
        },
    "CNN":{
        "prediction":{
            "class":"Cat",
            "confidence"::0.9964
            }
        },
    "ANN":{
        "prediction":{
            "class":"Dog",
            "confidence":0.5294
            }
        }
}
```

## How it works ?
Any image uploaded is resized to 128 x 128 pixels, which is the shape that the models take. For the ANN, it is also converted to greyscale since it takes only 1 color channel.

The accuracy of models in descending order is ResNet50, CNN, ANN.
