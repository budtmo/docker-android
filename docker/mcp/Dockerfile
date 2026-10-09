FROM python:3.14.7-slim

RUN apt-get -qqy update && apt-get -qqy install --no-install-recommends \
    adb \
 && apt autoremove -y \
 && apt clean all \
 && rm -rf /var/lib/apt/lists/*

COPY mcp ./mcp
WORKDIR /mcp
RUN pip install --no-cache-dir -r requirements.txt

ARG EMULATOR_HOST=android-emulator
ARG EMULATOR_PORT=5555
ARG ADB_CONNECT_RETRIES=20
ARG ADB_CONNECT_RETRY_DELAY_SECONDS=5
ARG MCP_HOST=0.0.0.0
ARG MCP_PORT=8000

ENV PYTHONPATH=/mcp \
	PYTHONUNBUFFERED=1 \
	EMULATOR_HOST=${EMULATOR_HOST} \
	EMULATOR_PORT=${EMULATOR_PORT} \
	ADB_CONNECT_RETRIES=${ADB_CONNECT_RETRIES} \
	ADB_CONNECT_RETRY_DELAY_SECONDS=${ADB_CONNECT_RETRY_DELAY_SECONDS} \
	MCP_HOST=${MCP_HOST} \
	MCP_PORT=${MCP_PORT}

EXPOSE 8000

CMD ["python", "-m", "src.server"]
