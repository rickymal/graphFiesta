Este projeto é um projeto intermediário para a construção de um sistema de computação distribuida para BigData. A documentação será escrita no dercorrer dos dias (caso seja levada adiante).

#
##



## Sobre o objetivo 
Esse projeto é um projeto intermediário para a construção de um sistema de computação distribuida em Ruby IaaS, com foco em gerenciamento de concorrência.

## Sobre os motivos
Quando se trabalha com BigData (c/ ruby), basicamente se trabalha com vários scripts pequenos, isolados que manipulam base de dados, não existe nenhum controle sob. No DataOps você tem que se preocupar com a infra, escala da aplicação (p/ maior carga de trabalho), estabilidade, e confiança quanto ao funcionamento do sistema, DataOps implica em manter uma cultura para operar e orquestrar os dados.

## Resumo do projeto
Nesse projeto em específico, são funções (Grafos, como é chamado) que armazenam algum pedaço de código ou um conjunto desses, que pode ser gerenciado por sua própria task (um processo ou thread separado por ex.), algo bem semelhante ao funcionamento de Atores (em concorrência). A ideia é permitir a construção de pipelines onde a construção de concorrência e paralelismo é gerenciada pela própria lib. Usando essa lib, você tem uma programação declarativa (dizendo como os grafos/pipelines serão construidos, e qual será o fluxo do dado). Eu não tenho intenção de continuar o projeto depois de finalizado devido a complexidade de se criar algo nesse estilo (a não ser que exista alguma viabilidade de mercado e tenha ajuda). Meu foco é treinar a construção de algoritmos de concorrência e aplicações de escala "infinita", e orquestração (manipulação de instancias, etc).

## Exemplo simples de aplicação
- Considere um pipeline que tem por foco realizar o cálculo de equação do segundo grau, cada grafo tem a capacidade
![image](img/pipbasic.png)

A estrutura em código no pipeline acima seguirá da seguinte forma
```ruby
Graph.new(
    UsaRoupa.new(),
    ColocaRoupaCesto.new(),
    SeparaRoupaLavagem.new(),
    Lavar.new(),
    Sescar.new(),
    Separar.new(),
    Guardar.new()
)
```
Cada classe acima é um grafo por definição.

- Considere agora que queremos separar as responsabilidades de cada grafo. Supondo que queremos acelerar a eficiencia do pipeline utilizando, podemos separar em grafos menores, onde cada um é controlado por um sistema separado, permitindo o uso básico de concorrência. Uma nova estrutura pode ser montada da seguinda forma
![image](img/pipe_grouped.png)
```ruby
Graph.new(
    Person.new(
        UsaRoupa.new(),
        ColocaRoupaCesto.new(),
        SeparaRoupaLavagem.new(),
    ),
    Machine.new(
        Lavar.new(),
        Secar.new(),    
    ),
    AnotherPerson.new(
        Separar.new(),
        Guardar.new()
    )
)
```

- Supondo ainda que uma única maquina de lavar não seja suficiente. A Ideia é que facilmente isso possa ser escalado 
![image](img/pipe_switched.png)
```ruby
Graph.new(
    Person.new(
        UsaRoupa.new(),
        ColocaRoupaCesto.new(),
        SeparaRoupaLavagem.new(),
    ),
    Switcher.new(
        Machine.new(
            Lavar.new(),
            Secar.new(),    
        ),
        Machine.new(
            Lavar.new(),
            Secar.new(),    
        ),
        Machine.new(
            Lavar.new(),
            Secar.new(),    
        ),
    ),
    AnotherPerson.new(
        Separar.new(),
        Guardar.new()
    )
)
```

## O que falta fazer
- [ ] permitir com que cada grafo seja executado de forma assíncrona, fazendo com que cada grafo tenha sua propria fila interna.
- [ ] Permitir uma comunicação indireta entre o grafo anterior e posterior, No caso de um 'switcher' por exemplo, não há controle quando um grafo está sobrecarregado ou não. A ideia é que este graafo seja capaz de liberar um grafo interno caso este esteja sobrecarregado, o grafo interno ao switcher deve se capaz de avisar o proprio switcher que está sobrecarregado.
- [ ] Criar Grafos Remotos utilizando o protocolo nativo de comunicação do ruby (drb).
- [ ] Cria grafos com capacidade de acumular resultado para tratamento de dados em lotes.
- [ ] Observar comportamentos caso algum grafo não funcione corretamente (tolerância à falha)
- Fim do projeto