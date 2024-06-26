USE [easycollector]
GO

/****** Object:  View [dbo].[vw_FATACORDO]    Script Date: 22/03/2024 17:53:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_FATACORDO] AS

SELECT	C.ID_CEDENTE,
		A.ID_CLIENTE, 
		B.ID_FATURA, 
		A.ID_ACORDO,
		A.ID_USUARIO,
		B.ID_ASSESSORIA,
		F.ID_PRODUTO,
		B.NU_PARCELA,
		A.NU_PLANO,
		B.TP_FATURA,
		B.TP_STATUS,
		CASE	WHEN B.TP_FATURA = 0 THEN 'BOLETO'
				WHEN B.TP_FATURA = 1 THEN 'DI'
				WHEN B.TP_FATURA = 2 THEN 'PAGAMENTO INTEGRAL NO CEDENTE'
				WHEN B.TP_FATURA = 3 THEN 'PAGAMENTO PARCIAL NO CEDENTE'
				WHEN B.TP_FATURA = 4 THEN 'PAGAMENTO ACORDO NO CEDENTE'
				WHEN B.TP_FATURA = 5 THEN 'PAGAMENTO DIVERGENTE ACORDO NO CEDENTE'
				WHEN B.TP_FATURA = 6 THEN 'PAGAMENTO CARGA RECIBO'
				END [TIPO FATURA], 
		B.DT_PARCELA AS [DATA VENCIMENTO],
		A.DT_CANCELAMENTO AS [DATA CANCELAMENTO],
		B.DT_PAGAMENTO [DATA PAGAMENTO],
		B.VL_PARCELA,
		B.VL_PAGO,
		B.VL_RECEITA,
		B.VL_REPASSE,
		D.[VALOR DIVIDA],
		D.[VALOR DIVIDA]/A.NU_PLANO AS [VALOR DIVIDA PARCELA], 
		CASE	WHEN B.TP_STATUS IN (0,3,4,5) THEN 'ABERTO'
				WHEN B.TP_STATUS = 1 THEN 'PAGO'
				WHEN B.TP_STATUS = 2 THEN 'CANCELADO'
				END [TP STATUS], 
		CASE	WHEN B.TP_STATUS = 0 THEN 'ABERTO'
				WHEN B.TP_STATUS = 1 THEN 'DIRETO'
				WHEN B.TP_STATUS = 2 THEN 'CANCELADO'
				WHEN B.TP_STATUS IN (3,4) THEN 'INDIRETO'
				END [TIPO PAGAMENTO],
		CASE	WHEN B.TP_STATUS = 0 THEN 'ABERTO'
				WHEN B.TP_STATUS = 1 THEN 'PAGO'
				WHEN B.TP_STATUS = 2 THEN 'CANCELADO'
				WHEN B.TP_STATUS = 3 THEN 'AGUARDANDO RETORNO DO CEDENTE'
				WHEN B.TP_STATUS = 4 THEN 'AGUARDANDO RETORNO DO WEB SERVICE'
				WHEN B.TP_STATUS = 5 THEN 'AGUARDANDO APROVACAO'
				END [STATUS FATURA], 
		CASE	WHEN A.TP_STATUS = 0 THEN 'ABERTO'
				WHEN A.TP_STATUS = 1 THEN 'ABERTO COM PAGAMENTO'
				WHEN A.TP_STATUS = 2 THEN 'QUITADO'
				WHEN A.TP_STATUS = 3 THEN 'CANCELADO'
				WHEN A.TP_STATUS = 4 THEN 'AGUARDANDO APROVACAO'
				WHEN A.TP_STATUS = 5 THEN 'NEGADO'
				END [STATUS ACORDO],
        CASE	WHEN B.TP_STATUS = 2 AND B.TP_ORIGEM_BAIXA = NULL THEN 'CANCELADO'
				WHEN B.TP_STATUS = 2 AND B.TP_ORIGEM_BAIXA = 0 THEN 'CANCELADO'
				WHEN B.TP_ORIGEM_BAIXA = 0 THEN 'CARGA'
				WHEN B.TP_ORIGEM_BAIXA = 1 THEN 'CNAB'
				WHEN B.TP_ORIGEM_BAIXA = 2 THEN 'MANUAL'
				WHEN B.TP_ORIGEM_BAIXA = 3 THEN 'MANUAL CARTAO'
				WHEN B.TP_ORIGEM_BAIXA = 4 THEN 'CARGA RENEGOCIACAO' 
				WHEN B.TP_ORIGEM_BAIXA = 5 THEN 'WEB SERVICE' 
				WHEN B.TP_ORIGEM_BAIXA = 6 THEN 'PIX' 
				ELSE 'DESCONHECIDO'END [ORIGEM BAIXA],
		CASE	WHEN A.TP_ORIGEM = 0 THEN 'OPERAÇÃO'
				WHEN A.TP_ORIGEM = 1 THEN 'CARGA, ACORDO NO PARCEIRO'
				WHEN A.TP_ORIGEM = 2 THEN 'PAGAMENTO LOJA'
				WHEN A.TP_ORIGEM = 3 THEN 'INTEGRACAO CEDENTE'
				WHEN A.TP_ORIGEM = 4 THEN 'PROPOSTA'
				WHEN A.TP_ORIGEM = 5 THEN 'CARGA ACORDO NO PARCEIRO ESPECIAL'
				WHEN A.TP_ORIGEM = 6 THEN 'RECIBO VIA CARGA'
				WHEN A.TP_ORIGEM = 7 THEN 'ACORDO SEM REGRA'
				WHEN A.TP_ORIGEM = 8 THEN 'AUTO ATENDIMENTO'
				WHEN A.TP_ORIGEM = 9 THEN 'AUTO ATENDIMENTO SEM REGRA'
				WHEN A.TP_ORIGEM = 10 THEN 'INTEGRACAO ROBO'
				WHEN A.TP_ORIGEM = 11 THEN 'NOVACAO'
				WHEN A.TP_ORIGEM = 12 THEN 'CARTAO DE CREDITO'
				END AS [ORIGEM ACORDO],
				D.ATRASO AS ATRASO,
				E.NM_FASE AS [FASE]
		
FROM TB_ACORDO A
LEFT JOIN TB_FATURA B
ON A.ID_CLIENTE = B.ID_CLIENTE
AND A.ID_ACORDO = B.ID_ACORDO
LEFT JOIN TB_CLIENTE C
ON A.ID_CLIENTE = C.ID_CLIENTE
LEFT JOIN (SELECT
		ID_CLIENTE,
		MIN(ID_CONTRATO) AS ID_CONTRATO,
		DATEDIFF(DAY, MIN(DT_VENCIMENTO), GETDATE()) AS [ATRASO],
		SUM(VL_DIVIDA) AS  [VALOR DIVIDA]
			  FROM TB_ACORDO_DIVIDA
		  GROUP BY ID_CLIENTE) D
ON A.ID_CLIENTE = D.ID_CLIENTE
LEFT JOIN TB_FASE E
ON C.ID_CEDENTE = E.ID_CEDENTE
AND D.ATRASO BETWEEN E.NU_ATRASO_DE AND E.NU_ATRASO_ATE 
LEFT JOIN TB_CONTRATO F
ON D.ID_CLIENTE = F.ID_CLIENTE
AND D.ID_CONTRATO = F.ID_CONTRATO
 
GO

