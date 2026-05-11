-- Questão 01: Procedimento salaryHistogram
-- Objetivo: Distribuir as frequências dos salários dos professores 
-- em N intervalos.
CREATE OR ALTER PROCEDURE salaryHistogram
    @num_intervals INT
AS
BEGIN
    -- Validação de segurança: o número de intervalos deve ser maior 
    -- que zero
    IF @num_intervals <= 0 RETURN;

    -- Variáveis para guardar o maior salário, o menor salário e o 
    -- tamanho do intervalo
    DECLARE @MinSal INT;
    DECLARE @MaxSal INT;
    DECLARE @Step INT;

    -- 1. Captura o salário mínimo e máximo da tabela e converte para 
    -- número inteiro
    SELECT 
        @MinSal = CAST(MIN(salary) AS INT), 
        @MaxSal = CAST(MAX(salary) AS INT)
    FROM instructor;

    -- 2. Calcula o "tamanho" (largura) de cada intervalo
    -- Subtraímos o min do max e dividimos pelo número de intervalos
    SET @Step = (@MaxSal - @MinSal) / @num_intervals;

    -- 3. Usa uma CTE Recursiva para gerar a lista de intervalos
    -- dinamicamente
    ;WITH HistogramBins AS (
        -- Base da recursão: O Primeiro Intervalo (Bin 1)
        SELECT 
            1 AS bin_id,
            @MinSal AS valorMinimo,
            @MinSal + @Step AS valorMaximo
        
        UNION ALL
        
        -- Passo recursivo: Gera os próximos intervalos somando o Step
        SELECT 
            bin_id + 1,
            valorMaximo + 1, 
            -- Condição para garantir que o último intervalo termine
            -- exatamente no salário máximo
            CASE 
                WHEN bin_id + 1 = @num_intervals THEN @MaxSal 
                ELSE valorMaximo + 1 + @Step 
            END
        FROM HistogramBins
        WHERE bin_id < @num_intervals
    )
    -- 4. Junta os intervalos gerados com a tabela de instrutores para fazer
    -- a contagem
    SELECT 
        b.valorMinimo,
        b.valorMaximo,
        COUNT(i.ID) AS total
    FROM HistogramBins b
    LEFT JOIN instructor i 
        -- A condição do join verifica se o salário do professor está dentro
        -- da faixa do balde
        ON i.salary >= b.valorMinimo AND i.salary <= b.valorMaximo
    GROUP BY 
        b.bin_id,
        b.valorMinimo,
        b.valorMaximo
    ORDER BY 
        b.bin_id; 
END;



-- Exemplo de uso exigido na questão:
EXEC salaryHistogram 5;