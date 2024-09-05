# frozen_string_literal: true

module Crono
  class Engine < ::Rails::Engine
    isolate_namespace Crono

    initializer 'crono.assets.precompile' do |app|
      if app.config.respond_to?(:assets)
        if defined?(Sprockets) && Sprockets::VERSION >= '4'
          app.config.assets.precompile += %w[crono/application.css crono/materialize.min.css]
        else
          app.config.assets.precompile << proc { |path| path == 'crono/application.css' }
          app.config.assets.precompile << proc { |path| path == 'crono/materialize.min.css' }
        end
      end
    end

  end
end
