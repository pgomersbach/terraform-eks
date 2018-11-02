#!/bin/bash
docker build -t artifactory .
docker tag artifactory pgomersbach/mn-artifactory:latest
docker push pgomersbach/mn-artifactory:latest
