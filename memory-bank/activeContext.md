# Active Context

The current focus is on maintaining and improving the core parsing logic within the `lib/parser` directory. Recent changes have involved analyzing and understanding the structure of `DixyParser` and `MagnitParser` to identify common patterns and potential areas for refactoring.

Next steps include:

-   Documenting the identified patterns and architectural decisions in `systemPatterns.md`.
-   Refactoring the parsers to reduce code duplication and improve maintainability.
-   Adding support for new online stores.
-   Addressing known issues with existing parsers (e.g., the Lenta parser).

Important considerations:

-   The project should be designed to easily accommodate new parsers.
-   Error handling should be robust and consistent across all parsers.
-   The parsing logic should be as efficient as possible to minimize processing time.
