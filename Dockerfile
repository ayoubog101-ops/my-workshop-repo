FROM python:3.10-slim

WORKDIR /app

COPY ./backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY backend /app/backend

ENV FLASK_APP=backend.app
ENV FLASK_ENV=production

EXPOSE 8000
CMD ["gunicorn","-b","0.0.0.0:8000","backend.app:app"]
