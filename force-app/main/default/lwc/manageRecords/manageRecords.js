import { LightningElement, track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OpportunitiesController from '@salesforce/apex/OpportunitiesController.OpportunitiesController';
import getOpportunitiesCount from '@salesforce/apex/OpportunitiesController.getOpportunitiesCount';

const COLS = [
    { label: 'Opportunity', fieldName: 'Name', editable: true, sortable: "true" },
    { label: 'Account', fieldName: 'AccountName', editable: true , sortable: "true"},
    { label: 'Stage', fieldName: 'StageName', editable: true , sortable: "true"},
    { label: 'Close Date', fieldName: 'CloseDate', type: 'date', editable: true , sortable: "true"},
    { label: 'Amount', fieldName: 'Amount', type: 'currency', editable: true , sortable: "true"}
];
export default class FetchMultipleRecords extends LightningElement { 
    @track opportunities; 
    @track error;
    @track columns = COLS;
    @track sortBy;
    @track sortDirection; 
    @track isChecked;
    //pagination variables
    @api currentpage;  
    @api pagesize;  
    @track searchKey;  
    totalpages;  
    localCurrentPage = null;  
    isSearchChangeExecuted = false;      

    handleKeyChange(event) {  
        if (this.searchKey !== event.target.value) {  
            this.isSearchChangeExecuted = false;  
            this.searchKey = event.target.value;  
            this.currentpage = 1;  
        }  
    } 
    handleChange(event) {
        this.isChecked= event.target.checked;
    } 
    //Method to fetch the opportunities
    renderedCallback() {  
    // This line added to avoid duplicate/multiple executions of this code.  
    if (this.isSearchChangeExecuted && (this.localCurrentPage === this.currentpage)) {  
        return;  
    }  
    this.isSearchChangeExecuted = true;  
    this.localCurrentPage = this.currentpage;  
    getOpportunitiesCount({ searchString: this.searchKey, isAccountSearch: this.isChecked})  
        .then(recordsCount => {  
        this.totalrecords = recordsCount;
        if (recordsCount !== 0 && !isNaN(recordsCount)) {  
            this.totalpages = Math.ceil(recordsCount / this.pagesize);  
            OpportunitiesController({ pagenumber: this.currentpage, numberOfRecords: recordsCount, pageSize: this.pagesize, searchString: this.searchKey, isAccountSearch: this.isChecked })  
            .then(opportunitiesList => {  
                this.opportunities = opportunitiesList;  
                this.error = undefined;  
            })  
            .catch(error => {  
                this.error = error;  
                this.opportunities = undefined;  
            });  
        } else {  
            this.opportunities = [];  
            this.totalpages = 1;  
            this.totalrecords = 0;  
        }  
        const event = new CustomEvent('recordsload', {  
            detail: recordsCount  
        });  
        this.dispatchEvent(event);  
        })  
        .catch(error => {  
        this.error = error;  
        this.totalrecords = undefined;  
        });  
    } 
    //Sorting Logic 
    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;
        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldName, sortDirection){
        var data = JSON.parse(JSON.stringify(this.opportunities));
        //function to return the value stored in the field
        var key =(a) => a[fieldName]; 
        var reverse = sortDirection === 'asc' ? 1: -1;
        //Sorting the Currency fields
        if(fieldName === 'Amount'){ 
            data.sort(function(a,b){
                let valueA = key(a) ? key(a) : '';
                let valueB = key(b) ? key(b) : '';
                return reverse * ((valueA>valueB) - (valueB>valueA));
            }); 
        }else{
            data.sort((a,b) => {
                let valueA = key(a) ? key(a).toLowerCase() : '';
                let valueB = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((valueA > valueB) - (valueB > valueA));
            });
    
        }
        //set sorted data to opportunities attribute
        this.opportunities = data;
    }
    //Method to display the modal popup to create a new opportunity
    handlePopup() {
        this.template.querySelector("section").classList.remove("slds-hide");
        this.template
          .querySelector("div.modalBackdrops")
          .classList.remove("slds-hide");
    }
    //Method to close the Modal popup
    closePopup() {
        //To clear the input fields
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {   
                field.reset();
            });
        }
        //Hide popup
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
          .querySelector("div.modalBackdrops")
          .classList.add("slds-hide");
    }
    //Method to Save the opportunity and display the toast message upon successful save
    handleSave()
    {
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
          .querySelector("div.modalBackdrops")
          .classList.add("slds-hide");
          //Creating toast event
          const evt = new ShowToastEvent({
            title: 'Record Created',
            message: 'Record Created successfully ',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}