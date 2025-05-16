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
  - Смена тестового раннера с `rails test` на `rspec`.
  - Обновление ссылок на классы для использования полного пространства имён `Parser::LentaParser`.
  - Корректировка вызовов методов с `parse` на `get_product_info`.
- Устранили ошибку несовместимости кодировок в `Parser::LentaParser`:
  - Добавили `response.body.force_encoding('UTF-8')` для установки кодировки ответа в UTF-8

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
