BINARY = vsphere-influxdb-go
GOARCH = amd64
CURRENT_DIR=$(shell pwd)
VAULT_FILE=~/vault.txt

all: env glide linux darwin windows

build: setup config

collect:
	chmod +x bin/linux-amd64/vsphere-influxdb-go && \
	bin/linux-amd64/vsphere-influxdb-go -config deploy/vsphere-influxdb.json

test_collect:
	chmod +x bin/darwin-amd64/vsphere-influxdb-go && \
	bin/darwin-amd64/vsphere-influxdb-go -config deploy/vsphere-influxdb.json

clean:
	rm -rf ${CURRENT_DIR}/bin

setup:
	docker run --rm -v "${CURRENT_DIR}":/go/src/${BINARY} -w /go/src/${BINARY} golang:1.8 make all

config:
	ansible-playbook ./ci/create-config.yml --vault-password-file ${VAULT_FILE} --connection=local

env:
	go env

glide:
	curl https://glide.sh/get | sh && \
	glide up && \
	glide install

linux:
	cd src && \
	GOOS=linux GOARCH=${GOARCH} go build -o ../bin/linux-${GOARCH}/${BINARY} . ; \
	cd - >/dev/null

darwin:
	cd src && \
	GOOS=darwin GOARCH=${GOARCH} go build -o ../bin/darwin-${GOARCH}/${BINARY} . ; \
	cd - >/dev/null

windows:
	cd src && \
	GOOS=windows GOARCH=${GOARCH} go build -o ../bin/windows-${GOARCH}/${BINARY}.exe . ; \
	cd - >/dev/null

.PHONY: all setup clean build env glide linux darwin windows deploy
