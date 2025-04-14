# Start from a TensorFlow image that includes Python and GPU support if needed
FROM tensorflow/tensorflow:2.10.0

# Set working directory
WORKDIR /app

# Install Git and Git LFS
RUN apt-get update && \
    apt-get install -y git git-lfs && \
    git lfs install

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Clone your repository with LFS support
# Note: You may need to use SSH keys or access tokens for private repos
RUN git clone https://github.com/your-username/cat-dog-classifier-api.git . && \
    git lfs pull

# Initialize and update submodules with LFS support
RUN git submodule update --init --recursive && \
    git submodule foreach 'git lfs pull'

# Copy your application code
COPY . .

ENV PORT=8000

EXPOSE $PORT

# Command to run your application
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
