# SVG меток

Файлы категорий: public_spaces.svg (городские пространства), houses.svg, public_buildings.svg, churches.svg, estates.svg, industrial.svg, metro.svg, lost.svg.

Для одной общей метки: default.svg.

Для отдельного объекта: places/ID.svg, например places/1.svg. Она имеет приоритет над значком категории. ID — номер существующего объекта из адреса /places/1.

Категория выбирается в форме «Редактировать статью» (/places/:id/edit) и сохраняется в базе. config/map_places.yml больше не используется. Пока категория не задана, объект отображается в группе «Без категории». Координаты берутся из существующих Place.latitude/longitude; SVG сам по себе не задаёт положение точки.

Добавляйте SVG с viewBox. Размер метки на карте 44×44; центр SVG совпадает с координатой. Настройки — memory_map_controller.js, iconImageSize и iconImageOffset. Пока файла нет, отображается стандартная метка Яндекса. После добавления файлов обновите страницу; для production пересоберите assets.
