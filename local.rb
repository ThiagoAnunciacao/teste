class Estado
  include Mongoid::Document

  field :uf, type: String
  field :descricao, type: String
end

class Cidade
  include Mongoid::Document

  field :uf, type: String
  field :municipio, type: String
end