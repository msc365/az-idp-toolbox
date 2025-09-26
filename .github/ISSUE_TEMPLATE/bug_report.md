---
name: "Bug report \U0001F41B"
description: Report errors or unexpected behavior
title: "Bug: "
labels: ['needs triage :wave:', 'bug :beetle:']
assignees: msc365admin
---
body:
- type: markdown
    attributes:
      value: |
        Thank you for taking the time to fill out a bug report.
        If you are not running the latest version of this module, please try to reproduce your bug with the latest version before opening an issue.
- type: checkboxes
    attributes:
      label: Is there an existing issue for this?
      description: Please search to see if an issue already exists for the bug you encountered.
      options:
        - label: I have searched the existing issues
          required: true
- type: input
    attributes:
      label: PowerShell Module Version (Optional)
      description: Please provide the version of the PowerShell Module you are using if relevant.
    validations:
      required: false
- type: input
    attributes:
      label: IDP Toolbox Version (Required)
      description: Please provide the version of the IPD Toolbox Module you are using.
    validations:
      required: true
- type: dropdown
    attributes:
      label: Function? (Required)
      description: Which function are you using?
      multiple: false
      options:
        - New-RandomPassword
        - Other
        - Not relevant
    validations:
      required: true
- type: dropdown
    attributes:
      label: Infra as Code Type? (Optional)
      description: Are you using Bicep or Terraform?
      multiple: false
      options:
        - Bicep
        - Terraform
        - Both
        - Not relevant
    validations:
      required: false
- type: textarea
    id: inputs
    attributes:
      label: Input arguments of the Az.Idp.Toolbox Module (Optional)
      description: Please provide any relevant input arguments of the Az.Idp.Toolbox Module that can reproduce the issue.
    validations:
      required: false
- type: textarea
    id: debug
    attributes:
      label: Debug Output (Optional)
      description: |
        For long debug logs please provide a link to a GitHub Gist containing the complete debug output. Please do NOT paste the debug output in the issue; just paste a link to the Gist.
      render: shell
    validations:
      required: false
- type: textarea
    id: expected
    attributes:
      label: Expected Behavior (Required)
      description: What should have happened?
    validations:
      required: true
- type: textarea
    id: actual
    attributes:
      label: Actual Behavior (Required)
      description: What actually happened?
    validations:
      required: true
- type: textarea
    id: reproduce
    attributes:
      label: Steps to Reproduce (Optional)
      description: |
        Please list the steps required to reproduce the issue, e.g.:
- type: textarea
    id: facts
    attributes:
      label: Important Factoids (Optional)
      description: |
        Are there anything atypical about your accounts that we should know? For example: Running in a Azure China/Germany/Government?
  - type: textarea
    id: references
    attributes:
      label: References (Optional)
      description: |
        Information about referencing Github Issues: <https://help.github.com/articles/basic-writing-and-formatting-syntax/#referencing-issues-and-pull-requests>
        Are there any other GitHub issues (open or closed) or pull requests that should be linked here? Such as vendor documentation?
