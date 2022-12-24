require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'pry-stack_explorer'
require './test/mock/mock.rb'
require "./core/utils.rb"
require "./lib/switcher.rb"
require "./lib/remote_sender.rb"
require "./lib/ractor.rb"
require "./lib/default.rb"
Minitest::Reporters.use!


class Fallback
    def on_finish(graph, response)
        @last_response = response
    end

    def get_last_response()
        @last_response
    end
end

describe "Testes" do
    emitter = Fallback.new()
    it "Montagem de um simple grafo com os pipes P1, P2 e P3" do
        # 0. Permitir a entrada de código 
        ctx = Graph::Default.new(P1.new(), P2.new(), P3.new())
        resp = ctx.flow(10)
        assert true
    end

    it "Cria grafos aninhados" do
        ctx = Graph::Default.new(
            Graph::Default.new(P1.new(), P2.new(), P3.new()),
            Graph::Default.new(P1.new(), P2.new(), P3.new()),
            Graph::Default.new(P1.new(), P2.new(), P3.new()),
        )
        resp = ctx.flow(10)
        assert true
    end

    it "obtem resultado de execução de pipeline por meio de event_listener (para futuras implementações)" do
        # inserindo um resultado
        ctx = Graph::Default.new(P1.new(), P2.new(), P3.new()).attach(emitter)
        resp = ctx.flow(10)
        resp = emitter.get_last_response()
        assert_equal resp, 10
    end
    
    it "Avaliando comportamento sob alta concorrência em grafos aninhados" do
        ctx = Graph::Default.new(
            Graph::Default.new(P1.new(), P2.new(), P3.new()),
            Graph::Switcher.new(
                Graph::Default.new(P1.new(), P2.new()),
                Graph::Switcher.new(
                    Graph::Default.new(P1.new(), P2.new()),
                    Graph::Default.new(P2.new(), P3.new()),
                ),
            ),
            Graph::Default.new(P1.new(), P2.new(), P3.new()),
        )

        pool = Concurrent::FixedThreadPool.new(20)
        10.times do
            pool.post { ctx.flow(10) }
        end
        d1 = ctx.describe()

        ctx = Graph::Default.new(
            Graph::Default.new(P1.new(), P2.new(), P3.new()),
            Graph::Switcher.new(
                Graph::Default.new(P1.new(), P2.new()),
                Graph::Switcher.new(
                    Graph::Default.new(P1.new(), P2.new()),
                    Graph::Default.new(P2.new(), P3.new()),
                ),
            ),
            Graph::Default.new(P1.new(), P2.new(), P3.new()),
        )


        10.times do
            ctx.flow(10)
        end
        d2 = ctx.describe()

        assert_equal d2, d1, "resultado divergênte sob alta concorrência!"
    end

    it "metodo 'flow' para a execução da aplicação por erro de execução do código" do
        # Permitir um disparo de erro
        ctx = Graph::Default.new(P1.new(), PRaiseError.new(), P3.new()).attach(emitter)

        begin
            ctx.flow(10)
        rescue Exception => exception
            if exception.message == "Uma simulação de erro"
                assert true
            else
                assert false
            end
        end
    end

    it "O uso dos grafos deve apresentar um bom desempenho" do
        vanila_exec_time = benchmark() do
            p1, p2, p3 = P1.new(), P2.new(), P3.new()
            ([p1, p2, p3] * 10000).inject(10) do |val, pipe|
                pipe.run(val)
            end
        end
        
        graph_framework_exec_time = benchmark() do
            p1, p2, p3 = P1.new(), P2.new(), P3.new()
            ctx = Graph::Default.new(*([p1, p2, p3] * 10000))
            ctx.attach(Fallback.new())
            ctx.attach(Fallback.new())
            ctx.attach(Fallback.new())
            ctx.attach(Fallback.new())
            ctx.attach(Fallback.new())
            ctx.flow(10)
        end

        exec_diff = graph_framework_exec_time - vanila_exec_time
        if exec_diff < 0.003
            assert true
        else
            assert false
        end
    end

    it "Obtem descrição correta da estrutura criada" do
        ctx = Graph::Switcher.new(
            Graph::Default.new(P1.new(), P2.new()),
            Graph::Default.new(P2.new(), P3.new()),
        )
        descr = ctx.describe()

        assert_equal descr, {
            "Switcher" => [{
                "Default" => [{
                    :counter => 0,
                    :var => nil
                }, {
                    :counter => 0,
                    :var => nil
                }]
                },
                {
                "Default" => [{
                    :counter => 0,
                    :var => nil
                }, {
                    :counter => 0,
                    :var => nil
                }]
                }
            ]
        }
    end

    it "Realiza o update de dados do grafo" do 
        ctx = Graph::Switcher.new(
            Graph::Ractor.new(P1.new(), P2.new()),
            Graph::Default.new(PCommented.new(), P3.new()),
        )

        ctx.flow(10)
        ctx.flow(10)
        ctx.flow(10)
        ctx.flow(10)
        ctx.flow(10)
        ctx.update(100)
        ctx.flow(10)
        ctx.flow(10)

        descr = ctx.describe()
        assert_equal descr, {
            "Switcher" => [{
                "Ractor" => [{
                  :counter => 0,
                  :var => 100
                }, {
                  :counter => 0,
                  :var => 100
                }]
              },
              {
                "Default" => [{
                  :counter => 3,
                  :var => 100
                }, {
                  :counter => 3,
                  :var => 100
                }]
              }
            ]
        }

    end
end


# describe "Testes seguintes" do
#     it "Capaz de acessar o grafo remoto em localhost:3030" {}
#     it "Capaz de gerar testes atravez de grafos/pipes especiais" {}
#     it "Capaz de enviar status dos grafos para outra maquina" {}
#     it "Ligar e desligar processos por meio de rotinas" {}
#     it "Auto-gerenciamento de threads de acordo com carga de trabalho" {}
#     it "Criar grafos que separem seus resultados em diferentes grafos e os junte posteriormente" {}
#     it "Fim" {}
# end

