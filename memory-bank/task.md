
## Задача
Парсер для dixy по аналогии с парсером magnit

нужно написать парсер данных для магазина dixy, похожий парсер написан для магнита, нужно достать следующую информацию:
Наименование товара,
цена без скидки, 
цена со скидкой


### содержимое html в котором необходимые данные

```html
<div class="card-info">
          <h1 class="detail-card__title open" data-id="214954">Сыр полутвердый Брест-Литовск Тильзитер 45% 200г</h1>
          <div class="card-info__head">
            <div class="card-info__head_holder">
              <div class="logo-brand"><span class="logo-brand__title">Брест-Литовск</span></div>
            </div>
            <div class="card-info__head_actions">
              <div class="share" onclick="copyUrl(this)">
                <svg>
                  <use xlink:href="/local/templates/dixy_ru/images/sprites.svg#share"></use>
                </svg>
              </div>
              <div class="bookmark transit">
                <svg>
                  <use xlink:href="/local/templates/dixy_ru/images/sprites.svg#bookmark"></use>
                </svg>
              </div>
            </div>
          </div>
          <div class="main-info">
            <div class="card-line detail" data-bsk_data="214954 1 1 шт 0" data-id="214954" data-template="detail-button">
  <div class="card-line__price">
    <div class="card-line__price_holder">
      <div class="card__price in-time">
        <div class="card__price-num">199.<span>90</span><span class="rub">руб.</span></div><span class="card__price-crossed">229.<span>90</span><span class="rub">руб.</span></span>
      </div>
      <div class="card__price-note">
        <svg data-pop-content="" onclick="dataLayerShopDetail(this)">
          <use xlink:href="/local/templates/dixy_ru/images/sprites.svg#info"></use>
        </svg>
        <p>Цена в конкретном магазине</p>
        <div class="note-block top">                   
                            
                 <p class="text">Товарное предложение доступно в магазине по адресу:</p>
                 
                 <button class="btn tertiary-light" aria-label="Действие кнопки">Понятно</button>                 
            </div>
      </div>
    </div>
    <div class="main-info__cart desktop">
          <button class="btn primary card-line__cartBnt" onclick="countpluse(this,'listingInitiator'); event.preventDefault();" type="button" aria-label="Кнопка Добавить в корзину"><span>В корзину</span></button>
  </div>
  </div>
</div>
              <div class="main-info__block"><span class="heading">Способ получения заказа:</span>
                <div class="main-info__block_wrapper">
                  <div class="main-info__block_holder">
                    <svg class="icon">
                      <use xlink:href="/local/templates/dixy_ru/images/sprites.svg#delivery"></use>
                    </svg>
                    <div class="main-info__block_content">
                      <p>Доставка,&nbsp;<span>от 168 <span class="rub">руб.</span></span></p>
                      <button class="main-info__block-btn" type="button" onclick="document.querySelector('.address').click(); dataLayerAddressChoice(this)" aria-label="Укажи адрес"><span>Укажи адрес</span>
                        <svg>
                          <use xlink:href="/local/templates/dixy_ru/images/sprites.svg#arrow_right"></use>
                        </svg>
                      </button>
                    </div>
                  </div>
                  <div class="main-info__block_holder">
                    <svg class="icon">
                      <use xlink:href="/local/templates/dixy_ru/images/sprites.svg#shop"></use>
                    </svg>
                    <div class="main-info__block_content">
                      <p>Самовывоз из магазина:&nbsp;<span>Сегодня, бесплатно</span></p>
                      <button class="main-info__block-btn" type="button" onclick="document.querySelector('.address').click(); dataLayerAddressChoice(this)" aria-label="Выбери магазин"><span>Выбери магазин</span>
                        <svg>
                          <use xlink:href="#arrow_right"></use>
                        </svg>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
          </div>
          

        </div>
```
