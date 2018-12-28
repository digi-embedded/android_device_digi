# DATETIME is expected to be set from the environment (Jenkins)
ifndef DATETIME
DATETIME = $(shell date +'%Y%m%d%H%M%S')
endif

BUILDINFO_TARGET = $(TARGET_OUT_ETC)/build

.PHONY: buildinfo
buildinfo: $(BUILDINFO_TARGET)

$(BUILDINFO_TARGET):
	$(hide) mkdir -p $(dir $@)
	$(hide) ( \
		printf "%-16s%s\n" "Version:" "$(BUILD_ID)"; \
		printf "%-16s%s\n" "Build number:" "$(BUILD_NUMBER)"; \
		printf "%-16s%s\n" "Date:" "$(DATETIME)"; \
		printf "\n"; \
		repo forall -c '\
			printf "%-12s %-53s %s" \
				"$${REPO_REMOTE}" \
				"$${REPO_PROJECT} " \
				"$$(git rev-parse --verify --short HEAD)"; \
			if git diff-index --name-only HEAD | grep -qv "^scripts/package"; then \
				printf '%s' -dirty; \
			fi; \
			printf "\n"' \
		| sort -r -k1 \
	) > $@

ALL_DEFAULT_INSTALLED_MODULES += $(BUILDINFO_TARGET)