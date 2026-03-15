# Changelog

All notable changes to the Pixoo64 PowerShell module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-01-29

### Added
- Complete PowerShell module for Pixoo64 LED display control
- **31 public functions** covering all documented API endpoints:
  - 5 connection & discovery functions (Find-Pixoo, Connect-Pixoo, etc.)
  - 6 display settings functions (brightness, channels, clock faces, etc.)
  - 8 drawing & display functions (text, images, animations, colors)
  - 1 batch command function
  - 5 tool functions (timer, stopwatch, scoreboard, buzzer, noise meter)
  - 6 device settings functions (rotation, mirror, time format, etc.)

- **Device Discovery**:
  - Three-stage discovery: Cloud API + ARP cache + full subnet scan
  - Parallel IP probing for fast results
  - Cross-platform support (Windows/Linux/macOS)

- **Module Foundation**:
  - Session management with automatic retry logic
  - Pipeline support throughout
  - Comprehensive error handling with exponential backoff
  - PowerShell 5.1+ and 7+ compatibility

- **Testing**:
  - Unit test infrastructure with Pester 5.x
  - Integration test suite for real device testing
  - Mock framework for reliable unit tests
  - 80%+ code coverage target

- **Documentation**:
  - Complete README with quick start guide
  - Comment-based help for all 31 public functions
  - 5 example scripts demonstrating all features
  - Comprehensive troubleshooting guide
  - Contributing guidelines
  - Full API reference documentation

- **Quality**:
  - PSScriptAnalyzer configuration
  - Consistent code formatting (4-space indentation)
  - Approved PowerShell verbs throughout
  - ShouldProcess support for state-changing functions

### Known Issues
- Pixoo64 device has ~300 update limit (requires power cycle)
- Animation frame limit ~40 frames (varies by firmware)
- Buffer reset required before images (Reset-PixooDisplay)
- High brightness mode requires 5V 3A power supply

## [0.1.0] - 2026-01-29

### Added
- Project initialization
- Directory structure setup
- Core infrastructure files (.gitignore, LICENSE, CHANGELOG)
