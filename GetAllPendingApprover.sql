USE [Adidas_Sap]
GO

/****** Object:  StoredProcedure [dbo].[GetAllPendingApprover]    Script Date: 09/09/2017 17:25:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:	    Andy ZHANG
-- Create date: 7/19/2017
-- Description:	Get the pending approver of the claim
-- =============================================
CREATE PROCEDURE [dbo].[GetAllPendingApprover]
	-- Add the parameters for the stored procedure here
	@ClaimNo varchar(50),
	@ApprovalLevel varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

    -- Insert statements for procedure here
    
	--SELECT TOP 1
 --     [ActionerName] 
	--FROM [K2].[Server].[ActionActInstRights]
	--, [K2].[Server].[Actioner]
	--WHERE ProcInstID=(
	--SELECT  [ID]  
	--FROM [K2].[ServerLog].[ProcInst]
	--where Folio=@ClaimNo) 
	--and ID=ActionerID 
	--and ActID in 
	--(SELECT  [ID]      
	--FROM [K2].[ServerLog].[Act] 
	--WHERE Name='CM')
	SELECT [K2].[ServerLog].[Worklist].[Destination]
      FROM [K2].[ServerLog].[ActInst] 
      INNER JOIN [K2].[Server].[Act] ON [ActInst].ActID = [Act].ID AND [Act].Name = @ApprovalLevel
      LEFT JOIN [K2].[ServerLog].[ActInstDest] ON [K2].[ServerLog].[ActInstDest].ActInstID = [K2].[ServerLog].[ActInst].ID 
      AND [K2].[ServerLog].[ActInstDest].[ProcInstID] = [K2].[ServerLog].[ActInst].[ProcInstID] 
      AND [K2].[ServerLog].[ActInstDest].[Status] = 0
      LEFT JOIN [K2].[ServerLog].[Worklist] ON [K2].[ServerLog].[Worklist].ActInstDestID = [K2].[ServerLog].[ActInstDest].ID 
      AND [K2].[ServerLog].[Worklist].[ProcInstID] = [K2].[ServerLog].[ActInstDest].[ProcInstID] 
      AND [K2].[ServerLog].[Worklist].[Status] = 0
      LEFT JOIN [K2].[ServerLog].[ProcInst] ON [K2].[ServerLog].[ProcInst].ID=[K2].[ServerLog].[Worklist].[ProcInstID]
      WHERE [K2].[ServerLog].[ProcInst].Folio=@ClaimNo AND [ActInst].Status=2
  
END


GO


