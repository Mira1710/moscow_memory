Place.destroy_all

places = [
  {
    name: "Архитектурный объект №1",
    description: "Тестовое описание архитектурного объекта. Здесь позже будет настоящий исторический текст.",
    address: "Москва",
    latitude: 55.7558,
    longitude: 37.5837,
    year_from: 1928,
    year_to: 1930
  },
  {
    name: "Архитектурный объект №2",
    description: "Заглушка для будущего описания объекта.",
    address: "Москва",
    latitude: 55.7512,
    longitude: 37.6184,
    year_from: 1950,
    year_to: 1960
  },
  {
    name: "Архитектурный объект №3",
    description: "Здесь позднее появится информация об истории этого места.",
    address: "Москва",
    latitude: 55.7600,
    longitude: 37.6200,
    year_from: 1970,
    year_to: 1980
  }
]

places.each do |place|
  Place.create!(place)
end

puts "Created #{Place.count} places"