public class MergeAccounrJson {
    public class NoloCustomerNumbers {
        public Long noloCustomerNumber;
        public Long noloGidNumber;
    }
    
    public Message message;
    
    public class Message {
        public CurrentSfNumbers currentSfNumbers;
        public CurrentSfNumbers previousSfNumbers;
        public Long updatedAt;
    }
    
    public class CurrentSfNumbers {
        public Long sfGuid;
        public MhCustomerNumbers mhCustomerNumbers;
        public Long ngageCustomerNumber;
        public Long captorraCustomerNumber;
        public NoloCustomerNumbers noloCustomerNumbers;
        public AvvoCustomerNumbers avvoCustomerNumbers;
    }
    
    public class AvvoCustomerNumbers {
        public Long avvoFirmCustomerNumber;
        public List<Integer> avvoAttorneyCustomerNumbers;
    }
    
    public class MhCustomerNumbers {
        public Long mhCustomerNumber;
        public Long mhOrgId;
    }
    public static MergeAccounrJson parse(String json) {
        return (MergeAccounrJson) System.JSON.deserialize(json, MergeAccounrJson.class);
    }
}