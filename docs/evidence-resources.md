# Autoria do catálogo em Resources

Implementação da [#11](https://github.com/brunoantunesc/dead-letter/issues/11), complementada pela rede causal da [#2](https://github.com/brunoantunesc/dead-letter/issues/2). A autoria mantém IDs e textos separados da lógica. A integração posterior da rede está descrita em [rede e posicionamento](evidence-network.md).

## Onde editar

Abrir o projeto no Godot 4.6.2. No painel FileSystem, abrir um arquivo de `data/catalog/definitions/`: os campos aparecem no Inspector. Os tipos também estão disponíveis em **New Resource**, como EvidenceDefinition, EvidenceVisual, EvidenceRelation e EvidenceCatalogData.

- `data/catalog/catalog.tres`: índice explícito das definições, visuais e relações incluídas. Adicionar um arquivo à pasta não o inclui automaticamente.
- `definitions/*.tres`: um modelo por arquivo, com ID estável, seletor, chaves de tradução, parâmetros e visual_id.
- `visuals/*.tres`: entradas visuais independentes. As 37 atuais estão pendentes.
- Relações futuras: salvar Resources EvidenceRelation e adicioná-los ao índice. O índice atual inclui 73 relações de produção, com exemplos de escopo e condições.
- `localization/messages.csv`: textos por idioma, preservados.

O JSON anterior foi movido para `tests/fixtures/evidence_catalog_v1.json`, apenas como referência de migração. Não é lido pelo jogo nem deve receber conteúdo novo.

## Cadastrar uma definição

1. Criar um EvidenceDefinition e salvar em `definitions/`.
2. Definir um `id` único e permanente. Títulos e nomes de arquivos não identificam a prova.
3. Preencher `selector` com propriedades canônicas. Seletores não podem se sobrepor: um achado deve resolver exatamente um modelo.
4. Informar `title_key`, `text_key` e os parâmetros. Cada parâmetro possui `field` e `format`: person, term, location, time ou value. Formato de linhas segue o contrato de localização existente.
5. Criar um EvidenceVisual com ID próprio e atribuir esse ID a `visual_id`.
6. Adicionar ambos ao índice, criar traduções e executar validação e testes.

Criar um modelo não cria um acontecimento: vocabulário e regras causais novos continuam exigindo implementação e testes. Preencher também category_id, claim_ids, causal_kinds e observation_fields; a validação exige categorias e cobertura de contraprovas. Os parâmetros ainda são Dictionaries editáveis pelo Inspector; não há formulário especializado ou editor gráfico de redes nesta entrega.

## Referência visual sem arte

Uma definição sempre possui `visual_id`, apontando para uma entrada existente. Várias definições podem compartilhar uma entrada quando houver justificativa visual.

- `pending`: `asset_path` vazio. Significa que a representação ainda será produzida ou selecionada. É um estado válido; não gera objeto automaticamente.
- `ready`: caminho `res://` existente, de Texture2D, Mesh ou PackedScene. O campo aceita imagens, recursos e cenas/modelos; o validador de autoria confere o tipo realmente carregado.

`author_note` é anotação de produção, sem texto para o jogador. Atribuir um asset não certifica licença nem legibilidade; essas revisões continuam nas issues de assets e apresentação.

`EvidenceCatalog.visual_for(definition_id)` devolve cópia de ID, estado e caminho. A resolução de definição e a validação de metadados em runtime não carregam a arte. A futura camada visual decide quando carregar esse caminho. O vínculo identifica uma representação de apresentação, não prova adicional, relevância, variante de culpa ou regra de acusação.

Variações procedurais de aparência e texto sobre objetos ainda não são materializadas. Não usar versões “culpado/inocente” de um asset para revelar a solução.

## Relações

O contrato agora inclui afirmação de origem, afirmação contestada, linhas de registros, contexto adicional e predicados finitos. As relações usam IDs, sem ciclos de carregamento de arquivos. Ver [rede, condições e exemplos](evidence-network.md).

O catálogo verifica a estrutura; a geração e o validador do caso verificam origens, aplicabilidade, cadeias e suficiência. Uma relação nova precisa de um exemplo realizável; referências válidas sozinhas não provam qualidade investigativa.

## Verificação

Com o executável Godot instalado:

```sh
godot --headless --path . --script tools/validate_catalog.gd
godot --headless --path . --script tests/catalog_tests.gd
godot --headless --path . --script tests/network_tests.gd
godot --headless --path . --script tests/localization_tests.gd
godot --headless --path . --script tests/run_tests.gd
godot --headless --path . --script tests/ui_smoke.gd
```

O validador de autoria carrega assets preenchidos para verificar seus tipos, sem instanciar cenas. A validação usada pelo núcleo verifica metadados e existência dos caminhos sem carregar arte. Rodar a validação completa antes de integrar conteúdo.

Os testes comparam as 25 apresentações originais ao catálogo anterior, verificam cópias independentes, ciclo de relações, ResourceSaver/load, referências quebradas, seletores ambíguos, parâmetros inválidos, estado visual pendente e preenchido. Uma malha BoxMesh própria nos fixtures testa o vínculo preenchido; não é arte de produção.

O catálogo é cacheado durante uma execução. Reiniciar o teste/jogo depois de editar conteúdo; recarga dinâmica não foi implementada. IDs permanecem iguais nesta migração, mas não há promessa de reprodução entre futuras versões diferentes do conteúdo.

## Estado atual

A autoria em Resources foi complementada por 37 modelos, 73 relações e categorias recursivas. Os resultados atuais estão em tests/results/catalog.json, network.json, localization.json e latest.json. O editor reconhece os tipos nativos; a ergonomia do Inspector e a qualidade dos casos ainda precisam de revisão humana. Não houve inclusão de arte de terceiros ou mudança do GDD.

A autoria dos novos vestígios e perfis de ambiente está descrita em [gameplay-feedback.md](gameplay-feedback.md). O catálogo conserva modelos médicos para testes e evolução, mas não os distribui nos casos atuais.

Os modelos podem registrar alternativas localizadas em `text_variants` e `initial_text_variants`. Ver [autoria e validação de redações](prose-variations.md).

## Nomes dos vestígios físicos

`EvidenceDefinition.observable_titles` associa um token de detalhe observável às chaves `title_key` e `short_key`. Os cinco modelos de vestígios de cenário possuem 25 pares de nomes PT/EN, correspondentes aos detalhes físicos já existentes. A identificação usa o detalhe observado, sem consultar culpa ou relevância: por exemplo, no jardim, corte no tecido, sulcos no cascalho, vaso perfurado, lascas no banco e resíduo no copo.

`Presentation.title` e `short_title` resolvem os nomes para cenário, inspeção, seleção de provas, conversas, diagnóstico e quadro. `Investigation.objects_at` oferece `title_token` para a identificação inicial, sem descobrir a prova ou expor sua origem causal. As descrições e regras probatórias permanecem iguais. O quadro mantém o cômodo acima do nome curto.

`tests/trace_title_tests.gd`: 583 verificações, cobrindo os 25 detalhes nos dois idiomas, unicidade dos nomes completos e curtos por ambiente, encaixe no card, consistência entre lista e inspeção e 100 seeds. A seed 83 reproduz dois vestígios distintos no jardim; a captura `tests/results/trace_titles.png` foi inspecionada. Se a geração futura permitir dois vestígios do mesmo tipo no mesmo cômodo, será necessário diferenciá-los por suporte/posição física; este recorte gera métodos distintos.
