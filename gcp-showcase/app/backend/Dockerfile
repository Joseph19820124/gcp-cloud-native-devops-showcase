FROM python:3.12-slim AS base

WORKDIR /app

RUN groupadd --system app && useradd --system --gid app app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Build version baked into the image (CI passes the commit SHA). Read back at
# runtime via /api/hello so you can tell exactly which build is deployed.
ARG APP_VERSION=dev
ENV APP_VERSION=$APP_VERSION

USER app

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
