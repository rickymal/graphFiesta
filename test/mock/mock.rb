require "./core/base_graph.rb"

class HelloWorld < Core::BaseGraph

    def run()
        return "Hello world!"
    end
    
end

class P1 < Core::BaseGraph

    def init_graph()
        @counter = 0
    end

    def run(data)
        @counter += 1
        return data + 1
    end

    def describe()
        return {
            counter: @counter,
            var: @var
        }
    end
end

class PCommented < Core::BaseGraph

    def init_graph()
        @counter = 0
        @var = 0
    end

    def run(data)
        puts "O valor de var é #{@var}"
        @counter += 1
        return data + 1
    end

    def describe()
        return {
            counter: @counter,
            var: @var
        }
    end

    def update(data)
        @var = data
    end

end

class P2 < Core::BaseGraph

    def init_graph()
        @counter = 0
    end
    
    def run(data)
        @counter += 1
        return data + 2
    end

    def describe()
        return {
            counter: @counter,
            var: @var
        }
    end

end

class P3 < Core::BaseGraph

    def init_graph()
        @counter = 0
    end
    
    def run(data)
        @counter += 1
        return data + 3
    end

    def describe()
        return {
            counter: @counter,
            var: @var
        }
    end

end

class PRaiseError

    def run(data)
        fail Exception, "Uma simulação de erro"
    end

end

class PFailError

    def run()
        fail Exception, "Uma simulação de erro"
    end

end