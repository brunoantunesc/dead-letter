# DEAD LETTER
## Mini Game Design Document
**Versão:** 0.1 — Conceito e pré-produção  
**Engine:** Godot  
**Gênero:** Investigação, mistério, point-and-click, roguelite  
**Direção visual:** 3D low-poly, estética PSX  
**Ambientação inicial:** Hotel de luxo no interior de São Paulo, Brasil  
**Estado:** Pré-produção

---

## 1. High Concept

**Dead Letter** é um roguelite de investigação de assassinatos, em que cada partida apresenta um novo caso gerado proceduralmente.

O jogador assume o papel de um investigador em um hotel de luxo, explorando ambientes, examinando objetos, utilizando ferramentas forenses, interrogando personagens e organizando suas descobertas em um quadro de investigação livre.

O objetivo não é simplesmente descobrir quem cometeu o assassinato, mas **construir uma acusação suficientemente fundamentada para sustentar a condenação do culpado**.

O jogo não indica automaticamente quais objetos são pistas, quais evidências são relevantes ou quais hipóteses estão corretas. Cabe ao jogador observar, experimentar, interpretar e conectar informações.

A arquitetura do hotel permanece reconhecível entre partidas, mas o estado dos ambientes, os personagens, suas relações, os acontecimentos e o crime são gerados proceduralmente.

### Fantasia central do jogador

**Ser um investigador de verdade: encontrar evidências por conta própria, interpretar um mundo cheio de informações ambíguas e conseguir provar o que aconteceu.**

---

## 2. Pilares de Design

### 2.1. Investigação sem condução artificial

O jogo deve confiar na capacidade de observação e dedução do jogador.

- Não destacar automaticamente evidências importantes.
- Não apresentar checklists de pistas obrigatórias.
- Não indicar quando uma sala foi completamente investigada.
- Não confirmar durante a investigação se uma hipótese está correta.
- Não exigir uma sequência fixa de descobertas.

O jogador pode deixar passar informações importantes e chegar a conclusões equivocadas.

### 2.2. Verdade causal

Cada caso deve possuir uma verdade interna consistente.

Objetos, marcas, documentos, depoimentos e outros vestígios precisam existir como consequência de acontecimentos simulados.

O sistema não deve simplesmente espalhar pistas aleatórias e depois inventar uma explicação para elas.

**Primeiro os acontecimentos; depois suas consequências observáveis.**

### 2.3. Evidências físicas e ferramentas

A investigação deve depender da observação de objetos e ambientes.

O jogador poderá examinar elementos do cenário e utilizar ferramentas para descobrir informações que não seriam perceptíveis imediatamente.

As ferramentas não funcionam como botões automáticos de encontrar pistas. Elas revelam propriedades concretas dos objetos, inclusive quando o resultado não possui relevância para o caso.

### 2.4. Informação ambígua e pistas falsas justificadas

Nem toda informação suspeita está relacionada ao assassinato.

O hotel possui acontecimentos paralelos, conflitos, acidentes e segredos que podem gerar evidências aparentemente incriminadoras.

Essas informações devem ter explicações próprias dentro da simulação.

**O jogo pode induzir interpretações equivocadas, mas não deve depender de inconsistências arbitrárias para enganar o jogador.**

### 2.5. Conhecimento como principal habilidade

O progresso de uma investigação depende da capacidade do jogador de:

- Observar detalhes.
- Investigar possibilidades.
- Utilizar ferramentas adequadamente.
- Relacionar informações.
- Reconhecer contradições.
- Revisar hipóteses.
- Construir argumentos.

A inspiração principal é a descoberta orientada pelo conhecimento, como em *Outer Wilds*, e a atenção aos detalhes e relações ambientais de *Blue Prince*.

### 2.6. Rejogabilidade sistêmica

Cada partida deve oferecer um novo problema investigativo, e não apenas reorganizar respostas de casos previamente escritos.

O sistema procedural deve permitir diferentes combinações de personagens, relações, crimes, evidências e acontecimentos paralelos.

---

## 3. Ambientação e Identidade

### 3.1. Local

O primeiro cenário do jogo é um hotel de alto padrão localizado no interior de São Paulo.

A ambientação combina luxo, tradição, isolamento e decadência.

O hotel deve transmitir respeitabilidade e sofisticação, mas também sugerir tensões sociais, segredos, conflitos de interesse e relações de poder.

Sua identidade deve ser reconhecivelmente brasileira, evitando depender exclusivamente de referências genéricas de hotéis europeus ou mansões góticas.

### 3.2. Período histórico

O jogo ocorre em um mundo semelhante ao nosso, mas com um período histórico propositalmente indefinido.

Elementos de diferentes décadas coexistem sem que o cenário estabeleça uma data inequívoca.

A ambiguidade temporal reflete a própria desorientação do protagonista.

### 3.3. Tecnologia

A tecnologia mistura características analógicas, mecânicas e retrofuturistas, com influência sutil de steampunk.

Equipamentos podem ser sofisticados em suas capacidades, mas devem possuir interfaces materiais e tangíveis.

Exemplos de linguagem visual:

- Máquinas eletromecânicas.
- Arquivos e registros físicos.
- Gravadores e dispositivos analógicos.
- Painéis de controle com botões e mostradores.
- Ferramentas forenses com mecanismos próprios.
- Equipamentos avançados sem aparência digital contemporânea.

A tecnologia deve contribuir para a investigação, sem tornar a descoberta de evidências automática.

### 3.4. Tom

A atmosfera deve ser:

- Melancólica.
- Elegante.
- Estranha.
- Introspectiva.
- Ocasionalmente desconfortável.
- Marcada por contradições sociais.

*Disco Elysium* é uma referência de densidade atmosférica, subjetividade e construção de mundo, não necessariamente de estrutura de diálogos ou sistemas de RPG.

### 3.5. Direção audiovisual

A direção visual utiliza estética PSX:

- Modelos 3D low-poly.
- Texturas de baixa resolução.
- Ambientes com forte identidade arquitetônica.
- Iluminação atmosférica.
- Interfaces que remetam a documentos, arquivos e instrumentos físicos.

A estética retrô deve reforçar a identidade do jogo, sem comprometer a legibilidade de pistas importantes.

---

## 4. Estrutura de uma Partida

Cada run representa uma investigação independente.

### Etapa 1 — Geração do estado do mundo

O jogo define:

- Condições de funcionamento dos ambientes.
- Áreas temporariamente inacessíveis.
- Hóspedes e funcionários.
- Relações pessoais e profissionais.
- Rotinas e acontecimentos paralelos.
- Circunstâncias que poderão influenciar o crime.

### Etapa 2 — Geração do assassinato

O sistema estabelece:

- Vítima.
- Assassino.
- Motivação.
- Método.
- Local.
- Cronologia.
- Ações realizadas.
- Consequências físicas e documentais.

### Etapa 3 — Investigação livre

O jogador explora o cenário no próprio ritmo.

Não há limite obrigatório de ações ou tempo para concluir o caso.

Ele pode investigar ambientes, interrogar pessoas, analisar objetos, consultar documentos e registrar descobertas no quadro.

### Etapa 4 — Construção da acusação

Quando julgar possuir informações suficientes, o jogador submete seu relatório final.

A acusação deve incluir:

- Pessoa acusada.
- Motivação alegada.
- Método do assassinato.
- Evidências selecionadas para sustentar a conclusão.

### Etapa 5 — Veredito

O jogo avalia a precisão da acusação e a força das provas apresentadas.

A run termina com um dos resultados definidos na seção 8.

---

## 5. Hotel e Variação Procedural

### 5.1. Arquitetura persistente

A disposição estrutural do hotel permanece fixa entre partidas.

Quartos, corredores, escadarias, instalações e áreas comuns mantêm suas posições.

O jogador pode aprender a geografia do hotel ao longo de várias investigações.

### 5.2. Estado variável

A cada partida, o hotel pode apresentar condições diferentes.

Exemplos:

- Um andar inteiro fechado.
- Piscina disponível ou interditada.
- Cozinha em reforma.
- Quartos temporariamente indisponíveis.
- Ambientes reservados para eventos.
- Áreas de serviço com funcionamento alterado.

Essas mudanças devem possuir consequências coerentes sobre circulação, rotinas e acontecimentos.

Uma cozinha em reforma, por exemplo, pode modificar a distribuição dos funcionários, a disponibilidade de utensílios e os serviços prestados aos hóspedes.

### 5.3. Acessibilidade e investigação

Áreas inacessíveis podem afetar o caso, mas o sistema precisa garantir que existam meios viáveis de obter evidências suficientes para solucioná-lo.

Isso não significa que todas as pistas serão acessíveis em todas as partidas ou que o jogador necessariamente as encontrará.

### 5.4. Expansibilidade

A estrutura procedural de casos, personagens e evidências não deve depender especificamente de hotéis.

O hotel é o primeiro cenário, mas a arquitetura deve permitir futuros ambientes investigativos.

---

## 6. Personagens e Relações

Hóspedes, funcionários, vínculos pessoais, interesses e conflitos são gerados proceduralmente.

Cada personagem poderá possuir:

- Identidade.
- Papel social ou profissional.
- Relações com outros personagens.
- Rotinas.
- Informações conhecidas.
- Interesses e objetivos.
- Possíveis motivos para mentir.
- Participação em acontecimentos paralelos.
- Relação com o assassinato, quando aplicável.

Um personagem pode mentir sem ser o assassino.

Por exemplo, alguém pode esconder um relacionamento extraconjugal e oferecer um álibi falso, mesmo sem qualquer envolvimento no crime.

O sistema deve distinguir **comportamento suspeito** de **culpa efetiva**.

---

## 7. Sistema de Evidências

### 7.1. Evidências como elementos do mundo

As pistas devem estar incorporadas ao ambiente.

Podem assumir a forma de:

- Objetos físicos.
- Vestígios.
- Documentos.
- Registros.
- Depoimentos.
- Marcas ambientais.
- Inconsistências observáveis.

O jogador não recebe automaticamente uma classificação de relevância ao encontrá-las.

### 7.2. Categorias conceituais

**Evidências reais:** informações que sustentam fatos relacionados ao assassinato.

**Evidências contextuais:** informações necessárias para interpretar corretamente outras descobertas.

**Pistas falsas causais:** elementos aparentemente incriminadores, mas originados de acontecimentos não relacionados ao crime.

**Informações ambíguas:** fatos que admitem interpretações diferentes até serem contextualizados.

### 7.3. Exemplo de pista falsa

O jogador encontra uma faca com sangue na cozinha.

Inicialmente, pode considerá-la a arma do assassinato.

Posteriormente, encontra um memorando registrando que um funcionário se cortou com uma faca durante o trabalho naquela manhã e recebeu atendimento.

Outras informações podem corroborar o acidente.

A faca continua existindo como objeto físico verdadeiro, mas sua interpretação inicial pode estar errada.

**A pista falsa não foi criada apenas para confundir: ela pertence a uma cadeia causal independente.**

### 7.4. Ferramentas investigativas

O jogo deverá oferecer ferramentas capazes de revelar propriedades específicas dos objetos.

Possibilidades para exploração de design:

- Lupa.
- Lanterna especializada.
- Kit de impressões digitais.
- Câmera fotográfica.
- Coleta e comparação de amostras.
- Instrumentos analógicos de análise.

A seleção definitiva das ferramentas e seus níveis de complexidade permanece em aberto.

### 7.5. Força probatória

Cada evidência relevante possui uma força probatória interna.

Diferentes evidências podem contribuir com pesos diferentes para sustentar uma acusação.

Uma prova especialmente forte pode valer mais do que várias informações circunstanciais.

Essa pontuação **não deve ser exibida ao jogador durante a investigação**.

O sistema deve considerar a relação da evidência com a hipótese apresentada e evitar pontuação duplicada para múltiplos registros do mesmo fato.

---

## 8. Sistema de Acusação e Resultados

O jogador decide quando encerrar a investigação.

A submissão é definitiva para aquela run.

O relatório apresenta a hipótese do jogador e as evidências que ele escolheu utilizar para sustentá-la.

### 8.1. Acusação incorreta

O jogador identifica a pessoa errada.

**Resultado:** investigação fracassada.

### 8.2. Culpado correto, caso insuficiente

O jogador identifica o verdadeiro assassino, mas sua investigação não sustenta a acusação adequadamente.

Possíveis razões:

- Motivação incorreta ou não demonstrada.
- Método do crime incorreto.
- Evidências insuficientes.
- Evidências incompatíveis com a hipótese.
- Pontuação probatória abaixo do mínimo necessário.

**Resultado:** investigação fracassada, com reconhecimento de que o suspeito correto foi identificado, mas sem provas suficientes para condenação.

### 8.3. Caso solucionado

O jogador identifica corretamente o assassino, apresenta uma explicação válida para motivação e método e reúne evidências suficientes.

**Resultado:** vitória, com condenação do culpado dentro da narrativa do jogo.

### 8.4. Pontuação invisível

A avaliação utiliza uma pontuação ponderada por evidências.

O jogador não precisa encontrar todas as pistas do caso, apenas reunir evidências suficientemente fortes para atingir o limiar exigido.

A interface deve transmitir a necessidade de fundamentar uma acusação, sem revelar o cálculo interno ou transformar a investigação em uma barra de progresso.

---

## 9. Geração Procedural dos Casos

O gerador deve produzir investigações consistentes e solucionáveis.

### 9.1. Ordem de geração

1. Definir o estado do cenário.
2. Gerar personagens e relações.
3. Gerar acontecimentos paralelos.
4. Estabelecer o crime e sua cronologia.
5. Produzir consequências observáveis.
6. Distribuir evidências e informações contextuais.
7. Validar a consistência e a acessibilidade da investigação.

### 9.2. Fatos e consequências

O crime deve ser modelado como uma sequência de acontecimentos.

A partir dessa sequência, o sistema produz objetos, marcas, depoimentos, registros e outros elementos compatíveis.

As consequências precisam respeitar o estado do cenário e as ações dos personagens.

### 9.3. Acontecimentos paralelos

O mundo não existe exclusivamente para sustentar o assassinato.

O gerador também produz eventos independentes, como:

- Acidentes de trabalho.
- Conflitos pessoais.
- Problemas de manutenção.
- Relações secretas.
- Objetos perdidos.
- Incidentes administrativos.

Esses acontecimentos podem gerar pistas falsas e explicações alternativas.

### 9.4. Validação automática

Antes de liberar um caso, o sistema deve verificar:

- Consistência da cronologia.
- Compatibilidade entre ações e locais.
- Coerência dos depoimentos com o conhecimento dos personagens.
- Existência de evidências suficientes.
- Possibilidade de alcançar a pontuação mínima de condenação.
- Ausência de dependência obrigatória de áreas inacessíveis.
- Compatibilidade entre método do crime e vestígios.
- Ausência de contradições causais não intencionais.

Sempre que possível, devem existir múltiplas combinações de evidências capazes de sustentar uma acusação válida.

A validação garante que **o caso pode ser resolvido**, não que será fácil ou que o jogador encontrará a solução.

---

## 10. Quadro de Investigação

O quadro é o principal espaço de organização das descobertas.

Deve permitir ao jogador construir sua própria interpretação do caso.

Funcionalidades desejadas:

- Criar anotações livres.
- Registrar hipóteses.
- Adicionar fotografias.
- Anexar documentos e descobertas.
- Organizar informações espacialmente.
- Conectar elementos.
- Revisar ou descartar hipóteses.

O sistema não deve confirmar automaticamente se uma conexão feita pelo jogador está correta.

O quadro representa **o conhecimento e as suposições do jogador**, não a verdade interna da simulação.

A interface deve ser flexível o suficiente para permitir investigações desorganizadas, hipóteses equivocadas e interpretações pessoais.

---

## 11. Exploração e Interface

O jogo utiliza interação point-and-click em ambientes tridimensionais.

A exploração deve privilegiar:

- Observação.
- Inspeção de objetos.
- Manipulação contextual.
- Uso de ferramentas.
- Leitura de documentos.
- Conversas e interrogatórios.
- Navegação entre ambientes.

Não há necessidade de mecânicas de combate ou controles complexos de movimentação.

A interface deve permitir investigação livre sem excesso de marcadores, notificações ou orientação automática.

A estética visual deve preservar a legibilidade de pequenos detalhes importantes para a investigação.

---

## 12. Direção Técnica

### Engine

Godot, com ambientes 3D de estética PSX.

### Princípios arquiteturais

Separar claramente:

**Simulação do mundo:** personagens, relações, horários e acontecimentos.

**Verdade do caso:** fatos reais sobre o assassinato.

**Representação ambiental:** salas, objetos, documentos e vestígios.

**Conhecimento do jogador:** descobertas efetivamente realizadas.

**Quadro de investigação:** anotações e interpretações organizadas pelo jogador.

**Avaliador de acusação:** validação de autoria, explicação e suficiência probatória.

Esses sistemas não devem depender de conhecer previamente um caso específico.

A geração procedural precisa ser reproduzível por seed para facilitar testes e depuração.

### Uso de agentes de IA

Agentes podem auxiliar na implementação, testes e evolução das ferramentas de geração procedural.

As decisões de design, a aprovação de funcionalidades e a validação da experiência permanecem sob direção humana.

O uso de IA no desenvolvimento não implica necessariamente dependência de LLMs durante a execução do jogo. A implementação inicial deve priorizar sistemas determinísticos e verificáveis.

---

## 13. Escopo do Primeiro Protótipo

O primeiro protótipo deve demonstrar que a investigação procedural funciona antes de expandir o conteúdo.

### Escopo sugerido

- Um pequeno conjunto de ambientes do hotel.
- Um crime gerado proceduralmente.
- Quatro suspeitos.
- Um conjunto limitado de motivos e métodos.
- Evidências físicas.
- Um ou dois acontecimentos paralelos.
- Pelo menos uma pista falsa com explicação verificável.
- Ferramentas básicas de inspeção.
- Quadro de investigação funcional.
- Submissão de relatório.
- Três possíveis resultados.
- Validação automática da solução.

### Critério principal de sucesso

**O jogador consegue resolver dois ou mais casos diferentes usando observação, ferramentas e dedução, sem que o jogo indique quais são as pistas corretas.**

O protótipo não precisa ter grande variedade visual, muitos ambientes ou uma narrativa extensa.

Seu objetivo é comprovar a qualidade do sistema investigativo.

---

## 14. Questões Ainda em Aberto

As seguintes decisões deverão ser definidas ao longo da pré-produção:

- Identidade e história do protagonista.
- Justificativa narrativa para investigações repetidas.
- Sistema de progressão roguelite entre runs.
- Existência e comportamento de personagens durante a investigação.
- Profundidade dos interrogatórios.
- Complexidade das análises forenses.
- Forma exata de navegação point-and-click.
- Tipos de documentos e manipulação de objetos.
- Feedback oferecido após acusações incorretas.
- Limiares e pesos de pontuação probatória.
- Tamanho e complexidade dos casos.
- Possíveis ambientes futuros além do hotel.

Essas decisões não devem ser presumidas durante a implementação.

---

## 15. Declaração de Visão

**Dead Letter é um jogo sobre a diferença entre suspeitar, saber e provar.**

O jogador investiga um mundo que não foi construído exclusivamente para ajudá-lo. Objetos existem por razões próprias, pessoas escondem segredos que nem sempre têm relação com o crime e informações aparentemente decisivas podem adquirir outro significado quando contextualizadas.

O sistema procedural deve produzir mistérios que possam ser resolvidos por raciocínio, não por tentativa e erro ou memorização de soluções.

A experiência ideal é aquela em que o jogador encontra duas informações aparentemente desconexas, percebe sozinho a relação entre elas e entende algo que o jogo nunca lhe explicou diretamente.