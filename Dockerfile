# Start from a TensorFlow image that includes Python and GPU support if needed
FROM tensorflow/tensorflow:2.10.0

# Set working directory
WORKDIR /app

# Install Git and Git LFS
RUN apt-get update && \
    apt-get install -y git git-lfs

COPY . .

RUN git lfs install

RUN pip install --no-cache-dir -r requirements.txt

# Initialize and update submodules with LFS support
RUN git submodule update --init --recursive && \
    git submodule foreach 'git lfs pull'

ENV PORT=8000

EXPOSE $PORT

# Command to run your application
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
