SKILLS_DIR := skills
TARGET_DIR := $(HOME)/.claude/skills

# All skill directories (exclude INDEX.md)
SKILLS := $(shell find $(SKILLS_DIR) -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

.PHONY: install uninstall list diff status clean help

## install: Deploy all skills to ~/.claude/skills (overwrites existing)
install:
	@echo "Installing $(words $(SKILLS)) skills to $(TARGET_DIR)..."
	@mkdir -p $(TARGET_DIR)
	@for skill in $(SKILLS); do \
		echo "  → $$skill"; \
		rm -rf $(TARGET_DIR)/$$skill; \
		cp -R $(SKILLS_DIR)/$$skill $(TARGET_DIR)/$$skill; \
	done
	@echo ""
	@echo "✅ $(words $(SKILLS)) skills installed to $(TARGET_DIR)"

## update: Same as install (alias)
update: install

## uninstall: Remove only skills that exist in this pack from ~/.claude/skills
uninstall:
	@echo "Removing skills pack from $(TARGET_DIR)..."
	@for skill in $(SKILLS); do \
		if [ -d "$(TARGET_DIR)/$$skill" ]; then \
			echo "  ✕ $$skill"; \
			rm -rf $(TARGET_DIR)/$$skill; \
		fi; \
	done
	@echo ""
	@echo "✅ Skills pack removed (other skills untouched)"

## list: Show all skills in the pack
list:
	@echo "Skills Pack ($(words $(SKILLS)) skills):"
	@echo ""
	@for skill in $(SKILLS); do \
		desc=$$(head -5 $(SKILLS_DIR)/$$skill/SKILL.md 2>/dev/null | grep -m1 "^name:" | sed 's/name: //'); \
		echo "  /$$skill"; \
	done

## diff: Show which skills differ from installed versions
diff:
	@echo "Comparing repo vs installed skills..."
	@echo ""
	@changed=0; new=0; same=0; \
	for skill in $(SKILLS); do \
		if [ ! -d "$(TARGET_DIR)/$$skill" ]; then \
			echo "  + $$skill (new — not installed)"; \
			new=$$((new + 1)); \
		elif ! diff -rq $(SKILLS_DIR)/$$skill $(TARGET_DIR)/$$skill > /dev/null 2>&1; then \
			echo "  ~ $$skill (modified)"; \
			changed=$$((changed + 1)); \
		else \
			same=$$((same + 1)); \
		fi; \
	done; \
	echo ""; \
	echo "$$new new | $$changed modified | $$same up-to-date"

## status: Show installed vs repo skills
status:
	@echo "Installed skills not in this pack:"
	@for skill in $$(ls $(TARGET_DIR) 2>/dev/null); do \
		if [ ! -d "$(SKILLS_DIR)/$$skill" ]; then \
			echo "  ⊘ $$skill (external)"; \
		fi; \
	done
	@echo ""
	@echo "Pack skills not yet installed:"
	@for skill in $(SKILLS); do \
		if [ ! -d "$(TARGET_DIR)/$$skill" ]; then \
			echo "  + $$skill"; \
		fi; \
	done

## clean: Remove .DS_Store files from skills directory
clean:
	@find $(SKILLS_DIR) -name ".DS_Store" -delete 2>/dev/null
	@echo "✅ Cleaned .DS_Store files"

## help: Show available targets
help:
	@echo "Claude Skills Pack — Makefile targets"
	@echo ""
	@grep -E '^## ' Makefile | sed 's/## /  make /' | sed 's/: /\t— /'
