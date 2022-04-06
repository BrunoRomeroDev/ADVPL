#Include "protheus.ch"

User Function MA410COR()

Local aCores := {} // PARAMIXB traz a estrutura do array padrão

aAdd(aCores, {"Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ).And. C5_XPARCIA <> 'P'", "ENABLE", "Pedido em Aberto"})
aAdd(aCores, {"!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)", "DISABLE", "Pedido Encerrado"})
aAdd(aCores, {"!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)", "BR_AMARELO", "Pedido Liberado"})
aAdd(aCores, {"C5_BLQ == '1'", "BR_AZUL"})
aAdd(aCores, {"C5_BLQ == '2'", "BR_PRETO"})   
aAdd(aCores, {"Empty(C5_LIBEROK).And. Empty(C5_NOTA) .And. Empty(C5_BLQ).And. C5_XPARCIAL = 'P'", "BR_LARANJA", "Pedido Liberado Parcialmente"})

Return aCores
