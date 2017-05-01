({  
  setFilterOptions : function(component,event,helper){
      var sortElement = component.find('ByName');
      component.set("v.isNotSearch", true);
      var action = component.get("c.getFields");
      var objectName = component.get('v.objectName');
      var fsName = component.get('v.fieldSetName');
      action.setParams({'ObjectName':objectName,
                        'fieldSetName':fsName});
      debugger;
      action.setCallback(this, function(response){
              console.log('callBack Executed');
              var state = response.getState();
              if(state== "SUCCESS") {
                  var data = response.getReturnValue();
                  var opts = [];
                  opts.push({label:'All', value:'All', selected:true});
                  Object.keys(data).forEach(function(key) {
                      opts.push({label:data[key], value: key});
                  });
                  component.find("sort").set("v.options", opts);
                }
                //  this.hideSpinner();
            });
            //this.showSpinner();
            $A.enqueueAction(action);
      component.set("v.pageNumber",0);
  },
  nextPage : function(component){
      var pageNumber = component.get("v.pageNumber");
      var caseList = component.get('v.caseList') || [];
      var displayCaseList = component.get('v.displayCaseList') || [];
      var offset = (pageNumber) * 8 + 1;
      if(offset <= caseList.length){
          component.set('v.displayCaseList', 
                        displayCaseList.concat(caseList.slice(offset-1, 8*(pageNumber+1))));
          component.set('v.pageNumber', ++pageNumber);
      }
  },
  updateCaseList : function(component){
      var self = this;
      var search = component.get("v.val");
      if(search.length > 2 || search.length==0){
          var sortBy = component.find("sort").get("v.value");
          var sortDirection = component.get("v.sortDirection") == 'Z-A' ? 'DESC' : 'ASC';
          if(!sortBy){
              sortBy = 'All';
          }
          var action = component.get("c.getCases");
          action.setParams({"search": search, "sortBy": sortBy, "sortDirection": sortDirection
                            , "ObjectName": component.get('v.objectName')});
          
          action.setCallback(this, function(response){
              console.log('callBack Executed');
              var state = response.getState();
              if(state== "SUCCESS") {
                  var caseList = response.getReturnValue();
                  component.set('v.objectWrapperData',caseList);
                  component.set('v.caseList',response.getReturnValue().detailValues);
                  self.nextPage(component);
                  component.set("v.pageNumber",0);
                  if(component.get('v.detailPageActivated')){
                      self.highlightSelected(component);
                  }
                  else{
                      component.set('v.displayCaseList', []);
                      self.getScrollEvent(component);
                      self.nextPage(component);
                  }
                }
            });
            $A.enqueueAction(action);
        } 
    },
  highlightSelected : function(component){
      var cases = component.get('v.caseList');
      _.each(cases, function(case1){
          if(case1.Id.includes(component.get('v.recordId'))){
              component.set('v.displayCaseList',case1);
          }
      });
      component.set('v.detailPageActivated',false);
  }
  ,
  getScrollEvent : function(component){
      var self = this;
      var caseListSection= document.getElementById("myTabContent");
      console.log('caseListSection',caseListSection);
      component.set("v.scrollActivated",true);
      var self = this;
      $(caseListSection).scroll(function () {
              var pageNumber = component.get('v.pageNumber');
              var scrollHeight = document.getElementById("myTabContent").scrollHeight;
              var scrollTop = document.getElementById("myTabContent").scrollTop; 
              var sectionHeight = $(caseListSection).height();
              if((scrollHeight == Math.ceil(sectionHeight + scrollTop)) && !component.get('v.fetchedAllRecords')){
                  console.log('event Fired');
                  var appEvent = component.getEvent("cmpEvent");
                  console.log('appEvent'+appEvent);
                  appEvent.fire();  
              }
          });
  },
    getHeaderLabels : function(component ,event, helper){
        var fsName = component.get('v.fieldSetToDisplayData');
        var action = component.get('c.getHeaders');
        action.setParams({ObjectName : component.get('v.objectName'),
                          fieldSetName : fsName});
        action.setCallback(this,function(response){
            debugger;
            if(response.getState() == 'SUCCESS'){
                component.set('v.objectWrapperData',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    toggle: function(cmp) {
        var spinner = cmp.find('spinner');
        var evt = spinner.get("e.toggle");
        
        if(!$A.util.hasClass(spinner, 'hideEl')){
            evt.setParams({ isVisible : false });
        }		
        else {
            evt.setParams({ isVisible : true });
        }
        evt.fire();
    }
})