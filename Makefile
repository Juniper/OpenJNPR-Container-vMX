# Copyright (c) 2018, Juniper Networks, Inc.
# All rights reserved.

all: up

build: bionic trusty

bionic: FORCE
	docker build -f src/Dockerfile.bionic -t juniper/openjnpr-container-vmx:bionic src

trusty: FORCE
	docker build -f src/Dockerfile.trusty -t juniper/openjnpr-container-vmx:trusty src
	
FORCE: ;

license-eval.txt:
	curl -o license-eval.txt https://www.juniper.net/us/en/dm/free-vmx-trial/E421992502.txt

id_rsa.pub:
	cp ~/.ssh/id_rsa.pub .

up: license-eval.txt id_rsa.pub
	docker-compose up -d

regress: license-eval.txt id_rsa.pub regression/docker-compose.yml
	docker-compose -f regression/docker-compose.yml up -d
	regression/check.sh

ps:
	docker-compose ps
	docker-compose -f regression/docker-compose.yml ps
	./getpass.sh

down:
	docker-compose down
	docker-compose -f regression/docker-compose.yml down

clean:
	docker system prune -f
