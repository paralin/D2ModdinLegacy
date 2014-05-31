#!/bin/bash
export PORT=3000
export ROOT_URL="http://10.0.1.2:3000/"
export MONGO_URL=mongodb://root:3s3msqKx7qDTpQNyfWem@candidate.20.mongolayer.com:10131/d2moddin
export MONGO_OPLOG_URL=mongodb://root:3s3msqKx7qDTpQNyfWem@candidate.20.mongolayer.com:10131/local?authSource=d2moddin
export TEMP_DIR=/tmp/
meteor --port 3000 --production
