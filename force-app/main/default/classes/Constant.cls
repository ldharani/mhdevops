/**@@
#APEX CLASS NAME     :    Constant
#TEST CLASS          :    ConstantTest
#Created By          :    Serge Kandukuri
#DESCRIPTION         :    This Helper class used to store static variables
@@**/
public class Constant{
    // PICKLIST VALUES -- START
    public static string ORDER_STATUS_ACTIVATED = 'Activated';
    
    public static string ORDER_STATUS_ACTIVE = 'Active';
    
    public static string ORDER_STATUS_PAUSE = 'paused';
    public static string ORDER_STATUS_INACTIVE = 'inactive';
    
    public static string ORDER_STATUS_CANCELLED  = 'Cancelled';
    public static string ORDER_STATUS_TRUNCATED  = 'Truncated';
    
    public static string ORDER_TYPE_AMENDMENT  = 'Amendment';
    // PICKLIST VALUES -- END
    
    public static string QUOTE_CLOSED_WON = 'Closed Won';
    public static string QUOTE_CLOSED_LOST = 'Closed Lost';
    public static string QUOTE_TYPE_AMEND = 'Amendment';
    public static string QUOTE_RECORD_TYPE = 'M-A Quote';
    public static string CONTRACT_AMEND_PROGRESS = 'Amend in Progress';
    public static string CONTRACT_EVERGREEN = 'Evergreen';
   
}