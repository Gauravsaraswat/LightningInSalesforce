# LightningInSalesforce

To Show All Existing Records With better filter criterion and with their sorting order as well. 
This component is having a Pick-list of field Names which will be used to filter all records based on the selected value in the pick-list and basis on the selected value in the Pick-list, Search Functionality will also work for all records. And One Additional Button Is given to sort all records in Ascending or Descending Direction. 
Complete Component has been divided into two column. First Column will be having the list view and second column will be used to show the detail Record view of selected records from the list view itself. 
As Lightning Does not Have any view state Issue, So All Records will be fetched at a single time on the client side and then With the use of Infinity Scrolling Pagination Feature, All Records are getting shown to the user

To Use this component in your org we will be first needing to create two field Sets of a particular object for which we want to show records in list View.

One Field Set Will be used to Set All Those Fields based on those we want to filter in list view. :- FieldsToFilter
Second Field Set Will decide all those fields which will be displayed on the list view. :- FieldsToDisplay

 <c:ObjectListComponent objectName="Contact" 
                           fieldSetName="FieldsToFilter" 
                           fieldSetToDisplayData="FieldsToDisplay" />

To User ObjectList Component We need to set three parameters as described above. In My Example I had Created Two Field Set 'FieldsToFilter' And 'FieldsToDisplay' As previously Mentioned. And You need to set the objectName as well. 


Once component successfully deploys in the org, User Can view the component as defined in the screenshot above.
User Can Search for a particular Record using search box.
User Can Use the picklist value to sort or change the search criterion. 
User Can Use Ascending And Descending Button To change the sorting order.
