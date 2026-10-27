FROM python:3.15.0-slim

RUN apt-get -qqy update && apt-get -qqy install --no-install-recommends \
    adb \
 && apt autoremove -y \
 && apt clean all \
 && rm -rf /var/lib/apt/lists/*

COPY mcp ./mcp
WORKDIR /mcp
RUN pip install --no-cache-dir -r requirements.txt

ENV PYTHONPATH=/mcp \
	PYTHONUNBUFFERED=1

EXPOSE 8000

CMD ["python", "-m", "src.server"]
