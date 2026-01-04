# Changelog

All notable changes to the Hermes Payment & Remittance Portal project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Network security improvements with IP-based access control
- Docker file organization in `infra/docker/` directory
- Security documentation with CIDR configuration examples

### Security
- Restricted SSH and web access using configurable CIDR blocks
- Replaced `0.0.0.0/0` rules with specific IP ranges
- Added GitHub Secrets support for security variables

## [2.0.0] - 2026-01-03

### Changed
- **BREAKING**: Migrated from Kubernetes (k3s) to Docker Compose
- Simplified container orchestration for better resource efficiency
- Updated deployment scripts for Docker-based infrastructure

### Removed
- Kubernetes manifests and k3s setup scripts
- Atlas Terraform configuration (atlas.tf)

### Performance
- Reduced memory overhead by 80% (Docker vs k3s)
- Faster deployment and startup times

## [1.8.0] - 2025-12-23

### Fixed
- MongoDB Atlas Terraform integration with `project_ip_access_list`
- Added `auth_database_name` parameter for proper authentication
- Consolidated documentation and deployment scripts

### Changed
- Updated MongoDB connection parameters
- Improved Atlas + Terraform integration

## [1.7.0] - 2025-12-22

### Fixed
- Terraform MongoDB parameter validation
- Micronaut build and dependency resolution issues
- Maven dependency management for Micronaut framework

### Removed
- Problematic `mvn dependency:go-offline` step from build process

## [1.6.0] - 2025-12-18

### Changed
- **BREAKING**: Migrated from Spring Boot to Micronaut framework
- **BREAKING**: Migrated from MySQL to MongoDB Atlas
- Removed Redis dependency for simplified architecture

### Added
- MongoDB Atlas integration with cloud-native database
- Micronaut framework for faster startup and lower memory usage

### Performance
- 75% memory reduction (Micronaut vs Spring Boot)
- 5x faster startup time (<1s vs 3-5s)
- Eliminated Redis overhead (20MB memory saved)

## [1.5.0] - 2025-12-13

### Added
- Network security configuration with OCI Security Lists
- Automated instance recreation based on deployment triggers
- Conditional deployment logic to avoid unnecessary recreations

### Changed
- Updated from creating new subnets to modifying existing security lists
- Improved deployment efficiency with change detection

### Security
- Added ingress rules for SSH (22), Dashboard (8080), and Server (9292)
- Implemented proper network access controls

## [1.4.0] - 2025-12-10

### Added
- Kubernetes (k3s) deployment with separate manifests
- Container orchestration for better scalability

### Changed
- Migrated from direct systemd services to Kubernetes deployment
- Updated CI/CD pipeline for k3s deployment

## [1.3.0] - 2025-12-09

### Added
- **Database Layer**: MySQL 8.0 with comprehensive schema
- **Caching Layer**: Redis 7 with cache-aside pattern
- **Performance**: 10x faster reads with Redis caching
- **Data Integrity**: Transaction support with rollback capabilities
- **Audit Trail**: Comprehensive audit logging for all payment actions

### Security
- **BREAKING**: Strict DB_PASSWORD validation (no fallback)
- Enhanced health checks with detailed error reporting
- Fail-fast deployment with clear error messages

### Database Schema
- `payments` table for transaction records
- `validation_results` table for payment validation
- `audit_log` table for comprehensive tracking

## [1.2.0] - 2025-11-23

### Added
- Comprehensive CI/CD pipeline with conditional execution
- Docker image building and GitHub Container Registry integration
- Advanced health checks for both Node.js and Spring Boot services

### Fixed
- Terraform public IP extraction from VNIC
- OCI firewall rules (removed default REJECT rules)
- Duplicate Terraform outputs

### Changed
- Optimized test execution (skip if no code changes)
- Improved deployment reliability with proper health endpoints

## [1.1.0] - 2025-11-21

### Added
- **Dual Service Architecture**: Node.js backend + Spring Boot frontend
- **Infrastructure as Code**: Complete Terraform configuration for OCI
- **Automated Deployment**: GitHub Actions CI/CD pipeline
- **Health Monitoring**: Comprehensive health checks and monitoring

### Changed
- **BREAKING**: Migrated from Ruby to Node.js for backend services
- Updated deployment scripts for dual-service architecture
- Enhanced error handling and validation

### Infrastructure
- OCI Compute Instance with 50GB boot volume
- Automated Java 17 and Maven installation
- Systemd service management for both applications

## [1.0.0] - 2025-11-20

### Added
- **Modern UI**: Complete frontend redesign with Bootstrap
- **Payment Processing**: Full payment submission and confirmation flow
- **API Integration**: RESTful API with proper JSON handling
- **Production Pipeline**: 7-stage CI/CD with comprehensive testing

### Features
- HTML5 payment forms with client-side validation
- Ruby/Sinatra backend with JSON API endpoints
- Spring Boot dashboard for payment management
- Code quality tools (HTMLHint, ESLint, Checkstyle)

### Testing
- Unit tests with Maven/JUnit
- Integration tests with Ruby server
- Multi-stage validation and verification

## [0.9.0] - 2025-11-19

### Added
- **Cloud Deployment**: OCI integration with automated provisioning
- **Ruby Backend**: Sinatra-based payment processing server
- **Error Handling**: Improved setup scripts with better error management

### Fixed
- Ruby gem installation and permission issues
- OCI setup script reliability
- GitHub Actions deployment workflow

## [0.8.0] - 2025-11-16

### Added
- **Architecture Patterns**: Implemented SOLID principles and design patterns
- **Code Quality**: Enhanced maintainability and extensibility
- **Documentation**: Comprehensive architecture documentation

### Changed
- Refactored codebase following design patterns
- Improved separation of concerns
- Enhanced code organization

## [0.7.0] - 2025-11-14

### Added
- **Modern UI**: Complete interface modernization
- **Auto-refresh**: Automatic page refresh functionality
- **Manual Controls**: Manual refresh button for user control

### Changed
- Updated user interface with modern design principles
- Enhanced user experience with real-time updates

## [0.1.0] - 2025-11-10

### Added
- **Initial Release**: Basic payment portal functionality
- **Core Features**: Payment submission and tracking
- **Basic UI**: Initial user interface implementation
- **Git Setup**: Repository initialization and basic structure

### Infrastructure
- Initial project structure
- Basic payment processing logic
- Fundamental UI components

---

## Release Notes

### Version Naming Convention
- **Major versions** (x.0.0): Breaking changes, architecture changes
- **Minor versions** (x.y.0): New features, enhancements
- **Patch versions** (x.y.z): Bug fixes, security updates

### Key Milestones
- **v2.0.0**: Docker Migration - Simplified deployment architecture
- **v1.6.0**: MongoDB + Micronaut - Modern cloud-native stack
- **v1.3.0**: Database Layer - Added persistence and caching
- **v1.0.0**: Production Ready - Complete payment processing system

### Upgrade Path
- **v1.x → v2.0**: Migration guide available in `DOCKER_COMPOSE_MIGRATION.md`
- **v0.x → v1.0**: Complete rewrite, no direct upgrade path

### Support
- **Current**: v2.0.0 (Active development)
- **LTS**: v1.6.0 (Security updates only)
- **EOL**: v0.x (No longer supported)