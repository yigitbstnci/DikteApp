SHELL := /bin/zsh

PROJECT := Dikte.xcodeproj
SCHEME := Dikte
CONFIGURATION ?= Debug
DESTINATION ?= platform=macOS
APP_PATH_FILE := .build/dikte-app-path
LOG_DIR := $(HOME)/Library/Logs/Dikte
LOG_FILE := $(LOG_DIR)/dikte.log

.PHONY: generate build run test stop clean context-load context-save context-check

generate:
	@xcodegen generate

build: generate
	@xcodebuild -quiet \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-configuration "$(CONFIGURATION)" \
		build
	@mkdir -p .build
	@xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-configuration "$(CONFIGURATION)" \
		-showBuildSettings 2>/dev/null | \
		awk -F ' = ' '/TARGET_BUILD_DIR = / { dir = $$2 } /FULL_PRODUCT_NAME = / { name = $$2 } END { if (dir != "" && name != "") print dir "/" name }' > "$(APP_PATH_FILE)"
	@test -s "$(APP_PATH_FILE)"

run: stop build
	@mkdir -p "$(LOG_DIR)"
	@: > "$(LOG_FILE)"
	@printf "\033[38;5;111m-- ACTION   make       run.start                    %s\033[0m\n" "Dikte terminal log stream başlıyor. Çıkmak için Ctrl-C."
	@trap 'pkill -x Dikte 2>/dev/null || true' INT TERM EXIT; \
	app_path=$$(cat "$(APP_PATH_FILE)"); \
	printf "\033[38;5;245m-- INFO     make       run.app                      %s\033[0m\n" "$$app_path"; \
	open -n "$$app_path"; \
	tail -n +1 -f "$(LOG_FILE)" | awk '\
		/!!  ERROR/ { print "\033[38;5;203m" $$0 "\033[0m"; next } \
		/!!  WARNING/ { print "\033[38;5;214m" $$0 "\033[0m"; next } \
		/--  ACTION/ { print "\033[38;5;111m" $$0 "\033[0m"; next } \
		/--  INFO/ { print "\033[38;5;245m" $$0 "\033[0m"; next } \
		{ print } \
	'

test: generate
	@xcodebuild -quiet \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-destination "$(DESTINATION)" \
		test

stop:
	@pkill -x Dikte 2>/dev/null || true

clean:
	@rm -f "$(APP_PATH_FILE)"
	@xcodebuild -quiet \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-configuration "$(CONFIGURATION)" \
		clean

context-load:
	@scripts/context/load.sh

context-save:
	@test -n "$(SUMMARY)" || (echo 'usage: make context-save SUMMARY=/path/to/session.md TITLE="short-title"' >&2; exit 2)
	@SUMMARY="$(SUMMARY)" TITLE="$(TITLE)" scripts/context/save-session.sh

context-check:
	@scripts/context/check.sh
