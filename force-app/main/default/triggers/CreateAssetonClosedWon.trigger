trigger CreateAssetonClosedWon on Opportunity (after update) {

    for(Opportunity o: trigger.new){
    
        if( trigger.oldMap.get(o.Id).StageName != o.StageName ) {
        
            Id OppRecordTypePSId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
            Id OppRecordTypeExceptionalId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Exceptional').getRecordTypeId();
             
            if(o.isWon == true && o.HasOpportunityLineItem == true && o.RecordTypeId <> OppRecordTypePSId && o.RecordTypeId <> OppRecordTypeExceptionalId){
                String opptyId = o.Id;
                OpportunityLineItem[] OLI = [Select ListPrice, Quantity, PricebookEntry.Product2Id, PricebookEntry.Product2.Name, Description, Production_Id__c, Staging1_Id__c, Staging2_Id__c, Staging3_Id__c, Converted_to_Asset__c  
                                              From OpportunityLineItem 
                                              where OpportunityId = :opptyId  
                                              and Converted_to_Asset__c = false
                                              and (PricebookEntry.Product2.Family = 'Plugin' or PricebookEntry.Product2.Family = 'Editions')];
                Asset[] ast = new Asset[]{};
                Asset a = new Asset();
                for(OpportunityLineItem ol: OLI){
                    a = new Asset();
                    a.AccountId = o.AccountId;
                    a.Product2Id = ol.PricebookEntry.Product2Id;
                    a.Creation_Opportunity__c = opptyId;
                    a.Invoice_Date__c = o.Invoice_Date__C;
                    a.Start_Date__c = o.Start_Date__c;
                    a.End_Date__c = o.End_Date__c;
                    // a.SerialNumber = o.Serial_Number__c;
                    // Backlog Id 104 - 20180805 LPT a.Quantity = ol.Quantity;
                    a.Quantity = 1;
                    a.CurrencyIsoCode = o.CurrencyIsoCode;
                    a.Price = ol.ListPrice;
                    a.PurchaseDate = o.CloseDate;
                    a.Status = 'Purchased';
                    a.Description = ol.Description;
                    a.Name = ol.PricebookEntry.Product2.Name;
                    a.Production_Id__c= ol.Production_Id__c;
                    a.Staging1_Id__c= ol.Staging1_Id__c;
                    a.Staging2_Id__c= ol.Staging2_Id__c;
                    a.Staging3_Id__c= ol.Staging3_Id__c;
                    ast.add(a);
                    ol.Converted_to_Asset__c = true;
                }
                update OLI; 
                insert ast;
            }       
        } 
    }
}