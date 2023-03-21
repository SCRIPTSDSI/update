SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[QFJPGMON]
AS

      SELECT NRD,                 -- Komentet e fundit me 03.01.2015

             EURMON       = 'EU', 

             EURVLEFTESHL = SUM(CASE WHEN IsNull(KMONSHL,'')='' THEN VLEFTESHL              ELSE 0 END),
                                  -- WHEN KMONSHL='EU'          THEN VLEFTESHL

             EURVLEFTEFAT = SUM(CASE WHEN IsNull(KMONSHL,'')='' THEN VLEFTESHLFAT           ELSE 0 END),
                                  -- WHEN KMONSHL='EU'          THEN VLEFTESHLFAT

             EURKURS      = CASE WHEN SUM(CASE WHEN IsNull(KMONSHL,'')='' THEN VLEFTESHL    ELSE 0 END)=0 
                                            -- WHEN KMONSHL='EU' THEN VLEFTESHL
                                 THEN 0
                                 ELSE SUM(CASE WHEN IsNull(KMONSHL,'')='' THEN VLEFTESHLFAT ELSE 0 END) / 
                                            -- WHEN KMONSHL='EU'          THEN VLEFTESHLFAT
                                      SUM(CASE WHEN IsNull(KMONSHL,'')='' THEN VLEFTESHL    ELSE 0 END)
                                            -- WHEN KMONSHL='EU'          THEN VLEFTESHL
                                 END, 

             LEKMON       = 'LEK', 

             LEKVLEFTESHL = SUM(CASE WHEN KMONSHL='LEK' THEN VLEFTESHL    ELSE 0 END), 

             LEKVLEFTEFAT = SUM(CASE WHEN KMONSHL='LEK' THEN VLEFTESHLFAT ELSE 0 END), 

             LEKKURS      = CASE WHEN SUM(CASE WHEN KMONSHL='LEK' THEN VLEFTESHL ELSE 0 END)=0 
                                 THEN 0 
                                 ELSE MAX(KURSSHL) END

        FROM FJPG

    GROUP BY NRD








GO
