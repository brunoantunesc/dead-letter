# IDs e localização das provas

Cada achado tem **ID de instância** (`id`) e **ID de definição** (`definition_id`). Por exemplo, `object_0` é uma instância do tipo `object.knife`. IDs não são textos e não mudam com o idioma. Instâncias só são únicas dentro do caso; para identificação global, incluir a identidade e a versão do caso.

Eventos, origens, argumentos, descobertas e acusações usam IDs e propriedades estruturadas. O snapshot atual não guarda títulos ou descrições em português. Nomes próprios brasileiros continuam sendo identidades; nomes genéricos, locais e papéis são traduzidos.

## Arquivos de autoria

- `data/evidence_catalog.json`: 25 definições possíveis, com seletor, chave de título, chave de descrição e parâmetros. O caso curto continua com 15 instâncias.
- `localization/messages.csv`: 143 chaves nas colunas `key`, `pt_BR`, `en`. Contém provas, termos, locais, interface e vereditos.
- `localization/languages.json`: nomes dos idiomas oferecidos pelo seletor.
- `ui/localization.gd`: registra mensagens no `TranslationServer` nativo do Godot e aplica parâmetros nomeados.
- `ui/presentation.gd`: renderiza parâmetros e linhas do catálogo, sem frases por tipo de pista ou acesso à verdade.

Uma instância com `definition_id: object.knife` resolve, pelo catálogo, a chave `evidence.object.knife.body`. O idioma selecionado determina o texto dessa chave. Não comparar títulos para reconhecer uma faca.

## Tradução e conteúdo

Para um idioma novo, acrescentar uma coluna com código de locale Godot ao CSV, traduzir todas as linhas e acrescentar seu nome em `languages.json`. Preservar parâmetros como `{person}`, `{time}` e `{entries}`; sua posição pode mudar. Não é necessário editar a UI. Os testes percorrem automaticamente os idiomas declarados e verificam suas chaves e parâmetros.

Para uma variante dentro do vocabulário atual, criar um ID estável e seletor sem sobreposição no catálogo, declarar `title_key`, `text_key` e parâmetros, e acrescentar as mensagens em todos os idiomas. Formatos disponíveis: `person`, `term`, `location`, `time` e valor simples; registros com várias linhas usam `rows`.

Traduzir frases completas. Não concatenar palavras traduzidas para construir frases. Templates próprios para linhas de cadastros permitem reorganização gramatical. Anotações livres do jogador não são traduzidas ou reescritas.

Um tipo novo de acontecimento ainda exige suas regras causais; criar um texto não cria uma mecânica investigativa.

## Comportamento e distribuição

O seletor muda o idioma durante a investigação e após o veredito. Preserva seed, sessão, descobertas, notas, acusado/motivo/método, provas marcadas e encerramento. Não gera um novo caso. A preferência vale para a execução atual; persistência entre execuções não foi criada.

O terminal aceita `--language=en`. Dados de observação continuam com IDs e propriedades canônicas, independentes do idioma.

Ao criar um preset de exportação, incluir `data/*.json`, `localization/*.csv` e `localization/*.json` em `include_filter`, pois são lidos com `FileAccess`. O repositório ainda não tem um preset distribuível. Recursos `.translation` que o editor possa importar do CSV não são necessários ao carregador atual.

## Escopo e contraprovas

O catálogo de apresentação e as traduções agora são orientados por dados. Geração causal e operadores probatórios continuam em GDScript; o sistema inteiro não foi convertido para conteúdo externo nesta entrega.

A regra aprovada exige ao menos uma contraprova possível por tipo no catálogo, sem obrigar sua presença no caso. Essas relações usarão os mesmos `definition_id` e IDs factuais, nunca títulos traduzidos. A rede completa e seus efeitos no avaliador ainda não foram implementados. Não foram criados pares fictícios apenas para passar uma validação estrutural. Essa migração é o próximo incremento sobre este contrato de identidade.

## Verificação

`tests/localization_tests.gd` verifica chaves, parâmetros, resolução das 25 definições, títulos/descrições sem tokens pendentes e invariância da geração ao idioma. `tests/ui_smoke.gd` troca o idioma durante uma investigação e após o veredito, conferindo preservação de estado e capturando a tela em inglês. A revisão visual foi feita em português e inglês; outros idiomas não foram revisados.
