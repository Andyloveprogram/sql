USE [Carlsberg_K2Workflow]
GO

/****** Object:  StoredProcedure [dbo].[sp_GetPAReportSearchByCondition]    Script Date: 9/9/2017 2:39:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



-- =============================================
-- Author:		<Author,,Lester Lau and Andy ZHANG>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetPAReportSearchByCondition] 
	-- Add the parameters for the stored procedure here
	@UserAccount nvarchar(max) 
	
	,@PaymentType nvarchar(max) = null
	,@ApplicationNo nvarchar(max) = null
	,@Company nvarchar(max) = null
	,@PurchaseNo nvarchar(max) = null
	,@ApplicationType nvarchar(max) = null
	,@InvoiceNumber nvarchar(max) = null
	,@Amount nvarchar(max) = null
	,@Status nvarchar(max) = null
	,@ApplicationDateStart date = null
	,@ApplicationDateEnd date = null
	,@PrepaymentDateStart date = null
	,@PrepaymentDateEnd date = null
	,@VendorName nvarchar(max) = null
	,@PaymentTypeV3 nvarchar(max) = null
	
	
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- RoleID	RoleName
	-- 1	Local Procurement
	-- 2	Local Finance
	-- 3	Local Production
	-- 4	China Commercial
	-- 5	APC
	-- 6	SSC
	-- 7	System Administrator
	-- 8	Master Data Admin
	-- 9	PA Submitter
	-- 10	PA Approver
	
	IF @PaymentType is NULL
		SET @PaymentType = ''

	
	DECLARE @ROLECount INT

	-- Role 7	
	SET @ROLECount = (SELECT Count(u.UserID) 
	FROM Users as u JOIN User_Role_Mapping as urm
	ON u.UserID = urm.UserID
	WHERE u.IsDeleted = 0
	AND u.UserAccount = @UserAccount
	AND urm.RoleID=7)
	
	
	
	IF @ROLECount > 0
	BEGIN
		SELECT *
		FROM New_PaymentApplication
		WHERE Payment_Type like '%'+ @PaymentType +'%'
--		AND Payment_Company=@Company
		AND Payment_App_No = @ApplicationNo
      OR ISNULL(@ApplicationNo, '') = ''
      
     AND (Payment_Company = @Company
      OR ISNULL(@Company, '') = '')
      
    AND (PO_NO=@PurchaseNo
      OR ISNULL(@PurchaseNo, '') = '' )
      
    AND (Application_Type=@ApplicationType
      OR ISNULL(@ApplicationType, '') = '') 
      
      AND (Payment_Type=@PaymentType
      OR ISNULL(@PaymentType, '') = '') 
      
    AND (VInvoiceNo=@InvoiceNumber
      OR ISNULL(@InvoiceNumber, '') = '') 
	
	AND (Amount=@Amount
	  OR ISNULL(@Amount,'')='')
	  
	AND (Status=@Status
	  OR ISNULL(@Status,'')=''
	  Or CASE
	  WHEN @Status = 'B' 
	  THEN NULLIF(New_PaymentApplication.Status,'')  
	  ELSE New_PaymentApplication.Payment_User  --if status is ´ýÉóÅú @status = B and will search all status is null
	  END is null)
	  
	  
	AND (ApplicationDate>=@ApplicationDateStart
	 OR ISNULL(@ApplicationDateStart,'')='')
	  
	AND (ApplicationDate<=@ApplicationDateEnd
	  OR ISNULL(@ApplicationDateEnd,'')='')
	  
	AND (ExpectPayDate<=@PrepaymentDateEnd
	  OR ISNULL(@PrepaymentDateEnd,'')='')
	  
	AND (ExpectPayDate>=@PrepaymentDateStart
	  OR ISNULL(@PrepaymentDateStart,'')='')
	  
    AND (REPLACE(VendorNameAndID, ' ', '')=@VendorName
	  OR ISNULL(@VendorName,'')='')
	  	  
	AND (Payment_Type=@PaymentTypeV3
	  OR ISNULL(@PaymentTypeV3,'')='')
		ORDER BY PayAppID DESC  
	END

	Else
	BEGIN
	--print 1
	-- Role (1,2,3,4,5,6)
    SELECT  
	PayAppID,
	max(Payment_User) as Payment_User,
	max(Payment_Company) as Payment_Company ,
	max(Application_Type)as Application_Type,
	max(ADCast_Type) as ADCast_Type,
	max(Payment_Type)as Payment_Type,
	max(PaperRequestID)as PaperRequestID,
	max(NeedDepart)as NeedDepart,
	max(VendorNameAndID) as VendorNameAndID,
	max(VendorBankAndAccount) as VendorBankAndAccount,
	max(ExpectPayDate) as ExpectPayDate
	,max(Currency) as Currency
	,max(Amount) as Amount
	,max(PO_NO) as PO_NO
	,max(VInvoiceNo) as VInvoiceNo
	,max(Contract_NO) as Contract_NO
	,max(LocalManApproveDate) as LocalManApproveDate
	,max(IN_NO) as IN_NO
	,max(ApplicationDate) as ApplicationDate
	,max(LocalFinancialApproveDate) as LocalFinancialApproveDate
	,max(Remark) as Remark
	,max(Payment_App_No) as Payment_App_No
	,max(Business_Depart_Date) as Business_Depart_Date
	,max(Business_Genger_Manager_Date) as Business_Genger_Manager_Date
	,max(Finance_Director_Date) as Finance_Director_Date
	,max(Status) as Status
	,max(ForeignGuid) as ForeignGuid
	,max(Appuser) as Appuser
	,max(Appremark) as Appremark
	,max(Action) as Action
	,max(GL_Account) as GL_Account
	,MAX(CostCenter) as CostCenter
	,MAX(PaymentBank) as PaymentBank
	,max(CashFlow) as CashFlow
	,max(Document_Date)as Document_Date
	,max(Version)as  Version
	,max(UserID) as UserID
	,MAX(UserAccount) as UserAccount
	,max(id) as id
	,max(Company) as Company
	,max(RoleID) as RoleID
	,max(DepartmentID) as DepartmentID
	FROM
	(SELECT * FROM
	(SELECT *
	FROM New_PaymentApplication WHERE
	 --Version='v3'
	 	 Payment_App_No = @ApplicationNo
      OR ISNULL(@ApplicationNo, '') = ''
      
     AND (Payment_Company = @Company
      OR ISNULL(@Company, '') = '')
      
    AND (PO_NO=@PurchaseNo
      OR ISNULL(@PurchaseNo, '') = '' )
      
    AND (Application_Type=@ApplicationType
      OR ISNULL(@ApplicationType, '') = '') 
      
      AND (Payment_Type=@PaymentType
      OR ISNULL(@PaymentType, '') = '') 
      
    AND (VInvoiceNo=@InvoiceNumber
      OR ISNULL(@InvoiceNumber, '') = '') 
	
	AND (Amount=@Amount
	  OR ISNULL(@Amount,'')='')
	  
AND (Status=@Status
	  OR ISNULL(@Status,'')=''
	  Or CASE
	  WHEN @Status = 'B' 
	  THEN NULLIF(New_PaymentApplication.Status,'')  
	  ELSE New_PaymentApplication.Payment_User
	  END is null)
	  
	AND (ApplicationDate>=@ApplicationDateStart
	 OR ISNULL(@ApplicationDateStart,'')='')
	  
	AND (ApplicationDate<=@ApplicationDateEnd
	  OR ISNULL(@ApplicationDateEnd,'')='')
	  
	AND (ExpectPayDate<=@PrepaymentDateEnd
	  OR ISNULL(@PrepaymentDateEnd,'')='')
	  
	AND (ExpectPayDate>=@PrepaymentDateStart
	  OR ISNULL(@PrepaymentDateStart,'')='')
	  
    AND (REPLACE(VendorNameAndID, ' ', '')=@VendorName
	  OR ISNULL(@VendorName,'')='')
	  	  
	AND (Payment_Type=@PaymentTypeV3
	  OR ISNULL(@PaymentTypeV3,'')='')
	)as np join
	(SELECT 
	max(u.UserID)as UserID, 
	max(u.UserAccount) as UserAccount
	,max( udm.DepartmentID) as id
	, u.Company
	,max(urm.RoleID) as RoleID
	,max( udm.DepartmentID) as DepartmentID
	FROM Users as u INNER JOIN User_Role_Mapping as urm
	ON u.UserID = urm.UserID
	LEFT JOIN User_Department_Mapping as udm
	ON u.UserID = udm.UserID
	WHERE u.IsDeleted = 0
	AND u.UserAccount = @UserAccount
	AND urm.RoleID in (1,2,3,4,5,6)
	group by u.Company) as ur
	ON (np.Payment_Company = ur.Company
	)
	  
	UNION
	-- Role (9)
	SELECT * FROM(SELECT *
	FROM New_PaymentApplication WHERE 
		Payment_App_No = @ApplicationNo
      OR ISNULL(@ApplicationNo, '') = ''
      
    AND (Payment_Company = @Company
      OR ISNULL(@Company, '') = '')
      
    AND (PO_NO=@PurchaseNo
      OR ISNULL(@PurchaseNo, '') = '' )
      
    AND (Application_Type=@ApplicationType
      OR ISNULL(@ApplicationType, '') = '') 
      
      AND (Payment_Type=@PaymentType
      OR ISNULL(@PaymentType, '') = '') 
      
    AND (VInvoiceNo=@InvoiceNumber
      OR ISNULL(@InvoiceNumber, '') = '') 
	
	AND (Amount=@Amount
	  OR ISNULL(@Amount,'')='')
	  
AND (Status=@Status
	  OR ISNULL(@Status,'')=''
	  Or CASE
	  WHEN @Status = 'B' 
	  THEN NULLIF(New_PaymentApplication.Status,'')  
	  ELSE New_PaymentApplication.Payment_User
	  END is null)
	  
	AND (ApplicationDate>=@ApplicationDateStart
	  OR ISNULL(@ApplicationDateStart,'')='')
	  
	AND (ApplicationDate<=@ApplicationDateEnd
	  OR ISNULL(@ApplicationDateEnd,'')='')
	  
	AND (ExpectPayDate<=@PrepaymentDateEnd
	  OR ISNULL(@PrepaymentDateEnd,'')='')
	  
	AND (ExpectPayDate>=@PrepaymentDateStart
	  OR ISNULL(@PrepaymentDateStart,'')='')
	  
    AND (REPLACE(VendorNameAndID, ' ', '')=@VendorName
	  OR ISNULL(@VendorName,'')='')
	  	  
	AND (Payment_Type=@PaymentTypeV3
	  OR ISNULL(@PaymentTypeV3,'')='')
	)as np join
	(SELECT  u.UserID, u.UserAccount
	,udm.DepartmentID as id
	,u.Company, urm.RoleID, udm.DepartmentID 
	FROM Users as u JOIN User_Role_Mapping as urm
	ON u.UserID = urm.UserID
	JOIN User_Department_Mapping as udm
	ON u.UserID = udm.UserID
	WHERE u.IsDeleted = 0
	AND u.UserAccount = @UserAccount
	AND urm.RoleID = 9) as ur
	ON (np.Payment_Company = ur.Company
	AND np.NeedDepart =ur.id
	AND np.Version='v3'
	)

	UNION
	-- Role 10
	SELECT * FROM(SELECT *
	FROM New_PaymentApplication WHERE 
	 Payment_App_No = @ApplicationNo
      OR ISNULL(@ApplicationNo, '') = ''
      
     AND (Payment_Company = @Company
      OR ISNULL(@Company, '') = '')
      
    AND (PO_NO=@PurchaseNo
      OR ISNULL(@PurchaseNo, '') = '') 
      
    AND (Application_Type=@ApplicationType
      OR ISNULL(@ApplicationType, '') = '') 
      
      AND (Payment_Type=@PaymentType
      OR ISNULL(@PaymentType, '') = '' )
      
    AND (VInvoiceNo=@InvoiceNumber
      OR ISNULL(@InvoiceNumber, '') = '') 
	
	AND (Amount=@Amount
	  OR ISNULL(@Amount,'')='')
	  
AND (Status=@Status
	  OR ISNULL(@Status,'')=''
	  Or CASE
	  WHEN @Status = 'B' 
	  THEN NULLIF(New_PaymentApplication.Status,'')  
	  ELSE New_PaymentApplication.Payment_User
	  END is null)
	  
	AND (ApplicationDate>=@ApplicationDateStart
	  OR ISNULL(@ApplicationDateStart,'')='')
	  
	AND (ApplicationDate<=@ApplicationDateEnd
	  OR ISNULL(@ApplicationDateEnd,'')='')
	  
	AND (ExpectPayDate<=@PrepaymentDateEnd
	  OR ISNULL(@PrepaymentDateEnd,'')='')
	  
	AND (ExpectPayDate>=@PrepaymentDateStart
	  OR ISNULL(@PrepaymentDateStart,'')='')
	  
    AND (REPLACE(VendorNameAndID, ' ', '')=@VendorName
	  OR ISNULL(@VendorName,'')='')
	  	  
	AND (Payment_Type=@PaymentTypeV3
	  OR ISNULL(@PaymentTypeV3,'')='')
	)as np join
	(SELECT u.UserID, u.UserAccount
	,pac.DepartmentID as id, pac.Company,urm.RoleID,  pac.DepartmentID
	FROM Users as u JOIN User_Role_Mapping as urm
	ON u.UserID = urm.UserID
	JOIN PA_ApprovalConfig as pac
	ON u.UserID = pac.UserID
	WHERE u.IsDeleted = 0
	AND u.UserAccount = @UserAccount
	AND urm.RoleID = 10) as ur
	ON (np.Payment_Company = ur.Company
	AND np.NeedDepart like ur.id
	AND np.Version='v3'
	)
	
	
	--ORDER BY 
	--PayAppID DESC 
	) AS FINAL_TABLE
	GROUP BY FINAL_TABLE.PayAppID
	ORDER BY
        MAX(PayAppID) DESC
		OPTION(RECOMPILE)
	END
END
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON



GO


