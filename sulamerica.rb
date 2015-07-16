class Sulamerica

  def initialize
    url_rede_main = 'http://sulamericasaudesa.com.br/rede-referenciada-especialidade.php'

    # doc = Nokogiri::HTML(open(url_rede_main))

    # doc.css('#form1 .inputlaranja2 option').each do |op|
    #   puts op.attr('value')
    #   puts op.text

    #   Estado.create(uf: op.attr('value'), descricao: op.text)
    # end

    url_rede1 = 'http://sulamericasaudesa.com.br/pesquisa_resultado1.php'
    url_rede2 = 'http://sulamericasaudesa.com.br/pesquisa_resultado1b.php'
    url_rede3 = 'http://sulamericasaudesa.com.br/pesquisa_resultado2.php'

    # Estado.all.each do |estado|
    #   result = RestClient.post(url_rede, uf: estado.uf)

    #   page = Nokogiri::HTML(result)

    #   page.css('#busca_sul select[name="municipio"] option').each do |m|
    #     Cidade.create(uf: estado.uf, municipio: m.text)
    #   end
    # end

    # Cidade.all.each do |cidade|
    #   result = RestClient.post(url_rede2, uf: cidade.uf, municipio: cidade.municipio)

    #   page = Nokogiri::HTML(result)

    #   page.css('#busca_sul select[name="especialidade"] option').each do |e|
    #     Especialidade.create(uf: cidade.uf, municipio: cidade.municipio, nome: e.text)
    #   end
    # end

    # Especialidade.in(uf: ['SE', 'TO']).each do |especialidade|
    #   result = RestClient.post(url_rede3,
    #                            uf: especialidade.uf,
    #                            municipio: especialidade.municipio,
    #                            especialidade: especialidade.nome)

    #   page = Nokogiri::HTML(result)

    #   referenciados = []

    #   Parallel.each(page.css('td.td1 table[width="450"]'), in_threads: 8) do |referenciado|
    #     refer_split = referenciado.text.split("\r\n")

    #     endereco = refer_split[6].strip
    #     planos = refer_split[9].strip

    #     referenciados << {
    #       uf: especialidade.uf,
    #       municipio: especialidade.municipio,
    #       especialidade: especialidade.nome,
    #       prestador: refer_split[2].strip,
    #       bairro: refer_split[3].strip,
    #       endereco: endereco[0..endereco.index(' - Telefone:') -1],
    #       telefone: endereco[endereco.index(' - Telefone:') + 13..100],
    #       planos: planos.sub('Planos Atendidos: ', '')
    #     }
    #   end

    #   Prestador.create(referenciados)
    # end

    # pp Prestador.all.pluck(:uf).uniq
  end
end
