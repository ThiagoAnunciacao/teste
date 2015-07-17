class Sulamerica
  def initialize
    prestadores
  end

  def prestadores
    url = 'http://sulamericasaudesa.com.br/pesquisa_resultado2.php'

    Especialidade.all.each do |especialidade|
      result = RestClient.post(url,
                               uf: especialidade.uf,
                               municipio: especialidade.municipio,
                               especialidade: especialidade.nome)

      page = Nokogiri::HTML(result)

      referenciados = []

      Parallel.each(page.css('td.td1 table[width="450"]'), in_threads: 8) do |referenciado|
        refer_split = referenciado.text.split("\r\n")

        endereco = refer_split[6].strip
        planos = refer_split[9].strip

        referenciados << {
          plano: 'SulAmérica',
          uf: especialidade.uf,
          municipio: especialidade.municipio,
          especialidade: especialidade.nome,
          prestador: refer_split[2].strip,
          bairro: refer_split[3].strip,
          endereco: endereco[0..endereco.index(' - Telefone:') -1],
          telefone: endereco[endereco.index(' - Telefone:') + 13..100],
          planos: planos.sub('Planos Atendidos: ', '')
        }
      end

      Prestador.create(referenciados)
    end
  end

  def especialidades
    url = 'http://sulamericasaudesa.com.br/pesquisa_resultado1b.php'
    Cidade.all.each do |cidade|
      result = RestClient.post(url, uf: cidade.uf, municipio: cidade.municipio)

      page = Nokogiri::HTML(result)

      page.css('#busca_sul select[name="especialidade"] option').each do |e|
        Especialidade.create(uf: cidade.uf, municipio: cidade.municipio, nome: e.text)
      end
    end
  end
end
