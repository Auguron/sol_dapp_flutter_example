.PHONY: webpack build_web debug profile_build run


webpack:
	npm run webpack

build_web:
	flutter build web

debug:
	npm run webpack && \
	flutter run -d chrome

human_readable_build:
	npm run webpack && \
	flutter build web --profile --dart-define=Dart2jsOptimization=O0 && \
	python -m http.server 8080 --directory build/web

run:
	npm run webpack && \
	flutter build web && \
	python -m http.server 8080 --directory build/web
