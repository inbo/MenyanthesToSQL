-- bijwerken van de tabel tbl_xg3
use D0136_00_Flaven
MERGE tbl_xg3 as trg
	USING (SELECT t.Jaar , t.IsHydroJaar , mtptn.MeetpuntCode,
         (GHGm1_fpm.mMaaiveld + GHGm2_fpm.mMaaiveld + GHGm3_fpm.mMaaiveld ) /3 as hg3_std,
         (GVGm1_fpm.mMaaiveld + GVGm2_fpm.mMaaiveld + GVGm3_fpm.mMaaiveld ) /3 as vg3_std,
         (GLGm1_fpm.mMaaiveld + GLGm2_fpm.mMaaiveld + GLGm3_fpm.mMaaiveld ) /3 as lg3_std,
         (iif( GHGm1_fpm.mMaaiveld > 0, 0, GHGm1_fpm.mMaaiveld) + iif( GHGm2_fpm.mMaaiveld > 0, 0, GHGm2_fpm.mMaaiveld) + iif( GHGm3_fpm.mMaaiveld > 0, 0, GHGm3_fpm.mMaaiveld) ) /3 as hg3_afgetopt,
         (iif( GVGm1_fpm.mMaaiveld > 0, 0, GVGm1_fpm.mMaaiveld) + iif( GVGm2_fpm.mMaaiveld > 0, 0, GVGm2_fpm.mMaaiveld) + iif( GVGm3_fpm.mMaaiveld > 0, 0, GVGm3_fpm.mMaaiveld) ) /3 as vg3_afgetopt,
         (iif( GLGm1_fpm.mMaaiveld > 0, 0, GLGm1_fpm.mMaaiveld) + iif( GLGm2_fpm.mMaaiveld > 0, 0, GLGm2_fpm.mMaaiveld) + iif( GLGm3_fpm.mMaaiveld > 0, 0, GLGm3_fpm.mMaaiveld) ) /3 as lg3_afgetopt,
		 [ParamMinAantalMetingen], [MaxRepresentatievePeriode], [GHG_Range], [GVG_Range], [GLG_Range]
		, 0 as OokModelData 
         FROM FactBRPeilMetingJaar_Flaven t
		  inner join [INBO-SQL08-PRD.INBO.BE].[W0002_00_Watina].[dbo].DimMeetpunt mtptn on mtptn.MeetpuntWID = t.MeetpuntWID 
		  LEFT JOIN [INBO-SQL08-PRD.INBO.BE].[W0002_00_Watina].[dbo].FactPeilMeting GHGm1_fpm ON GHGm1_fpm.[PeilMetingWID] = t.GHGmMaaiVeldPeilMetingWID1
		  LEFT JOIN [INBO-SQL08-PRD.INBO.BE].[W0002_00_Watina].[dbo].FactPeilMeting GHGm2_fpm ON GHGm2_fpm.[PeilMetingWID] = t.GHGmMaaiVeldPeilMetingWID2
		  LEFT JOIN [INBO-SQL08-PRD.INBO.BE].[W0002_00_Watina].[dbo].FactPeilMeting GHGm3_fpm ON GHGm3_fpm.[PeilMetingWID] = t.GHGmMaaiVeldPeilMetingWID3
		  LEFT JOIN [INBO-SQL08-PRD.INBO.BE].[W0002_00_Watina].[dbo].FactPeilMeting GVGm1_fpm ON GVGm1_fpm.[PeilMetingWID] = t.GVGmMaaiVeldPeilMetingWID1
		  LEFT JOIN [INBO-SQL08-PRD.INBO.BE].[W0002_00_Watina].[dbo].FactPeilMeting GVGm2_fpm ON GVGm2_fpm.[PeilMetingWID] = t.GVGmMaaiVeldPeilMetingWID2
		  LEFT JOIN [INBO-SQL08-PRD.INBO.BE].[W0002_00_Watina].[dbo].FactPeilMeting GVGm3_fpm ON GVGm3_fpm.[PeilMetingWID] = t.GVGmMaaiVeldPeilMetingWID3
		  LEFT JOIN [INBO-SQL08-PRD.INBO.BE].[W0002_00_Watina].[dbo].FactPeilMeting GLGm1_fpm ON GLGm1_fpm.[PeilMetingWID] = t.GLGmMaaiVeldPeilMetingWID1
		  LEFT JOIN [INBO-SQL08-PRD.INBO.BE].[W0002_00_Watina].[dbo].FactPeilMeting GLGm2_fpm ON GLGm2_fpm.[PeilMetingWID] = t.GLGmMaaiVeldPeilMetingWID2
		  LEFT JOIN [INBO-SQL08-PRD.INBO.BE].[W0002_00_Watina].[dbo].FactPeilMeting GLGm3_fpm ON GLGm3_fpm.[PeilMetingWID] = t.GLGmMaaiVeldPeilMetingWID3
		  ) src
	ON (src.MeetpuntCode = trg.MeetpuntCode 
	AND src.Jaar = trg.Jaar
	AND src.IsHydroJaar = trg.IsHydroJaar
	AND src.ParamMinAantalMetingen = trg.MinAantalMetingen
	AND src.MaxRepresentatievePeriode = trg.MaxRepresentatievePeriode
	AND src.GHG_Range = trg.GHG_Range
	AND src.GLG_Range = trg.GLG_Range
	AND src.GVG_Range = trg.GVG_Range
	AND src.OokModelData = trg.OokModelData
	)
	WHEN MATCHED THEN UPDATE
		SET	 trg.HG3_std 			= src.HG3_std 			
			,trg.VG3_std			= src.VG3_std			
			,trg.LG3_std			= src.LG3_std	
			,trg.HG3_afgetopt 		= src.HG3_afgetopt 	
			,trg.VG3_afgetopt		= src.VG3_afgetopt	
			,trg.LG3_afgetopt		= src.LG3_afgetopt		
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (MeetpuntCode, Jaar, IsHydrojaar, HG3_std , VG3_std, LG3_std, HG3_afgetopt , VG3_afgetopt, LG3_afgetopt, MinAantalMetingen , MaxRepresentatievePeriode , GHG_Range , GLG_Range , GVG_Range, OokModelData  )
		VALUES (src.MeetpuntCode, src.Jaar, src.IsHydrojaar, src.HG3_std , src.VG3_std, src.LG3_std, src.HG3_afgetopt , src.VG3_afgetopt, src.LG3_afgetopt, src.ParamMinAantalMetingen , src.MaxRepresentatievePeriode , src.GHG_Range , src.GLG_Range , src.GVG_Range, src.OokModeldata );
