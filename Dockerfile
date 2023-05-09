FROM python:3-slim

RUN apt-get update && \
    apt-get install --no-install-recommends -y git && \
    git clone --depth=1 https://github.com/frozenpandaman/s3s.git /app/s3s && \
    apt-get purge -y git && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /app/s3s-config && \
    ln -s /app/s3s-config/config.txt /app/s3s/config.txt && \
    pip install --no-cache-dir -r /app/s3s/requirements.txt

ENTRYPOINT ["python", "/app/s3s/s3s.py"]
CMD ["-r", "-M"]
STOPSIGNAL SIGINT
