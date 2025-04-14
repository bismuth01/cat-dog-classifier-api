FROM alpine/git:latest as git-clone

RUN apk add --no-cache git-lfs && git lfs install

WORKDIR /app
RUN git clone --recurse-submodules https://github.com/bismuth01/cat-dog-classifier-api.git && \
    git lfs pull && \
    git submodule foreach 'git lfs pull'

FROM tensorflow/tensorflow:2.10.0

WORKDIR /app

COPY --from=git-clone /app .

RUN pip install --no-cache-dir -r requirements.txt

ENV PORT=8000

EXPOSE $PORT

CMD uvicorn main:app --host 0.0.0.0 --port $PORT
