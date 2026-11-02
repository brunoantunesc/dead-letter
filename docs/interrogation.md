# Conversas e esclarecimento de pistas — primeiro recorte

Aprovado pelo responsável: transferir pistas para interrogatórios, posicionar personagens em cômodos coerentes e permitir que uma conversa esclareça a ambiguidade de uma pista encontrada. GDD inalterado. Implementação em texto na mesa atual, sem NPCs 3D, pressão psicológica ou mentira dinâmica.

## Fluxo

Entrar num cômodo lista seus personagens presentes. Encontrá-los registra seus cards como disponíveis na pilha; conversar não coloca cards automaticamente no quadro. **Conversar com…** abre a fala inicial. Trechos da própria fala são clicáveis, na mesma cor e sem sublinhado. O jogador retoma o assunto mencionado em vez de escolher uma pergunta que já anuncia a pista. A instrução geral informa o gesto, sem marcar os trechos relevantes.

Os dois relatos de Amadeu sobre encontros com Vicente saíram da lista de objetos do cenário. Só perguntar ao porteiro adquire o depoimento. Repetir a pergunta não duplica a prova. A inspeção direta de um ID de depoimento é recusada.

O **Registro de utensílio** começa informando retirada, responsável, horário e a existência de marcas, sem explicar sua origem. Após descobri-lo, encontrar a pessoa responsável e mostrar o registro faz o interlocutor mencionar uma atividade anterior. Retomar o trecho dessa fala revela a explicação já estabelecida no acontecimento causal. Mostrar a prova não conclui o esclarecimento automaticamente. A explicação é anexada à mesma prova, atualizando leitura, card e entrada na acusação. Não cria outra prova, muda fatos ou atribui pontos extras pela conversa. O título inicial também evita entregar a atividade explicativa.

O esclarecimento resolve a dúvida sobre a origem das marcas; não confirma culpa, inocência ou relevância na interface. A explicação não é inventada na hora da conversa. A política já aprovada de considerar contraprovas existentes, mesmo não descobertas, permanece: conversar muda conhecimento, não a validade factual dos argumentos.

## Posições atuais

Snapshot após retirada do corpo, referência de horário 20h30 (`investigation_time` no snapshot), separado da cronologia anterior: gerente Ana na recepção coordenando atendimento; Amadeu no posto da recepção; Carlos na cozinha; hóspedes Bruno e Diana em áreas comuns (salão, restaurante ou jardim), escolhidas por um fluxo determinístico independente da culpa. Responsável pela remoção encerra o atendimento na recepção; Vicente está ausente. A autópsia continua indisponível.

Todos os personagens vivos têm local acessível. O validador verifica disponibilidade e tempo para chegar desde seus acontecimentos anteriores. Não há movimentação em tempo real. A posição atual não comprova um álibi passado.

## Contratos

`Investigation.characters_at`, `begin_conversation`, `conversation_topics`, `ask`, `related_proofs` e `present_proof` limitam o acesso ao cômodo atual e ao conhecimento factual do interlocutor. `dialogue` fornece fragmentos de fala com alvos autorizados; `introduce_proof` introduz um assunto a partir de uma prova já descoberta. Os fragmentos iniciais e suas chaves ficam em `core/conversation_content.gd`. O seletor de apresentação oferece todas as provas descobertas, sem filtrar pela relevância para aquele NPC; quando não há resposta escrita, a fala é neutra e não julga culpa ou validade. O NPC só responde a um depoimento cuja fonte seja ele e cujo evento conheça. Apenas o participante associado ao registro pode esclarecer seu uso. Não se pode apresentar prova não descoberta ou conversar remotamente depois de sair do local.

A sessão preserva quais registros foram esclarecidos separadamente do snapshot factual. A apresentação pública recebe `needs_clarification` e `clarified`; a verdade interna e os pesos não são enviados à interface. Texto usa chaves de localização PT/EN. Novas runs descartam conversas e esclarecimentos da anterior.

Snapshot esquema 6, gerador 0.7.0, conteúdo hotel_prose_1. A mesma seed preserva a solução e as observações do recorte anterior; muda sua forma de aquisição e acrescenta posições atuais.

## Limites e validação

Somente os dois relatos do porteiro e o esclarecimento do registro de utensílio estão escritos neste recorte. Outros NPCs podem ser abordados e apresentar suas falas iniciais, mas ainda não têm ramificações adicionais escritas. Ainda não há diálogos completos para todos, fotografias, respostas específicas para qualquer pista apresentada ou novos argumentos probatórios derivados de falas. A seleção de esclarecimentos ainda é restrita a esse tipo de registro; não é um editor genérico de diálogos.

`tests/conversation_tests.gd` cobre 100 seeds, acesso local, conhecimento, repetição, prova inicial ambígua, esclarecimento sem duplicação, preservação factual e trechos clicáveis da cena. Gera `tests/results/conversation.png` no modo renderizado. A revisão humana de clareza e gameplay continua necessária.

Validação desta versão: 3.760 verificações de conversas em 100 seeds; 4.101 do núcleo em 101 seeds; 468 da rede, 1.095 da regressão de gameplay, 1.496 de localização e 103 da interface do quadro, além do ciclo renderizado da mesa. As capturas de fala inicial, assunto introduzido por prova e esclarecimento foram inspecionadas.

O teste legado de exame clínico utiliza um snapshot posterior, às 21h40, para manter os eventos do laudo e deslocamentos anteriores ao início da investigação. Isso não disponibiliza autópsia na geração atual. O teste de arraste renderizado do quadro pode sofrer interferência dos eventos de mouse do desktop; a execução isolada final passou.

Respostas neutras têm quatro variações curtas em PT/EN. A escolha é reproduzível por seed, interlocutor e prova, independente da culpa e sem consumir o fluxo aleatório do gerador. Repetir a mesma apresentação mantém a resposta. Nenhuma variante introduz assunto ou julga a relevância da prova.

## Falas iniciais dos interlocutores

Todos os NPCs abordáveis possuem uma fala em primeira pessoa, localizada em PT/EN, em vez da descrição de sua posição. As aberturas são escritas por personagem e independentes da verdade do crime. Ana mantém o atendimento, Carlos fala do serviço da cozinha, Diana aguarda na área comum e o responsável pela remoção explica a indisponibilidade do laudo. Bruno prefere evitar comentários e explicita que aceita examinar um registro ou objeto apresentado. Essa reserva não indica culpa nem muda regras probatórias; a mesma abertura vale quando ele é inocente ou culpado. Amadeu preserva sua abertura com assuntos retomáveis no texto. Há uma fala neutra padrão para futuros interlocutores sem abertura específica.

[Variações de redação das provas](prose-variations.md): alternativas localizadas por Resource, escolhidas por seed sem alterar fatos ou avaliação.
