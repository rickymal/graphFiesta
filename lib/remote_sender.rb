require "./core/base_graph.rb"

# Ainda precisa ser implementado
module Graph
    class RemoteSender < Core::BaseGraph
        def run(initial_value)
            resp = @pipegraphs.inject(initial_value) do |val, pipe|
                pipe.flow(val)
            end
            return resp
        end
    end
end