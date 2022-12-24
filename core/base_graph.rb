module Core
    class BaseGraph
        def initialize(*pipeflows, **kwargs)
            @listeners = [] 
            @pipegraphs = pre_init(pipeflows.empty? ? [HelloWorld] : pipeflows)
            @var = nil
            if self.respond_to? :build_engine
                @engine = build_engine(*pipeflows, **kwargs)            
            end
            if self.respond_to? :init_graph
                self.init_graph()
            end
        end
    
        def pre_init(pipeflows, *args, **kwargs)
            return pipeflows
        end
    
        def self.update_method(type)
            @@update_method = type
        end
    
        def update(data)
            @var = data
            if @@update_method == :cascade
                @pipegraphs.each do |ctx|
                    if ctx.respond_to? :update
                        ctx.update(data)
                    end
                end
            end
        end
    
        def flow(value)
            response = self.run(value)
            @listeners.each do |ctx|
                ctx.on_finish(self, response)
            end
            return response
        end
    
        def name()
            return self.class.name.split("::").last()
        end
    
        def describe()
            return {
                self.name => @pipegraphs.map do |pipegraph|
                    pipegraph.describe()
                end
            }   
        end
        
        def attach(emitter)
            @listeners << emitter
            return self
        end
    end
end