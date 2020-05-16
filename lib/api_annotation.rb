# frozen_string_literal: true

require 'annotations/annotation_generator'
require 'annotations/annotation_map'
require 'validator/params'
require 'general/general'
require 'constants/constants'

module ApiAnnotation
  class << self
    attr_accessor :configuration
    attr_accessor :annotation_map
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.annotations
    self.annotation_map ||= AnnotationMap.new
  end

  def self.show_warns
    configuration && configuration.show_warns
  end

  class Configuration
    attr_accessor :show_warns

    def initialize
      @show_warns = true
    end

    def settings
      settings = {}
      settings[:show_warns] = @show_warns
      settings
    end
  end
end
