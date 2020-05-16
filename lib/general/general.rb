# frozen_string_literal: true

module ApiAnnotation
  module General
    def api_annotations!
      extend ApiAnnotation::AnnotationGenerator

      create_tag(REQUIRED_PARAMS)
      create_tag(OPTIONAL_PARAMS)

      validate_method =
        'def validate_params
          method_name = action_name
          class_name = self.class.name
          path = "#{class_name}/#{method_name}"
          result = ApiAnnotation::Params.clean_params(path, params.to_unsafe_h)
          required_params = result[' + MISSING_PARAMS.to_s + ']
          if required_params
            render json: { message: "Os parametros #{required_params.join(\', \')} são obriatórios" }, status: 400
          end
          params = result[' + PARAMS.to_s + ']
        end'

      class_eval validate_method
    end
  end
end
