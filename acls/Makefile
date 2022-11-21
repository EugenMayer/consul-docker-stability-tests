test:
	docker-compose down -v > /dev/null 2>&1 || true
	docker-compose up server -d
	docker-compose up client1 -d
	docker-compose up client2 -d
	./test.sh
