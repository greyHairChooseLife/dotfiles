# Color Palette & Brand Style

**This is the single source of truth for all colors and brand-specific styles.** To customize diagrams for your own brand, edit this file — everything else in the skill is universal.

---

## Shape Colors (Semantic)

Colors encode meaning, not decoration. Each semantic purpose has a fill/stroke pair.

| Semantic Purpose | Fill | Stroke |
|------------------|------|--------|
| Primary/Neutral | `#3b82f6` | `#1e3a5f` |
| Secondary | `#60a5fa` | `#1e3a5f` |
| Tertiary | `#93c5fd` | `#1e3a5f` |
| Start/Trigger | `#fed7aa` | `#c2410c` |
| End/Success | `#a7f3d0` | `#047857` |
| Warning/Reset | `#fee2e2` | `#dc2626` |
| Decision | `#fef3c7` | `#b45309` |
| AI/LLM | `#ddd6fe` | `#6d28d9` |
| Inactive/Disabled | `#dbeafe` | `#1e40af` (use dashed stroke) |
| Error | `#fecaca` | `#b91c1c` |

**Rule**: Always pair a darker stroke with a lighter fill for contrast.

---

## Text Colors (Hierarchy)

Use color on free-floating text to create visual hierarchy without containers.

| Level | Color | Use For |
|-------|-------|---------|
| Title | `#1e40af` | Section headings, major labels |
| Subtitle | `#3b82f6` | Subheadings, secondary labels |
| Body/Detail | `#64748b` | Descriptions, annotations, metadata |
| On light fills | `#374151` | Text inside light-colored shapes |
| On dark fills | `#ffffff` | Text inside dark-colored shapes |

---

## Evidence Artifact Colors

Used for code snippets, data examples, and other concrete evidence inside technical diagrams.

| Artifact | Background | Text Color |
|----------|-----------|------------|
| Code snippet | `#1e293b` | Syntax-colored (language-appropriate) |
| JSON/data example | `#1e293b` | `#22c55e` (green) |

---

## Default Stroke & Line Colors

| Element | Color |
|---------|-------|
| Arrows | Use the stroke color of the source element's semantic purpose |
| Structural lines (dividers, trees, timelines) | Primary stroke (`#1e3a5f`) or Slate (`#64748b`) |
| Marker dots (fill + stroke) | Primary fill (`#3b82f6`) |

---

## Background

| Property | Value |
|----------|-------|
| Canvas background | `#ffffff` |

---

## Architecture / Component Palettes

Use these when diagramming real infrastructure or platform-specific architectures.

### Default (Platform-Agnostic)

| Component Type | Fill | Stroke |
|----------------|------|--------|
| Frontend/UI | `#a5d8ff` | `#1971c2` |
| Backend/API | `#d0bfff` | `#7048e8` |
| Database | `#b2f2bb` | `#2f9e44` |
| Storage | `#ffec99` | `#f08c00` |
| AI/ML Services | `#e599f7` | `#9c36b5` |
| External APIs | `#ffc9c9` | `#e03131` |
| Orchestration | `#ffa8a8` | `#c92a2a` |
| Validation | `#ffd8a8` | `#e8590c` |
| Network/Security | `#dee2e6` | `#495057` |
| Classification | `#99e9f2` | `#0c8599` |
| Users/Actors | `#e7f5ff` | `#1971c2` |
| Message Queue | `#fff3bf` | `#fab005` |
| Cache | `#ffe8cc` | `#fd7e14` |
| Monitoring | `#d3f9d8` | `#40c057` |

### AWS

| Service Category | Fill | Stroke |
|-----------------|------|--------|
| Compute (EC2, Lambda, ECS) | `#ff9900` | `#cc7a00` |
| Storage (S3, EBS) | `#3f8624` | `#2d6119` |
| Database (RDS, DynamoDB) | `#3b48cc` | `#2d3899` |
| Networking (VPC, Route53) | `#8c4fff` | `#6b3dcc` |
| Security (IAM, KMS) | `#dd344c` | `#b12a3d` |
| Analytics (Kinesis, Athena) | `#8c4fff` | `#6b3dcc` |
| ML (SageMaker, Bedrock) | `#01a88d` | `#017d69` |

### Azure

| Service Category | Fill | Stroke |
|-----------------|------|--------|
| Compute | `#0078d4` | `#005a9e` |
| Storage | `#50e6ff` | `#3cb5cc` |
| Database | `#0078d4` | `#005a9e` |
| Networking | `#773adc` | `#5a2ca8` |
| Security | `#ff8c00` | `#cc7000` |
| AI/ML | `#50e6ff` | `#3cb5cc` |

### GCP

| Service Category | Fill | Stroke |
|-----------------|------|--------|
| Compute (GCE, Cloud Run) | `#4285f4` | `#3367d6` |
| Storage (GCS) | `#34a853` | `#2d8e47` |
| Database (Cloud SQL, Firestore) | `#ea4335` | `#c53929` |
| Networking | `#fbbc04` | `#d99e04` |
| AI/ML (Vertex AI) | `#9334e6` | `#7627b8` |

### Kubernetes

| Component | Fill | Stroke |
|-----------|------|--------|
| Pod | `#326ce5` | `#2756b8` |
| Service | `#326ce5` | `#2756b8` |
| Deployment | `#326ce5` | `#2756b8` |
| ConfigMap/Secret | `#7f8c8d` | `#626d6e` |
| Ingress | `#00d4aa` | `#00a888` |
| Node | `#303030` | `#1a1a1a` |
| Namespace | `#f0f0f0` | `#c0c0c0` (dashed) |
