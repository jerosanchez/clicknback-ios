
# Colors for terminal output
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_BLUE := \033[34m
COLOR_YELLOW := \033[33m
COLOR_RED := \033[31m

# ============================================================================
# PRE-CHECKS & INSTALLATION
# ============================================================================

.PHONY: check-xcode check-homebrew check-tuist check-swiftformat check-swiftlint install generate

check-xcode:
	@if [ "$$(xcode-select -p)" = "/Library/Developer/CommandLineTools" ]; then \
		echo "$(COLOR_RED)✗ Error: Xcode is not properly configured$(COLOR_RESET)"; \
		echo ""; \
		echo "$(COLOR_BOLD)You currently have Command Line Tools active.$(COLOR_RESET)"; \
		echo "To use xcodebuild for building and testing, run:"; \
		echo ""; \
		echo "  $(COLOR_YELLOW)sudo xcode-select --switch /Applications/Xcode.app$(COLOR_RESET)"; \
		echo ""; \
		echo "Or for a specific Xcode version:"; \
		echo "  $(COLOR_YELLOW)sudo xcode-select --switch /Applications/Xcode_15.2.app$(COLOR_RESET)"; \
		echo ""; \
		echo "After setting Xcode, you can use: $(COLOR_GREEN)make build$(COLOR_RESET)"; \
		exit 1; \
	fi

check-homebrew:
	@command -v brew >/dev/null 2>&1 || { \
		echo "$(COLOR_RED)Homebrew not found. Install from https://brew.sh$(COLOR_RESET)"; \
		exit 1; \
	}

check-tuist:
	@command -v tuist >/dev/null 2>&1 || { \
		echo "$(COLOR_YELLOW)Error: tuist not found. Install via:$(COLOR_RESET)"; \
		echo "  brew install tuist"; \
		exit 1; \
	}

check-swiftformat:
	@command -v swiftformat >/dev/null 2>&1 || { \
		echo "$(COLOR_YELLOW)Error: swiftformat not found. Install via:$(COLOR_RESET)"; \
		echo "  brew install swiftformat"; \
		exit 1; \
	}

check-swiftlint:
	@command -v swiftlint >/dev/null 2>&1 || { \
		echo "$(COLOR_YELLOW)Error: swiftlint not found. Install via:$(COLOR_RESET)"; \
		echo "  brew install swiftlint"; \
		exit 1; \
	}

check-markdownlint:
	@command -v markdownlint >/dev/null 2>&1 || { \
		echo "$(COLOR_YELLOW)Error: markdownlint-cli not found. Install via:$(COLOR_RESET)"; \
		echo "  brew install markdownlint-cli"; \
		exit 1; \
	}

install: check-homebrew
	@echo "$(COLOR_BLUE)Installing dev tools...$(COLOR_RESET)"
	brew install swiftformat swiftlint tuist markdownlint-cli
	@$(MAKE) generate
	@echo ""
	@echo "$(COLOR_GREEN)✓ Setup complete. Run 'make open' to open the project in Xcode.$(COLOR_RESET)"

generate: check-tuist
	@echo "$(COLOR_BLUE)Generating Xcode project with Tuist...$(COLOR_RESET)"
	tuist generate --no-open
	@echo "$(COLOR_GREEN)✓ Project generated successfully$(COLOR_RESET)"

# ============================================================================
# DEVELOPMENT LIFECYCLE
# ============================================================================

.PHONY: open qa-gates 

open: check-xcode
	@if [ -d "ClickNBack.xcworkspace" ]; then \
		echo "$(COLOR_BLUE)Opening ClickNBack.xcworkspace...$(COLOR_RESET)"; \
		open ClickNBack.xcworkspace; \
	elif [ -d "ClickNBack.xcodeproj" ]; then \
		echo "$(COLOR_BLUE)Opening ClickNBack.xcodeproj...$(COLOR_RESET)"; \
		open ClickNBack.xcodeproj; \
	else \
		echo "$(COLOR_YELLOW)Project not found. Run 'make generate' first.$(COLOR_RESET)"; \
		exit 1; \
	fi

# coverage is not mandatory as a QA gate yet, it runs separately as informational in CI, 
# so we don't fail the gate if it doesn't pass
qa-gates: build lint lint-md test-all
	@echo "$(COLOR_GREEN)✓ All QA gates passed$(COLOR_RESET)"

# ============================================================================
# BUILD CONFIGURATION
# ============================================================================

# Simulator device used for all debug/test builds. Override with:
#   make build SIM_DEVICE="iPhone 17 Pro"
SIM_DEVICE ?= iPhone 17

# Auto-detect scheme: prefer ClickNBack-Dev (Tuist-generated), fall back to ClickNBack (original xcodeproj)
SCHEME := $(shell xcodebuild -list -project ClickNBack.xcodeproj 2>/dev/null | grep -qw "ClickNBack-Dev" && echo "ClickNBack-Dev" || echo "ClickNBack")

ifeq ($(CI),true)
	SIM_DEST := platform=iOS Simulator,name=iPhone 17
else
	SIM_DEST := platform=iOS Simulator,name=$(SIM_DEVICE)
endif

# Bypass code signing for simulator builds (no development team required)
NO_SIGN := CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO

# Minimum required coverage percentage (override with: make coverage MIN_COVERAGE=70)
MIN_COVERAGE ?= 65

# ============================================================================
# CODE QUALITY
# ============================================================================

.PHONY: build boot-sim test test-integration test-all coverage format lint

# Boots the simulator before running tests to avoid "preflight checks" failures
# when the simulator is left in a mid-shutdown state. Skipped on CI.
boot-sim:
ifneq ($(CI),true)
	@xcrun simctl boot "$(SIM_DEVICE)" 2>/dev/null || true
endif

build: check-xcode
	@echo "$(COLOR_BLUE)Building ClickNBack [$(SCHEME)] → $(SIM_DEVICE)...$(COLOR_RESET)"
	xcodebuild -scheme $(SCHEME) -configuration Debug \
		-destination '$(SIM_DEST)' \
		-derivedDataPath build \
		$(NO_SIGN)
	@echo "$(COLOR_GREEN)✓ Build succeeded$(COLOR_RESET)"

test: check-xcode boot-sim
	@echo "$(COLOR_BLUE)Running unit tests [$(SCHEME)] → $(SIM_DEVICE)...$(COLOR_RESET)"
	xcodebuild test -scheme $(SCHEME) -configuration Debug \
		-destination '$(SIM_DEST)' \
		-only-testing ClickNBackTests \
		-derivedDataPath build \
		$(NO_SIGN)
	@echo "$(COLOR_GREEN)✓ Unit tests completed$(COLOR_RESET)"

test-integration: check-xcode boot-sim
	@echo "$(COLOR_BLUE)Running integration tests [$(SCHEME)] → $(SIM_DEVICE)...$(COLOR_RESET)"
	xcodebuild test -scheme $(SCHEME) -configuration Debug \
		-destination '$(SIM_DEST)' \
		-only-testing ClickNBackIntegrationTests \
		-derivedDataPath build \
		$(NO_SIGN)
	@echo "$(COLOR_GREEN)✓ Integration tests completed$(COLOR_RESET)"

# We do not runt UI tests to improve CI speed until we have proper UI tests in place
test-all: check-xcode boot-sim
	@echo "$(COLOR_BLUE)Running all tests [$(SCHEME)] → $(SIM_DEVICE)...$(COLOR_RESET)"
	xcodebuild test -scheme $(SCHEME) -configuration Debug \
		-destination '$(SIM_DEST)' \
		-only-testing ClickNBackTests \
		-derivedDataPath build \
		$(NO_SIGN)
	@echo "$(COLOR_GREEN)✓ All tests completed$(COLOR_RESET)"

coverage: check-xcode
	@echo "$(COLOR_BLUE)Checking coverage (minimum: $(MIN_COVERAGE)%)...$(COLOR_RESET)"
	@python3 Scripts/check_coverage.py $(MIN_COVERAGE)

format: check-swiftformat
	@echo "$(COLOR_BLUE)Formatting Swift code...$(COLOR_RESET)"
	swiftformat ClickNBack/ ClickNBackTests/ ClickNBackUITests/ --swift-version 6
	@echo "$(COLOR_GREEN)✓ Code formatted$(COLOR_RESET)"

lint: check-swiftlint
	@echo "$(COLOR_BLUE)Running SwiftLint...$(COLOR_RESET)"
	swiftlint lint --quiet ClickNBack/ ClickNBackTests/ ClickNBackUITests/
	@echo "$(COLOR_GREEN)✓ SwiftLint completed$(COLOR_RESET)"

lint-md: check-markdownlint
	@echo "$(COLOR_BLUE)Running markdownlint...$(COLOR_RESET)"
	markdownlint '**/*.md' --ignore node_modules --ignore build
	@echo "$(COLOR_GREEN)✓ Markdown lint completed$(COLOR_RESET)"

# ============================================================================
# CLEANUP
# ============================================================================

.PHONY: clean-artifacts clean-cache regenerate clean-all

clean-artifacts:
	@echo "$(COLOR_BLUE)Cleaning build artifacts...$(COLOR_RESET)"
	rm -rf build/
	rm -rf Derived/
	rm -rf .build/
	@echo "$(COLOR_GREEN)✓ Cleanup complete$(COLOR_RESET)"

clean-cache: check-tuist
	@echo "$(COLOR_BLUE)Clearing Tuist cache...$(COLOR_RESET)"
	tuist clean
	@echo "$(COLOR_GREEN)✓ Cache cleared$(COLOR_RESET)"

regenerate: check-tuist clean-artifacts
	@echo "$(COLOR_BLUE)Removing generated project files...$(COLOR_RESET)"
	rm -rf ClickNBack.xcodeproj/
	rm -rf ClickNBack.xcworkspace/
	@echo "$(COLOR_BLUE)Regenerating from Tuist...$(COLOR_RESET)"
	tuist generate --no-open
	@echo "$(COLOR_GREEN)✓ Project regenerated$(COLOR_RESET)"

clean-all: clean-artifacts clean-cache regenerate
	@echo "$(COLOR_GREEN)✓ Full cleanup complete$(COLOR_RESET)"
