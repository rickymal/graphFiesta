require "./core/base_graph.rb"

module Graph
    class Ractor < Core::BaseGraph
        def build_engine(*pipeflows, **kwargs)
            ractor = ::Ractor.new(*pipeflows, **kwargs) do |*pipeflows, **kwargs|
                ::Ractor.yield(0)
                while resp = ::Ractor.receive()
                    ::Ractor.yield (pipeflows.inject(resp) do |val, pipe|
                        pipe.flow(val)
                    end)
                end
            end
    
            if ractor.take() != 0
                raise Exception
            end
    
            return ractor
    
        end
    
        def update(data)
            @pipegraphs.each do |ctx|
                if ctx.respond_to? :update
                    ctx.update(data)
                end
            end
        end
    
        def run(initial_value, *args, **kwargs)      
            @engine.send(initial_value)
            resp = @engine.take()
            return resp
        end
    end
end