/**
 * @author Vishal Shah
 **/

public class HelperClass {
	public class Badge {

		public Id badge {set; get;}
		public Id contact {set; get;}
		public Id oldContact {set; get;}
		public Id businessGroup {set; get;}

	    public Badge (Id b, Id c, Id oc, Id bg) {
	    	badge = b;
	    	contact = c;
	    	oldContact = oc;
	    	businessGroup = bg;
	    }
	}

	public class GroupMember {

		public Id groupId {set; get;}
		public Id userOrGroupId {set; get;}

	    public GroupMember (Id g, Id u) {
	    	groupId = g;
	    	userOrGroupId = u;
	    }
	}
}