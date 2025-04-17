complete-clean-docker:
	docker system prune -a --volumes
	
clean-docker:
	docker system prune
	
dev-start:
	docker compose -p atlas_dev -f deploy/compose/compose.dev.yml up -d

dev-stop:
	docker compose -p atlas_dev -f deploy/compose/compose.dev.yml down

dev-restart:
	docker compose -p atlas_dev -f deploy/compose/compose.dev.yml down
	docker compose -p atlas_dev -f deploy/compose/compose.dev.yml build --no-cache
	docker compose -p atlas_dev -f deploy/compose/compose.dev.yml up -d

dev-rm:
	docker compose -p atlas_dev -f deploy/compose/compose.dev.yml down --rmi all -v