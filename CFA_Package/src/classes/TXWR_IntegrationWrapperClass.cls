/**
 *
 * Apex utility class for taxware integration
 * @author Nikilesh Kopparthi
 *
 **/

public without sharing class TXWR_IntegrationWrapperClass {

    public class SOLResponseDetails{
        public string txwTrnDocId           {get;set;}
        public string txAmt                 {get;set;}
        public List<linesDetails> lnRslts   {get;set;}
    }
    
    public class linesDetails{
        public string lnNm                  {get;set;}
        public string lnId                  {get;set;}
        public string txAmt                 {get;set;}
        public string grossAmt              {get;set;}
        public List<SOLDetails> jurRslts    {get;set;}
        public string mergedResult          {get;set;}
    }
    
    public class SOLDetails{
        public string txAmt                 {get;set;}
        public string txName                {get;set;}
    }
    
    /**
     * This is the wrapper class which will be used to create the Taxware request 
     * All the attributes of the class will be attributes of the JSON request
     */
    public class TaxwareRequestWrapper{
        
        public string usrname               {get;set;}
        public string pswrd                 {get;set;}
        public string isAudit               {get;set;}
        public string currn                 {get;set;}
        public String docDt                 {get;Set;}
        public List<SOLDetailWrapper> lines {get;set;}
        
        // constructor
        public TaxwareRequestWrapper(){
            //this.currn = 'USD';
            this.lines = new List<SOLDetailWrapper>();      
            this.docDt = datetime.now().formatGMT('yyyy-MM-dd');
        }
    }
    
    public class SOLDetailWrapper{
        
        public Decimal grossAmt     {get;set;}
        public string discnts       {get;set;}
        public string orgCd         {get;set;}
        public Id lnItmId           {get;set;}
        public string goodSrvCd     {get;set;}
        public string bTStNameNum   {get;set;}
        public string bTCity        {get;set;}
        public string bTStateProv   {get;set;}
        public string bTPstlCd      {get;set;}
        public string bTCountry     {get;set;}
        public string lOAStNameNum  {get;set;}
        public string lOACity       {get;set;}
        public string lOAStateProv  {get;set;}
        public string lOAPstlCd     {get;set;}
        public string lOACountry    {get;set;}
        public string lORStNameNum  {get;set;}
        public string lORCity       {get;set;}
        public string lORStateProv  {get;set;}
        public string lORPstlCd     {get;set;}
        public string lORCountry    {get;set;}
        public string lSPStNameNum  {get;set;}
        public string lSPCity       {get;set;}
        public string lSPStateProv  {get;set;}
        public string lSPPstlCd     {get;set;}
        public string lSPCountry    {get;set;}
        public string lUStNameNum   {get;set;}
        public string lUCity        {get;set;}
        public string lUStateProv   {get;set;}
        public string lUPstlCd      {get;set;}
        public string lUCountry     {get;set;}
        public string sFStNameNum   {get;set;}
        public string sFCity        {get;set;}
        public string sFStateProv   {get;set;}
        public string sFPstlCd      {get;set;}
        public string sFCountry     {get;set;}
        public string sTStNameNum   {get;set;}
        public string sTCity        {get;set;}
        public string sTStateProv   {get;set;}
        public string sTPstlCd      {get;set;}
        public string sTCountry     {get;set;}
        
        public CustomAttributesWrapper custAttrbs {get;set;}         
        
        public SOLDetailWrapper(){
            this.grossAmt = 0.0;    
            this.discnts = '';      
            this.orgCd = '';            
            this.lnItmId = NULL;            
            this.goodSrvCd = '';    
            this.bTStNameNum = '';  
            this.bTCity = '';       
            this.bTStateProv = '';  
            this.bTPstlCd = '';         
            this.bTCountry = '';        
            this.lOAStNameNum = ''; 
            this.lOACity = '';      
            this.lOAStateProv = ''; 
            this.lOAPstlCd = '';        
            this.lOACountry = '';   
            this.lORStNameNum = ''; 
            this.lORCity = '';      
            this.lORStateProv = ''; 
            this.lORPstlCd = '';        
            this.lORCountry = '';   
            this.lSPStNameNum = ''; 
            this.lSPCity = '';      
            this.lSPStateProv = ''; 
            this.lSPPstlCd = '';        
            this.lSPCountry = '';   
            this.lUStNameNum = '';  
            this.lUCity = '';       
            this.lUStateProv = '';  
            this.lUPstlCd = '';     
            this.lUCountry = '';        
            this.sFStNameNum = '';  
            this.sFCity = '';       
            this.sFStateProv = '';  
            this.sFPstlCd = '';     
            this.sFCountry = '';        
            this.sTStNameNum = '';  
            this.sTCity = '';       
            this.sTStateProv = '';  
            this.sTPstlCd = '';     
            this.sTCountry = '';
            this.custAttrbs = new CustomAttributesWrapper();
        }
    }
    
    public class CustomAttributesWrapper{
        public string ORDERNUMBER {get;set;}
        public string TAXACCOUNTINGDATE {get;set;}
        
        public CustomAttributesWrapper(){
            ORDERNUMBER = '';
            TAXACCOUNTINGDATE = '';
        }
    }

}