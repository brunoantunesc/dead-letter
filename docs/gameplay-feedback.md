# Revisão de gameplay — 31/10/2026

Direção aprovada pelo responsável após jogar a seed **708272**: notas somente no quadro; relatos concretos em vez de proximidade genérica; autópsia indisponível; informações distribuídas pela cena; local do crime variável dentro da planta fixa.

## Regressão preservada

`tests/fixtures/seed_708272_v0_5_0.json` guarda o caso anterior. As cinco provas informadas foram livro de atividades, vestígios na camisa, laudo, bilhete e fichas de roupas. Reproduzem autoria 2, motivo 2, método 0.

A regra antiga de método exigia o laudo junto de um objeto. A autoria ainda precisava de um relato adicional. A sugestão de aceitar automaticamente a convergência sem relato não foi adotada: o responsável preferiu relatos realmente informativos. Os limiares permanecem autoria 3, motivo 2, método 2, total 7.

Na reprodução anterior, a ocorrência da manhã explica a **corda**. Há um registro separado de retirada da **pistola** por Ana. A nova geração remove esse uso cotidiano da arma verdadeira e torna os títulos das ocorrências mais específicos para reduzir confusões.

## Autópsia pendente

O caso começa com a informação pública de onde Vicente foi encontrado. O corpo foi recolhido e a autópsia ainda não está disponível. Não há card de laudo, evento de exame concluído ou diagnóstico médico público nos casos gerados.

As antigas definições médicas continuam no catálogo e em testes autorais da rede; não são sorteadas nesta fase. Isso não habilita autópsia no jogo.

As funções antes concentradas no laudo foram separadas:

- **Registro do encontro do corpo:** horários de um atendimento em que Vicente respondeu e do encontro sem vida. A origem é um registro de serviço, sem estimativa médica. Seus acontecimentos e fontes são validados.
- **Vestígios ambientais:** marcas observáveis e consequências físicas específicas do ambiente. Permitem interpretar um mecanismo compatível; não identificam uma arma individual nem apresentam uma conclusão médica.

O método pode ser sustentado pela evidência física pertinente sem anexar obrigatoriamente o objeto usado no crime. Relatos cotidianos não sustentam oportunidade por si sós.

## Relatos e autoria

Há dois relatos públicos de contato concreto com Vicente, próximos da janela delimitada pelo registro. Um envolve o culpado e outro um inocente; as ações são distribuídas independentemente da culpa. Não há testemunha ocular do assassinato.

O porteiro presenciou uma conversa e uma entrega, em um acontecimento compartilhado. Pessoas presentes, horários, local e conhecimento da fonte são rastreáveis. Outros acontecimentos cotidianos podem existir no mundo sem gerar relatos redundantes.

Para pontuar oportunidade, o relato precisa de contato explícito com a vítima e proximidade temporal configurada em minutos. Álibis aplicáveis podem contestar a interpretação. Identificação material, motivação e método continuam exigindo sustentação própria; o relato isolado não soluciona o caso.

## Cinco ambientes de crime

A planta e as rotas não mudam. Um fluxo de seed separado escolhe entre salão, cozinha, jardim, depósito e lavanderia, respeitando acessibilidade e cobertura do método no perfil.

`core/catalog/crime_scene_profile.gd` e `data/catalog/scenes/*.tres` guardam o conteúdo por ambiente. `core/crime_scenes.gd` seleciona perfis e resolve assinaturas. Cada ambiente possui cinco consequências específicas: 25 descrições observáveis, não apenas troca do nome da sala. Exemplos incluem perfuração em vaso de barro no jardim, em chapa junto ao passe da cozinha ou em divisória do depósito.

As consequências são registradas nos efeitos do acontecimento e não posicionadas arbitrariamente. Vestígios ficam no local de origem. Atividades dos inocentes evitam o local do crime, sem viagens ou sobreposições impossíveis. A retirada do objeto após o crime também respeita os trajetos.

Uma ocorrência independente pode deixar uma marca em outro ambiente ou na própria sala do crime. A explicação compartilha a origem causal e a instância do objeto com essa marca, contestando sua interpretação como mecanismo do assassinato.

Na geração atual, as explicações de uso independente se referem apenas ao desvio, nunca à arma verdadeira. Essa restrição do recorte é validada; não é uma regra de que usos legítimos seriam impossíveis no mundo em geral.

## Quantidade e validação

Os casos têm **15–16 observações**, dentro do orçamento aprovado de 14–18. A remoção de dois relatos redundantes e do registro cotidiano da arma verdadeira abriu espaço para separar horário e cena.

Há uma rota suficiente com **cinco provas**, sem exigir encontrar tudo nem anexar a arma: contato recente, horários, mecanismo na cena, motivação e reconstrução dos álibis. A rota por identificação material usa seis. Textos e relações não são classificados como relevantes na interface, e conexões do quadro não são lidas pelo avaliador.

Esquema de snapshot 5; gerador **0.6.0**, conteúdo **hotel_feedback_1**. A seed 708272 preserva Diana/ciúme/disparo como solução factual, mas as observações mudaram. Conteúdo antigo não é aceito silenciosamente pelo validador atual; o arquivo histórico permite reproduzir o diagnóstico anterior.

Testes:

```sh
godot --headless --path . --script tests/gameplay_feedback_tests.gd
godot --headless --path . --script tests/run_tests.gd
godot --headless --path . --script tests/network_tests.gd
godot --headless --path . --script tests/localization_tests.gd
godot --path . --script tests/ui_smoke.gd
godot --path . --script tests/board_ui_smoke.gd
```

`tests/results/gameplay_feedback.json` registra 102 seeds e exemplos para revisão: **0 salão, 1 lavanderia, 4 depósito, 9 cozinha, 14 jardim**. Não é preciso consultar a verdade antes de jogar.

## Limites

Esta é variação lógica e textual na mesa de teste; móveis, vestígios 3D e ferramentas não foram materializados. Os perfis ainda são autorais e o vocabulário de assinaturas é limitado. Ampliar métodos com sinais ambíguos exige outras combinações probatórias; o resolvedor não escolhe silenciosamente um método quando a assinatura tem mais de uma correspondência.

A validação automática verifica propriedades explícitas, não certifica dificuldade ou justiça da dedução humana. A revisão de gameplay continua necessária. Nenhum limiar foi reduzido, nenhuma conexão automática foi criada e o GDD não foi reescrito.

Resultado da verificação: 1.095 checks específicos em 102 seeds, 4.101 do núcleo em 101 seeds, 468 da rede, 79 do catálogo e 1.208 de localização, sem falhas. Mesa e quadro também passaram pelos fluxos renderizados. Ainda é necessária revisão humana dos novos casos.
