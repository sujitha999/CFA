/**
 *
 * Domain class for the User SObjectType
 * @author Vishal Shah
 *
 **/

global class User_Trigger extends Framework.Domain{

    public User_Trigger(List<User> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new User_Trigger(sObjectList);
        }
    }

    public override void afterInsert(){
        Framework.Log.push(User_Trigger.class.getName(),'afterInsert');
        UserGroupMemberService.addUserToGroupOnCreate((User[])records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(User_Trigger.class.getName(),'beforeUpdate');

        Framework.Log.pop();
    }

}