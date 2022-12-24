require 'pry'
require 'concurrent'
require 'concurrent-edge'

# asdasd
class BaseRactorTransport < Ractor
    def chsend(data)
        Ractor.yield(data)
    end

    def chtake()
        Ractor.receive()
    end

end

class BaseSingleChannelTransport

    def initialize(*args, **kwargs, &block)
        @ch1 = Concurrent::Channel.new capacity: 1
        @ch2 = Concurrent::Channel.new capacity: 1
        # Concurrent::Promise.execute { instance_eval(&block) }
        
        Concurrent::Promise.execute { instance_exec(*args, **kwargs, &block) } 
    end

    def take()
        
        return @ch1.take()
    end
    
    def send(data)
        Concurrent::Channel.go { @ch2.put data }
    end

    def chsend(data)
        Concurrent::Channel.go { @ch1.put data }
    end
    
    def chtake()
        return @ch2.take()
    end



end

module DefaultApplication
    def pre_init(*args, **kwargs)
        args[0] = args[0].map {|ctx| ctx.new()}
        return args, kwargs
    end


    def init(*args, **kwargs)

    end

    def run(initial_value, pipeinstances)
        return pipeinstances.inject(initial_value) do |response, pipe|
            pipe.flow(response)
        end
    end
end


class DefaultRactorTransport < BaseRactorTransport
    prepend DefaultApplication
end



class DefaultRSingleTransport < BaseSingleChannelTransport
    prepend DefaultApplication
end

module DefaultEngine

    def program()
        return lambda do |*args, **kwargs|
            args, kwargs = self.pre_init(*args, **kwargs)
            response = 0 # shacking and aknowlegment
            loop do  
                self.chsend(response)  
                initial_value = self.chtake()
                args << 
                response = self.run(initial_value, args[0])
            end
        end
    end
end
module DataFlow

    
    class BasePipeGraph
        prepend DefaultEngine
        def initialize(transport_klass, pipeklasses)
            args = [pipeklasses]
            kwargs = {}
            
            # extracted_procedure = self.method(:program).to_proc() # não funciona por causa do contexto
            @worker = transport_klass.new(*args, **kwargs, &program())
            
            if take() != 0 # Iniciando a aplicação.
                fail Exception, "Aplicação não esta funcionando"
            end
            
            @pool = Concurrent::FixedThreadPool.new(10)
            
        end

        def send(initial_value)
            @worker.send(initial_value)
        end
    
        def take()
            @worker.take()
        end 

        def run_pipe(initial_value)
            self.send(initial_value)
            return self.take()
        end

        def run_async_pipe(initial_value)
            ivar = Concurrent::Ivar.new()
            @pool.post do 
                ivar.set run_pipe(initial_value)
            end
            return ivar
        end
    end

end

class PFactor
    def flow(data)
        data + 1
    end
end

P1 = PFactor
P2 = PFactor
P3 = PFactor

pctx = DataFlow::BasePipeGraph.new(
    DefaultRactorTransport,
    [P1, P2, P3]
)
    
resp = pctx.run_pipe(10)
binding.irb

pctx = DataFlow::BasePipeGraph.new(
    DefaultRSingleTransport,
    [P1, P2, P3]
)
    
resp = pctx.run_pipe(10)
binding.irb

