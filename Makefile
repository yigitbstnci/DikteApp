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
	@mkdir -p "$(LOG_DIR)" .build
	@: > "$(LOG_FILE)"
	@printf "\033[38;5;111m00:00:00.000 ACT make.run.start | %s\033[0m\n" "Dikte terminal log stream başlıyor. Uygulama kapanınca veya Ctrl-C ile biter."
	@trap 'pkill -x Dikte 2>/dev/null || true; test -n "$$tail_pid" && kill "$$tail_pid" 2>/dev/null || true; test -n "$$awk_pid" && kill "$$awk_pid" 2>/dev/null || true; test -n "$$log_pipe" && rm -f "$$log_pipe" 2>/dev/null || true' INT TERM EXIT; \
	app_path=$$(cat "$(APP_PATH_FILE)"); \
	log_pipe=".build/dikte-log-pipe-$$$$"; \
	printf "\033[38;5;250m00:00:00.000 INF make.run.app | %s\033[0m\n" "$$app_path"; \
	open -n "$$app_path"; \
	launch_deadline=$$((SECONDS + 15)); \
	until pgrep -x Dikte >/dev/null 2>&1; do \
		if (( SECONDS >= launch_deadline )); then \
			printf "\033[38;5;203m00:00:00.000 ERR make.run.launch | %s\033[0m\n" "Dikte process başlatılamadı."; \
			exit 1; \
		fi; \
		sleep 0.1; \
	done; \
	mkfifo "$$log_pipe"; \
	tail -n +1 -f "$(LOG_FILE)" > "$$log_pipe" & \
	tail_pid=$$!; \
	awk '\
		BEGIN { reset = "\033[0m"; dim = "\033[38;5;245m"; target = "\033[38;5;150m"; msg = "\033[38;5;252m"; meta = "\033[38;5;110m"; } \
		function level_color(level) { \
			if (level == "ERR") return "\033[38;5;203m"; \
			if (level == "WRN") return "\033[38;5;214m"; \
			if (level == "ACT") return "\033[38;5;111m"; \
			return "\033[38;5;250m"; \
		} \
		{ \
			count = split($$0, parts, " \\| "); \
			split(parts[1], head, " "); \
			if (head[2] == "") { print; next } \
			color = level_color(head[2]); \
			printf "%s%s%s %s%s%s %s%s%s", dim, head[1], reset, color, head[2], reset, target, head[3], reset; \
			if (count >= 2 && parts[2] != "") printf " %s|%s %s%s%s", dim, reset, msg, parts[2], reset; \
			if (count >= 3 && parts[3] != "") printf " %s|%s %s%s%s", dim, reset, meta, parts[3], reset; \
			for (i = 4; i <= count; i++) printf " %s|%s %s%s%s", dim, reset, meta, parts[i], reset; \
			print ""; \
		} \
	' < "$$log_pipe" & \
	awk_pid=$$!; \
	while pgrep -x Dikte >/dev/null 2>&1; do \
		sleep 0.5; \
	done; \
	kill "$$tail_pid" 2>/dev/null || true; \
	wait "$$awk_pid" 2>/dev/null || true; \
	printf "\033[38;5;245m00:00:00.000 INF make.run.stop | %s\033[0m\n" "Dikte kapandı; terminal log stream duruyor."

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
