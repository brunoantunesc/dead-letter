# Variações de redação das provas

Aprovado: variar a escrita de uma mesma informação para reduzir repetição, sem gerar novos fatos ou mudar sua força probatória. O GDD permanece inalterado.

## Conteúdo

28 modelos possuem alternativas: os dois encontros narrados por Amadeu, fibras, roupas, atividades, horários, cinco objetos, cinco explicações de uso, seis estados de conflitos, pedido de quarto e registros contextuais de atendimento, limpeza, empréstimo, retirada e reparo.

Cada encontro com Vicente possui quatro redações; os outros 26 modelos cobertos possuem três. São **58 corpos alternativos**, além dos textos-base. O registro inicialmente ambíguo de uso de utensílio também ganhou **duas alternativas de apresentação inicial**. Tudo possui tradução PT/EN. Títulos curtos e IDs permanecem estáveis.

Não se trata de trocar palavras aleatoriamente: as frases foram escritas integralmente. Ordem das informações, construção e ritmo podem variar. Pessoa, local, horário, observações, limitações do depoimento e situação de documentos precisam permanecer equivalentes. Uma versão não pode tornar a testemunha mais segura, sugerir culpa, acrescentar acontecimentos ou omitir a ressalva de que ela saiu para outro atendimento.

As cinco famílias de vestígios de cenário mantêm as 25 descrições físicas por ambiente/método já existentes. Seus textos físicos não ganharam alternativas nesta etapa. Os dois relatos não emitidos e os modelos clínicos legados também ficam fora deste lote.

## Autoria e contratos

`EvidenceDefinition.text_variants` lista chaves alternativas ao `text_key` original nos Resources de `data/catalog/definitions`. `initial_text_variants` lista alternativas da apresentação inicial nos cinco registros que precisam de esclarecimento. O CSV contém apenas o texto localizado; não replica regras, IDs de provas ou relações causais.

A sessão fornece `prose_index`, calculado somente a partir da seed e do ID da observação. A apresentação escolhe entre o texto-base e suas alternativas usando esse índice. Não consulta culpa, pontuação, descoberta de contraprovas ou idioma, nem consome o gerador aleatório da simulação. A mesma observação mantém sua redação entre leitura, quadro, acusação e reabertura na mesma seed. Observações sem índice (ferramentas e fixtures antigas) usam o texto-base.

Esquema 6 e gerador 0.7.0 permanecem; a versão de conteúdo passa a **hotel_prose_1**. A seed continua produzindo os mesmos fatos e argumentos. Não houve mudança de limiares ou dificuldade.

Para adicionar alternativas:

1. Escrever versões completas do corpo, mantendo todos os fatos e ressalvas do original.
2. Usar exatamente os mesmos parâmetros nomeados do texto-base e fornecer PT/EN.
3. Registrar as chaves no Resource correspondente, sem repetir a chave-base ou outra alternativa.
4. Executar os testes de catálogo, localização e variações; revisar semanticamente os textos. Parâmetros corretos não garantem, sozinhos, equivalência de significado.

## Validação

`tests/prose_variation_tests.gd`: 8.360 verificações em 100 seeds. Cobre reprodução, renderização PT/EN, preservação de pessoa/local/horário nos relatos, ausência de parâmetros pendentes, igualdade dos parâmetros entre versões e ausência de mutação factual. As quatro versões de cada relato foram selecionadas ao longo do conjunto de seeds.

Os testes de localização verificam também todas as novas chaves. O ciclo da mesa e as conversas são conferidos na cena renderizada. A revisão humana do ritmo das falas durante partidas continua necessária.
