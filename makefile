.PHONY: build
build:
	docker build -t nas-image .

.PHONY: run
run:
	docker run -d --name nas-container -p 445:445 -v /path/to/local/disks:/mnt/raid nas-image
