# encoding: utf-8
class Bradesco
  def initialize
    begin
      Cidade.all.each do |cidade|
        pages = bairros_num_pages(cidade.uf, cidade.municipio)

        (1..pages).each do |page|
          bairros(cidade.uf, cidade.municipio, page)
        end
      end
    rescue Exception => e
      p e.message
      p e.backtrace
    end
  end

  def locais
    url = 'http://www.bradescosaude.com.br/acessibilidade/dwr/exec/BuscaReferenciadoDWR.listarCidadePorUf.dwr'

    result = RestClient.post(url, {
                             'callCount' => 1,
                             'c0-scriptName' => 'BuscaReferenciadoDWR',
                             'c0-methodName' => 'listarCidadePorUf',
                             'c0-id' => '2_1437069349081',
                             'c0-param0' => 0,
                             'c0-param1' => 'AC',
                             'c0-param2' => false,
                             'xml' => true
                            })

    pp result
  end

  def bairros_num_pages(uf, cidade)
    url_rede_main = "https://wwws.bradescosaude.com.br/PCBS-BuscaReferenciadoRAD/buscaReferenciadoPortal.do?especialidade=0&nomeReferenciado=&css=urlHttpServer&pesquisa=tipo&NOVO_PORTAL_DENTAL=N&uf=#{uf}&tipoServico=9999&tpPesq=M&cidade=#{cidade}&cdRede=0"

    html_page = Nokogiri::HTML(open(url_rede_main))

    itens = html_page.css('.pagebanner').first.text[0..10].gsub(/[a-zA-Z.,]/, '').to_f rescue 12

    (itens.to_f / 12).ceil rescue 1
  end

  def bairros(uf, cidade, page)
    url_rede_main = "https://wwws.bradescosaude.com.br/PCBS-BuscaReferenciadoRAD/buscaReferenciadoPortal.do?especialidade=0&nomeReferenciado=&css=urlHttpServer&pesquisa=tipo&NOVO_PORTAL_DENTAL=N&uf=#{uf}&tipoServico=9999&tpPesq=M&d-442767-p=#{page}&cidade=#{cidade}&cdRede=0"

    html_page = Nokogiri::HTML(open(url_rede_main))

    itens = html_page.css('.pagebanner').first.text[0..10].gsub(/[a-zA-Z.,]/, '').to_f rescue 12

    pages = (itens.to_f / 12).ceil

    html_page.xpath("//table[contains(@id,'bairro')]/tbody/tr/td[contains(@class,'fundodegradee')]").search('img').each do |img|
      bairro = img.attributes.first.last.to_s.sub('img_', '')
      prestadores(uf, cidade, bairro)
    end
  end

  def prestadores(uf, cidade, bairro)
    url_rede1 = "https://wwws.bradescosaude.com.br/PCBS-BuscaReferenciadoRAD/dwr/exec/BuscaReferenciadoDWR.listarReferenciadosPorBairro.dwr"

    result = RestClient.post(url_rede1, {
                             'callCount' => 1,
                             'c0-scriptName' => 'BuscaReferenciadoDWR',
                             'c0-methodName' => 'listarReferenciadosPorBairro',
                             'c0-id' => '3940_1437068520609',
                             'c0-param0' => '',
                             'c0-param1' => false,
                             'c0-param2' => '000000000000000',
                             'c0-param3' => bairro,
                             'c0-param4' => '',
                             'c0-param5' => uf,
                             'c0-param6' => cidade,
                             'c0-param7' => '9999',
                             'c0-param8' => '0',
                             'c0-param9' => 'tipo',
                             'c0-param10' => 'M',
                             'c0-param11' => '0',
                             'c0-param12' => '0',
                             'c0-param13' => 'N',
                             'c0-param14' => 'E',
                             'c0-param15' => '',
                             'c0-param16' => '',
                             'c0-param17' => '',
                             'c0-param18' => '',
                             'c0-param19' => '',
                             'xml' => false})

    page = Nokogiri::HTML(result)

    classe = 'on'

    resultados = []
    dados = []
    hash = { uf: uf, municipio: cidade, bairro: bairro, plano: 'Bradesco' }

    page.xpath("//table[contains(@class,'bg_tabela1')]/tr").each do |tr|
      tr_classe = tr.attr('class')
      next unless tr_classe
      tr_classe = tr_classe.gsub('\\"', '')

      texto = tr.text.gsub("\\t", '').gsub("\\n", '').gsub("\\r", ' ').tr('  ', ' ').sub('\\u00BA', 'º').sub('\\u00C7', 'Ç').strip

      next if texto.empty?

      dados << texto

      if tr_classe != classe
        classe = tr_classe
        hash = { uf: uf, municipio: cidade, bairro: bairro, plano: 'Bradesco' }
        resultados << dados.collect { | dado | mapea_dado(hash, dado) }.first
        dados = []
      end
    end

    unless dados.blank?
      resultados << dados.collect { | dado | mapea_dado(hash, dado) }.first
    end

    resultados.each do |resultado|
      Prestador.create(resultado)
    end
  end

  def mapea_dado(hash, dado)
    nome = 'Nome do Profissional:'
    nome_fantasia = 'Nome Fantasia:'
    endereco = 'Endereço:'
    telefone = 'Telefone(s):'
    especialidade = 'Especialidade(s):'
    data_cadastro = 'Cadastro Atualizado em:'

    if dado.index(nome)
      hash.merge!(prestador: dado.sub(nome, '').strip)
    elsif dado.index(nome_fantasia)
      hash.merge!(prestador: dado.sub(nome_fantasia, '').strip)
    elsif dado.index(endereco)
      hash.merge!(endereco: dado.sub(endereco, '').strip)
    elsif dado.index(telefone)
      hash.merge!(telefone: dado.sub(telefone, '').strip)
    elsif dado.index(especialidade)
      hash.merge!(especialidade: dado.sub(especialidade, '').strip)
    elsif dado.index(data_cadastro)
      hash.merge!(data_cadastro: dado.sub(data_cadastro, '').strip)
    end
  end
end
