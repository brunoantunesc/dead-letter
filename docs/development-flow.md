# Fluxo de desenvolvimento — primeiro recorte investigativo jogável

Planejamento autorizado em 30/10/2026. Este documento organiza entregas; não altera o GDD nem aprova decisões de design ainda abertas.

## Objetivo do marco

No [marco Primeiro recorte investigativo jogável](https://github.com/brunoantunesc/dead-letter/milestone/1), uma pessoa deve conseguir investigar dois casos distintos em um pequeno trecho do hotel, examinar provas, organizar hipóteses e apresentar uma acusação. A revisão humana precisa avaliar a investigação, além dos testes de consistência.

## Entregas e dependências

| Issue | Entrega | Dependências para conclusão |
|---|---|---|
| [#11](https://github.com/brunoantunesc/dead-letter/issues/11) | Catálogo em Resources, contrato de relações e vínculos visuais pendentes | Preparação técnica de #2; não implementa política de contestação |
| [#2](https://github.com/brunoantunesc/dead-letter/issues/2) | Catálogo data driven de provas e contraprovas | Aprovar a política de contestação antes de mudar resultados de acusações |
| [#3](https://github.com/brunoantunesc/dead-letter/issues/3) | Auditoria dos assets e lacunas | Consolidar relatório, revisão e pendências de origem/licença |
| [#4](https://github.com/brunoantunesc/dead-letter/issues/4) | Qualidade investigativa dos casos curtos | #2; protocolo pode ser preparado antes |
| [#5](https://github.com/brunoantunesc/dead-letter/issues/5) | Definição do primeiro recorte do hotel | Resultados de #3 e aprovação do recorte |
| [#6](https://github.com/brunoantunesc/dead-letter/issues/6) | Preparação dos assets selecionados | #3, #5 e permissões dos assets usados |
| [#7](https://github.com/brunoantunesc/dead-letter/issues/7) | Caso procedural na exploração 3D | #2, #5 e #6; #4 orienta a seleção dos casos |
| [#8](https://github.com/brunoantunesc/dead-letter/issues/8) | Provas legíveis e traduzíveis | #7; preparação visual pode acompanhar #6 |
| [#9](https://github.com/brunoantunesc/dead-letter/issues/9) | Quadro com cards, conexões e marcações | Antecipado para a mesa atual; #7 não bloqueia a primeira versão |
| [#10](https://github.com/brunoantunesc/dead-letter/issues/10) | Validação do ciclo completo | #4, #7, #8 e #9 |

As dependências estão descritas nos corpos das issues; não foram cadastradas como bloqueios nativos do GitHub.

## Ordem de execução

1. Preparar autoria em Resources na #11, priorizar #2 e consolidar a auditoria #3. Preparar o protocolo de #4 e a proposta de #5 em paralelo, quando não dependerem de decisões pendentes.
2. Revisar a qualidade dos casos em #4, usando o quadro antecipado da #9, e aprovar o recorte de #5. Não expandir o conteúdo para disfarçar problemas de lógica ou apresentação.
3. Preparar apenas a seleção necessária em #6; integrar os dados e a exploração em #7.
4. Completar a leitura das provas em #8 e integrar o quadro da #9 às descobertas da exploração 3D.
5. Executar a revisão integrada em #10; registrar falhas antes de encerrar o marco.

Essa ordem permite investigação técnica em paralelo, mas não autoriza implementar uma decisão criativa pendente.

## Acompanhamento das tarefas

Usar os estados conceituais **próximas → prontas para começar → em andamento → em revisão → concluídas**. Eles são o protocolo de acompanhamento; um GitHub Project com essas colunas ainda não foi criado.

- **Próximas:** escopo definido, mas há dependências ou decisões pendentes.
- **Prontas:** dependências necessárias satisfeitas, documentação consultada e critérios verificáveis.
- **Em andamento:** trabalho iniciado; registrar descobertas, impedimentos e mudanças de escopo na issue.
- **Em revisão:** entrega concreta disponível, validações executadas e limitações descritas; revisão humana pendente quando aplicável.
- **Concluídas:** critérios de aceite verificados, documentação atualizada e pendências relevantes resolvidas ou transferidas explicitamente para outra issue.

O estado aberto/fechado da issue é oficial para conclusão. Enquanto não houver quadro, registrar mudanças de etapa relevantes na discussão da própria issue. Evitar manter várias implementações simultâneas sem necessidade.

## Decisões e validação

Antes de iniciar uma implementação, ler a issue, o GDD, AGENTS.md e os contratos existentes. Registrar dúvidas que mudem experiência, dificuldade ou regras.

Decisões importantes devem registrar: problema, opções, proposta, decisão do responsável e link da aprovação. Aprovar a criação de uma issue não aprova automaticamente as alternativas de design nela descritas.

Pontos de aprovação já identificados:

- #2: política aprovada nesta etapa — considerar todas as contraprovas existentes/aplicáveis, retirando apenas argumentos contestados, mesmo sem descoberta ou apresentação. Mudanças futuras dessa política exigem nova decisão.
- #5: ambientes, câmera/navegação, presença de personagens/corpo e eventual uso de ferramentas.
- #4 e #10: mudanças relevantes de dificuldade, orçamento de pistas ou regras de vitória.
- #6: verificar termos aplicáveis antes da incorporação de assets; compras continuam exigindo autorização própria.

Para encerrar uma tarefa, registrar o que mudou, testes realmente executados, documentação afetada, limitações e revisão humana quando pertinente. Para falhas procedurais, preservar seed, versão e dados de reprodução. Não confundir uma bateria de seeds válida com uma investigação interessante.

## Situação de partida e manutenção

A #1 contém a entrega inicial do núcleo e seu comentário de implementação. Permanece aberta até revisão dos critérios; este planejamento não a encerra nem presume que todo o escopo original foi aprovado.

A auditoria #3 tem relatório local em [docs/assets/psx-audit/README.md](assets/psx-audit/README.md), incluindo pendências. A [pesquisa de outros packs](assets/psx-audit/author-packs.md) é uma recomendação, não compra ou integração.

Este documento descreve a sequência, não é um espelho diário de progresso. Consultar as issues para o estado atual. Atualizar dependências aqui e nas issues quando o planejamento mudar.

Hotel completo, progressão roguelite, elenco animado, diálogos avançados e ferramentas forenses completas ficam fora deste marco. Abrir tarefas específicas após comprovar o primeiro ciclo investigativo.

A implementação atual da rede e distribuição lógica está descrita em [evidence-network.md](evidence-network.md). A #2 continua exigindo revisão de seus critérios completos: os operadores de sustentação ainda não foram integralmente migrados para dados, e a revisão humana dos casos permanece pendente.
