
-- Werkt enkel binnen de SQL08-server
-- Voor alle meetpunten
use W0002_00_Watina

declare @tmp as [dbo].[FactBRPeilMetingJaar];
Drop table if exists #TempFlaven;
	insert @tmp
	exec [dbo].[usp_BR_GXG_info]
	@MeetpuntWID = NULL,
	-- hier de default-waarden eventueel aanpassen
	@MinMetingen = 20,
	@MaxReprPeriode = 40,
	@GHG_Range =14,
	@GLG_Range =14,
	@GVG_Range =14,
 --@IsModeldata = 0, --0: modeldata (bijv. Menyanthes simulatie worden niet gebruikt; 1: modeldata worden wel gebruikt
	-- de laatste twee mogen zo blijven: histosgram=1 berekent een histogram (type xml) met de spreiding van de representatieve perioden: deze wordt niet in flaven meegenomen
	-- is silent= 0, creëert meer outpunt messages, handig tijdens het debuggen
	@MetHistoGram = 0,
	@IsSilent = 1;
	SELECT * INTO #TempFlaven FROM @tmp;    
	ALTER TABLE #TempFlaven DROP COLUMN RepresentatievePeriodeHistogram, BRPeilMetingJaarWID;

delete factflaven
    from [INBO-SQL07-PRD.INBO.BE].[D0136_00_Flaven].[dbo].[FactBRPeilMetingJaar_Flaven] factflaven
insert [INBO-SQL07-PRD.INBO.BE].[D0136_00_Flaven].[dbo].[FactBRPeilMetingJaar_Flaven] ( [MeetpuntWID], [Jaar], [IsHydroJaar], [EerstePeilMetingWID], [ReprPeriodeEerstePeilMeting], [LaatstePeilMetingWID], [ReprPeriodeLaatstePeilMeting], [BRResultaatWID], [GHGmTAWPeilMetingWID1], [GHGmTAWPeilMetingWID2], [GHGmTAWPeilMetingWID3], [GHGmTAWFout], [GHGmMaaiVeldPeilMetingWID1], [GHGmMaaiVeldPeilMetingWID2], [GHGmMaaiVeldPeilMetingWID3], [GHGmMaaiveldFout], [GLGmTAWPeilMetingWID1], [GLGmTAWPeilMetingWID2], [GLGmTAWPeilMetingWID3], [GLGmTAWFout], [GLGmMaaiVeldPeilMetingWID1], [GLGmMaaiVeldPeilMetingWID2], [GLGmMaaiVeldPeilMetingWID3], [GLGmMaaiveldFout], [GVGmTAWPeilMetingWID1], [GVGmTAWPeilMetingWID2], [GVGmTAWPeilMetingWID3], [GVGmTAWFout], [GVGmMaaiVeldPeilMetingWID1], [GVGmMaaiVeldPeilMetingWID2], [GVGmMaaiVeldPeilMetingWID3], [GVGmMaaiVeldFout], [MinGmTAWPeilmetingWID], [MaxGmTAWPeilmetingWID],
         [MinGmMaaiveldPeilmetingWID], [MaxGmMaaiveldPeilmetingWID], [ParamMinAantalMetingen], [MaxRepresentatievePeriode], [GHG_Range], [GVG_Range], [GLG_Range] )
    select * from #TempFlaven;

Drop table #TempFlaven;