# Auditoria do pack PSX — primeira entrega

**Data:** 30/10/2026 · **Issue:** [#3](https://github.com/brunoantunesc/dead-letter/issues/3) · **Godot:** 4.6.2.

O pacote oferece uma base útil de interiores, móveis e objetos. As lacunas de maior impacto são **a identidade de hotel brasileiro de luxo, os suportes legíveis da investigação e a representação de corpo/roupas**. Grande parte da aparência atual remete a espaços residenciais ou industriais gastos; a adaptação visual deve preservar luxo e decadência localizada.

Foram inventariados todos os arquivos e os 489 GLBs. **73 amostras foram importadas e renderizadas no Godot**, com seus materiais originais, sem falhas de importação. O trabalho ocorreu em um projeto temporário, sem inserir os assets no jogo, alterar o GDD ou criar o hotel.

A licença aplicável à compra do Mega Pack permanece por confirmar. Esta é uma avaliação técnica/artística local, não uma aprovação de incorporação ou publicação dos arquivos-fonte.

## 1. O que existe de fato

Arquivo analisado: `Texturas PSX.zip`, 276.777.183 bytes (~264 MiB).

SHA256: `f6f464da268b7831bd649f77c39f0b512b0877726c1bfead0ead7318ba1e3a0c`.

| Conteúdo | Quantidade | Observação |
|---|---:|---|
| GLBs do Mega Pack | 489 | Base principal do inventário de modelos |
| FBX / OBJ / DAE | 489 de cada | Exportações correspondentes; não representam mais 1.467 modelos distintos |
| Grupos de assinatura geométrica | 387 | Agrupamento conservador de atributos/índices/transforms; não equivale a contar famílias artísticas |
| Imagens de textura | 389 caminhos / 363 hashes únicos | Há arquivos idênticos; não remover variações só pelo nome |
| Previews fornecidos | 10 | Separados das texturas do inventário |
| Conjunto de papéis | 1 glTF + buffer + 3 mapas | Uma malha reúne folhas e pilhas |
| Arquivo Blender | 1 | Não foi aberto nesta auditoria |
| GLBs com animações / skins | 0 / 0 | Nenhum rig ou animação no conjunto exportado analisado |

Os previews internos citam versões 2.9 e 3.1, mas não há um manifesto que permita afirmar uma versão única do ZIP. A página pública candidata já oferece outra versão. O hash acima identifica o conteúdo efetivamente testado, sem extrapolar os resultados ao pack atual do vendedor.

### Categorias dos GLBs

| Categoria | Arquivos |
|---|---:|
| Furniture | 123 |
| Items & Weapons | 116 |
| Modular Structures | 96 |
| Small Props | 44 |
| Electronics & Misc | 38 |
| Lighting | 36 |
| Large Props | 32 |
| Decals | 4 |

A mediana é de 216 triângulos por GLB. O maior é `tunnel_1`, com 18.074. Isso indica geometria geralmente leve, mas **não constitui benchmark de FPS ou memória**. Nenhuma primitiva dos GLBs ficou sem UV0 na leitura estrutural. Há 31 materiais BLEND e 3 MASK no inventário; transparências precisam de revisão por contexto.

Detalhes completos: [inventário](inventory.json), [manifesto das amostras](sample_manifest.json), [classificação individual das 73 amostras](sample_assessment.json).

## 2. Seleção visual observada

Cada folha mostra o ID do arquivo e suas dimensões importadas. O enquadramento é normalizado para comparação: uma chave aparece grande na miniatura, mas sua medida real continua indicada. Unidades são as importadas pelo glTF/Godot, tratadas como metros nesta avaliação; não se deve normalizar a escala de produção pelas miniaturas.

| Folha | Exemplos e leitura |
|---|---|
| [Móveis](previews/furniture.png) | Sofás, cadeiras, mesas, vitrines e armários aproveitáveis. As camas e o acabamento predominante são mais simples que o hotel pretendido. |
| [Estruturas](previews/structures.png) | Paredes, portas, pisos, arcos e elevador formam base modular; acabamento e transições ainda exigem direção própria. |
| [Objetos investigativos](previews/investigation_props.png) | Chave, faca, caderno, fita, relógio e garrafas funcionam como objetos reconhecíveis. Letras impressas nos livros não oferecem o conteúdo de uma prova jogável. |
| [Eletrônicos](previews/electronics.png) | CRT, rádio e botões têm potencial de adaptação. Interfaces de computador, celulares e placas reconhecíveis puxam para uma época específica. |
| [Iluminação e materiais](previews/lighting_materials.png) | Há luminárias, tapete, quadro e varão. O varão não traz uma cortina; brilho desenhado não ilumina a cena sozinho. |
| [Serviço](previews/service.png) | Caixas, tubulação, embalagens e ferramentas ajudam áreas de manutenção. Sanitários muito sujos não representam automaticamente os banheiros de hóspedes. |
| [Papéis](previews/paper_set.png) | A forma de folhas/pilhas existe, mas a apresentação e a escala precisam de preparação; o atlas contém texto decorativo pré-impresso. |

As classificações “reutilizar como base”, “adaptar” e “evitar no recorte” são avaliações de adequação, condicionadas à licença. Não significam aprovação artística definitiva. “Evitar no recorte” não declara que um objeto jamais possa existir no mundo do jogo.

## 3. Resultados técnicos no Godot

- **73/73 amostras carregadas e renderizadas**, sendo 72 GLBs e o glTF dos papéis. O relatório de importação está em [godot_report.json](previews/godot_report.json).
- **Escala:** sofá `sofa_1` com 2,60 m de largura; `chair_mp_3` com ~1 m de altura; chave `key_mp_1` com ~7,35 cm de comprimento. São proporções utilizáveis como base. Módulos têm medidas externas diferentes: parede ~4,09 m e piso ~4,04 m; arcos selecionados têm 3 m. Isso não prova defeito de encaixe, mas impede adotar todo AABB como um único grid sem teste de montagem.
- **Orientação:** a amostra ficou reconhecível sem correção global de eixos. Portas e armários têm partes filhas separadas em exemplos testados. Não foram ensaiados todos os pivôs de abertura nem combinações de módulos.
- **Materiais:** 144 referências de material na amostra usam nearest com mipmaps e 5 usam linear com mipmaps. O Mega Pack já traz filtragem que preserva pixels em grande parte dos exemplos. Redimensionar tudo para 64×64 não é uma solução geral.
- **Texturas:** as imagens do Mega Pack chegam a 930 pixels em uma dimensão; os três mapas dos papéis são 2048×2048. Há dimensões não potências de dois e atlas diferentes. O material PBR dos papéis precisa harmonização com o restante, sobretudo sob luz forte.
- **Luzes:** nenhum Light3D veio nos 73 modelos. Alguns materiais emitem e há geometrias de luz falsa. Criar e testar iluminação ambiente, fontes, contraste e eventuais sombras é trabalho de integração/renderização.
- **Colisões:** nenhum CollisionObject3D veio na amostra carregada por GLTFDocument. Colisores, áreas de clique e regras de interação precisam ser preparados no pipeline; não são um asset visual ausente.
- **Legibilidade:** o caderno e os livros usam escrita como textura; o atlas dos papéis não tem o conteúdo localizado do jogo. Para nomes, horários, assinaturas e números probatórios, separar a aparência do objeto do texto gerado a partir dos IDs e da língua selecionada.
- **Papéis:** o conjunto ocupa ~24,02 × 1,89 × 22,58 unidades e chega como uma única malha. Não deve ser colocado como se fosse uma folha A4 pronta. Separação e calibração de escala são necessárias. O enquadramento do conjunto não comprova a legibilidade de cada documento.

Não há shader PSX do jogo neste teste, nem benchmark, navegação, interação ou cenário de hotel montado. A renderização padronizada avalia os assets, não valida a atmosfera final do gameplay.

## 4. Cobertura do primeiro recorte do hotel

| Necessidade | Cobertura observada | Reaproveitamento e lacuna |
|---|---|---|
| Recepção | Parcial | Mesas, cadeiras, relógios, chaves e botões existem. Não localizei balcão de recepção, quadro de chaves, campainha ou mobiliário administrativo específico nos exports. |
| Salão e quarto | Parcial | Sofás, mesas, armários e camas. Falta um conjunto coerente de acabamento/têxteis que comunique sofisticação. |
| Circulação | Boa base geométrica | Portas, arcos, escadas, elevador, janelas e paredes. Confirmar encaixes, vãos, materiais e iluminação antes de um layout inteiro. |
| Cozinha e serviço | Parcial | Caixas, faca, pratos e utensílios pontuais. Não localizei pia, fogão, equipamentos de copa e mobiliário de cozinha completo. |
| Documentos/registros | Forma parcial; conteúdo ausente | Caderno, livros e papéis. Precisam de formulários, identidade do hotel e texto localizado legível. |
| Suportes das provas atuais | Parcial | Faca, pistola e chaves existem. Não localizei corda, casacos, vestígios de sangue/impressões/fibras ou estados probatórios prontos. Frascos genéricos exigem adaptação à função. |
| Corpo e pessoas | Ausente no conjunto exportado | Sem personagens/cadáveres identificados, rigs ou animações. Visibilidade e comportamento dos NPCs continuam decisão aberta do GDD; não assumir um elenco 3D completo como requisito imediato. |
| Equipamentos analógicos | Parcial | Rádio, fita, relógios e CRTs. Não localizei telefone de mesa, máquina de escrever ou equipamento investigativo analógico específico. |
| Identidade brasileira | Muito limitada | A amostra traz “ELEVATOR”, notas em dólar, embalagens e interfaces externas ao contexto. São necessários sinais, registros e objetos com história local. Um dólar pode existir por contexto; não deve ser a única linguagem financeira disponível. |
| Luxo e decadência | Precisa de seleção/adaptação | Tapete, vitrine e madeira ajudam. Predominam acabamentos comuns/desgastados; faltam peças de assinatura e variação de estados conservados/usados/danificados. |
| Exterior/jardim | Sem cobertura relevante identificada | Não localizei vegetação, paisagismo ou fachada de hotel. Adiar se o primeiro recorte for interno. |

“Ausente/não localizado” refere-se ao inventário dos GLBs, glTF dos papéis e seleção visual. Outros formatos correspondentes e o arquivo Blender não foram examinados como fontes de conteúdo adicional. Não deduzir ausência somente pela quantidade de arquivos ou pelos anúncios de versões mais novas.

## 5. Faltas mais gritantes e prioridade

Esforço é comparativo, não orçamento de horas: **baixo** = seleção/material/texto simples; **médio** = pequenas peças próprias, composição ou preparação de estados; **alto** = personagens/rigs ou um conjunto arquitetônico de grande alcance.

| Prioridade | Falta | Impacto | Ação proposta | Esforço |
|---|---|---|---|---|
| P0 — primeiro recorte 3D | Documentos e vestígios legíveis | A investigação depende de distinguir o que foi observado. Textura borrada não pode carregar um horário ou assinatura decisiva. | Preparar um documento, um registro e um objeto com estados observáveis, usando IDs/localização já existentes; reaproveitar só a forma física dos papéis/caderno. | Médio |
| P0 — primeiro recorte 3D | Corpo/roupa de referência para o crime | O pack não supre os elementos humanos/material de comparação usados pelo núcleo. | Definir um proxy estático para o teste visual e a necessidade real de roupa/corpo inspecionável antes de encomendar um elenco. | Médio; elenco animado é alto |
| P0 — identidade do cenário | Recepção reconhecível como hotel brasileiro | Um conjunto genérico de móveis tende a comunicar apartamento ou depósito. | Usar mesas/armários como base, acrescentando um pequeno kit de balcão, registro, quadro de chaves e sinalização; submeter a linguagem visual ao responsável. | Médio |
| P1 | Acabamento de luxo com desgaste localizado | Sem hierarquia de conservação, tudo parece igualmente abandonado. | Selecionar madeira, metal, piso e estofado; criar poucos estados coerentes e uma peça de assinatura, em vez de substituir o pack inteiro. | Baixo a médio |
| P1 | Equipamento analógico e identidade gráfica | Celular/desktop moderno e placa inglesa enfraquecem a linguagem material estabelecida. | Priorizar telefone de mesa, registro físico e painéis; adaptar telas/placas dos existentes. A seleção definitiva de ferramentas exige decisão de design. | Médio |
| P1/P2 conforme a sala | Copa/cozinha e utensílios de serviço | Há poucos elementos para ler um ambiente de hotel em funcionamento. | Completar somente o ambiente escolhido; não construir toda a cozinha para um teste de recepção/salão. | Médio |
| P2 | Fachada, jardim, vegetação e grande elenco | Não bloqueiam uma primeira amostra interna. | Planejar depois de aprovar um enquadramento interno e decidir presença/comportamento dos NPCs. | Alto |

Antes de comprar outro pack, vale testar um **único enquadramento de recepção ou salão** com a base disponível, uma peça de assinatura e um documento inspecionável. Isso permite aprovar a linguagem material e a legibilidade. É recomendação para a próxima etapa, não uma cena criada nesta auditoria.

## 6. Origem e permissões

### Papéis

O `license.txt` e `asset.extras` do glTF identificam **Marim_Studio**, o [modelo de origem](https://sketchfab.com/3d-models/low-poly-papers-set-2edf57ce2e6c4475bd4897b9c91b0a77) e **CC BY 4.0**. A licença requer atribuição; o crédito deve preservar autor, origem/licença e indicar alterações, conforme o [resumo oficial](https://creativecommons.org/licenses/by/4.0/). O acesso web ao modelo retornou 403, mas os dois registros locais concordam. Não estender essa licença ao Mega Pack.

Crédito base fornecido pelo arquivo: Low-poly Papers Set, por Marim_Studio, via Sketchfab, CC BY 4.0. Acrescentar indicação das adaptações efetivamente feitas quando houver.

### Mega Pack

A [página de Pizza Doggy](https://pizzadoggy.itch.io/psx-mega-pack) corresponde aos previews e categorias fornecidos; a origem da compra ainda não foi confirmada por recibo/link. O usuário informou compra no itch.io.

O contrato público obtido em 30/10/2026, datado de 01/09/2026, permite jogos comerciais e adaptações sob condições; restringe redistribuição de fontes reutilizáveis e usos ligados a IA. A seção 12 associa a licença à data de obtenção. **Confirmar a versão aplicável à compra antes da integração e de criação/adaptação assistida por IA.** Não tratar a compra como licença irrestrita.

PDF consultado: `License Agreement.pdf`, em Downloads; SHA256 `22e90e1ca9e2f01d0a6917eb867ba74613dd958ed7ff6405ef5c5ea6337d27f4`. Evidências e pendências em [license_review.json](license_review.json). Não foram publicados o ZIP ou arquivos-fonte do pack.

## 7. Reprodução e estado da entrega

A partir da raiz do projeto, com o ZIP local disponível:

```sh
python3 tools/asset_inventory.py
cp tools/asset_audit_project.godot /tmp/dead-letter-asset-audit/project.godot
```

Executar o Godot instalado com o projeto temporário:

```sh
godot --path /tmp/dead-letter-asset-audit --script "$PWD/tools/render_asset_audit.gd" -- "$PWD/docs/assets/psx-audit/sample_manifest.json" "$PWD/docs/assets/psx-audit/previews"
```

O inventário usa Python padrão, sem instalar dependências. O renderizador usa o Godot instalado. Os modelos extraídos ficam em `/tmp/dead-letter-asset-audit/source`, fora do projeto de produção. A documentação mantém caminhos do ZIP, hashes e relatórios; não copia fontes de terceiros para o jogo.

**Entregue:** inventário, deduplicação conservadora, 73 renderizações agrupadas em sete folhas, resultados técnicos, classificação das amostras, matriz de cobertura e prioridades. **Pendente:** confirmação da licença/versão da compra do Mega Pack e revisão das escolhas artísticas pelo responsável. Não houve alteração de gameplay, GDD, assets de produção, commit ou encerramento da issue.
