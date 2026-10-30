# AGENTS.md — Dead Letter

## 1. Propósito

Este documento estabelece as diretrizes de trabalho dos agentes de IA responsáveis pelo desenvolvimento de **Dead Letter**.

Dead Letter é um roguelite de investigação de assassinatos, desenvolvido em Godot, com exploração point-and-click, estética PSX e casos gerados proceduralmente.

O projeto prioriza:

- Coerência lógica e causal dos acontecimentos.
- Liberdade de investigação e interpretação.
- Evidências físicas e interações significativas.
- Geração procedural reproduzível e validável.
- Fidelidade à identidade narrativa e visual do jogo.
- Código modular, testável e sustentável.
- Documentação consistente com a implementação.

**A responsabilidade do agente não é apenas entregar código funcional, mas implementar corretamente a intenção de design do projeto.**

---

## 2. Hierarquia das fontes de verdade

Antes de implementar funcionalidades, consultar a documentação relevante.

Ordem de referência:

1. **GDD e decisões de design aprovadas pelo responsável pelo projeto.**
2. Especificação e critérios de aceite da issue em andamento.
3. Documentação técnica e registros de decisões arquiteturais.
4. Arquitetura e contratos existentes no código.
5. Este `AGENTS.md`, para convenções gerais de trabalho.

Caso exista conflito entre essas fontes, não escolher arbitrariamente uma interpretação.

Informar o conflito, indicar os documentos ou componentes afetados e solicitar esclarecimento.

O GDD define **o que o jogo deve ser**. A arquitetura e o código definem **como esse objetivo é implementado**.

Uma implementação existente não deve ser considerada automaticamente correta apenas porque já está no repositório.

---

## 3. Respeito ao GDD

O GDD deve ser consultado sempre que uma tarefa envolver:

- Mecânicas de investigação.
- Geração procedural.
- Sistema de evidências.
- Comportamento de personagens.
- Acusação e resultados.
- Progressão roguelite.
- Exploração e interação.
- Interface e experiência do jogador.
- Narrativa e ambientação.
- Direção artística ou audiovisual.

Não introduzir novas mecânicas, automatismos ou mudanças de experiência que contrariem os pilares do projeto.

Em particular:

- Não transformar a investigação em um checklist de objetivos.
- Não destacar automaticamente quais evidências são relevantes.
- Não revelar a pontuação probatória durante a investigação.
- Não confirmar hipóteses do jogador antes do veredito.
- Não exigir uma única sequência de descobertas para resolver um caso.
- Não confundir suspeita, verdade factual e prova suficiente.
- Não fazer o quadro investigativo resolver conexões automaticamente.
- Não introduzir limites de tempo ou ações sem aprovação explícita.
- Não substituir a interpretação do jogador por deduções automáticas da interface.

**Soluções que simplifiquem o desenvolvimento às custas da proposta central do jogo não devem ser adotadas sem aprovação.**

---

## 4. Ambiguidades e dúvidas

Os agentes devem demonstrar iniciativa técnica, mas não presumir decisões criativas importantes.

### Solicitar esclarecimento quando:

- Uma tarefa permitir interpretações que produzam experiências de jogo diferentes.
- O GDD não definir o comportamento necessário.
- Uma mudança alterar regras de vitória, derrota ou progressão.
- Houver conflito entre uma implementação solicitada e mecânicas existentes.
- For necessário alterar a identidade de um personagem, ambiente ou sistema.
- Uma decisão afetar significativamente balanceamento, dificuldade ou liberdade do jogador.
- A implementação exigir mudar um requisito previamente aprovado.
- A solução introduzir dependências externas, custos recorrentes ou riscos de propriedade intelectual não previstos.

### Resolver autonomamente quando:

- A decisão for puramente técnica, localizada e reversível.
- Existir uma convenção consolidada no repositório.
- A solução não alterar comportamento ou experiência do jogador.
- A escolha estiver coberta pelos critérios de aceite da tarefa.

Quando houver dúvida relevante:

1. Identificar exatamente a ambiguidade.
2. Explicar brevemente o impacto das alternativas.
3. Apresentar uma recomendação, quando possível.
4. Solicitar a decisão antes de implementar a parte ambígua.

**Não inventar uma decisão de game design para concluir uma tarefa.**

Entretanto, não interromper o trabalho com perguntas sobre detalhes técnicos triviais que possam ser resolvidos de maneira segura.

---

## 5. Responsabilidades sobre a documentação

A documentação faz parte da entrega, não é uma atividade opcional.

Sempre verificar se a tarefa exige atualizar:

- GDD.
- Documentação de arquitetura.
- Especificações de sistemas.
- Modelos de dados.
- Contratos e interfaces.
- Instruções de desenvolvimento.
- Testes e seus cenários.
- Limitações conhecidas.

### Atualizações que podem ser feitas autonomamente

Os agentes podem atualizar documentação técnica para refletir comportamentos efetivamente implementados e aprovados.

Exemplos:

- Nova interface entre componentes.
- Estrutura de dados alterada.
- Novo formato de serialização.
- Procedimento de teste atualizado.
- Comportamento técnico consolidado.

### Alterações que exigem aprovação

Não modificar silenciosamente o GDD para justificar uma implementação.

Mudanças em mecânicas, visão do jogo, narrativa, regras de investigação ou critérios de vitória exigem autorização do responsável pelo projeto.

Caso seja identificada uma melhoria de design, apresentar a proposta separadamente.

**O código deve seguir o design aprovado; não se deve reescrever o design para fazê-lo concordar com o código.**

### Ao concluir uma tarefa

Informar:

- O que foi implementado.
- Quais comportamentos foram alterados.
- Quais testes foram realizados.
- Quais documentos foram atualizados.
- Quais limitações permanecem.
- Quais decisões precisam de aprovação.

Não declarar uma funcionalidade como concluída se critérios de aceite relevantes ainda não foram verificados.

---

## 6. Arquitetura e separação de responsabilidades

Priorizar sistemas reutilizáveis, com responsabilidades claras e baixo acoplamento.

A arquitetura deve separar conceitualmente:

- Simulação do mundo.
- Geração procedural.
- Verdade factual dos casos.
- Personagens, relações e acontecimentos.
- Evidências e propriedades observáveis.
- Conhecimento efetivamente adquirido pelo jogador.
- Quadro de investigação.
- Avaliação da acusação.
- Apresentação visual e interação no Godot.

Evitar que cenas, HUDs ou objetos visuais contenham diretamente regras centrais de geração e validação dos casos.

A lógica investigativa deve ser testável sem depender do carregamento de todo o mundo 3D.

Preferir soluções orientadas por dados quando permitirem composição, validação e extensão mais simples.

Não introduzir abstrações genéricas sem necessidade concreta, nem duplicar funcionalidades já existentes.

Antes de implementar novos sistemas, investigar componentes reutilizáveis no repositório.

---

## 7. Geração procedural e integridade dos casos

**A consistência da investigação é um requisito fundamental.**

O gerador deve produzir uma verdade interna definida e consequências compatíveis com ela.

Regras:

- Acontecimentos devem possuir causas identificáveis.
- Pistas falsas devem possuir explicações consistentes.
- Personagens não podem saber informações que não teriam como descobrir.
- Cronologias e deslocamentos não podem apresentar contradições acidentais.
- Os estados dos ambientes devem influenciar a disponibilidade de locais e acontecimentos.
- O culpado, a motivação e o método devem ser compatíveis com os acontecimentos gerados.
- Evidências devem possuir origem e relações causais rastreáveis.
- Não posicionar provas obrigatórias em locais impossíveis de investigar.
- Casos devem possuir evidências suficientes para uma acusação válida.
- O jogador não precisa necessariamente descobrir essas evidências.
- Diferentes combinações de provas devem poder sustentar a solução, quando apropriado.

A geração deve utilizar seeds reproduzíveis.

Sempre que um caso inválido for identificado, preservar a seed e os dados necessários para reproduzir o problema.

Casos inválidos devem ser rejeitados ou corrigidos de maneira verificável, e não simplesmente aceitos porque parecem plausíveis.

---

## 8. Evidências e pontuação probatória

A força probatória das evidências é uma propriedade interna do sistema.

- Evidências podem possuir pesos distintos.
- Evidências devem sustentar afirmações específicas da acusação.
- Evidências verdadeiras não são necessariamente relevantes para o assassinato.
- Informações repetidas não devem ser contadas como provas independentes sem justificativa.
- A suficiência probatória deve ser avaliada no contexto da acusação.
- A pontuação não deve ficar visível ao jogador durante a investigação.

Preservar a distinção entre:

1. O que realmente aconteceu.
2. O que existe no mundo como consequência.
3. O que o jogador descobriu.
4. O que o jogador acredita.
5. O que o jogador consegue demonstrar.

Essas dimensões não devem ser unificadas em um único estado de conhecimento.

---

## 9. Interface e experiência do jogador

A interface deve respeitar a liberdade investigativa.

O jogador pode:

- Ignorar objetos importantes.
- Examinar elementos irrelevantes.
- Interpretar uma pista incorretamente.
- Registrar hipóteses falsas.
- Deixar de encontrar evidências.
- Encerrar a investigação com informações insuficientes.

Essas possibilidades fazem parte do design, não são necessariamente problemas a corrigir.

O quadro de investigação deve permitir organização e anotações livres, sem validar automaticamente as conclusões.

Os sistemas visuais podem oferecer feedback sobre ações realizadas, mas não devem revelar informações ocultas sobre a solução.

A estética PSX não deve comprometer a capacidade de perceber e inspecionar detalhes investigativos necessários.

---

## 10. Ambientação e direção artística

A ambientação inicial é um hotel de luxo no interior de São Paulo.

O mundo deve parecer reconhecível, porém deslocado no tempo, combinando tecnologias analógicas avançadas, elementos eletromecânicos e influências retrofuturistas.

Manter:

- Ambiguidade temporal intencional.
- Identidade cultural brasileira.
- Atmosfera de luxo, isolamento e decadência.
- Materialidade dos objetos e equipamentos.
- Coerência visual interna.
- Elementos sociais e humanos que sustentem a narrativa.

Não interpretar a ambiguidade histórica como ausência de regras de mundo.

A estética pode ser estranha, mas a investigação precisa continuar logicamente consistente.

Não adicionar assets externos ou substituir assets existentes sem verificar compatibilidade, origem e permissões de uso.

---

## 11. Desenvolvimento em Godot

Utilizar os recursos e padrões existentes no projeto sempre que adequados.

Diretrizes:

- Manter cenas e scripts com responsabilidades bem definidas.
- Evitar dependências circulares e acoplamento desnecessário.
- Não concentrar lógica central em scripts de interface.
- Priorizar componentes reutilizáveis para objetos interativos.
- Evitar lógica específica de um único caso dentro de componentes genéricos.
- Manter compatibilidade com a versão de Godot utilizada pelo repositório.
- Considerar desempenho, manutenção e facilidade de depuração.
- Preservar a separação entre dados procedurais e sua representação visual.

Alterações que envolvam cenas, materiais, colisões ou renderização devem ser validadas também no ambiente do jogo, não apenas pela ausência de erros de execução.

---

## 12. Testes e qualidade

A implementação deve incluir validação proporcional ao risco da alteração.

Dar prioridade especial a testes de:

- Reprodutibilidade por seed.
- Consistência causal.
- Cronologia de acontecimentos.
- Relações entre suspeitos.
- Geração de pistas verdadeiras e falsas.
- Explicações de eventos paralelos.
- Suficiência probatória.
- Resultados de acusações.
- Persistência e recuperação de dados.
- Interação entre objetos e ferramentas.
- Regressões em sistemas existentes.

Para geradores procedurais, executar conjuntos de seeds diferentes e registrar falhas reproduzíveis.

Testes automatizados são necessários, mas não substituem revisão humana de gameplay e qualidade visual.

Não alterar ou enfraquecer testes apenas para fazer uma implementação ser aprovada.

Não afirmar que testes passaram se não foram executados.

---

## 13. Fluxo de trabalho

Antes de implementar:

1. Ler a issue e seus critérios de aceite.
2. Consultar as partes relevantes do GDD.
3. Inspecionar a arquitetura existente.
4. Identificar componentes afetados.
5. Esclarecer ambiguidades relevantes.
6. Definir uma abordagem compatível com o projeto.

Durante a implementação:

1. Manter o escopo da tarefa.
2. Reaproveitar componentes existentes.
3. Evitar refatorações não relacionadas.
4. Preservar contratos e comportamentos existentes.
5. Implementar validações e testes pertinentes.
6. Registrar decisões técnicas importantes.

Ao finalizar:

1. Verificar os critérios de aceite.
2. Executar os testes disponíveis pertinentes.
3. Revisar regressões e efeitos colaterais.
4. Atualizar documentação técnica afetada.
5. Indicar propostas de alteração do GDD, se houver.
6. Apresentar um resumo objetivo da entrega e suas limitações.

---

## 14. O que os agentes não devem fazer

- Alterar pilares do jogo sem aprovação.
- Inventar mecânicas para preencher lacunas de especificação.
- Modificar o GDD silenciosamente.
- Fazer com que toda pista encontrada seja relevante.
- Criar pistas falsas sem explicação no mundo.
- Revelar automaticamente ao jogador relações entre evidências.
- Expor pontuações internas de investigação.
- Produzir casos impossíveis sem sinalizar erros.
- Acoplar o gerador de casos a uma cena específica.
- Introduzir soluções específicas para um único caso como se fossem genéricas.
- Ignorar regressões para concluir rapidamente uma tarefa.
- Substituir testes reais por afirmações de que algo funciona.
- Considerar uma entrega visualmente adequada apenas porque passou nos testes técnicos.
- Expandir escopo ou introduzir dependências relevantes sem necessidade justificada.

---

## 15. Princípio final

**Dead Letter é um jogo sobre a diferença entre suspeitar, saber e provar.**

Todas as decisões técnicas devem preservar essa distinção.

O papel dos agentes é construir sistemas capazes de produzir investigações complexas, consistentes e interessantes, sem retirar do jogador a responsabilidade de observar, raciocinar e formular conclusões.

Na presença de ambiguidades importantes, preservar a intenção do projeto é mais importante do que implementar rapidamente uma interpretação não aprovada.