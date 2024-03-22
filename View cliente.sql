USE [easycollector]
GO

/****** Object:  View [dbo].[vw_CLIENTE]    Script Date: 22/03/2024 17:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_CLIENTE] AS

SELECT	A.ID_CLIENTE,
		A.ID_CEDENTE,
		A.NM_NOME,A.NU_CPF_CNPJ,
		SUBSTRING(CAST(NU_CPF_CNPJ AS VARCHAR), LEN(NU_CPF_CNPJ) - 2, 1) AS [REGISTRO FISCAL],
		A.DT_NASCIMENTO,
		CASE	WHEN DT_NASCIMENTO = NULL THEN 'NULL' 
				WHEN DT_NASCIMENTO = '' THEN ''
				WHEN DT_NASCIMENTO != '' THEN DATEDIFF(YEAR,DT_NASCIMENTO,GETDATE()) END [IDADE],
		A.DT_CADASTRO,
		A.DT_ATUALIZACAO,
		CASE	WHEN A.TP_SEXO = 0 THEN 'M' ELSE 'F' END SEXO, 
		CASE	WHEN A.TP_ESTADO_CIVIL = '0' THEN 'SOLTEIRO'
				WHEN A.TP_ESTADO_CIVIL = '1' THEN 'CASADO'
				WHEN A.TP_ESTADO_CIVIL > '1' THEN 'OUTROS' END TP_ESTADO_CIVIL,
		A.NM_CARGO,
		A.VL_RENDA,
		CASE	WHEN LEN(A.NU_CPF_CNPJ) <= 11 OR A.TP_PESSOA = '0' THEN 'PF'
				WHEN LEN(A.NU_CPF_CNPJ) > 11 OR A.TP_PESSOA = '1' THEN 'PJ'
				WHEN A.TP_PESSOA = '2' THEN 'OUTROS' END TP_PESSOA,
		A.TP_NOVO,
		A.NU_SCORE_EC,
		CASE	WHEN B.NM_UF not in ('PR','RS','SC','ES','MG','RJ','SP','AC','AM','AP','PA','RO','RR','TO','AL','BA','CE','MA','PB','PE','PI','RN','SE','DF','GO','MS','MT')  THEN NULL
				ELSE B.NM_UF END NM_UF,
		B.NM_CIDADE AS [CIDADE],
		C.NU_DDD,
		CASE	WHEN C.TP_TELEFONE = '0' THEN 'RESIDENCIAL'
				WHEN C.TP_TELEFONE = '1' THEN 'COMERCIAL'
				WHEN C.TP_TELEFONE = '2' THEN 'CELULAR'
				WHEN C.TP_TELEFONE = '3' THEN 'REFERENCIA'
				WHEN C.TP_TELEFONE = '4' THEN 'OUTROS' END TP_TELEFONE,
		D.DT_EXPIRACAO
FROM TB_CLIENTE A
LEFT JOIN(SELECT ID_CLIENTE,
				 NM_UF,
				 NM_CIDADE
			FROM TB_CLIENTE_ENDERECO
			WHERE TP_PREFERENCIAL = 1 
			 AND TP_HABILITADO = 1) B
ON A.ID_CLIENTE = B.ID_CLIENTE
LEFT JOIN (SELECT ID_CLIENTE,
				  NU_DDD,
				  TP_TELEFONE 
             FROM TB_CLIENTE_TELEFONE 
            WHERE TP_PREFERENCIAL = 1 
              AND TP_HABILITADO = 1) C
ON A.ID_CLIENTE = C.ID_CLIENTE
LEFT JOIN (SELECT MAX(DT_EXPIRACAO) AS DT_EXPIRACAO, ID_CLIENTE 
			 FROM TB_CONTRATO 
			 WHERE DT_EXPIRACAO > GETDATE()
		 GROUP BY ID_CLIENTE) D
ON A.ID_CLIENTE = D.ID_CLIENTE
GO


