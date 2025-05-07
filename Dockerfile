FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt . 
RUN pip install --no-cache-dir -r requirements.txt
COPY hello.py .
EXPOSE 6565
CMD ["python", "hello.py"]

