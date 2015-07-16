class Prestador
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :plano, type: String
end