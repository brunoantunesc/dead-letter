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

Um objeto examinado tem um único card que reúne suas observações descobertas. Novos achados físicos sobre o mesmo object_id atualizam esse card e sua leitura ampliada. Na acusação há uma única entrada por objeto, que apresenta em conjunto os achados descobertos. Documentos e relatos permanecem fontes separadas; mencionar uma faca em um documento não descobre a faca física.

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

Interface e conteúdo conhecido são traduzidos em PT/EN. Posições, IDs, marcações e textos escritos pelo jogador permanecem iguais ao trocar idioma. As anotações ficam somente no quadro; o campo separado da mesa foi removido.

Direção PSX reafirmada pelo responsável: paleta contida, fichas físicas, bordas duras, linhas sem suavização e tipografia de aspecto raster. A textura do suporte é desenhada por código, sem novo asset externo. Usa fontes monoespaçadas do sistema com alternativas por plataforma.

A leitura padrão usa controles de 20 px, conteúdo lateral de 20 px e títulos de cards de 22 px. O quadro começa em aproximação 1:1; localizar um card pelo seletor restaura no mínimo essa aproximação. Categorias usam 14 px nos cards e 16 px no painel. O painel lateral tem largura mínima de 360 px e as instruções ficam em uma linha separada dos botões. Os cards podem ficar pequenos ao afastar a visão geral; o conteúdo integral permanece em tamanho fixo no painel. Os vínculos visuais do catálogo continuam pendentes, sem imagens inventadas para as provas.

## Validação e limites

Cada card colocado possui um alfinete vermelho com haste metálica e sombra em pixels no topo. É decoração idêntica em todos os tipos de card, sem área de interação nem significado investigativo.

A interface usa o tamanho real da janela, sem esticar um canvas lógico fixo. Aumentar/maximizar a janela amplia a área útil do quadro; diminuir reduz essa área. Cards mantêm suas posições e a aproximação escolhida. O painel lateral preserva uma largura legível. `tests/board_resize.gd` verifica e renderiza a transição 1280×820 → 1600×1000 → 1280×820.

```sh
godot --headless --path . --script tests/board_tests.gd
godot --headless --path . --script tests/board_ui_smoke.gd
godot --path . --script tests/board_ui_smoke.gd
```

O teste renderizado gera `tests/results/board_pile.png` (início vazio), `board_evidence.png` e `board_connection.png`. A organização dessas capturas foi montada deliberadamente pelo teste como exemplo de ações do jogador; não é uma disposição automática do jogo.

As verificações cobrem identidades, conteúdo desconhecido, menções sem descoberta, múltiplas observações reunidas no mesmo objeto, arraste real por eventos de mouse com aproximação, marcações, notas, remoção, idioma, reabertura, reinício e preservação do veredito com hipóteses erradas. A revisão humana de gameplay/ergonomia permanece necessária e a issue fica aberta.

Nesta entrega, no Godot 4.6.2 instalado: 30 verificações do estado do quadro, 103 da cena renderizada, 2.048 de localização e 4.101 do núcleo em 101 seeds passaram, além do smoke test da mesa. As capturas em PT/EN foram inspecionadas visualmente. Não houve sessão humana completa de investigação.

Fechar/reabrir preserva estado na mesma sessão; repetir a seed como nova run cria outro quadro. Não há salvamento em disco, desfazer/refazer, fotos do mundo, filtros, editor da rede causal ou resolução automática de sobreposições. Posição e interpretação são estado lógico; câmera e aproximação pertencem à apresentação.

## Revisão de entrada dos cards

A pilha é separada da colocação manual (placed/was_placed). A sessão expõe visited_locations e known_characters; abrir o quadro sincroniza essas listas, sem usar a lista completa do gerador. A organização visual continua independente da verdade, da força probatória e da acusação.

A [revisão de gameplay](gameplay-feedback.md) retirou a autópsia das descobertas, adicionou vestígios por ambiente e registros de horário, mantendo a entrada progressiva dos cards.

## Identificação e leitura ampliada das pistas

Cards de provas e objetos exibem o local de descoberta e um nome curto traduzido (por exemplo, **Salão — Fibras**). Quando uma pista cita uma pessoa em seu campo próprio, o nome aparece em uma segunda linha para distinguir registros semelhantes. Os nomes curtos ficam na localização, separados do título completo; os 37 modelos são verificados em PT/EN contra a largura do card.

O ícone **+** no canto do card abre uma janela de leitura com local, título completo e descrição integral, com rolagem. Fechar retorna ao mesmo quadro sem mudar organização, descobertas ou hipóteses. A janela recebe apenas o conteúdo público já descoberto.

A lixeira é representada somente pelo ícone, sem texto, e fica fixa no canto inferior direito do canvas, independente da aproximação e navegação. Arrastar e soltar um card sobre ela devolve-o à pilha; o alvo acende durante o arraste. Não apaga descobertas, notas ou conexões. Recolocar o card restaura sua posição anterior ao arraste. Soltar fora da lixeira apenas move o card normalmente.

Os vestígios de cenário usam nomes curtos do detalhe observado (por exemplo, **Jardim — Sulcos** ou **Jardim — Lascas**), definidos em `observable_titles` no catálogo. O mesmo detalhe identifica a prova nas outras telas.
