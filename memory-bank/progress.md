# Progress

## What Works
- The form for adding product links is working.
- The form saves the link and product information if parsing is successful.
- The rating is displayed in a chart after successful parsing.

## What's Left to Build
- Ensure that the product is added even if there is an error in parsing.
- Show the parsing status on the form for all added links (currently shows "Parsing" always).
- Add a "Get Data" button to ProductSource, which calls the parser and attempts to get new data for the product and add the rating to a new product_metric if a new rating is available.

## Current Status
- Basic functionality is implemented, but there are issues with error handling and updating data.

## Known Issues
- Lenta parser is not working.
- Parsing status is not updated correctly on the form.

## Evolution of Project Decisions
- The project is evolving towards a modular architecture where parsers can be easily added and updated.

## Progress Log
- Устранили ошибку несовместимости кодировок в `Parser::LentaParser`:
  - Добавили `response.body.force_encoding('UTF-8')` для установки кодировки ответа в UTF-8

## All parsers
- dixy
- [x] magnit
- [x] lenta
- megamarket
- ozon
- vprok
- perekrestok
- yandex market
- wildberries
- flamb
- drom
- chinamobil
- skidka-msk
- metro
- mvideo
- eldorado
- foodsprice
- ratengoods
- zoon
- yell
- rostov.flamp
- yandex maps
- banki
- dreamjob
- nerab
- orabote
- vseotzyvy.ru
- otzovik
- irecommend
- 2gis
- otzyvru
- ru.OTZYV
- utkonos
- komus

## Parser in progress
dixy

