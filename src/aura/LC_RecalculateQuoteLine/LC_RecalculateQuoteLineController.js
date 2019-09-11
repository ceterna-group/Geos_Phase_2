({
	 doInit: function(component,event,helper) {
    	var action=component.get("c.reCalculateAffectedOpportunities");
        action.setParams({
                          "mdpId":component.get("v.recordId")
                          });
        action.setCallback(this, function(response){
        var state = response.getState();
            if (state === "SUCCESS") {
    			var toastEvent = $A.get("e.force:showToast");
       			toastEvent.setParams({
                    "title": 'Success!',
                    "message": 'Successfully executed opportunity revalidation',
                   "type":'Success'
                  });
            	$A.get('e.force:refreshView').fire();
    		}else{
    			var toastEvent = $A.get("e.force:showToast");
       			toastEvent.setParams({
                    "title": 'Error!',
                    "message": 'Some error occurred. Please contact Admin!',
                   "type":'Error'
                  });
            	$A.get('e.force:refreshView').fire();

    		}
    		console.log('chec vals--'+response.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})