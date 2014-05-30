#!/bin/bash
export PORT=80
export ROOT_URL="http://ddp.d2modd.in/"
export MONGO_URL=mongodb://root:3s3msqKx7qDTpQNyfWem@candidate.20.mongolayer.com:10131/d2moddin
export MONGO_OPLOG_URL=mongodb://root:3s3msqKx7qDTpQNyfWem@candidate.20.mongolayer.com:10131/local?authSource=d2moddin
export TEMP_DIR=/tmp/
meteor --production --port 80
