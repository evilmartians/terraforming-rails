module RuboCop
  module Cop
    module Lint
      # This cops checks for direct usage of ENV variables and
      # Rails.env
      class Env < RuboCop::Cop::Cop
        MSG_ENV = "Avoid direct usage of ENV in application code"
        MSG_RAILS_ENV = "Avoid direct usage of Rails.env in application code"
        USAGE_MSG = ", use configuration parameters instead"

        def_node_matcher :env?, <<~PATTERN
          {(const nil? :ENV) (const (cbase) :ENV)}
        PATTERN

        def_node_matcher :rails_env?, <<~PATTERN
          (send {(const nil? :Rails) (const (cbase) :Rails)} :env)
        PATTERN

        def on_const(node)
          return unless env?(node)
          return if allowed_env?(node.parent.children.last.children.last)
          add_offense(node.parent, location: :selector, message: MSG_ENV + USAGE_MSG)
        end

        def on_send(node)
          return unless rails_env?(node)
          add_offense(node.parent.type == :send ? node.parent : node, location: :selector, message: MSG_RAILS_ENV + USAGE_MSG)
        end

        private

        def allowed_env
          Array(cop_config["AllowedEnv"])
        end

        def allowed_env?(env)
          return true if cop_config["AllowedEnv"] == "all"

          allowed_env.include?(env)
        end
      end
    end
  end
end
