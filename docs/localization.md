# IDs e localização das provas

Cada achado tem **ID de instância** (`id`) e **ID de definição** (`definition_id`). Por exemplo, `object_0` é uma instância do tipo `object.knife`. IDs não são textos e não mudam com o idioma. Instâncias só são únicas dentro do caso; para identificação global, incluir a identidade e a versão do caso.

Eventos, origens, argumentos, descobertas e acusações usam IDs e propriedades estruturadas. O snapshot atual não guarda títulos ou descrições em português. Nomes próprios brasileiros continuam sendo identidades; nomes genéricos, locais e papéis são traduzidos.

## Arquivos de autoria

- `data/catalog/catalog.tres` e `data/catalog/definitions/*.tres`: 31 definições possíveis em Resources, com seletor, chave de título, chave de descrição, parâmetros e visual_id. O caso curto agora tem 16–18 instâncias. Ver [autoria e referências visuais](evidence-resources.md).
- `localization/messages.csv`: 199 chaves nas colunas `key`, `pt_BR`, `en`. Contém provas, termos, locais, interface e vereditos.
- `localization/languages.json`: nomes dos idiomas oferecidos pelo seletor.
- `ui/localization.gd`: registra mensagens no `TranslationServer` nativo do Godot e aplica parâmetros nomeados.
- `ui/presentation.gd`: renderiza parâmetros e linhas do catálogo, sem frases por tipo de pista ou acesso à verdade.

Uma instância com `definition_id: object.knife` resolve, pelo catálogo, a chave `evidence.object.knife.body`. O idioma selecionado determina o texto dessa chave. Não comparar títulos para reconhecer uma faca.

## Tradução e conteúdo

Para um idioma novo, acrescentar uma coluna com código de locale Godot ao CSV, traduzir todas as linhas e acrescentar seu nome em `languages.json`. Preservar parâmetros como `{person}`, `{time}` e `{entries}`; sua posição pode mudar. Não é necessário editar a UI. Os testes percorrem automaticamente os idiomas declarados e verificam suas chaves e parâmetros.

Para uma variante dentro do vocabulário atual, criar um Resource com ID estável e seletor sem sobreposição, incluí-lo no índice, declarar `title_key`, `text_key`, parâmetros e visual_id, e acrescentar as mensagens em todos os idiomas. Formatos disponíveis: `person`, `term`, `location`, `time` e `value`; registros com várias linhas usam `rows`. O visual pode permanecer pendente.

Traduzir frases completas. Não concatenar palavras traduzidas para construir frases. Templates próprios para linhas de cadastros permitem reorganização gramatical. Anotações livres do jogador não são traduzidas ou reescritas.

Um tipo novo de acontecimento ainda exige suas regras causais; criar um texto não cria uma mecânica investigativa.

## Comportamento e distribuição

O seletor muda o idioma durante a investigação e após o veredito. Preserva seed, sessão, descobertas, notas, acusado/motivo/método, provas marcadas e encerramento. Não gera um novo caso. A preferência vale para a execução atual; persistência entre execuções não foi criada.

O terminal aceita `--language=en`. Dados de observação continuam com IDs e propriedades canônicas, independentes do idioma.

Ao criar um preset de exportação, incluir `localization/*.csv` e `localization/*.json` em `include_filter`, pois são lidos com `FileAccess`. O catálogo .tres é uma dependência explícita e suas referências são Resources nativos. Assets visuais futuros, referenciados por caminhos de texto, precisarão de inclusão explícita na exportação e teste no build. O repositório ainda não tem um preset distribuível. Recursos `.translation` que o editor possa importar do CSV não são necessários ao carregador atual.

## Escopo e contraprovas

O catálogo e a rede de contestação são Resources orientados por dados. A regra de uma contraprova potencial por tipo é validada no catálogo de 31 definições e 46 relações. As condições usam IDs e propriedades canônicas, nunca títulos traduzidos. Ver [rede e limites](evidence-network.md).

Os construtores de acontecimentos e operadores de sustentação ainda usam GDScript. Criar textos ou uma relação não gera automaticamente uma causa nova. A rede permanece oculta na apresentação normal.

## Verificação

`tests/localization_tests.gd` verifica chaves, parâmetros, resolução das 31 definições, títulos/descrições sem tokens pendentes e invariância da geração ao idioma. `tests/ui_smoke.gd` troca o idioma durante uma investigação e após o veredito, conferindo preservação de estado e capturando a tela em inglês. A revisão visual foi feita em português e inglês; outros idiomas não foram revisados.

## Quadro de investigação

As chaves board.* traduzem controles e tipos de cards. O conteúdo conhecido continua usando os IDs de provas, pessoas e locais. Textos de notas e rótulos de conexões são autorais e não são traduzidos. Trocar idioma preserva o estado do quadro e da acusação. Ver [controles e limites](investigation-board.md).
