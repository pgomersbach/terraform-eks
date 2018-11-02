#!/bin/bash
docker build -t jenkins .
docker tag jenkins pgomersbach/mn-jenkins:latest
docker push pgomersbach/mn-jenkins:latest
