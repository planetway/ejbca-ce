build:
	./jenkins-files/planetway/run_build.sh
	docker-compose build

up:
	docker-compose up

build-image-and-up:
	docker-compose build
	docker-compose up

down:
	docker-compose down -v
