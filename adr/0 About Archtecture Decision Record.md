# About Architecture Decision Records

## Definitions

An architectural decision (AD) is a software design choice that addresses 
a significant requirement.

An architectural decision record (ADR) is a way to track an AD, such as by 
writing notes, or logging information.

An architecturally significant requirement (ASR) is a requirement that has 
a measurable effect on a software system’s architecture.

All these are within the topic of architectural knowledge management (AKM).

## Goal 

The goal of these documents is to document the evolution and current state 
of the architecture of this project. They also may document its relation with 
external part of its broader ecosystem (third-party components integration, 
for instance).

## Submission

New ADR may be submitted through pull requests on [GitHub](https://github.com/rak/rak).

However, existing ADR may not be updated.

## Template

This project use a template based on https://github.com/joelparkerhenderson/architecture_decision_record/blob/master/adr_template_by_jeff_tyree_and_art_akerman.md

The template can be found in this directory: [1 Template.md](./1 Template.md).

## Structure

All ADRs must go under the [./adr](./) directory; new files must follow the following
name format:

    YYYY-MM-DD Title with spaces.md

Files may be archived in sub-directories, per year, as the project grows in scope and size.

## Groups

Groups serve the purpose of classifying architectural changes 
in a way that will contextualize such modififications or additions.

### Architectural groups

#### Core

Core components binding how components are interconnected to each others.

#### Components

Addition, removal, or change in role of one or multiple component group(s).

#### Interface

Changes to the way third-party or end-user code can interface with core systems.

### Non-architectural groups

Additionally to the previous architectural groups, other non-architectural groups
may be attached to an ADR; they should normally follow the architectural groups.

The goal of providing such groups is to allow any reader to judge whether a given
architectural change did achieve its objective.

#### Resilience

Changes meant to improve resilience against failiure.

#### Scalability

Changes meant to improve scalability, or allow end-user to structure
deployments in a more scalable way.

#### Usability

Changes making the provided APIs easier to use or simpler to understand.

Changes meant to ease or simplify the addition or maintenance
of tools. 

#### Performance

Changes meant to enhance performance, or allow enhancements by end-users.

#### Configurability

Changes meant add or simplify the use of the core system through
non-functional means (configuration, definition files or external tools).

#### Knowledge management

Changes meant to simplify or abstract the architecture to enhance documentation
capabilities for the core system, the larger ecosystem or the projects using them.

### Additional groups

Additional groups may be added upon request; simply make a pull request
requesting the group, with a description of the motivations behind the addition.

## Sources

https://www.utdallas.edu/~chung/SA/zz-Impreso-architecture_decisions-tyree-05.pdf
https://github.com/joelparkerhenderson/architecture_decision_record
http://www.cs.rug.nl/search/uploads/Publications/deGraaf2015phdthesis.pdf
