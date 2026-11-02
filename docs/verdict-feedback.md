# Diagnóstico após o veredito

Melhoria aprovada para ajudar nos testes de investigação. O GDD e as regras de avaliação não foram alterados. A análise detalhada é exclusiva da opção **Diagnóstico após o veredito**, após encerrar definitivamente a run.

## O que aparece

- Resumo das lacunas em combinações parcialmente apresentadas.
- Autoria, motivação e método: sustentação suficiente ou insuficiente; hipótese incorreta é identificada separadamente.
- Argumentos aceitos, com as provas envolvidas e a relação que sustentam.
- Argumentos incompletos, indicando o complemento que não foi apresentado naquela combinação.
- Contraprovas causalmente aplicáveis, com conteúdo explicativo e estado de descoberta/apresentação/esclarecimento.
- Outros anexos que não formaram um argumento adicional para a acusação.
- Totais técnicos comparados aos mínimos reais da política do caso, além da verdade interna já exposta pelo diagnóstico anterior.

Uma prova faltante é identificada como **não descoberta** ou **descoberta, mas não apresentada**. Isso evita confundir o que o jogador encontrou com o que anexou ao relatório. O resumo não afirma que uma pista específica seja obrigatória em qualquer rota: descreve lacunas nos argumentos que o jogador começou a apresentar.

A análise também explica que argumentos sobre o mesmo fato não acumulam força em duplicidade e que uma contestação invalida apenas a inferência afetada. Contraprovas existentes e aplicáveis continuam valendo mesmo quando não descobertas, conforme a decisão anterior do responsável. O diagnóstico deixa isso explícito.

## Regressão 258361

Com as sete provas do relato do jogador, a autoria permanece 2/3, a motivação 2/2 e o método 2/2. O registro do encontro do corpo foi descoberto, mas não apresentado. Sem ele, os argumentos temporais do depoimento e do livro de atividades ficam incompletos. A ligação material entre fibras e roupas continua aceita.

Apresentar também o registro sustenta o caso, preservando os limiares e a avaliação anteriores. O diagnóstico agora explica essa relação, em vez de apenas mostrar “autoria insuficiente”.

## Contratos

`AccusationEvaluator.evaluate` produz um rastro estruturado por argumento: inferência, provas exigidas, complementos faltantes, contestações e grupo de independência. Ele deriva esse rastro dos mesmos requisitos e ataques usados para calcular o resultado, sem reavaliar a acusação por outra regra.

Os campos anteriores (`scores`, `reasons`, comparações aceitas/contestadas) são preservados. `minimum_by_claim` e `minimum_total` refletem a política real, sem depender apenas de valores fixos no texto.

`Investigation.submit` continua retornando somente o resultado normal quando o diagnóstico está desligado. Com diagnóstico explicitamente habilitado, acrescenta um índice de observações para nomear e explicar as provas, incluindo as não descobertas. Esse índice nunca integra as descobertas durante a investigação.

`Presentation.verdict_text` traduz o rastro em PT/EN. As explicações dos tipos de inferência ficam na localização. Depoimentos usam o local descrito na fala, sem exibir o antigo slot físico onde eram listados antes da implementação de conversas.

Ler ou traduzir o diagnóstico não descobre pistas, não esclarece provas na sessão, não muda o quadro e não reabre a acusação. Explicações ocultas usadas pelo diagnóstico são renderizadas sobre cópias.

## Validação e limites

`tests/verdict_feedback_tests.gd`: 24 verificações. Reproduz a seed 258361, distingue provas não descobertas das não apresentadas, confirma solução ao completar a cronologia, verifica contraprova não descoberta, diagnóstico desligado, hipótese incorreta, anexos inválidos, ausência de pontuação duplicada, imutabilidade e apresentação na cena real.

A captura `tests/results/verdict_feedback.png` mostra o diagnóstico na mesa, com rolagem para a análise completa. Textos longos não alteram o tamanho do quadro nem a estética existente. A revisão humana do conteúdo durante partidas continua necessária.

A explicação corresponde aos argumentos codificados atualmente; não é análise de linguagem natural das hipóteses do jogador. Novos tipos de inferência precisam de uma explicação localizada própria. Há uma descrição genérica de segurança para tipos ainda sem texto específico.
