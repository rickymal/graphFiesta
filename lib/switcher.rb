require "./core/graph_delegator.rb"
require "./core/base_graph.rb"

module Graph
    class Switcher < Core::BaseGraph

        def build_engine(*pipeflows, **kwargs)
            return GraphDelegator.new *pipeflows, **kwargs
        end
    
        def run(initial_value)
            resp = @engine.flow(initial_value)
            @engine.switch()
            return resp
        end
    end
end