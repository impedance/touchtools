# System Patterns

## System Architecture
The application consists of the following components:
- **ProductSource**: Represents a product with a name and a link to the website where the product description is located. Each store has a unique ProductSource, even if the products are the same.
- **ProductMetric**: Stores the ratings for each ProductSource.

## Key Technical Decisions
- Using a Factory pattern (ProviderFactory) to connect providers.

## Design Patterns
- Factory pattern (ProviderFactory) for connecting providers (currently not working).

## Component Relationships
- ProductSource has many ProductMetrics.

## Critical Implementation Paths
- Connecting providers through the Factory pattern.
