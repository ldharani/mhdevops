public with sharing class AccountLookUpController {
    public  String selAccountId {set;get;}
    public Boolean render1 {
        get;
        set;
    }
    List < Account > records = new List < Account > ();
    public String searchvalue {
        get;
        set;
    }
    public AccountLookUpController() {
        try {
            searchvalue = ApexPages.currentPage().getParameters().get('parentname');
            String id = ApexPages.currentPage().getParameters().get('parentid');
            if (String.IsNotBlank(searchvalue)) {
                render1 = true;
                records = [Select Name from Account where Name like: +searchvalue + '%'
                    order by Name asc
                ];
            } else {
                render1 = true;
                records = [Select Name from Account order by LastModifiedDate desc LIMIT 10];
            }
        } catch (Exception e) {}
    }
    public List < Account > getRecords() {
        if (records.size() != 0) {
            return records;
        } else {
            return null;
        }
    }
    public PageReference onkeyupAction() {
        searchAction();
        return null;
    }
    public PageReference searchAction() {
        render1 = true;
        records = [Select Name from Account where Name like: +searchvalue + '%'
            order by Name asc
        ];
        if (records.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'No Records Found'));
        }
        return null;
    }
}