# Referência Python original

Os fontes em `python/` foram extraídos sem alteração do arquivo `unnamed-investigation-game.zip`. Metadados macOS, caches e o repositório Git aninhado não foram incorporados à árvore de referência.

SHA256 do ZIP: `72a7e7b9a7bfe9d961656d30c74e85bf7c12a8713720bb00540a6b17cf99b302`.

Execute `python3 reference/python/main.py` para jogar o terminal original. Seu comportamento foi preservado, inclusive limitações.

`python3 tools/characterize_legacy.py` verifica os snapshots registrados em `characterization.json`; `--record` regenera a caracterização intencionalmente. O arquivo registra versão do Python, seeds 0–99, seeds com pistas descartadas e casos completos das seeds 0 e 42. Não exige equivalência de PRNG entre Python e Godot.

## Diagnóstico e migração

| Original | Aproveitamento | Mudança no núcleo |
|---|---|---|
| Case / solution | Separação caso/resposta | Snapshot estruturado com vítima e eventos |
| ObjectClue, GossipClue, DocumentClue | Formas de observação | Dados separados dos fatos e da avaliação |
| Suspect | Intenção de identidades e relações | Personagens participam de acontecimentos |
| Pista alternativa + explicação | Exemplo faca/acidente/registro | Consequências da mesma origem causal |
| Catálogos de armas e motivos | Faca, corda e três motivos | IDs consistentes; conteúdo pequeno e revisável |
| CaseGenerator / ClueGenerator | Separação de geração/apresentação | Acontecimentos antes de consequências |
| Terminal | Consumidor simples | Novo consumidor sem regras centrais |

O gerador anterior sorteia respostas e descrições sem cronologia ou origem causal. Suspect e Solution não são usados pela geração. A vítima não tem identidade própria. Explicações de motivos escolhem pessoas independentemente da pista que deveriam contextualizar. Relatos não têm observador identificável. `poison` não coincide com a chave `poison vial` do catálogo. `is_true` mistura relevância e verdade factual.

Em 82 das 100 seeds caracterizadas houve pistas geradas que não chegaram às salas. A seed 0 perde um documento contextual sobre um conflito resolvido. A distribuição aleatória e seus descartes foram substituídos por posicionamento causal e validação de suficiência. Esses defeitos não devem virar requisitos de paridade.

O terminal original descobre todas as pistas de cada sala e compara três respostas para vencer, sem provas. Essa experiência não foi migrada: o novo consumidor inspeciona itens individualmente e exige seleção de evidências, respeitando o GDD.

## Recuperação da experiência após a primeira revisão

A primeira migração tornou a investigação explícita demais: testemunha ocular, autoria identificada na arma e um único acidente paralelo. Isso foi rejeitado pelo responsável pelo projeto. A versão 0.2.0 recupera os aspectos que funcionavam na referência:

- Proximidade é suspeita, não uma declaração de culpa; os quatro suspeitos têm relatos.
- A razão padrão `false_count=3` reaparece como três objetos alternativos e ocorrências contextuais próprias.
- Os objetos apresentam os mesmos tipos de vestígios genéricos independentemente de sua relação com o crime.
- Conflitos de várias pessoas e documentos posteriores exigem distinguir problemas persistentes de questões já encerradas.
- Álibis e explicações são descobertas separadas, com eventos e pessoas compatíveis, corrigindo o pareamento aleatório do original.

Foram acrescentadas comparações materiais e uma avaliação que exige apresentar as informações cruzadas. Não há tentativa de reproduzir bit a bit o gerador Python, suas contradições ou seus descartes. A base de referência continua preservada sem alteração; a migração deve conservar a experiência de suspeitas concorrentes, não só os nomes das classes.
