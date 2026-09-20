# Enterprise Cloud Pre-Production Security Audit Checklist
**Project**: NNPC Subsidiary Digital Platforms & Energy EDW Infrastructure  
**Lead Cloud Architect**: Jerry A. Nabasu, CInS, CInP  
**Standard**: ISO/IEC 27001 & Microsoft Cloud Adoption Framework (CAF) Zero Trust  

---

### 1. Identity & Access Management (IAM)
- [x] **Zero Plaintext Secrets**: Zero connection strings or passwords stored in application code or configuration repositories. All credentials injected via Azure Key Vault references (`@Microsoft.KeyVault(...)`).
- [x] **Managed Identities**: Azure App Service and Azure Functions utilize System-Assigned Managed Identity for authenticating to Key Vault, Storage Blobs, and Managed Redis.
- [x] **Least-Privilege RBAC**: Explicit role assignments restricted to `Key Vault Secrets User` and `Storage Blob Data Contributor`. Subscription-level Contributor access prohibited.

### 2. Network Security & Perimeter Defense
- [x] **Private Endpoints & VNet Integration**: All backend services (Azure Cache for Redis, Azure Synapse Workspace, and Data Lake Storage Gen2) have `publicNetworkAccess: 'Disabled'`.
- [x] **Network Security Groups (NSGs)**: Default Deny-All inbound rule enforced; explicit HTTPS (Port 443) only for internet-facing App Service gateways.
- [x] **Egress Control**: Regional VNet integration routed through subnets (`snet-appservice`, `snet-functions`).

### 3. Data Protection & Cryptography
- [x] **Encryption in Transit**: Strict enforcement of `minimumTlsVersion: '1.2'` across all endpoints. Plaintext HTTP (Port 80) permanently disabled via `httpsOnly: true`.
- [x] **Encryption at Rest**: Azure Storage Accounts and Data Lake Gen2 encrypted using 256-bit AES customer-managed / platform-managed keys.
- [x] **Key Vault Protection**: Soft-delete enabled with 90-day retention and purge protection to prevent accidental secret destruction.

### 4. Application Hardening & Logging
- [x] **FTPS Disabled**: FTP and FTPS publishing profiles disabled to prevent credential sniffing.
- [x] **HTTP/2 Enabled**: Enhanced transport throughput and security.
- [x] **Diagnostic Telemetry**: Azure Monitor and Application Insights structured logging enabled.
