# frozen_string_literal: true

module ApiAnnotation
  module Params
    def self.clean_params(path, params)
      annotations = ApiAnnotation.annotations.get(path)
      return nil unless annotations

      result = {}
      result[MISSING_PARAMS] = if annotations[REQUIRED_PARAMS]
                                 missing_params(path, params)
                               else
                                 []
                               end

      if annotations[REQUIRED_PARAMS] || annotations[OPTIONAL_PARAMS]
        result[PARAMS] = remove_unexpected_params(path, params)
      else
        warn "#{path} is not annotated" if ApiAnnotation.show_warns
        result[PARAMS] = params
      end
      result
    end

    def self.remove_unexpected_params(path, params)
      annotations = ApiAnnotation.annotations.get(path)
      expected_params = expected_params(annotations)
      clean_json(params, expected_params)
    end

    def self.missing_params(path, params)
      annotations = ApiAnnotation.annotations.get(path)
      required = json_keys(annotations[REQUIRED_PARAMS])
      params_keys = json_keys(params)
      array_diff(required, params_keys)
    end

    def self.array_diff(array1, array2)
      array1 - array2
    end

    def self.json_keys(json)
      json_keys_array(json).join(',').split(',')
    end

    def self.json_keys_array(json, current_key = nil)
      json.map do |i|
        key = current_key ? "#{current_key}#{PARAMS_SPLIT}#{i[0]}" : i[0]
        if i[1].class == Hash
          json_keys_array(i[1], key)
        else
          key
        end
      end
    end

    def self.clean_json(params, expected_params)
      result = {}
      expected_params.keys.map do |key|
        param = params[key.to_s]
        next unless param

        result[key] = if expected_params[key].class == Hash
                        clean_json(param, expected_params[key])
                      else
                        param
                      end
      end
      result
    end

    def self.expected_params(annotations)
      if annotations[REQUIRED_PARAMS] && annotations[OPTIONAL_PARAMS]
        annotations[REQUIRED_PARAMS].merge(annotations[OPTIONAL_PARAMS])
      else
        annotations[REQUIRED_PARAMS] || annotations[OPTIONAL_PARAMS]
      end
    end
  end
end
