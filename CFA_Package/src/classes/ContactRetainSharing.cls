/**
 *
 * Service class for Contact
 * @author Nikilesh
 *
 **/

public without sharing class ContactRetainSharing {
  
  public static void retainSharing(Map<Id,SObject> oldMap, Contact[] records) {
    Framework.Log.push(ContactRetainSharing.class.getName(),'retainSharing');
    
    Set<Id> cons = new Set<Id>();
    
    for(Contact c: records) {
    contact oldContact = (contact)oldMap.get(c.id);
      if(oldContact.OwnerId != c.OwnerId){
        cons.add(c.Id);
      }
    }
      if(!cons.isEmpty()){
      OrderApi__Badge__c[] badges = [SELECT Id, 
                                            BusinessGroup__c, 
                                            OrderApi__Contact__c 
                                            FROM OrderApi__Badge__c 
                                            WHERE OrderApi__Contact__c in :cons];
                                            
      ContactShare[] newJobShrs = new ContactShare[]{};
      ContactShare[] oldJobShrs = [SELECT Id FROM ContactShare WHERE ContactId IN :cons AND RowCause = 'Manual Sharing'];
      
      Delete oldJobShrs;
      
      Badge_Trigger.rss.ShareWithGroup(badges);                                      
      }

      Framework.Log.pop();
  }

}