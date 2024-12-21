#!/usr/bin/env ruby

require 'json'
require 'securerandom'

# Ruta al archivo JSON original
file_path = '/home/apresta/Workspace/ExamenInteractivo/db/preguntas.json'

# Ruta al nuevo archivo JSON
new_file_path = '/home/apresta/Workspace/ExamenInteractivo/db/preguntas_nuevo.json'

# Cargar el JSON
File.open(file_path, 'r') do |f|
  data = JSON.parse(f.read())

  # Crear un nuevo array con IDs únicos
  nuevo_data = data.map.with_index do |pregunta, index|
    pregunta['id'] = index + 1
    pregunta
  end

  # Guardar el JSON modificado
  File.open(new_file_path, 'w') do |f|
    f.write(JSON.pretty_generate(nuevo_data)) 
  end
end