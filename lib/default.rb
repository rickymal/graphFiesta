require "./core/base_graph.rb"


module Graph
    class Default < Core::BaseGraph
        update_method :cascade

        def run(initial_value)
            resp = @pipegraphs.inject(initial_value) do |val, pipe|
                pipe.run(val)
            end
            return resp
        end
    end
end