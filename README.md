# Enterprise Azure Cloud Platform & DevSecOps Infrastructure as Code (IaC)

[![Azure](https://img.shields.io/badge/Microsoft%20Azure-Enterprise%20Cloud-0089D6.svg?logo=microsoft-azure)](https://azure.microsoft.com/)
[![Bicep](https://img.shields.io/badge/Azure-Bicep%20IaC-0078D4.svg)](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
[![Managed Redis](https://img.shields.io/badge/Azure-Cache%20for%20Redis-DC382D.svg?logo=redis)](https://azure.microsoft.com/products/cache/)
[![Azure Synapse](https://img.shields.io/badge/Azure-Synapse%20Analytics-0078D4.svg)](https://azure.microsoft.com/products/synapse-analytics/)
[![Security Audit](https://img.shields.io/badge/Security-Zero%20Trust%20Audited-success.svg)](security_audit/pre_production_security_checklist.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-Jerry%20A.%20Nabasu-blue.svg)](https://github.com/JayNabasu)

Production-grade **Azure Infrastructure as Code (Bicep)** and DevSecOps architecture provisioning a hardened enterprise foundation for subsidiary digital platforms and the Enterprise Data Warehouse (EDW). Built to **Zero Trust (CAF)** principles, it automates the deployment of **Azure App Service, Serverless Functions, Managed Redis, Key Vault, and Azure Synapse Analytics** with strict private endpoint isolation.

---

## Architectural Highlights

- **Zero-Trust Network Perimeter**: Virtual Network (VNet) topology with dedicated subnets for App Service, Function Apps, and Managed Redis. Backend PaaS resources enforce `publicNetworkAccess: 'Disabled'`.
- **System-Assigned Managed Identity**: Eliminates hardcoded service principal credentials and API keys. Applications authenticate to Azure Key Vault and Storage Blobs using Azure AD RBAC.
- **Enterprise PaaS & Data Services**:
  - **Azure App Service (Linux P1v3)**: High-availability web hosting with regional VNet injection, HTTP/2, and TLS 1.2.
  - **Azure Functions (Elastic Premium)**: Event-driven SCADA and telemetry ingestion pipelines.
  - **Azure Cache for Managed Redis**: High-throughput distributed caching with SSL-only connectivity.
  - **Azure Synapse Analytics & Data Lake Gen2**: Scalable dimensional Enterprise Data Warehouse with hierarchical namespace storage.
- **Pre-Production Security Auditing**: Includes a comprehensive [Pre-Production Security Checklist](security_audit/pre_production_security_checklist.md) adhering to ISO/IEC 27001 standards.

---

## Architecture Topology

```mermaid
flowchart TD
    subgraph Internet_Traffic ["Public Traffic Boundary"]
        User((End Users & Subsidiaries)) -->|HTTPS Port 443| Gateway[Azure App Service Gateway]
    end

    subgraph Azure_VNet ["Azure Virtual Network (10.240.0.0/16)"]
        subgraph Subnet_App ["snet-appservice (10.240.1.0/24)"]
            Gateway
        end

        subgraph Subnet_Func ["snet-functions (10.240.2.0/24)"]
            Func[Azure Functions: Telemetry Ingest]
        end

        subgraph Subnet_Redis ["snet-redis (10.240.3.0/24)"]
            Redis[(Azure Cache for Redis Standard)]
        end

        subgraph Subnet_PE ["snet-private-endpoints (10.240.4.0/24)"]
            PE_KV[Key Vault Private Endpoint]
            PE_Synapse[Synapse Analytics Private Endpoint]
            PE_Storage[Data Lake Gen2 Private Endpoint]
        end
    end

    subgraph PaaS_Protected ["Hardened PaaS (No Public Access)"]
        KV[(Azure Key Vault RBAC)]
        Synapse[(Azure Synapse Analytics)]
        ADLS[(Azure Data Lake Gen2)]
    end

    Gateway -->|VNet Integration| Redis
    Gateway -->|Managed Identity| PE_KV -.-> KV
    Func -->|Event Stream| PE_Synapse -.-> Synapse
    Synapse --> PE_Storage -.-> ADLS
```

---

## Repository Structure

```text
azure-enterprise-cloud-platform-iac/
├── bicep/
│   ├── main.bicep                     # Master deployment orchestrator
│   ├── parameters.json                # Environment configuration values
│   └── modules/
│       ├── network.bicep              # VNet, Subnets, and NSG rules
│       ├── keyvault.bicep             # Key Vault with RBAC authorization
│       ├── redis.bicep                # Azure Cache for Redis (Standard)
│       ├── appservice.bicep           # Linux App Service & VNet integration
│       ├── functions.bicep            # Serverless Function App & Storage
│       └── synapse.bicep              # Synapse Workspace & ADLS Gen2
├── security_audit/
│   └── pre_production_security_checklist.md # Zero-trust audit checklist
├── .github/workflows/
│   └── ci.yml                         # Automated Bicep build & Checkov linting
├── .gitignore
└── README.md
```

---

## Deployment & Verification

### 1. Pre-Deployment Bicep Compilation & What-If
Validate syntax and preview Azure resource creation:
```powershell
az bicep build --file bicep/main.bicep

az deployment group what-if `
  --resource-group rg-nnpc-energy-prod `
  --template-file bicep/main.bicep `
  --parameters bicep/parameters.json
```

### 2. Execute Infrastructure Provisioning
```powershell
az deployment group create `
  --resource-group rg-nnpc-energy-prod `
  --template-file bicep/main.bicep `
  --parameters bicep/parameters.json
```

---

## Author & Contact

**Jerry A. Nabasu**  
- **Role**: Automation & Digital Innovation Professional  
- **Certifications**: GInI Certified Innovation Strategist (CInS), Azure Data Engineering (2024)  
- **Directorate**: Research, Technology & Innovation (RTI), NNPC Limited  
- **GitHub**: [@JayNabasu](https://github.com/JayNabasu)  
- **Email**: [jerrynabasu@gmail.com](mailto:jerrynabasu@gmail.com)
