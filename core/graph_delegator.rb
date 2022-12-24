class GraphDelegator < Delegator
    def initialize(*pipeflows, **kwargs)
        @options = pipeflows
        @idx = 0
    end

    def switch()
        if @idx < (@options.size() - 1)
            @idx += 1 
        else
            @idx = 0
        end
    end

    def __getobj__()
        return @options[@idx]
    end

    def __setobj__(obj)
        @options[@idx] = obj
    end

end