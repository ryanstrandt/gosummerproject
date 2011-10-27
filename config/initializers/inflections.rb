
ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural /(.*focus)$/i, '\1es'
  inflect.singular /(.*focus)es$/i, '\1'
end
