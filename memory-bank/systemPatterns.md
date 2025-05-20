# System Patterns

The system follows a modular architecture with a focus on reusable components and a consistent parsing flow.

**Key Components:**

-   **Parser Classes:** Each online store has its own parser class (e.g., `DixyParser`, `MagnitParser`). These classes are responsible for extracting product information from the store's website.
-   **Parser Factory:** The `ParserFactory` is responsible for creating instances of the appropriate parser class based on the product URL.
-   **Data Formatting:** The `format_output` method is used to format the extracted data into a human-readable string.

**Design Patterns:**

-   **Factory Pattern:** The `ParserFactory` implements the Factory Pattern to create parser instances.
-   **Template Method Pattern:** The parsing process follows a consistent template: fetch HTML, parse with Nokogiri, extract data, format output. Individual parsers can customize the extraction logic as needed.

**Implementation Details:**

-   Parsers use `net/http` to fetch HTML content from online stores.
-   Nokogiri is used to parse the HTML and extract data using CSS selectors.
-   Error handling is implemented using `begin...rescue` blocks.
-   Logging is used to track the parsing process and report errors.

**Relationships:**

-   The `ParserFactory` creates instances of parser classes.
-   Parser classes use `net/http` and Nokogiri to extract data.
-   Parser classes use `format_output` to format the extracted data.
