# Regressão de experiência: seed 914368

Relato do responsável: muitos documentos parecidos, grande volume de provas e conflitos financeiros repetidos; difícil distinguir hipóteses.

`seed_914368_v0_2_0.json` preserva o snapshot completo anterior às mudanças. `seed_914368_review.json` registra a transcrição pública, distribuição e auditoria daquela versão: 38 observações, 16 entradas de conflitos, mínimo de 9 itens para uma acusação suficiente. Esses arquivos são material de desenvolvimento e podem conter spoilers; não são consumidos pela interface.

Não regravar os arquivos com o gerador novo: a seed sozinha não reproduz um gerador antigo. O esquema anterior permanece como fixture histórica, não como save atual.

Direção aprovada para 0.3.0: 14–18 observações, duas linhas falsas distintas e menos sobreposição temática. Implementação atual: 15 observações; um conflito financeiro, um pessoal e um profissional, em três pessoas diferentes; um problema cotidiano sem relação com o crime. Uma linha alternativa vem de um conflito persistente de um inocente; outra vem de um objeto com origem independente documentada. Não há cartas e acompanhamentos separados repetindo esses mesmos fatos.

O teste inclui 914368 além de seeds 0–99. Verifica orçamento, diversidade, causas, preservação da verdade da seed relatada e duas formas de sustentar a acusação com 5 ou 6 itens. Isso evita regressões mensuráveis; não certifica dificuldade ou qualidade da experiência.

## Catálogo e rede

- evidence_catalog_v1.json: referência histórica das 25 apresentações anteriores à migração para Resources; não é fonte de produção.
- catalog_visual_mesh.tres: BoxMesh próprio para validar vínculo visual preenchido.
- network_witnesses.json: exemplos parciais de aplicabilidade das 73 relações, com contexto e explicação. Não equivalem a 73 mundos completos validados; testes de casos completos estão em network_tests.gd.

- seed_708272_v0_5_0.json: snapshot original do relato do jogador, com cinco provas que reproduzem autoria 2, motivo 2 e método 0. Não é um save compatível com o conteúdo 0.6.0.
