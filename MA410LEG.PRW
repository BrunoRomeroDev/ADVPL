#INCLUDE "TOTVS.CH"

User Function MA410LEG()
    Local aLeg := PARAMIXB

    aLeg := {   {'ENABLE' ,"Pedido de Venda em aberto"},;
                {'DISABLE' ,"Pedido de Venda encerrado"},;
                {'BR_AMARELO',"Pedido de Venda liberado" },;  
                {'BR_AZUL' ,"Pedido de Venda com Bloqueio de Regra"},;
                {'BR_LARANJA',"Pedido de Venda Liberado Parcialmente" }}

Return aLeg
