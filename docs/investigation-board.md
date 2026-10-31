# Quadro livre de investigação

Primeira versão da [issue #9](https://github.com/brunoantunesc/dead-letter/issues/9), antecipada por aprovação do responsável para testar as provas na mesa atual. A exploração 3D da #7 não é pré-requisito desta entrega. O GDD não foi modificado.

## Uso

Executar a cena principal, abrir uma seed, examinar elementos e clicar em **Abrir quadro**. O canvas começa vazio; as fichas conhecidas ficam na pilha lateral. Selecionar uma ficha e clicar em **Colocar no quadro** para posicioná-la manualmente.

- Arrastar um card muda sua posição; sobreposições são permitidas.
- Arrastar o fundo ou usar o botão central desloca a visão; a roda aproxima/afasta em torno do cursor.
- **Ver todos** enquadra o conjunto dentro dos limites de aproximação, sem reorganizar cards. Quadros muito espalhados podem exigir navegação adicional.
- Selecionar um card mostra seu conteúdo integral no painel lateral. O seletor também permite localizá-lo e centralizá-lo com aproximação legível.
- **Conectar cards** inicia a escolha manual de duas pontas. Clicar novamente no botão ou pressionar Escape cancela.
- Selecionar uma conexão pela linha ou pelo seletor permite editar marcação/texto ou removê-la.
- Marcações: sem símbolo, **?** (dúvida), **X** (descartada pelo jogador). A legenda no quadro pode ser abreviada; o texto integral permanece no painel.
- **Nova anotação** cria um card no centro da visão. Editar no painel, mover e conectar como os demais. Excluir a nota remove suas conexões.
- **Voltar à investigação** ou Escape fecha o quadro; reabrir preserva a organização.

Há uma conexão sem direção por par; selecionar o par novamente abre a existente. Não há conexão de um card consigo mesmo. **Guardar na pilha** retira um card do canvas, preservando posição, nota e ligações. As conexões ficam ocultas enquanto uma ponta estiver na pilha e reaparecem ao recolocar os cards. Remover uma nota, ao contrário, exclui suas ligações.

## Identidade e conhecimento

| Card | Entrada | Referência |
|---|---|---|
| Pessoa | Menção ou conversa registrada | ID da pessoa |
| Cômodo | Visita registrada | ID do local |
| Prova | Observação descoberta | ID da observação |
| Objeto | Objeto físico examinado | ID da instância do objeto |
| Anotação | Criação do jogador | ID próprio do quadro |

A planta e a lista de suspeitos da mesa de desenvolvimento não alimentam automaticamente o quadro. Só entram cômodos visitados e personagens citados por descobertas/depoimentos ou registrados por conversa. A entrada inicial da investigação conta como visitada; a vítima, nomeada na apresentação do caso, conta como mencionada. No início há somente as fichas da recepção e de Vicente na pilha, sem nenhum card no canvas.

Inspecionar um elemento registra a visita ao seu local e as pessoas explicitamente citadas em suas propriedades/linhas. A fonte de um relato ou laudo também conta como menção. Isso não cria conversas ou interrogatórios; record_conversation é o ponto de integração para esse sistema futuro.

Uma observação e o objeto examinado possuem cards separados. Várias observações podem apontar para o mesmo objeto, sem duplicá-lo. Mencionar uma faca em um documento não descobre a faca física.

O rótulo **OBJETO** não identifica uma arma verdadeira. Cards novos ficam na pilha até serem colocados; sincronizar conhecimento não move nem coloca cards. Nenhuma conexão é criada automaticamente, inclusive entre objeto e observação.

## Estado e arquitetura

- `core/investigation_board.gd`: cards, posições, notas e conexões; não importa gerador, avaliador, catálogo ou rede causal.
- `core/investigation.gd`: possui o quadro por sessão, separado do snapshot factual, das descobertas e das anotações gerais.
- `ui/investigation_board.gd`: recebe cópias das APIs públicas, resolve traduções e edita o estado do jogador.
- `ui/board_canvas.gd`: arraste, navegação, aproximação e desenho.
- `ui/main.gd`: integra a mesa ao quadro e cria outra sessão a cada run.

IDs usam namespaces `person:`, `room:`, `evidence:`, `object:` e `note:`. Redescobertas não duplicam entidades. O estado pertence à sessão e pode ser reaproveitado por outra apresentação.

Notas e conexões não são lidas pelo avaliador. Um X não invalida prova, uma ligação não demonstra autoria e o quadro não escolhe anexos do relatório. A acusação continua usando a seleção explícita existente na mesa. Hipóteses erradas são aceitas sem correção.

## Idioma e estética

Interface e conteúdo conhecido são traduzidos em PT/EN. Posições, IDs, marcações e textos escritos pelo jogador permanecem iguais ao trocar idioma. Anotações gerais da mesa continuam separadas; não são copiadas nem traduzidas automaticamente como cards.

Direção PSX reafirmada pelo responsável: paleta contida, fichas físicas, bordas duras, linhas sem suavização e tipografia de aspecto raster. A textura do suporte é desenhada por código, sem novo asset externo. Usa fontes monoespaçadas do sistema com alternativas por plataforma.

Os cards podem ficar pequenos na visão geral; o conteúdo integral permanece em tamanho fixo no painel. Os vínculos visuais do catálogo continuam pendentes, sem imagens inventadas para as provas.

## Validação e limites

```sh
godot --headless --path . --script tests/board_tests.gd
godot --headless --path . --script tests/board_ui_smoke.gd
godot --path . --script tests/board_ui_smoke.gd
```

O teste renderizado gera `tests/results/board_pile.png` (início vazio), `board_evidence.png` e `board_connection.png`. A organização dessas capturas foi montada deliberadamente pelo teste como exemplo de ações do jogador; não é uma disposição automática do jogo.

As verificações cobrem identidades, conteúdo desconhecido, menções sem descoberta, múltiplas observações por objeto, arraste real por eventos de mouse com aproximação, marcações, notas, remoção, idioma, reabertura, reinício e preservação do veredito com hipóteses erradas. A revisão humana de gameplay/ergonomia permanece necessária e a issue fica aberta.

Nesta entrega, no Godot 4.6.2 instalado: 30 verificações do estado do quadro, 22 da cena renderizada, 1.018 de localização e 4.236 do núcleo em 101 seeds passaram, além do smoke test da mesa. As capturas em PT/EN foram inspecionadas visualmente. Não houve sessão humana completa de investigação.

Fechar/reabrir preserva estado na mesma sessão; repetir a seed como nova run cria outro quadro. Não há salvamento em disco, desfazer/refazer, fotos do mundo, filtros, editor da rede causal ou resolução automática de sobreposições. Posição e interpretação são estado lógico; câmera e aproximação pertencem à apresentação.

## Revisão de entrada dos cards

A pilha é separada da colocação manual (placed/was_placed). A sessão expõe visited_locations e known_characters; abrir o quadro sincroniza essas listas, sem usar a lista completa do gerador. A organização visual continua independente da verdade, da força probatória e da acusação.
