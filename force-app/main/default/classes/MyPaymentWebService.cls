@RestResource(urlMapping='/Payment/create')
global class MyPaymentWebService {
	@HttpPost
    global static List<OperationResult> createPayments(List<PaymentDto> payments) {
        List<Payment__c> items = new List<Payment__c>();
        
        for (PaymentDto dto : payments) {
			items.add(dto.toPayment());
        }
        
        try {
        	insert items;
            
            List<OperationResult> results = new List<OperationResult>();
            for (Payment__c p : items) {
                results.add(new OperationResult(p.id, 'Success'));
            }
            
            return results;
        } catch (DmlException e) {
           	RestResponse response = RestContext.response;
            response.statusCode = 500;
            response.responseBody = Blob.valueOf('{\n\t"status": "Failure"\n\t"error": ' + '"' + e.getMessage() + '"' + '}'); 
            
			return null;         		    
        }
    }
    
    global class PaymentDto {
   		global String Opportunity;
        global Decimal Amount;
        global String FirstName;
        global String LastName;
        
        public Payment__c toPayment() {
            return new Payment__c(
            	OpportunityName__c=this.Opportunity,
                Amount__c=this.Amount,
                FirstName__c=this.FirstName,
                LastName__c=this.LastName
            );
        }
    }
    
    global class OperationResult {
        global Id recordId;
        global String status;
        
        OperationResult(Id recordId, String status) {
            this.status = status;
            this.recordId = recordId;
        }
    }
}