/* eslint-disable */
import { LightningElement, api, track } from 'lwc';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import fetchLookUpValues from '@salesforce/apex/InputLookUp_Sch.fetchLookUpValues';
import fetchLookUpValueById from '@salesforce/apex/InputLookUp_Sch.fetchLookUpValueById';
const DELAY = 300;
export default class SearchComponent extends LightningElement {
	  @track searchRecordsempty = false;
      @api hideLabel = false;
    @api valueName;
    @api iconName = 'standard:account';
    @api labelName;
    @api readOnly = false;
    @api currentRecordId;
    @api placeholder = 'Search';
    @api createRecord;
    @api displayFields = 'Name, Rating, AccountNumber';
    @track error;
    @api id;
    @api required = false;
    @track message = '';
    searchTerm;
    delayTimeout;

    searchRecords;
    selectedRecord;
    objectLabel;
    isLoading = false;

    field;
    field1;
    field2;
    _fields = ['Name'];
    _filter = '';
    _objName = 'Account';

    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';
_valueId;

@api
get fields() {
    return this._fields;
}
set fields(value) {
    this._fields = this.normalizeFields(value);
}

@api
get filter() {
    return this._filter;
}
set filter(value) {
    this._filter = typeof value === 'string' ? value : '';
}

@api
get objName() {
    return this._objName;
}
set objName(value) {
    this._objName = typeof value === 'string' && value.trim() !== '' ? value : 'Account';
}

@api
get valueId() {
    return this._valueId;
}
set valueId(val) {
    if (val && val !== this._valueId) {
        this._valueId = val;
        this.fetchInitialRecord(val);
    }
}
get isRequired() {
    return this.required === true;
}
normalizeFields(value) {
    if (Array.isArray(value)) {
        return value;
    }
    if (typeof value === 'string' && value.trim() !== '') {
        return value.split(',').map(item => item.trim()).filter(Boolean);
    }
    return ['Name'];
}
getSearchFieldValue() {
    return this._fields.join(',');
}
getQueryFilterValue() {
    return this._filter;
}
fetchInitialRecord(recordId) { //adnan changed to Camel case ObjectName and SearchField
  fetchLookUpValueById({ objectName: this.objName, searchField: this.getSearchFieldValue(), recordId: recordId })
    .then(serverRecord => {
        if (serverRecord && serverRecord.Id && serverRecord.Name) {
            this.selectedRecord = { Id: serverRecord.Id, Name: serverRecord.Name, FIELD1: serverRecord.Name };
            this.searchTerm = '';
            this.isDropdownOpen = false;
        } else {
            console.warn('Invalid record returned from fetchLookUpValueById');
        }
    })
    .catch(error => {
        console.error('Error in fetchInitialRecord:', JSON.stringify(error));
    });
}

    connectedCallback(){
        const icons           = this.iconName.split(':');
        this.ICON_URL       = this.ICON_URL.replace('{0}',icons[0]);
        this.ICON_URL       = this.ICON_URL.replace('{1}',icons[1]);
        if(this.objName.includes('__c')){
            const obj = this.objName.substring(0, this.objName.length-3);
            this.objectLabel = obj.replaceAll('_',' ');
        }else{
            this.objectLabel = this.objName;
        }
        this.objectLabel    = this.titleCase(this.objectLabel);
        let fieldList;
        if( !Array.isArray(this.displayFields)){
            fieldList       = this.displayFields.split(',');
        }else{
            fieldList       = this.displayFields;
        }

        if(fieldList.length > 1){
            this.field  = fieldList[0].trim();
            this.field1 = fieldList[1].trim();
        }
        if(fieldList.length > 2){
            this.field2 = fieldList[2].trim();
        }
        const combinedFields = [];
        fieldList.forEach(field => {
            if( !this.fields.includes(field.trim()) ){
                combinedFields.push( field.trim() );
            }
        });
        if(this.valueId != null && this.valueId != ''){
            fetchLookUpValueById({ // adnan changed to camel case OjectName and SearchField
                objectName : this.objName,
                searchField     : this.getSearchFieldValue(),
                recordId : this.valueId
            })
            .then(serverRecord => {
                if(serverRecord != null || serverRecord != ''){
                    this.selectedRecord = {Id : serverRecord.Id, Name : serverRecord.Name,FIELD1 : serverRecord.Name};
														if(this.selectedRecord != null && this.selectedRecord != '' && this.selectedRecord != undefined) {
                                                            this.searchRecordsempty = false;
                                                            this.message = '';
                                                        }

                }

            })
            .catch(error => {
                console.error('Error:', error);
            })
        }
        //this.fields = combinedFields.concat( JSON.parse(JSON.stringify(this.fields)) );


    }

    handleInputChange(event){
        window.clearTimeout(this.delayTimeout);
        let searchKey = event.target.value;
        if(searchKey == '' || searchKey == null || searchKey == undefined) searchKey = '';

        //this.isLoading = true;
        this.delayTimeout = setTimeout(() => {
                fetchLookUpValues({
                    request : {
                        searchKeyWord : searchKey,
                        objectName : this.objName, //adnan changed to camel case
                        queryFilter : this.getQueryFilterValue(),
                        searchField : this.getSearchFieldValue()   //adnan changed to camel case
                    }
                })
                //changes end here by abuzar
                .then(serverRecords => {
                    const records = Array.isArray(serverRecords)
                        ? serverRecords.map(record => ({ ...record }))
                        : [];
                    records.forEach( record => {
                        record.FIELD1 = record[this.Name];
                        if(this.field2){
                            record.FIELD2 = record[this.field1];
                        }
                       else {
                        record.FIELD2 = '';
                       }
                        if( this.field2 ){
                            record.FIELD3 = record[this.field2];
                        }else{
                            record.FIELD3 = '';
                        }
                    });
                    this.searchRecords = records;
                    if(this.searchRecords.length == 0){this.searchRecordsempty = true; this.message = 'No Records To display';}else {this.searchRecordsempty = false; this.message = '';}
                })
                .catch(error => {
                    console.error('Error:', error);
                })
                .finally( ()=>{
                    //this.isLoading = false;
                });
           // }
        }, DELAY);
    }

   handleSelect(event) {
    const recordId = event.currentTarget.dataset.recordId;
    if (!recordId || recordId === '' || recordId === undefined) {
        console.warn('Invalid recordId in handleSelect');
        return;
    }
    const selectRecord = this.searchRecords.find((item) => item.Id === recordId);
    if (selectRecord) {
        this.selectedRecord = selectRecord;
        this.searchRecordsempty = false;
        this.message = '';
        const selectedEvent = new CustomEvent('lookup', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                data: {
                    record: selectRecord,
                    recordId: recordId,
                    currentRecordId: this.currentRecordId
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    } else {
        console.warn('No matching record found for recordId:', recordId);
    }
}

   /* @api handleClose(event){
        console.log('close called');
        this.selectedRecord = undefined;
        this.searchRecords  = undefined;
       /* const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {
                record ,
                recordId,
                currentRecordId : this.currentRecordId
            }
        });
        console.log('close called ends' );
        this.dispatchEvent(new CustomEvent('remove'));

    }*/
   @api handleClose(event) {
    this.selectedRecord = undefined;
    this.searchRecords = [];
    this.searchTerm = '';
    this.searchRecordsempty = false;
    this.message = '';
    const inputElement = this.template.querySelector('input');
    if (inputElement) {
        inputElement.value = '';
    }
    this.dispatchEvent(new CustomEvent('remove'));
}


   /* titleCase(string) {
        var sentence = string.toLowerCase().split(" ");
        console.log(sentence);
        for(var i = 0; i< sentence.length; i++){
            sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
        }
        console.log('after : ',sentence);
        return sentence;
    }*/
    titleCase(str) {
    if (!str) {
        return '';
    }

    return str
        .trim()                  // remove leading/trailing spaces
        .toLowerCase()
        .split(/\s+/)            // split on ANY whitespace, handles multiple spaces
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
}

    valueChanged(event){
    }
}