# Validação consolidada — 01/11/2026

Godot 4.6.2 instalado neste computador. Todas as verificações abaixo passaram antes dos commits desta etapa. O GDD não foi alterado.

| Verificação | Resultado |
|---|---|
| `tests/run_tests.gd` | 4.101 verificações, 101 seeds |
| `tests/network_tests.gd` | 468 verificações |
| `tests/gameplay_feedback_tests.gd` | 1.095 verificações, 102 seeds |
| `tests/prose_variation_tests.gd` | 8.360 verificações, 100 seeds |
| `tests/conversation_tests.gd` | 3.760 verificações, 100 seeds; também renderizado |
| `tests/localization_tests.gd` | 2.048 verificações, PT/EN |
| `tests/catalog_tests.gd` | 82 verificações |
| `tests/board_tests.gd` | 30 verificações |
| `tests/verdict_feedback_tests.gd` | 24 verificações; também renderizado |
| `tests/trace_title_tests.gd` | 583 verificações, 100 seeds; também renderizado |
| `tests/board_ui_smoke.gd` | 103 verificações renderizadas |
| `tests/ui_smoke.gd` | Ciclo completo da mesa renderizado, zero falhas |
| `tests/board_resize.gd` | Redimensionamento do quadro e legibilidade da mesa, zero falhas |
| `tools/validate_catalog.gd` | 37 modelos, 37 referências visuais pendentes, 73 relações; zero erros |
| `tools/characterize_legacy.py` | 100 seeds do Python, snapshots reproduzíveis |

Os scripts de teste Godot podem ser executados com `godot --headless --path . --script caminho/do/teste.gd`. Para gerar capturas e validar desenho/interação real, executar sem `--headless`. Os testes renderizados devem ser executados um de cada vez para evitar interferência de foco e mouse entre janelas.

A inspeção via terminal também foi verificada: a seed 42 é solucionada adquirindo `sighting_0` pela conversa com Amadeu, junto às provas materiais, de motivação, método e horário. O terminal aceita `--visit`, `--talk` e `--ask`; `--inspect` continua impedido de adquirir depoimentos.

## Entrega consolidada

- Cinco possíveis ambientes do crime; autópsia indisponível e vestígios físicos separados dos registros de horário.
- Dois encontros concretos com a vítima, NPCs posicionados e primeiro recorte de conversas por trechos clicáveis sem destaque.
- Registro inicialmente ambíguo esclarecido com o participante relacionado, atualizando a mesma prova.
- Um card por objeto, com observações agrupadas e uma entrada no relatório.
- Quadro com alfinetes, pilha, lixeira que guarda cards, leitura ampliada, títulos curtos e redimensionamento.
- 58 corpos alternativos para 28 modelos, mais duas alternativas iniciais do registro, em PT/EN.
- Nomes de vestígios observáveis distintos para os 25 pares de ambiente e mecanismo.
- Diagnóstico pós-veredito com argumentos, lacunas, contestações e mínimos reais.
- Tipografia ampliada na mesa, conversas, relatório e quadro; rodapé da acusação acessível em janelas menores.

## Evidências e limites

Os relatórios JSON e as capturas estão em `tests/results`. As imagens de quadros com cards conectados usam organização deliberada do teste; o jogo continua iniciando o quadro vazio. A seed de legibilidade é fixa (995009), evitando imagens diferentes por mero sorteio no teste de janela.

As fixtures antigas de 914368 e 708272 permanecem preservadas para diagnóstico histórico. Não devem ser regravadas com o gerador atual. `network_witnesses.json` contém exemplos parciais das relações, não mundos completos.

As capturas foram conferidas ao longo da implementação. Os testes não certificam dificuldade, ritmo narrativo ou qualidade investigativa; continuam exigindo revisão humana. A mesa ainda não é o hotel 3D, os diálogos são um recorte pequeno e os vínculos visuais do catálogo permanecem pendentes. Fechar o jogo não salva o estado da sessão.

O ZIP local de assets permanece fora dos commits. Não houve incorporação de assets externos nesta etapa.
