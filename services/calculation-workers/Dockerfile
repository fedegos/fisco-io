# Fisco.io - Calculation Workers
# Python workers for heavy computation and data processing

FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Placeholder: replace with actual entrypoint when consumers are implemented
CMD ["python", "-m", "src.consumers" ]
