# Active Context

## Current Work Focus
- Implementing the basic part of the application.
- Working on the Lenta parser (Parser::LentaParser).
- Fixed test execution issues for Lenta parser.

## Recent Changes
- The application can receive a link from the user through a form.
- The application can make a request to the store using the link.
- The application can save the received data.
- The application can display ratings as a chart.
- The application can search for all created ProductSources by product name.
- Fixed Lenta parser test issues:
  - Changed test runner from `rails test` to `rspec`
  - Updated class references to use full namespace `Parser::LentaParser`
  - Corrected method calls from `parse` to `get_product_info`

## Next Steps
- Implement the pattern to use the application as a base and connect parsers as modules.
- Add more test coverage for parser functionality.

## Active Decisions
- How to best implement the module pattern for parsers.
- Using proper namespace structure for parsers (Parser:: namespace).

## Important Patterns
- Use the application as a base and connect parsers as modules.
- Always use full namespace references in tests.
- Prefer `rspec` over `rails test` for testing parsers.
