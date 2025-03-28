**Infrastruttura Multi-Cliente su AWS con Terraform**

**Descrizione**

Questo repository contiene un’infrastruttura AWS definita tramite Terraform per supportare un’architettura multi-cliente con microservizi blue/green. L’infrastruttura è progettata per scalabilità e modularità, con risorse isolate per ogni cliente, peering verso una VPC centrale per il traffico Internet e una pipeline CI/CD GitLab per il deployment manuale.

**Componenti Principali**

**VPC**
```
Una VPC per cliente con CIDR dinamico (es. 10.<business_id>.0.0/16)
Subnet pubbliche (/27) per ALB
Subnet private (/24) per EC2
Subnet dedicate (/27) per RDS e scraper
```

**ALB (Application Load Balancer)**

Pubblico, instrada il traffico ai microservizi principali

**EC2**
```

Istanze per microservizi (backend, frontend, fileupload) e scraper
Distribuite su subnet private
```

**Security Groups**

Regole specifiche per ALB, EC2, RDS e accesso al proxy centrale

**RDS**

Cluster Aurora PostgreSQL con una singola istanza nella prima AZ

**S3**

Bucket per cliente per storage generico

**Peering VPC**

Connessione tra VPC cliente e VPC centrale per il traffico Internet

**Proxy Centrale**

Instradamento del traffico tramite un’istanza proxy nella VPC centrale

**Microservizi**
```

**Backend**: Porta 8008 (HTTP), interno.
**Frontend**: Porta 80 (HTTP), pubblico tramite ALB.
**Fileupload**: Porta 8011 (HTTP), instradato su /upload/*.
**Scrapers**: Porte dedicate (es. 8012, 8013, 8014), interni, configurati per usare il proxy.
```

**Architettura**
```
+-------------------------------------+
|            AWS Account              |
|                                     |
|  +--------+       +--------+        |
|  | Client1|       | Client2|        |
|  +--------+       +--------+        |
|  | VPC    |       | VPC    |        |
|  | 10.1.0.0/16|   | 10.2.0.0/16|    |
|  |            |   |            |    |
|  |  +ALB+     |   |  +ALB+     |    |
|  |  Public    |   |  Public    |    |
|  |  Subnets   |   |  Subnets   |    |
|  |            |   |            |    |
|  |  +EC2+     |   |  +EC2+     |    |
|  |  Private   |   |  Private   |    |
|  |  Subnets   |   |  Subnets   |    |
|  +------------+   +------------+    |
|         |                |          |
|    Peering VPC      Peering VPC     |
|         +----------------+          |
|         |   VPC Centrale  |         |
|         |   Proxy (EC2)   |         |
|         +----------------+          |
+-------------------------------------+
```
**Prerequisiti**

```

**Terraform**: Versione >= 1.6.6.
**AWS CLI**: Configurato con credenziali IAM.
**Git**: Per clonare il repository e gestire i moduli.
**GitLab**: Accesso con permessi per avviare pipeline manuali.
```

**Permessi AWS**
```

IAM con permessi per: VPC, EC2, ALB, RDS, S3 (es. AdministratorAccess per test).
Accesso a Secrets Manager per credenziali RDS.
Credenziali salvate in ~/.aws/credentials o come variabili d’ambiente (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY).
Bucket S3 esistente per lo stato Terraform.
```

**Struttura del Repository**
```
terraform/
├── main.tf              # Configurazione principale
├── variables.tf         # Variabili globali
├── outputs.tf           # Output delle risorse
├── versions.tf          # Versioni provider e Terraform
├── vars/                # Directory per file .tfvars per cliente
│   └── <customer>.tfvars
├── modules/
│   ├── vpc/            # VPC, subnet, peering
│   ├── alb/            # Application Load Balancer
│   ├── ec2/            # EC2 
│   ├── rds/            # Cluster Aurora PostgreSQL
│   ├── s3/             # Bucket S3
│   ├── security_groups/# Security Groups
│   └── central_route_and_tg/ # Route table centrale e target group
├── .gitlab-ci.yml       # Pipeline CI/CD
└── README.md           # Documentazione
```
**Flusso di Provisioning**


File .tfvars per cliente in vars/, con parametri come regione, ID aziendale, e riferimenti alla VPC centrale.

**Esecuzione**

1-**Inizializzazione**: terraform init con backend S3.

2-**Provisioning**:
```

Creazione VPC e subnet.
Configurazione ALB, EC2, RDS, S3.
Configurazione Security Groups.
Peering VPC e aggiornamento route table.
Deploy di microservizi con strategia blue/green.
```

3-**Stato**: Salvato in S3 con chiave <customer>/terraform.tfstate.

**Pipeline CI/CD**

File **.gitlab-ci.yml**

**Stadi**
```

**deploy_customer**: Deploy delle risorse.
**destroy_customer**: Distruzione delle risorse.
```

**Variabili**
```

**CUSTOMER**: Nome del cliente (manuale).
**S3_BUCKET_NAME**: Bucket per stato.
Credenziali AWS come variabili CI/CD.
```

**Esecuzione**
```

git add vars/cliente1.tfvars
git commit -m "Aggiunto cliente1"
git push

Avvia la pipeline su GitLab selezionando deploy_customer.
```

**Manuale Utente**

Creazione del File .tfvars

**Esempio:**
```
aws_region        = "eu-west-1"
environment       = "poc"
business_division = "cliente1"
business_id       = 1
version_release   = "001"
tfstate_name      = "cliente1.tfstate"
```

Salva in vars/cliente1.tfvars e push su GitLab.

**Avvio della Pipeline**
```
Accedi a CI/CD > Pipelines.
Clicca Run Pipeline.
Imposta la variabile **CUSTOMER** = cliente1.
Seleziona deploy_customer.
Clicca Run Pipeline.
```
**Risoluzione Problemi**
```
Errore .tfvars non trovato: Controlla nome e percorso.
Errore S3: Verifica bucket e credenziali.
Pipeline fallita: Analizza log per errori Terraform.
```
