# Rede de contraprovas e distribuição por suporte

Direção implementada da #2 sobre a autoria da #11. Decisão do responsável nesta etapa: **considerar todas as contraprovas existentes e aplicáveis**, inclusive não descobertas ou não apresentadas. Retirar somente o argumento contestado, sem penalidade adicional ou conclusão automática de inocência.

O GDD não foi modificado. Pesos e limiares experimentais permanecem iguais.

## Dados e responsabilidades

O catálogo tem **31 definições, 46 relações, 9 categorias de suporte e 31 referências visuais pendentes**. Os 25 IDs anteriores foram preservados. Os seis novos modelos são contato anterior, remoção de resíduos, entrega de roupa emprestada, complemento médico, encerramento de atendimento e registro de uso de utensílio.

- Resources em `data/catalog/definitions/`: modelos, parâmetros, afirmações possíveis, categorias e tipos de acontecimento de origem.
- `data/catalog/relations/`: relações de contestação, escopo, condições e dependências de outras afirmações.
- `data/catalog/categories/`: hierarquia física/documental. Não classifica culpa ou relevância.
- `data/catalog/hotel_placement.tres`: hierarquia de pontos lógicos de posicionamento do cenário.
- `core/evidence_network.gd`: aplica as relações aos achados existentes e resolve cadeias.
- `core/evidence_placement.gd`: percorre a hierarquia de suportes e associa cada achado a um ponto admissível.
- `core/case_validator.gd`: verifica origem causal, cronologia, posse de roupas, relações recalculadas, posicionamento e suficiência.

O índice é explícito em `catalog.tres`. Novos arquivos precisam ser incluídos nele. As relações são indexadas pelos modelos presentes no caso; não é necessário comparar cada modelo com todos os objetos do hotel.

## O que uma relação significa

Uma observação pode admitir diferentes afirmações. A relação contesta uma delas:

| Origem → alvo | Afirmação contestada | Escopo necessário |
|---|---|---|
| Presença registrada → relato de passagem | A proximidade sustenta participação no crime | Mesma pessoa; presença em outro local cobre a janela do crime |
| Contato anterior → fragmentos encontrados | O material identifica contato durante o crime | Mesmo tecido e linha, pessoa do argumento e contato anterior à janela |
| Remoção de resíduos → contato anterior | Aquele contato anterior ainda explica os fragmentos | Mesmo material, remoção posterior e anterior ao crime |
| Novo contato → remoção de resíduos | A remoção impede qualquer resíduo posterior | Mesmo material; contato após a remoção e antes do crime |
| Entrega de casaco → ficha de lavanderia | A pessoa da ficha ainda tinha a peça no crime | Material, proprietário anterior e horário posterior à ficha |
| Complemento médico → exame | O achado descrito anteriormente é o principal para o método | Identidade do relatório, achado diferente e revisão posterior |
| Acidente/uso cotidiano → objeto | A origem dos vestígios só pode ser criminosa | Mesma instância do objeto, não apenas mesmo tipo |
| Novo uso → ocorrência anterior | A ocorrência explica todo o histórico posterior | Mesma instância e uso posterior |
| Acordo/reabertura → conflito | O estado anterior ainda determina o motivo | Mesma pessoa e assunto; mudança antes do crime |
| Reparo/novo pedido → atendimento | A ocorrência permanece aberta ou definitivamente resolvida | Mesma pessoa, problema e ordem temporal |

Um acidente não apaga o objeto, e um uso legítimo não torna uma arma incompatível com as lesões. Por isso, `criminal_origin` e `injury_method` são afirmações diferentes. O avaliador só descarta argumentos cuja `inference_id`, alvo e pessoa correspondam à contestação ativa.

O catálogo inclui entradas sem força probatória para o assassinato, como atendimentos do quarto. Ter uma contraprova possível não transforma um fato cotidiano em evidência de culpa.

## Contrato de autoria da relação

- `source_definition_id` e `target_definition_id`: modelos de origem e alvo.
- `source_claim_id`: afirmação da origem necessária para a contestação.
- `target_claim_id`: afirmação do alvo que está sendo contestada.
- `source_rows` / `target_rows`: selecionar uma linha de um registro, quando necessário; não atribuir todas as linhas à mesma pessoa.
- `context_definition_id`: observação contextual adicional, como o exame que delimita a janela.
- `subject_field`: caminho da pessoa afetada, quando a relação é pessoal.
- `equal_fields`: correspondência simples entre propriedades das duas observações.
- `conditions`: predicados finitos eq, ne, lt, lte, gt, gte. Cada condição tem `left` e `right` (caminhos) ou `value` (literal). Todas devem ser satisfeitas.

Os caminhos são limitados às propriedades declaradas, linhas e metadados de origem permitidos. Não há scripts de conteúdo, SQL, execução de expressões arbitrárias ou acesso à verdade do crime nas condições.

Toda definição, inclusive as novas contraprovas, tem uma relação de entrada possível. O validador rejeita referências inexistentes, afirmações desconhecidas, parâmetros de escopo inválidos, seletores ambíguos e falta de cobertura. Isso não substitui um exemplo causal para a relação nova.

## Cadeias sem dedução para o jogador

As relações entre tipos podem formar ciclos: um contato pode qualificar uma remoção, e uma remoção pode qualificar um contato. Nas instâncias, pessoas, materiais e horários delimitam quais ligações existem.

Uma contestação só fica ativa se a afirmação da sua origem não for derrotada por outra contestação ativa. A resolução usa estados ativo, derrotado e indeterminado. Um ciclo de instâncias sem fundamento externo torna o caso inválido; o sistema não escolhe uma solução arbitrária.

As conexões, categorias e pontos internos de posicionamento não são devolvidos pelas APIs públicas de descobertas. O quadro do jogador continua livre. Diagnósticos de argumentos contestados aparecem somente no resultado de desenvolvimento após a acusação.

## Categorias e posicionamento recursivo

A árvore de categorias é:

```text
evidence
├── material
│   ├── material.object
│   └── material.trace
├── record
│   ├── record.administrative
│   ├── record.medical
│   └── record.personal
└── support.testimony
```

A árvore do cenário é independente. Um ponto pode aceitar uma categoria ancestral: um suporte `record` admite documentos médicos, administrativos e pessoais. Restrições de categoria e acessibilidade dos antecessores são herdadas.

Exemplo suportado: cenário → sala → armário → gaveta → ponto de inspeção. A seleção percorre os descendentes recursivamente. A definição escolhe o tipo de suporte; a origem causal e o local da observação restringem onde procurar. O posicionador não transfere um vestígio físico para outra sala para resolver uma falta de espaço.

O hotel atual usa pontos lógicos genéricos de documentos, objetos, vestígios e depoimentos em cada sala, com IDs fixos entre runs. **Ainda não existem móveis, coordenadas, colisões, capacidade física ou cenas 3D materializados por esse sistema.** O layout poderá ser substituído por suportes concretos sem alterar as relações probatórias. O posicionador aceita outro Resource de layout.

O snapshot guarda árvore e `placement_id` de cada achado. O validador recalcula a árvore, verifica o local e rejeita pontos incompatíveis, referências quebradas, alterações de acessibilidade e categorias cíclicas. Os custos de deslocamento e a suficiência continuam sendo verificados pelo núcleo.

## Geração e reprodução

Esquema **5**, gerador **0.5.0**, conteúdo **hotel_network_1**. Esquemas anteriores não são saves compatíveis; fixtures históricas permanecem preservadas.

Os casos gerados têm **16–18 observações**, dentro do orçamento aprovado de 14–18:

- As 15 observações originais do caso curto.
- Um registro de uso cotidiano de utensílio, envolvendo qualquer suspeito, independentemente de culpa.
- Conforme a seed, um contato anterior e um registro posterior de remoção de resíduos.

Tanto culpados quanto inocentes podem participar dos contextos. Nem toda relação potencial aparece em cada caso. Em alguns casos, uma rota material isolada deixa de ser suficiente; a rota independente pelos álibis permanece disponível. Quando o contexto não derrota a identificação material, as duas rotas continuam válidas.

Os contextos usam um PRNG local separado, e o posicionamento outro fluxo determinístico, sem alterar a escolha inicial de culpado/método/motivo da regressão 914368. A mesma seed e versão reproduzem eventos, relações e pontos.

Não foi adicionado histórico global de frequência entre partidas. O catálogo ainda é pequeno e autoral; expansão por variedade de situações e revisão humana continuam necessárias.

## Validação e revisão humana

```sh
godot --headless --path . --script tools/validate_catalog.gd
godot --headless --path . --script tests/catalog_tests.gd
godot --headless --path . --script tests/network_tests.gd
godot --headless --path . --script tests/run_tests.gd
godot --headless --path . --script tests/localization_tests.gd
godot --headless --path . --script tests/ui_smoke.gd
```

O teste da rede verifica ausência/presença, contraprova não descoberta ou selecionada, pessoa/material/objeto/horário incorretos, cadeia de contestação, inocência não automática, empréstimo de roupa, contextualização médica, motivos, ciclos e busca recursiva em recipientes. Há exemplos parciais de aplicabilidade para as 46 relações em `tests/fixtures/network_witnesses.json`; eles não são 46 mundos completos simulados. Casos completos cobrem famílias centrais e a bateria de seeds.

**Para revisão na mesa de teste: seeds 0 e 87.** As duas apresentam a mesma descrição de material encontrado, com contextos diferentes. Abrir cada seed e investigar sem consultar a verdade antes do veredito. O relatório privado `tests/results/network.json` registra a diferença esperada. A seed 914368 continua sendo a regressão histórica e agora possui 16 observações.

A revisão humana de dificuldade, legibilidade e justiça investigativa permanece na #4. A validação automática não certifica sutileza. Novas relações devem ter contexto perceptível pelo jogador; comparações de objetos semelhantes precisarão de identificação visual/textual distinguível na futura apresentação.

Resultados desta entrega no Godot 4.6.2: 387 verificações da rede, 77 do catálogo, 862 de localização e 4.236 do núcleo em 101 seeds, sem falhas. O smoke test da interface também passou. As seeds de revisão foram selecionadas automaticamente; isso não equivale a uma sessão humana de gameplay.

## Limites da etapa

A rede de contestação é orientada por dados e está integrada. Os construtores de acontecimentos e os operadores de sustentação ainda possuem vocabulário e regras em GDScript; não se trata de um editor completo de simulação ou de todo o sistema probatório convertido em dados. As relações não inventam acontecimentos faltantes.

Casos autorais de empréstimo e complemento médico são exercitados nos testes; a rotação padrão ainda não sorteia todas essas famílias. Não foram adicionadas ferramentas forenses, erros médicos aleatórios, elenco, progressão ou alterações do hotel 3D.
