# Full Discovery Process for Technical Design

## Objective

Conduct comprehensive research and analysis to ensure the technical design is based on complete, accurate, and up-to-date information.

## Discovery Steps

### 1. Requirements Analysis

**Map Requirements to Technical Needs**

- Extract all functional requirements from EARS format
- Identify non-functional requirements (performance, security, scalability)
- Determine technical constraints and dependencies
- List core technical challenges

### 2. Existing Implementation Analysis

**Understand Current System** (if modifying/extending):

- Analyze codebase structure and architecture patterns
- Map reusable components, services, utilities
- Identify domain boundaries and data flows
- Document integration points and dependencies
- Determine approach: extend vs refactor vs wrap

### 3. Technology Research

**Investigate Best Practices and Solutions**:

- **Use WebSearch** to find:
  - Latest architectural patterns for similar problems
  - Industry best practices for the technology stack
  - Recent updates or changes in relevant technologies
  - Common pitfalls and solutions

- **Use WebFetch** to analyze:
  - Official documentation for frameworks/libraries
  - API references and usage examples
  - Migration guides and breaking changes
  - Performance benchmarks and comparisons

### 4. External Dependencies Investigation

**For Each External Service/Library**:

- Search for official documentation and GitHub repositories
- Establish API signatures, auth methods and version compatibility — documentation alone does not settle these (`evidence-discipline.md` §1); pin the version and run a minimal connectivity check
- Investigate rate limits, usage constraints, known issues, and security considerations
- Note any gaps requiring implementation investigation

### 5. Architecture Pattern & Boundary Analysis

**Evaluate Architectural Options**:

- Compare relevant patterns (MVC, Clean, Hexagonal, Event-driven)
- Assess fit with existing architecture and steering principles
- Identify domain boundaries and ownership seams required to avoid team conflicts
- Consider scalability implications and operational concerns
- Evaluate maintainability and team expertise
- Document preferred pattern and rejected alternatives in `research.md`

### 6. Risk Assessment

**Identify Technical Risks**:

- Performance bottlenecks and scaling limits
- Security vulnerabilities and attack vectors
- Integration complexity and coupling
- Technical debt creation vs resolution
- Knowledge gaps and training needs

## Search Strategy

Always search for external API documentation, security practices for auth, and migration paths for dependencies. Search when uncertain about architectural patterns, data-format standards, compliance requirements, or scaling approaches.

Start with official sources (documentation, GitHub), then recent articles, then similar open-source implementations. Prefer primary sources: a vendor's own docs over a blog post describing them.

## Output

Findings go to `research.md` in the claim form of `evidence-discipline.md` §2 — one claim per finding, each with its evidence, and each Design Decision naming the claims it rests on. The template governs the sections; do not invent your own.
