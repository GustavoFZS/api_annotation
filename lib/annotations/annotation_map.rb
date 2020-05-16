module ApiAnnotation
  class AnnotationMap
    attr_accessor :current

    def initialize
      @annotation_map = {}
      @current = {}
    end

    def add(path, value = @current)
      path = formatted_path(path)
      nodes = path.split('/')
      intermediate_nodes = nodes[0..-2]
      last_node = nodes.last
      filtred_map = @annotation_map

      intermediate_nodes.each do |node|
        @annotation_map[node] ||= {}
        filtred_map = @annotation_map[node]
      end

      @current = {}
      filtred_map[last_node] = value
    end

    def get(path = nil)
      return @annotation_map if path.nil?

      path = formatted_path(path)
      nodes = path.split('/')
      intermediate_nodes = nodes[0..-2]
      last_node = nodes.last
      filtred_map = @annotation_map

      intermediate_nodes.each do |node|
        return nil if @annotation_map[node].nil?

        filtred_map = @annotation_map[node]
      end

      filtred_map[last_node]
    end

    def to_html
      "<!DOCTYPE html>
      <html>
      <body>
      #{controllers_html(get)}
      </body>
      </html>"
    end

    def controllers_html(annotations)
      controllers = annotations.keys.select { |ann| ann.include?('controller') }
      controllers_html = ''
      controllers.each do |controller|
        controllers_html << "<h2>#{controller.gsub('controller', '')}</h2>"
        controllers_html << method_html(annotations[controller])
      end
      controllers_html
    end

    def method_html(annotations)
      methods = annotations.keys
      methods_html = ''
      methods.each do |method|
        methods_html << "<h3>#{method}</h3>"
        methods_html << examples_html(annotations[method])
      end
      methods_html
    end

    def examples_html(annotations)
      required = annotations[REQUIRED_PARAMS]
      optional = annotations[OPTIONAL_PARAMS]

      html = ''
      if required
        required = params_html(annotations[REQUIRED_PARAMS]) || ''
        html << "<h5>Parametros obrigatorios:</h5><br>#{required}"
      end
      if optional
        optional = params_html(annotations[OPTIONAL_PARAMS]) || ''
        html << "<br><h5>Parametros opcionais:</h5><br>#{optional}"
      end
      html
    end

    def params_html(params)
      return nil unless params

      html = '<table style="width:100%">
                <tr>
                  <th>Campo</th>
                  <th>Tipo</th>
                  <th>Default</th>
                  <th>Descricao</th>
                  <th>Comentario</th>
                </tr>'
      html << table_html(params)
      html << '</table>'
      html
    end

    def table_html(params)
      return nil unless params

      html = ''
      keys = params.keys
      keys.each do |key|
        html << if params[key].is_a? String
                  values = params[key].split('|')
                  "<tr>
                    <td>#{key}</td>
                    <td>#{values[0]}</td>
                    <td>#{values[1]}</td>
                    <td>#{values[2]}</td>
                    <td>#{values[3]}</td>
                  </tr>"
                else
                  table_html(params[key])
                end
      end
      html
    end

    def formatted_path(path)
      path = path.gsub(PARAMS_SPLIT, '/')
      path.downcase
    end
  end
end
