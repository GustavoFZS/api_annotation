module ApiAnnotation
  module AnnotationGenerator
    def method_added(met_sym)
      super

      method_name = met_sym.to_s
      class_name = to_s
      path = "#{class_name}/#{method_name}"

      if ApiAnnotation.annotations.current.empty?
        warn "#{method_name} is not annotated" if ApiAnnotation.show_warns
      else
        ApiAnnotation.annotations.add(path)
      end
    end

    def annotate_method(method_name, params)
      ApiAnnotation.annotations.current[method_name] = params
    end

    def create_tag(anot_sym)
      code =
        "def #{anot_sym}(val)
          annotate_method( :#{anot_sym} , val)
        end"
      instance_eval code
    end
  end
end
