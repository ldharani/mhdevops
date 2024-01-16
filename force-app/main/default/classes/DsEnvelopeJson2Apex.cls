public class DsEnvelopeJson2Apex {
	public String envelopeId;	//2b4b2bec-2ba7-4d74-8d29-1fa72f20b2d1
	public String uri;	///envelopes/2b4b2bec-2ba7-4d74-8d29-1fa72f20b2d1
	public String statusDateTime;	//2022-08-01T19:18:00.4800000Z
	public String status;	//sent
	public static DsEnvelopeJson2Apex parse(String json){
		return (DsEnvelopeJson2Apex) System.JSON.deserialize(json, DsEnvelopeJson2Apex.class);
	}
    /*
	static testMethod void testParse() {
		String json=		'{"envelopeId":"2b4b2bec-2ba7-4d74-8d29-1fa72f20b2d1","uri":"/envelopes/2b4b2bec-2ba7-4d74-8d29-1fa72f20b2d1","statusDateTime":"2022-08-01T19:18:00.4800000Z","status":"sent"}';
		DsEnvelopeJson2Apex.parse(json);
	}*/
}