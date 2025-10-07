# Changelog

All notable changes to this module will be documented in this file.

<!-- markdownlint-disable MD024 -->

<!--
## [Unreleased] - YYYY-MM-DD

### Summary


### What's Changed
- feat: Add or update feature
- fix: Fixed issue
- chore: Common tasks
- docs: Add or update documentation

### Breaking Changes
- _None_

<br>
-->

## [0.4.0-alpha] - 2025-10-07

### Summary

This major alpha release introduces comprehensive Azure DevOps integration capabilities to the MSc365.Idp.Toolbox module. The release adds a full suite of Azure DevOps cmdlets for managing core resources, repositories, policies, service endpoints, and more. This release includes important breaking changes with function renames for improved consistency.

### What's Changed
- feat!: Add new common module manifest with New-SecurePassword function with tests
- feat!: Add helper module manifest with Azure DevOps connection functions including some tests
- docs: Add documentation for ado/helper cmdlet
- feat: Add ado/core cmdlet for managing processes, projects, and teams
- feat: Add ado/feature cmdlets for managing feature state
- feat: Add ado/git cmdlet for managing repositories
- feat: Add ado/graph cmdlets for managing descriptors and groups
- feat: Add ado/policy cmdlets for managing policy types and configurations
- feat: Add ado/serviceEndpoints cmdlets for managing service endpoints
- feat: Add ado module manifest and initial script for ado cmdlets loading
- feat: Update module manifest and improve cmdlets loading script
- feat: Update build version to 0.4.0 and refine module publishing process
- fix: Update copyright information in LICENSE file
- docs: Revise README for clarity and enhance cmdlet usage examples
- docs: Update README to reflect changes in organization naming and command terminology
- docs: Update README to clarify project retrieval commands and their outputs
- docs: Comment out experimental features note in README for clarity
- docs: Update Commands.md to enhance documentation clarity and detail
- docs: Update links in Commands.md to ensure proper navigation to itself for unfinished docs
- chore: Rename file name from `updatePolicyConfiguration` to `setPolicyConfiguration`
- docs: Update CHANGELOG.md for 0.4.0-alpha release, detailing new features, fixes, and breaking changes

### Breaking Changes
- Renamed `New-RandomPassword` to `New-SecurePassword` for better clarity and naming consistency
- Renamed `Get-AzDevOpsAccessToken` to `Get-AdoAccessToken` to use shorter "Ado" prefix convention

<br>

## [0.3.0] - 2025-10-05

### Summary

This release introduces a new Azure DevOps integration feature with the `Get-AzDevOpsAccessToken` function, along with enhanced module structure and comprehensive testing. The release includes some improvements to the module organization.

### What's Changed
- feat: Add Get-AzDevOpsAccessToken function to retrieve Azure DevOps access tokens
- feat: Export Get-AzDevOpsAccessToken function in module manifest
- feat: Update file search patterns to include subdirectories for public and private functions
- feat: Refactor New-RandomPassword function and tests
- test: Add unit tests for Get-AzDevOpsAccessToken function
- docs: Add help file for Get-AzDevOpsAccessToken cmdlet
- fix: Add PlatyPS.ps1 to the build exclude
- chore: Update module version to 0.3.0
- chore: Update changelog for version 0.3.0 release

### Breaking Changes
- _None_

<br>

## [0.2.0] - 2025-10-04

### Summary

Stable release with enhanced build automation, CI/CD pipeline, documentation improvements, and various bug fixes. This release introduces psake build automation, PlatyPS documentation generation, and initial GitHub Actions workflow configuration.

### What's Changed
- feat: Add initial CI workflow configuration sample
- feat: Add PlatyPS script for generating markdown help files
- feat: Add psake as build automation tool
- fix: Update IconUri to point to the correct asset location
- fix: Update type and default value for parameter length
- fix: Update module link references
- fix: PlatyPS metadata configuration
- fix: Update file patterns in Properties to match specific script names
- chore: Set prerelease label to null for stable releases
- chore: Update changelog for version 0.2.0 release
- chore: Update icon asset with specific commit reference
- chore: Some minor clean up and improvements
- chore: Add GitHub release badge link in README file

### Breaking Changes
- _None_

<br>

## [0.2.0-alpha1] - 2025-10-01

### Summary
Major refactoring with new file structure, enhanced build system using `psake`, and PowerShell version requirement update.

### What's Changed
- feat: Add a new local build script with enhanced `psake` functionality
- feat: New file structure, update module manifest, main script, and tests
- chore: Update requirements and build instructions in README file
- chore: Update changelog for version 0.2.0-alpha1

### Breaking Changes
- Minimal PowerShell version requirement updated to 7.4

<br>

## [0.1.0] - 2025-09-28

### Summary
First none preview release of the MSc365.Idp.Toolbox PowerShell module.

### What's Changed
- docs: Improved some content in `README` file
- chore: Update manifest for version 0.1.0
- chore: Update changelog for version 0.1.0

### Breaking Changes
- _None_

<br>

## [0.1.0-prev2] - 2025-09-27

### Summary

Bug fixes and improvements to the MSc365.Idp.Toolbox PowerShell module, including enhanced documentation, variable naming improvements, and version updates.

### What's Changed
- fix: Sanitized variable naming and syntax
- fix: Enhance documentation for New-RandomPassword function parameters and examples
- chore: Update prerelease version from 'prev1' to 'prev2'
- chore: Update changelog for version 0.1.0-prev2

### Breaking Changes
- _None_

<br>

## [0.1.0-prev1] - 2025-09-26

### Summary

Initial preview release of the MSc365.Idp.Toolbox PowerShell module. This experimental module provides essential tools for Internal Developer Platforms (IDPs) on Azure cloud, starting with secure password generation capabilities.

### What's Changed
- feat: Add README.md to document module usage, installation, and development guidelines
- feat: Add initial changelog file to document module changes
- feat: Add build script for PowerShell module with publishing capabilities
- feat: Add New-RandomPassword function and corresponding tests
- feat: Add module manifest and initial implementation for MSc365.Idp.Toolbox
- feat: Add assets, configuration, and support documentation
- feat: Enhance issue templates for bug reports and feature requests
- feat: New issue templates (#1)
- chore: Update changelog for version 0.1.0-prev1
- chore: Update issue templates
- chore: Initial commit

### Breaking Changes
- _None_
