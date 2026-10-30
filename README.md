# Dead Letter

A PSX-style murder mystery roguelite set in a hotel in São Paulo, Brazil.

Every run presents a new murder case with procedurally generated suspects, evidence, motives, and relationships. Investigate the hotel and build an accusation supported by evidence of authorship, motive and method.

## Core pillars

- Procedurally generated murder mysteries
- Deduction-driven gameplay
- Interconnected suspects, motives, and evidence
- Atmospheric hotel setting
- Retro PSX visual style
- High replayability

## Status

Early development / pre-production.

The first logic prototype runs on **Godot 4.6.2**. Its GDScript core is independent of scenes and UI. No 3D hotel or final investigation interface is included yet.

## Experimentar a investigação

Abra `project.godot` no Godot e pressione **F5**. A cena principal já está configurada; não é necessário usar o terminal.

1. Escolha um local e clique em um objeto, documento ou depoimento para examiná-lo.
2. Faça anotações e volte às descobertas quando quiser.
3. No relatório à direita, escolha acusado, motivação e método. Marque as descobertas que deseja apresentar como provas.
4. Clique em **Encerrar e apresentar acusação**. Com **Diagnóstico após o veredito** marcado, o resultado também mostra a verdade e os cálculos para depuração.
5. Use **Outro caso** para uma seed aleatória ou **Abrir seed** para repetir um caso. Iniciar um caso apaga as descobertas e anotações da sessão anterior.

Esta mesa é uma interface de teste lógico, em português. As análises dos vestígios já estão disponíveis ao examinar os itens; ferramentas e exploração 3D serão integradas posteriormente. A tela não revela relevância ou pontuação durante a investigação.

O caso curto reúne 15 observações e recupera alternativas do Python: relatos sobre os quatro suspeitos, dois objetos aparentemente incriminadores e histórias financeira, pessoal e profissional de pessoas diferentes. As pistas não nomeiam quem cometeu o crime. A acusação exige cruzar informações, e pode usar vestígios ou a reconstrução de álibis. Ainda há padrões recorrentes no pequeno catálogo; a dificuldade precisa de teste humano.

## Run the logic tests

Use the installed Godot executable (on this computer, `/Users/brunocosta/Downloads/Godot.app/Contents/MacOS/Godot`):

```sh
godot --headless --path . --script tests/run_tests.gd
python3 tools/characterize_legacy.py
```

The Godot suite writes `tests/results/latest.json`, covering seeds 0–99 plus regression seed 914368 and negative causal/proof cases. Python checks the preserved reference, not the production core.

`godot --path . --script tests/ui_smoke.gd` exercises the actual scene controls, all three verdicts, resetting and invalid seed handling. Without `--headless` it also captures rendered screens in `tests/results/desk_*.png` for visual review.

## Inspect and accuse through the development terminal

```sh
godot --headless --path . --script tools/investigate.gd -- --seed=42
godot --headless --path . --script tools/investigate.gd -- --seed=73 --inspect=contact,wardrobe,examination
```

Each command starts a fresh session. Inspection is explicit and selected proof must have been discovered in that session. Omit `--debug` to hide internal scores and truth; debug feedback appears only after the verdict. This terminal lists inspectable items for development and is not the final player interface.

To accuse, add `--culprit=person_0 --motive=money --method=stabbing --evidence=id,id` with your hypothesis and selected discovery IDs. Add `--debug` for post-verdict diagnostics. A complete accusation can be supported with five or six observations through different arguments; the case contains 15 observations total. Duplicate documents are not required.

See [architecture and scope](docs/architecture.md), [original prototype analysis](reference/README.md), and [GDD](GDD.md). Numerical weights are experimental test configuration, not final balancing.

A seed 914368 foi preservada antes da redução em `tests/fixtures/`. Para comparar a revisão na tela, digite **914368** e clique em **Abrir seed**. A verdade factual foi mantida; a distribuição e os documentos foram refeitos.

## Idioma e autoria de textos

O seletor no cabeçalho alterna entre **Português (BR)** e **English**, inclusive no meio de um caso, preservando descobertas, anotações e relatório. Cada prova tem um ID de instância e um ID de tipo; títulos e descrições são resolvidos pelo idioma e não ficam no snapshot do núcleo.

O catálogo está em `data/evidence_catalog.json`; traduções estão em `localization/messages.csv`. Para adicionar idioma, incluir a coluna e o nome em `localization/languages.json`. Consulte [o contrato de IDs e tradução](docs/localization.md). A rede completa de contraprovas ainda é o próximo incremento do núcleo.

```sh
godot --headless --path . --script tests/localization_tests.gd
godot --headless --path . --script tools/investigate.gd -- --seed=914368 --language=en
```
