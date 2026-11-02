# Núcleo procedural — investigação com suspeitas concorrentes

## Direção aprovada

Godot **4.6.2.stable.official.71f334935**, instalado neste computador. GDScript é o runtime de produção, Python permanece como referência executável. A acusação é estruturada, com seleção de provas, sem interpretação de texto livre. Pontuação fica oculta durante a investigação; o diagnóstico completo após o veredito está autorizado para desenvolvimento.

A primeira versão entregava autoria, motivo e método explicitamente e empobrecia a referência. Após o teste do responsável pelo projeto, a direção aprovada foi recuperar a estrutura do Python: relatos de proximidade, várias armas suspeitas, conflitos concorrentes e explicações distribuídas, agora com causas e validação. O GDD não foi alterado.

Após o teste da seed 914368, o responsável aprovou um caso curto de 14–18 observações e duas linhas falsas distintas. Pediu também diversidade de funções e histórias: conflitos financeiros não devem ser repetidos para todos os suspeitos. O snapshot e a transcrição anteriores foram preservados em `tests/fixtures/`.

## Responsabilidades

- `case_data.gd`: snapshot privado, esquema 6, gerador 0.7.0 e catálogo `hotel_prose_1`.
- `evidence_catalog.gd`, `core/catalog/` e `data/catalog/catalog.tres`: Resources de definições, relações e referências visuais; apresentação exposta em cópias de dados, sem carregar arte no núcleo. Ver [autoria](evidence-resources.md).
- `case_content.gd`: vocabulário pequeno de métodos, formas físicas e conflitos, recuperado da referência.
- `case_generator.gd`: personagens, relações, acontecimentos, consequências e posições. PRNG local; no máximo três tentativas. Retorna os snapshots e diagnósticos dos candidatos rejeitados.
- `proof_rules.gd`: deriva cruzamentos internos a partir das propriedades observáveis, sem consultar a verdade do crime. Não é chamado pela interface para orientar o jogador.
- `case_validator.gd`: verifica referências, tempo, deslocamentos, causas, conhecimento das fontes, propriedades, material de roupas, explicações contextuais, regras probatórias e suficiência das provas alcançáveis.
- `accusation_evaluator.gd`: avalia precisão e suficiência das provas explicitamente selecionadas e descobertas.
- `investigation.gd`: mantém o snapshot privado, descobertas e anotações separados. Expõe apenas observações permitidas.
- `investigation_board.gd`: organização livre por sessão, sem acesso à verdade ou à rede causal; apresentação em `ui/investigation_board.gd` e `ui/board_canvas.gd`. Ver [contrato e controles](investigation-board.md).
- `ui/main.gd` e `ui/presentation.gd`: mesa de teste em português e descrições. Não decidem relevância ou veredito.
- `tools/investigate.gd`: consumidor de terminal, sem regras centrais.

Nenhuma classe do núcleo depende de Node, cenas, HUD ou assets. As regras não dependem de carregar o hotel 3D.

## Modelo e causalidade

O snapshot contém `characters`, `locations`, `entry_location`, `relations`, `events`, `evidence`, `support_rules`, `counterproofs`, `placements`, `truth` e `policy`.

Personagens possuem identidade, papel, flag pública de elegibilidade para acusação e acontecimentos conhecidos. Há quatro suspeitos (Ana, Bruno, Carlos e Diana), Vicente como vítima, Amadeu como porteiro e um responsável pelo exame. O porteiro presencia passagens pela recepção, não o assassinato; o responsável recolhe o corpo; não há exame concluído nos casos gerados atualmente.

A topologia de oito locais permanece fixa. O arquivo pode estar fechado. Conexões têm custos de deslocamento; acessibilidade refere-se ao momento da investigação. Os acontecimentos são anteriores à sessão, com intervalos relativos em minutos. Participações não podem se sobrepor nem exigir deslocamento impossível.

Cada acontecimento possui participantes, lugar, intervalo, causas, efeitos e consequências observáveis. A evidência guarda sua origem, local, forma de apresentação, propriedades e fonte humana quando aplicável. O validador compara consequências com os efeitos do acontecimento e rejeita alterações e descartes silenciosos. Documentos podem representar um acontecimento ocorrido em outro local; objetos e vestígios físicos permanecem em seu local de origem. O descarte da arma é um acontecimento posterior ao assassinato, com deslocamento verificável.

Na geração atual não há exame disponível: registros de serviço delimitam horários e vestígios ambientais sustentam mecanismos. Os modelos médicos permanecem somente no catálogo legado e nos testes autorais. As fibras e a linha derivam de contato físico durante o acontecimento; a arma é descartada depois. Cada objeto alternativo decorre de um uso independente: acidente de cozinha, trabalho com corda, inspeção de arma, desgaste esportivo ou limpeza. Cada conflito tem uma decisão posterior que o mantém aberto ou o encerra.

## Caso curto e diversidade

A [revisão de gameplay](gameplay-feedback.md) define o recorte atual: 15–16 observações, dois contatos concretos com a vítima, cinco locais possíveis na planta fixa e autópsia pendente. Horários são registros de serviço; mecanismo é inferido a partir de marcas específicas do ambiente. As consequências físicas são registradas no acontecimento de origem e respeitam deslocamentos e acessibilidade.

O catálogo possui 37 modelos e 73 relações. Perfis autorais em data/catalog/scenes descrevem consequências diferentes por local e método. A geração não atribui uma explicação de uso independente à arma verdadeira neste recorte. Pistas falsas continuam possuindo acontecimentos próprios.

## Acusação e provas

Entrada: `culprit`, `motive`, `method`, `evidence_ids`. IDs desconhecidos ou não descobertos são ignorados. Ter descoberto uma informação não a inclui automaticamente no relatório.

`support_rules` representa argumentos probatórios, não verdade factual nem conhecimento do jogador. Cada regra exige um conjunto de observações, candidato/afirmação compatíveis, peso e grupo de independência. O validador recalcula essas regras a partir das propriedades para impedir que uma etiqueta arbitrária transforme uma pista em prova.

No recorte atual:

- Autoria: a comparação do achado material (fibras e costura) com o cadastro de roupas sustenta identidade; há uma rota alternativa por exclusão de três álibis que cobrem a janela do crime. Um relato de proximidade compatível com o horário complementa a oportunidade. As rotas de identidade são alternativas no mesmo grupo, sem inflar pontos quando ambas são apresentadas.
- Método: requer compatibilidade entre as características clínicas e um objeto apresentado. O laudo contém características clínicas e horário em uma única observação; a arma apresentada precisa ser compatível com as lesões.
- Motivo: o registro contextualizado de um conflito aberto sustenta o motivo da própria pessoa. Ele já contém o histórico e a resposta; não se exige selecionar uma segunda ficha para repetir a mesma informação. Um problema resolvido ou de outra pessoa não subsidia a acusação.

A configuração experimental exige autoria 3 (identidade 2 e oportunidade 1), motivo 2, método 2 e total 7. Esses números são configuração do teste de lógica, não balanceamento final. Para cada afirmação/grupo, usa-se o maior peso uma única vez. Repetir provas ou cópias não acumula pontuação.

Há conjuntos suficientes de cinco ou seis achados, conforme a linha argumentativa; não há exigência de nove anexos. Há múltiplos conjuntos suficientes: a autoria pode ser sustentada por vestígios ou pela reconstrução dos álibis. O arquivo fechado não bloqueia a investigação. Não há cópias de provas adicionadas para preencher o mapa. A validação automática usa o mesmo avaliador com as provas alcançáveis. Isso é válido porque não existem ações consumíveis, exclusão mútua entre descobertas ou pré-requisitos de ferramentas neste recorte.

Os resultados são `wrong_culprit`, `insufficient_case` e `solved`. Não há penalidade extra por anexar uma pista irrelevante; ela não contribui. A política aprovada considera todas as contraprovas existentes e aplicáveis, mesmo não descobertas/apresentadas; somente argumentos afetados deixam de contribuir. Ver [rede e posicionamento](evidence-network.md).

## Fronteira da interface

`Investigation.characters()` retorna apenas ID, nome, papel e elegibilidade para acusação. `locations()` e `objects_at()` permitem navegação; `inspect()` revela um item individualmente, sem descobertas em lote. `discoveries()` retorna cópias das observações. As anotações não são lidas pelo avaliador.

`submit()` encerra definitivamente a sessão. Sem debug, retorna somente o resultado. Com debug, acrescenta verdade, motivos de falha, pontuação e comparações sustentadas, somente depois da submissão. A mesa habilita esse diagnóstico por padrão para desenvolvimento; ele pode ser desmarcado.

A interface possui rolagem nas listas de itens e descobertas, mantendo o botão de envio visível. Abrir outra seed ou repetir a mesma inicia uma sessão limpa, sem salvamento ou confirmação. A interface de teste não é o quadro investigativo definitivo nem a exploração 3D.

## Reprodução, testes e limites

Registrar seed, tentativa, engine, versão do gerador e conteúdo. Na tentativa N, o PRNG local usa seed + N. Não há promessa de identidade entre versões do Godot ou do catálogo, nem sequência aleatória idêntica à do Python. IDs só são estáveis dentro da mesma versão e caso.

`CaseData.encode/decode` faz roundtrip JSON do snapshot privado; a seed é string para preservar inteiros de 64 bits. Os esquemas 1, 2, 3 e 4 foram substituídos e são rejeitados, sem migração de saves de sessões (que nunca foram implementados). A leitura só valida formato básico: chamar o validador antes de consumir o snapshot. Não é um parser endurecido para conteúdo hostil.

`tests/run_tests.gd` cobre seeds 0–99 e a regressão 914368: reprodução, rotas suficientes ou legitimamente contestadas conforme o contexto, orçamento de observações, diversidade temática, candidato alternativo, ambiguidade das características materiais, ausência de frases que entregavam autoria, deduplicação, causalidade, cronologia, origem dos depoimentos e dos registros de atividade, contexto da pessoa correta, acessibilidade e serialização. O relatório fica em `tests/results/latest.json`; falhas de geração incluem snapshots rejeitados.

`tests/ui_smoke.gd` exercita controles da cena real, três vereditos, reinício e seed inválida. Com renderização, captura telas para inspeção visual. `tools/characterize_legacy.py` continua verificando os exemplos originais e seus defeitos conhecidos.

Limites: os acontecimentos e a estrutura temporal ainda usam um vocabulário autoral pequeno. As roupas seguem uma combinação pequena de características; os álibis documentais são confiáveis neste recorte. Há formas recorrentes que podem ficar previsíveis depois de várias runs. As análises estão disponíveis diretamente; não há ferramentas completas, simulação contínua, mentira sistêmica, autenticação documental ou progressão. O quadro livre da mesa atual já permite organização manual, sem integração 3D. A verificação automática garante propriedades específicas, não mede dificuldade, sutileza ou prazer de dedução. A revisão humana de casos continua sendo o critério de qualidade investigativa.

O validador rejeita casos com mais de 18 observações ou repetição de um mesmo tema de conflito, além das verificações de consistência. A fixture original da seed 914368 guarda 38 observações da versão 0.2.0; o teste exige a mesma verdade factual na versão curta e mede a preservação do recorte curto (15 observações sem autópsia pública).

## Localização

Cada observação expõe `id`, `definition_id`, forma, local e propriedades canônicas, sem título traduzido no núcleo. O renderizador resolve chaves e parâmetros externos no idioma selecionado. Locais e papéis também usam IDs. A troca entre português e inglês preserva a sessão. Ver [contrato de localização](localization.md), e [rede de contraprovas](evidence-network.md), incluindo os limites do vocabulário e das regras de sustentação ainda em GDScript.

## Rede e posicionamento lógico

A [especificação atual](evidence-network.md) descreve 37 modelos, 73 relações, nove categorias, contextos rotativos e árvore de pontos de inspeção. O conhecimento do jogador não controla a existência nem a eficácia de uma contraprova. O posicionador usa categorias de suporte, não rótulos de relevância; mantém o local causal e não carrega cenas.

Os operadores atuais de sustentação foram preservados e complementados para empréstimos e achados médicos. As relações de contestação são externas e parametrizadas. Posse de roupas é reconstruída pela cronologia de entradas e entregas; não se presume que a ficha inicial permaneça válida após um empréstimo. Esses cenários adicionais existem nos testes, sem sorteio de todas as famílias na geração padrão.

O quadro recebe apenas visited_locations() e known_characters(), além das descobertas. O elenco completo e a planta da mesa não geram fichas automaticamente. Cards disponíveis ficam na pilha; placed controla somente a colocação feita pelo jogador. Menções e conversas são registradas na sessão, sem consultar relevância.

Na versão 0.6.0, a mesa não tem campo separado de anotações. As hipóteses e notas ficam somente no quadro; o antigo campo session.notes foi removido. O briefing público informa a descoberta do corpo e autópsia pendente sem expor o culpado.

O [primeiro recorte de interrogatórios](interrogation.md) move os dois relatos do porteiro para conversas, acrescenta posições atuais dos NPCs e esclarecimento do registro de utensílio na mesma prova.

[Variações de redação das provas](prose-variations.md): alternativas localizadas por Resource, escolhidas por seed sem alterar fatos ou avaliação.

O [diagnóstico pós-veredito](verdict-feedback.md) traduz o rastro do avaliador em explicações localizadas. O índice de provas ocultas é exposto somente no retorno de diagnóstico de uma acusação encerrada.

## Legibilidade da mesa de investigação

A mesa utiliza fonte padrão de 20 px nos controles, texto de leitura/conversa/veredito de 22 px com separação entre linhas, rótulos de 16–18 px e títulos ampliados. As colunas laterais têm mínimos de 260 px e 380 px. O formulário e a lista de provas compartilham uma rolagem, enquanto o diagnóstico, o botão de submeter e o aviso de encerramento permanecem fixos no rodapé do relatório. Isso preserva acesso à submissão em janelas menores sem reduzir a fonte. Nomes longos de NPCs usam reticências e tooltip no seletor do cômodo. O quadro mantém sua apresentação própria.

`tests/board_resize.gd` também confere a leitura e o rodapé da mesa em 1280×820 e 1920×1080, com capturas `desk_readable.png` e `desk_readable_large.png`.
