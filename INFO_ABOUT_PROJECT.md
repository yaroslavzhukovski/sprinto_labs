# Info About Project

## Project name

Azure Learning Platform

## Main idea

This project is a beginner-friendly Azure learning environment built with Terraform.

The main purpose of the project is not to teach advanced Terraform.
The real purpose is to help students learn Azure in a practical and repeatable way.

Terraform is used mainly to:

- deploy the same environment for every student
- reduce setup time
- keep the labs repeatable
- allow fast destroy and rebuild between lessons

## Target audience

The project is designed for beginners.

Assume that the student:

- is new to Azure
- may have little or no Terraform experience
- may have a limited technical background
- can become overwhelmed if instructions are too abstract or too complex

Because of this, the project is built around:

- simple structure
- clear resource naming
- low-cost Azure resources
- step-by-step instructions
- practical labs based on healthy state vs changed state

## Teaching model

The teaching model used in this project is:

1. Create a healthy baseline Azure environment.
2. Let the student observe and understand the healthy state.
3. Apply a lab scenario that changes or breaks something.
4. Let the student observe the new state.
5. Compare healthy state and changed state.
6. Troubleshoot and fix the problem.
7. Destroy the environment after the lesson.

This is a very important design rule in the project.

Students must always observe a state before it is changed.
They should never be asked to analyze a state that no longer exists.

## Core design principles

The repository follows these priorities:

1. clarity for beginners
2. Azure learning value
3. low cost
4. easy teacher support
5. maintainability
6. Terraform elegance

If these goals conflict, the project should choose simplicity.

## Repository structure

The repository is intentionally small.

Important folders and files:

- `platform/`
  The Terraform baseline platform.

- `platform/modules/`
  Terraform modules for different Azure areas such as network, compute, storage, identity, monitoring, governance, and key vault.

- `labs/docs/`
  Student instructions for each lab.

- `labs/tfvars/`
  Terraform variable files that change the healthy baseline into a lab scenario.

- `answers/`
  Instructor answer keys.

- `README.md`
  Main project overview.

- `GETTING_STARTED.md`
  Step-by-step setup guide for students.

- `labs/README.md`
  Lab map / short lab overview.

## Baseline environment

The baseline platform creates a small Azure environment that is rich enough for security and cloud labs, but still low-cost.

Main baseline components include:

- hub and spoke virtual network design
- subnets
- virtual network peering
- network security groups
- route table
- two Linux virtual machines
- storage account
- blob container
- Key Vault
- managed identities
- RBAC role assignments
- Log Analytics Workspace
- diagnostic settings
- monitoring resources
- Azure Policy assignment
- budget configuration

Optional resources are enabled only when a lab needs them, for example:

- private endpoint
- private DNS
- Bastion

## Why Terraform is used

Terraform is used only as an enabling tool.

It is not the main learning topic.

It helps by:

- creating all student environments the same way
- reducing setup time to about 10 minutes for the healthy baseline
- making lab states reproducible
- allowing resources to be destroyed and recreated easily

Students are expected to do most lab work in:

- Azure Portal
- Azure CLI
- VM tests such as SSH, ping, `nslookup`, and `nc`

## Naming concept

The project uses a naming pattern that includes:

- `student_id`
- a short unique suffix based on the subscription ID

This allows multiple students to deploy the same project safely as long as each student uses a separate Azure subscription and their own Terraform state.

This is important because some Azure resources must be globally unique, especially:

- storage account names
- Key Vault names

The design works well for separate student subscriptions.
It is not intended for many students to share the same subscription.

## Important Azure 2026 networking note

The project takes into account an Azure platform behavior change introduced after March 31, 2026.

For newly created virtual networks after that date:

- subnets are private by default
- default outbound connectivity should not be assumed

Because of this, the project avoids depending on implicit outbound internet access.

If a lab needs a specific path or connectivity model, it should be explicit and simple.

## Documentation philosophy

Documentation is a major part of this project.

The instructions must be:

- simple
- clear
- detailed
- visually easy to follow
- written in English
- safe for weak beginners

The project has intentionally moved toward:

- shorter root README
- one clear setup guide
- lab-specific detailed instructions inside each lab document

## Current documentation files

Important documentation files currently include:

- `README.md`
- `GETTING_STARTED.md`
- `labs/README.md`
- `labs/docs/lab01.md` to `labs/docs/lab07.md`
- `answers/lab01_answer.md` to `answers/lab07_answer.md`

## Lab overview

### Lab 1 - Network Security Groups

Main idea:

- compare healthy connectivity with a broken NSG scenario

Students learn:

- subnet NSG vs NIC NSG
- effective security rules
- how deny rules break traffic

Important improvements made:

- clear SSH instructions
- explicit IP lookup guidance
- healthy baseline before broken scenario
- explicit cleanup and destroy step

### Lab 2 - Routing

Main idea:

- compare healthy private routing with a broken route table scenario

Students learn:

- route tables
- effective routes
- next hop
- private communication between lab VMs

Important improvements made:

- simpler SSH method for beginners
- strong Bash / PowerShell guidance
- SSH agent and `ssh-add` instructions
- explicit exit from SSH before applying the lab scenario
- optional advanced section for Network Watcher `Next hop`
- explicit cleanup and destroy step

### Lab 3 - Storage RBAC and SAS

Main idea:

- compare healthy storage access with reduced permissions and disabled shared key access

Students learn:

- storage data-plane RBAC
- read vs write capabilities
- SAS basics
- shared key access basics

Important improvements made:

- storage account is located only after baseline exists
- students upload their own test file
- direct blob URL is tested and fails without SAS
- SAS URL with `Read` is generated and tested
- explanation of shared key access moved to the logical place in State B
- explicit cleanup and destroy step

Important security change made:

- anonymous blob access was removed
- storage is now private by default in the baseline

## Lab 4 - Public vs Private Storage Access

Main idea:

- compare public storage access with private endpoint + private DNS based access

Students learn:

- public access vs private access
- private endpoint
- private DNS zone
- private DNS virtual network link
- DNS testing from inside the VM with `nslookup`

Important improvements made:

- strong State A public access explanation
- explicit SSH to VM1 instructions
- clear `nslookup` examples
- strong focus on DNS behavior before and after private access
- manual DNS break / restore scenario
- explicit cleanup and destroy step

Important technical fix made:

- private DNS zone link was corrected to the hub VNet because the DNS test uses VM1 in the hub network

## Lab 5 - Diagnostics and Log Analytics Workspace

Main idea:

- understand the chain:
  `resource -> diagnostic setting -> Log Analytics Workspace`

Students learn:

- what a Log Analytics Workspace is
- what diagnostic settings do
- where logs are stored
- why a workspace can exist while data is still missing

Main monitored resources in the final design:

- Key Vault
- Storage account / blob diagnostics

Important improvements made:

- clear note that old VM diagnostics extension pages are not the main focus
- Key Vault checked first
- Storage diagnostics checked through the Storage account `Diagnostic settings` page
- explicit note that blob logs are found through the `blob` entry
- clear note that logs may take about 5 to 10 minutes to appear
- explicit instruction to use the `Tables` view inside `Logs`
- use of `StorageBlobLogs` table to find blob operations
- manual recreation of missing diagnostic settings
- simple generation of real activity by uploading or deleting a blob
- explicit cleanup and destroy step

## Lab 6 - Azure Bastion

Main idea:

- understand Bastion as a secure access method for private VMs

Students learn:

- what Azure Bastion is
- why companies use Bastion
- why target VMs do not need public IPs
- how Bastion fits into hub-and-spoke design
- the difference between private internal connectivity and internet connectivity

Important improvements made:

- VM Scale Set content was removed so the lab focuses only on Bastion
- students compare private IP communication with public internet communication
- cost warning was added because Bastion is more expensive than many other lab resources
- explicit cleanup and destroy step

## Lab 7 - Azure Policy

Main idea:

- understand how Azure Policy is structured and how it affects real operations

Students learn:

- policy definitions
- initiatives
- assignments
- deny vs audit
- compliance vs non-compliance
- the difference between Azure Policy and RBAC

Important improvements made:

- Part A became a guided tour of the Policy blade
- students are guided through:
  - Overview
  - Assignments
  - initiative
  - Definitions
  - Compliance
- it is explained that an empty `Parameters` tab on the assignment page is normal in this project
- explicit cleanup and destroy step

## Governance and policy model

The project includes Azure Policy guardrails.

Main policy themes are:

- allowed locations
- allowed resource types
- allowed VM sizes
- allowed storage SKUs
- audit of storage HTTPS and TLS
- audit of storage diagnostics

These policies are grouped into an initiative:

- `lia-baseline-guardrails`

And assigned at subscription scope through:

- `lia-baseline-guardrails-assignment`

Important observation:

Because the assignment is at subscription level and the allowed resource types policy is strict, Azure Policy may show many non-compliant resources.

This does not always mean the student created many visible resources manually.

Azure Policy also counts:

- child resources
- provider-managed helper resources
- background Azure resources

This is especially important in private endpoint, private DNS, and storage scenarios.

## Policy-related technical work already done

During project improvement, the governance policy had to be expanded so the lab platform could work with real Azure behavior.

Important additions included support for resource types such as:

- private DNS zones
- private DNS zone links
- private DNS A records
- private endpoint DNS zone groups
- private endpoint helper/proxy resources
- storage account private endpoint connection resources
- storage child services such as blob, queue, table, and file related resource types

This was necessary because Azure often creates child resources or helper resources automatically during normal deployments.

Without allowing these, policy blocked some lab scenarios, especially Lab 4.

## Monitoring model

The monitoring design in the project is based on:

- Azure resources
- diagnostic settings
- Log Analytics Workspace

The project avoids making old VM diagnostics the center of the learning model.

Instead, the teaching focus is:

- source resource
- diagnostic setting
- central workspace
- actual tables and logs in Log Analytics

This is closer to how modern Azure monitoring should be explained to beginners.

## Security model

The project touches several practical security ideas:

- least privilege
- secure access paths
- controlled network exposure
- logging and monitoring
- governance and compliance
- private vs public access

Examples:

- storage access moved away from public anonymous access
- Bastion is used as a safer administrative access model
- private endpoint and DNS labs show how services can be kept private
- policy labs show how organizations restrict and monitor Azure use

## Access model

The project tries to keep access simple.

Important access patterns used:

- SSH to VM1 through public IP when needed
- SSH from VM1 to internal VM2 for private-network labs
- Bastion for private VM access without public IP exposure

Several improvements were made to make student access easier:

- explicit SSH key path examples
- Windows Bash and PowerShell instructions
- `ssh-agent` and `ssh-add` guidance
- reminders to exit SSH before running Terraform again

## Cleanup philosophy

Destroying resources after the lab is an important part of the project.

Students should not leave resources running unnecessarily.

This is important for:

- cost control
- predictability
- clean rebuilds for the next lesson

Several labs now end with explicit cleanup sections that tell students:

- how to exit the VM or Bastion session
- how to return to their own terminal
- which exact `terraform destroy` command to run

This is especially important for:

- Bastion
- private endpoint resources
- monitoring resources

## Setup guidance

The current setup experience is split into two layers:

- `README.md`
  Short overview and project map

- `GETTING_STARTED.md`
  Detailed step-by-step first-time setup

The setup guide includes:

- how to open Azure Portal
- how to find subscription ID and tenant ID in Portal
- how to create SSH keys
- how to update `platform/terraform.tfvars`
- reminders to save the file explicitly
- baseline deployment flow
- hand-off to the lab map after setup

## Files cleaned up during project work

The repository was simplified during the work.

Examples of cleanup:

- placeholder module README files were removed
- `CONTRIBUTING.md` was removed
- empty `platform/students/` folder was removed
- `.gitignore` was updated for local-only and temporary files
- agent/helper instruction files were added to `.gitignore`

The root `answers/` folder was kept as the canonical answer-key location.

## Important practical lessons from the project

During the work on this repository, several practical lessons became clear:

1. Azure Policy can block more than the obvious top-level resource.
2. Azure often creates child resources automatically.
3. Students need much more explicit Portal guidance than experienced users expect.
4. SSH is often harder for beginners than the actual cloud concept being taught.
5. Monitoring data often appears with delay, so labs must explain this clearly.
6. Lab sequence matters as much as lab content.
7. A good beginner lab should teach one main concept at a time.

## Current overall state of the project

At the current stage, the project includes:

- a structured baseline Azure learning platform
- seven beginner-focused labs
- instructor answer keys
- a shorter root README
- a detailed getting started guide
- clearer cleanup instructions
- improved Azure Policy compatibility with the lab platform

The project is now much more consistent in:

- documentation style
- lab flow
- healthy-state-first logic
- cleanup expectations

## Short summary

This project is a small, practical Azure training environment for beginners.

It teaches students to:

- deploy a healthy Azure baseline
- observe and understand how it works
- apply controlled lab scenarios
- troubleshoot real Azure behavior
- fix problems
- clean up resources afterward

The project is intentionally designed to stay:

- simple
- low-cost
- structured
- realistic
- easy to teach
- beginner-friendly
