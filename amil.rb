# encoding: utf-8
class Amil
  def initialize
    begin
      tipo_servicos = ['CONSULTORIO / CLINICAS', 'HOSPITAIS ELETIVOS', 'PRONTO ATENDIMENTO - HORARIO COMERCIAL', 'PRONTO-SOCORRO 24H (URGENCIA E EMERGENCIA)', 'SERVICOS AUXILIARES DE DIAGNOSTICOS E TERAPIA']

      Cidade.all.each do |cidade|
        url = 'http://www.amil.com.br/portal/web/servicos/saude/rede-credenciada/resultado-partial'
        default_params = 'plano.codigo=&filtro.operadora=&filtro.contexto=amil&identificacao=&filtro.codigoRede=628&filtro.bairro=TODOS+OS+BAIRROS&_=1437159803035'

        tipo_servicos.each do |tipo_servico|
          url_rede_main = "#{url}?#{default_params}&filtro.uf=#{cidade.uf}&filtro.municipio=#{cidade.municipio}&filtro.tipoServico=#{tipo_servico}"

          html_page = Nokogiri::HTML(open(url_rede_main))

          hash = { plano: 'Amil' }

          html_page.xpath("//table[contains(@class,'tabelaBusca')]").each do |page|
            hash.merge!(
              especialidade: page.at('caption').text,
              nome_fantasia: page.at('.nomeFantasia').text,
              cpnj: page.at('.nomeFantasia').next.next.text.gsub('CNPJ: ', ''),
              logradouro: page.at('.logradouro').text,
              complemento: page.at('.complemento').text,
              cep: page.at('.cep').text,
              cidade: page.at('.cidade').text,
              uf: page.at('.estado').text,
              prestador: page.at('.titulo').text,
              telefones: page.at('.telefones').text.scan(/([0-9-]+)/).flatten.join(' / '),
              bairro: page.at('.bairro').text
            )

            Prestador.create(hash)
          end
        end
      end
    rescue Exception => e
      p e.message
      p e.backtrace
    end

    # begin
    #   Cidade.all.each do |cidade|
    #     pages = bairros_num_pages(cidade.uf, cidade.municipio)

    #     (1..pages).each do |page|
    #       bairros(cidade.uf, cidade.municipio, page)
    #     end
    #   end
    # rescue Exception => e
    #   p e.message
    #   p e.backtrace
    # end
  end
end
