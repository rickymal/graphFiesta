def benchmark(&block)
    puts "Executando benchmarking..."
    exec_times = []
    1000.times do
        before = Time.now()
        block.call()
        after = Time.now()
        exec_times << after - before
    end
    return exec_times.inject(0, :+) / exec_times.size()
end

def afunc()
    p1, p2, p3 = P1.new(), P2.new(), P3.new()
    bf = Time.now()
    ([p1, p2, p3] * 10000).inject(10) do |val, pipe|
        pipe.flow(val)
    end
    af = Time.now()

    af - bf
end

def bfunc()
    p1, p2, p3 = P1.new(), P2.new(), P3.new()
    ctx = Graph::Default.new(*([p1, p2, p3] * 10000)).attach(Fallback.new())
    bf = Time.now()
    ctx.flow(10)
    af = Time.now()

    af - bf
end