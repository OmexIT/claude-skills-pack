SKILLS_DIR := skills
TARGET_DIR := $(HOME)/.claude/skills

# All skill directories (exclude INDEX.md)
SKILLS := $(shell find $(SKILLS_DIR) -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

.PHONY: install uninstall list diff status clean help overnight overnight-agent overnight-dry-run cron-install cron-remove

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

## overnight: Run tasks autonomously via CLI (edit scripts/tasks.txt first)
overnight:
	@chmod +x scripts/overnight.sh
	@scripts/overnight.sh

## overnight-agent: Run tasks via Agent SDK (pip install claude-agent-sdk)
overnight-agent:
	@python scripts/overnight-agent.py

## overnight-dry-run: Preview what overnight would run
overnight-dry-run:
	@chmod +x scripts/overnight.sh
	@scripts/overnight.sh --dry-run

## cron-install: Schedule overnight run at 10pm weekdays
cron-install:
	@(crontab -l 2>/dev/null | grep -v "claude-skills-pack/scripts/overnight"; \
	  echo "0 22 * * 1-5 cd $(CURDIR) && ./scripts/overnight.sh >> logs/cron.log 2>&1") | crontab -
	@echo "✅ Cron job installed: 10pm Mon-Fri"
	@echo "   View with: crontab -l"
	@echo "   Remove with: make cron-remove"

## cron-remove: Remove overnight cron job
cron-remove:
	@crontab -l 2>/dev/null | grep -v "claude-skills-pack/scripts/overnight" | crontab -
	@echo "✅ Cron job removed"

## help: Show available targets
help:
	@echo "Claude Skills Pack — Makefile targets"
	@echo ""
	@grep -E '^## ' Makefile | sed 's/## /  make /' | sed 's/: /\t— /'
