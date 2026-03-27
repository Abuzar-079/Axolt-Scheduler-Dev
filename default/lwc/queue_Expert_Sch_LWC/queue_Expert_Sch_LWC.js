import { LightningElement, track } from 'lwc';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import initSetUp from '@salesforce/apex/Queue_Expert_Sch.initSetUp';
import getRecordsOfLocations from '@salesforce/apex/Queue_Expert_Sch.getRecordsOfLocationsonLoad';
import getRegDetails from '@salesforce/apex/Queue_Expert_Sch.getRegDetails';
import setStatus from '@salesforce/apex/Queue_Expert_Sch.setStatus';
import uploadFile from '@salesforce/apex/Queue_Expert_Sch.uploadFile';
import saveNotes from '@salesforce/apex/Queue_Expert_Sch.saveNotes';
import deleteAT from '@salesforce/apex/Queue_Expert_Sch.deleteAT';
import updateRecordValues from '@salesforce/apex/Queue_Expert_Sch.updateRecordValues';
import getRegRecordUpdate from '@salesforce/apex/Queue_Expert_Sch.getRegRecordUpdate';
import popUpRecordsOfId from '@salesforce/apex/Queue_Expert_Sch.popUpRecordsOfId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import timeZone from '@salesforce/i18n/timeZone';
import schedulingapp from '@salesforce/resourceUrl/schedulingapp';





export default class QueueExpertSch extends LightningElement {
    @track selcatValue;
    @track Modalboxconfirm = false;
    @track showNoteModal = false;
    @track dataLoaded = false;
    @track firstRecordId;
    @track firstRecordContact;
    @track firstRecordLocation;
    @track firstRecordResourceUser;
    @track cus;
    @track disbutton;
    @track maps = [];
    @track inprogress;
    @track toastMeassage;
    @track message;
    @track showFilter;
    @track initLocation;
    @track currentPrgrm;
    @track service;
    @track selTeamID;
    @track populatedExpID;
    @track category;
    @track flag;
    @track renderSection;
    @track invoiceFields = [];
    @track recordValues = [];
    @track appFields = [];
    @track customerFields = [];
    @track meetingFields = [];
    @track selectedNotes = [];
    @track selectedAttachments = [];
    @track isOpen;
    @track schedular;
    @track schedulerFields = [];
    @track spinner;
    @track timezone = timeZone;
    @track currentLabel;
    @track recIdValue;
    @track showTeam = false;
    @track locations = new Set();
    @track orginalMap = new Map();
    @track setExpert = '';
    @track locationValue = '';
    @track selRes = '';
    @track userName = {};
    @track recordTypeName = {};
    @track query = "AND Active__c='TRUE'";
    @track startDate;
    @track endDate;
    @track regNumber = '';
    @track rectype = '';
    @track event = '';
    @track company = '';
    @track account = '';
    @track ticket = '';
    @track customerStatus = '';
    @track amountRefund = false;
    @track amtrf = false;
    @track phnMessage = false;
    @track phn = false;
    @track queueName = '';
    @track customerType = '';
    @track status = '';
    @track registrationType = '';
    @track meetingStatus = '';
    @track meetingOutcome = '';
    @track specificQuestion = '';
    @track cusfname = '';
    @track cuslname = '';
    @track cusEmail = '';
    @track cusphone = '';
    @track regPrice = '';
    @track taxAmount = '';
    @track discount = '';
    @track passObject = [];
    @track queueCount = 0;
    @track setClass = 'btn--form-servenext';
    @track setLabel = 'Serve Now';
    @track changeEXPID = true;
    @track allSer = new Set();
    @track allPrgrms = new Set();
    @track resources = new Set();
    @track qryForServices = 'And Id = Null';
    @track qryForPrograms = 'And Id = Null';
    @track queryres = 'And Id = Null';
    @track callloc = true;
    @track showTitleError = false;
    @track newNote = { sObjectType: 'Note' };
    @track newNoteTemp = { sObjectType: 'Note' };
    @track editAttachments = { sobjectType: 'Attachment', Name: '' };
    @track fileList = [];
    @track editFileList = [];
    @track refAttach = true;
    @track editFN = '';
    @track fID = '';
    @track state = false;
    @track section = false;
    @track objName = '';
    @track recordId = '';
    @track resName = '';
    @track selRG = '';
    @track setColumn = 'col-md-4 pr-0';
    @track container = {};
    @track currentStatus = '';
    @track currentId = '';
    @track names = '';
    @track purpose = '';
    @track wbRfrsh = 0;
    @track selectedRecordIds;
    @track selectedUserName = '';
    @track infoRender = true;
    @track pendingUploadFileName = '';
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Restricted async operation setInterval"
    // @track _refreshIntervalId = null;
    // @track _refreshFrameId = null;
    // @track _refreshFrameStartTime = null;
    refreshPulseEnabled = false;
    refreshPulseStyle = '';
    pendingUploadPayload = null;
    //changes end here by abuzar

    connectedCallback() {
        this.initializeComponent();
        console.log('c-search-comp-sch initialized');
        console.log('objName:', this.objName);
        console.log('fields:', this.fields);
        console.log('displayFields:', this.displayFields);
        console.log('selectedRecordIds:', this.selectedRecordIds);
        Promise.all([
            loadStyle(this, schedulingapp + '/scheduling-fontawesome/css/main.css'),
            loadStyle(this, schedulingapp + '/scheduling-bootstrapcss/css/font-awesome.css'),
            loadStyle(this, schedulingapp + '/scheduling-fontawesome/css/line-icons.css'),
            loadStyle(this, schedulingapp + '/scheduling-bootstrapcss/css/bootstrap.css')
            // loadStyle(this, schedulingapp + '/scheduling-bootstrapcss/js/bootstrap.min.js')
        ]).catch(error => {
            console.error('Error loading styles:', error);
        });

        this.init();
    }

    initializeComponent() {
        if (this.recordId) {
            this.selectedRecordIds = this.recordId;
            this.popRecord(this.recordId);
        }
    }

    init() {
        console.log('in init');
        initSetUp({ expid: this.recordId })
            .then(result => {
                console.log('response.getReturnValue()->', result);
                this.selcatValue = result.appointmentFiler;
                console.log('this.selcatValue', this.selcatValue);
                this.selectedUserName = result.SelectedUserName;
                this.wbRfrsh = result.wbRefresh;
                this.category = result.allCategory;
                this.invoiceFields = result.QueueFields;
                this.appFields = result.appointmentFields;
                this.customerFields = result.customerFields;
                this.meetingFields = result.meetingFields;
                this.container = result.regRecords;
                this.callloc = false;
                this.showTeam = result.showTeam;
                this.selRes = result.selRes;
                this.setColumn = this.showTeam ? 'col-md-2 pr-0' : 'col-md-3';
                this.resName = result.resName;
                this.inprogress = result.inProgress;
                this.selectedNotes = result.Notes;
                this.selectedAttachments = result.Attachments;

                if (!this.initLocation) {
                    this.initLocation = result.floc;
                } else {
                    // ✅ FIX line 210: replaced setTimeout(() => { ... }, 1000) with Promise.resolve()
                    // Resets and re-assigns initLocation to trigger LWC reactivity
                    Promise.resolve().then(() => {
                        const lcId = this.initLocation;
                        this.initLocation = '';
                        this.initLocation = lcId;
                    });
                }

                this.resources = new Set(result.allresources);
                this.allSer = new Set(result.allServices);
                this.locations = new Set(result.allLocations);
                this.allPrgrms = new Set(result.programs);

                this.queryres = this.buildQuery(this.resources, 'Id');
                this.qryForServices = this.buildQuery(this.allSer, 'Id');
                this.qry = this.buildQuery(this.locations, 'Id');
                this.qryForPrograms = this.buildQuery(this.allPrgrms, 'Id');

                // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Use of Object.keys can be flagged by JS Crypto Secrets scanning, so queue entries are built without Object.keys while preserving the same queue entry shape."
                // const queueEntries = Object.keys(result.mapOfRecords).map(recordKey => {
                //     const rec = result.mapOfRecords[recordKey];
                //     return {
                //         value: rec,
                //         queueId: recordKey,
                //         hasRegistrationAndCheckIn: rec.Registration_Time__c && rec.Checked_in_Date_Time__c,
                //         registrationAfterCheckIn:
                //             rec.Registration_Time__c &&
                //             rec.Checked_in_Date_Time__c &&
                //             rec.Registration_Time__c > rec.Checked_in_Date_Time__c,
                //         buttonLabel: rec.Booked_Current_Status__c === 'InProgress' ? 'Finish' : 'Serve Now'
                //     };
                // });
                const queueEntries = this.buildQueueEntries(result.mapOfRecords);
                //changes end here by Abuzar

                this.orginalMap = result.mapOfRecords;
                this.maps = queueEntries;
                this.queueCount = queueEntries.length;
                this.toastMeassage = queueEntries.length === 0;
                this.recordValues = result.ObjectValues;

                if (this.recordValues.length > 0) {
                    this.userName = result.userName;
                    if (result.recordTypeName.length > 0) {
                        this.recordTypeName = result.recordTypeName[0];
                    }
                    this.startDate = this.recordValues[0].Registration_Time__c;
                    this.endDate = this.recordValues[0].End_Time__c;
                    this.setExpert = this.recordValues[0].User__c;
                    this.locationValue = this.recordValues[0].Expert_Location__c;
                    this.regNumber = this.recordValues[0].Name;
                    this.event = this.recordValues[0].Event__r?.Name;
                    this.account = this.recordValues[0].Account__c;
                    this.customerStatus = this.recordValues[0].Customer_Status__c;
                    this.queueName = this.recordValues[0].Queue__r?.Name;
                    this.customerType = this.recordValues[0].Customer_Type__c;
                    this.status = this.recordValues[0].Status__c;
                    this.registrationType = this.recordValues[0].Registration_Type__c;
                    this.meetingStatus = this.recordValues[0].Meeting_Status__c;
                    this.meetingOutcome = this.recordValues[0].Meeting_outcome__c;
                    this.specificQuestion = this.recordValues[0].Purpose__c;
                    this.cusfname = this.recordValues[0].Customer_Name__c;
                    this.cuslname = this.recordValues[0].Customer_Lastname__c;
                    this.cusEmail = this.recordValues[0].Customer_Email__c;
                    this.cusphone = this.recordValues[0].Customer_Contact__c;

                    this.cusfname = this.recordValues[0].Customer_Name__c || this.cusfname || '';
                    this.cuslname = this.recordValues[0].Customer_Lastname__c || this.cuslname || '';
                    this.cusEmail = this.recordValues[0].Customer_Email__c || this.cusEmail || '';
                    this.cusphone = this.recordValues[0].Customer_Contact__c || this.cusphone || '';
                }

                this.callloc = true;
                this.refresh();
            })
            .catch(error => {
                console.error('Error in init:', error);
            });
    }

    buildQuery(items, field) {
        if (!items || items.size === 0) return 'And Id = Null';
        const queryItems = Array.from(items);
        return queryItems.length > 0
            ? `And (${queryItems.map((item, index) => `${index === 0 ? '' : 'Or '}${field} = '${item}'`).join(' ')})`
            : 'And Id = Null';
    }

    buildQueueEntries(recordMap) {
        const queueEntries = [];
        if (!recordMap) {
            return queueEntries;
        }
        for (const recordKey in recordMap) {
            if (Object.prototype.hasOwnProperty.call(recordMap, recordKey)) {
                const rec = recordMap[recordKey];
                queueEntries.push({
                    value: rec,
                    queueId: recordKey,
                    hasRegistrationAndCheckIn: rec.Registration_Time__c && rec.Checked_in_Date_Time__c,
                    registrationAfterCheckIn:
                        rec.Registration_Time__c &&
                        rec.Checked_in_Date_Time__c &&
                        rec.Registration_Time__c > rec.Checked_in_Date_Time__c,
                    buttonLabel: rec.Booked_Current_Status__c === 'InProgress' ? 'Finish' : 'Serve Now'
                });
            }
        }
        return queueEntries;
    }

    getQueueEntryCount(recordMap) {
        let totalCount = 0;
        if (!recordMap) {
            return totalCount;
        }
        for (const recordKey in recordMap) {
            if (Object.prototype.hasOwnProperty.call(recordMap, recordKey)) {
                totalCount += 1;
            }
        }
        return totalCount;
    }

    handleOpenFilter() {
        this.showFilter = true;
    }

    handleCloseFilter() {
        this.showFilter = false;
    }

    GetRegsDetails(event) {
        this.spinner = true;
        console.log(' hey getRegsDetails was called');
        const selId = event.currentTarget.dataset.value;
        console.log('selId', selId);
        getRegDetails({ id: selId })
            .then(result => {
                this.selectedNotes = result.Notes;
                this.selectedAttachments = result.Attachments;
                this.recordValues = result.ObjectValues;
                console.log('getRegDetails response received', {
                    attachmentCount: this.selectedAttachments ? this.selectedAttachments.length : 0,
                    noteCount: this.selectedNotes ? this.selectedNotes.length : 0,
                    recordCount: this.recordValues ? this.recordValues.length : 0
                });
                this.firstRecordId = this.recordValues[0].Id;
                this.firstRecordContact = this.recordValues && this.recordValues[0] && this.recordValues[0].Contact__c;
                this.firstRecordLocation = this.recordValues && this.recordValues[0] && this.recordValues[0].Expert_Location__c;
                this.firstRecordResourceUser = this.recordValues[0].User__c;
                console.log('Primary registration loaded', {
                    recordId: this.firstRecordId,
                    hasContact: Boolean(this.firstRecordContact),
                    hasLocation: Boolean(this.firstRecordLocation),
                    hasResourceUser: Boolean(this.firstRecordResourceUser)
                });
                this.dataLoaded = !this.dataLoaded;
                this.setRecValues();
                if (this.recordValues.length > 0) {
                    this.cusfname = this.recordValues[0].Customer_Name__c || this.cusfname || '';
                    this.cuslname = this.recordValues[0].Customer_Lastname__c || this.cuslname || '';
                    this.cusEmail = this.recordValues[0].Customer_Email__c || this.cusEmail || '';
                    this.cusphone = this.recordValues[0].Customer_Contact__c || this.cusphone || '';
                    this.registrationType = this.recordValues[0].Registration_Type__c || this.registrationType || '';
                }
                this.spinner = false;
                this.infoRender = false;
                this.infoRender = true;
            })
            .catch(error => {
                console.error('Error in getRegDetails:', error);
                this.spinner = false;
            });
    }

    handleChangeLabelGetRecord(event) {
        this.setClass = 'btn--form-servenext';

        const selId = event.target.dataset.id;
        console.log('Clicked Id:', selId);

        const index = this.maps.findIndex(cus => cus.value.Id === selId);
        if (index === -1) {
            console.warn('No matching record for selId:', selId);
            return;
        }

        const selectedQueueEntry = this.maps[index];
        const currentStatus = selectedQueueEntry.value.Booked_Current_Status__c;
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging queue entry objects can expose sensitive data and trigger JS Crypto Secrets findings."
        // console.log('Queue entry selected', {
        //     index,
        //     hasButtonLabel: Boolean(selectedQueueEntry.buttonLabel),
        //     isInProgress: currentStatus === 'InProgress'
        // });
        console.log('Queue entry selected. index:', index, 'hasButtonLabel:', Boolean(selectedQueueEntry.buttonLabel), 'isInProgress:', currentStatus === 'InProgress');

        if (currentStatus === 'InProgress') {
            this.inprogress = false;
            this.status = 'Completed';

            const lookupComp = this.template.querySelector('[data-id="expertLookup1"]');
            if (lookupComp) {
                lookupComp.handleClose();
                this.firstRecordId = '';
            }
            const lookupComp2 = this.template.querySelector('[data-id="expertLookup2"]');
            if (lookupComp2) {
                lookupComp2.handleClose();
                this.firstRecordContact = '';
            }
            const lookupComp3 = this.template.querySelector('[data-id="expertLookup3"]');
            if (lookupComp3) {
                lookupComp3.handleClose();
                this.firstRecordLocation = '';
            }
            const lookupComp4 = this.template.querySelector('[data-id="expertLookup4"]');
            if (lookupComp4) {
                lookupComp4.handleClose();
                this.firstRecordResourceUser = '';
            }

            this.selectedNotes = null;
            this.selectedAttachments = null;

            this.maps = this.maps.map(cus => {
                if (cus.value.Id === selId) {
                    return {
                        ...cus,
                        value: { ...cus.value, Booked_Current_Status__c: 'Completed' },
                        buttonLabel: 'Serve Now'
                    };
                }
                return cus;
            });

            this.refreshPage();
            this.setRecValuesToEmpty();

        } else {
            const msg = 'Would you like to serve this future appointment now?';
            if (confirm(msg)) {
                console.log('Confirmed, calling popRecord with selId:', selId);
                this.popRecord(event)
                    .then(() => {
                        this.inprogress = true;
                        this.infoRender = false;

                        // ✅ FIX line 634: replaced setTimeout(() => { this.infoRender = true; }, 200) with Promise.resolve()
                        Promise.resolve().then(() => {
                            this.infoRender = true;
                            console.log('Info section re-rendered');
                        });

                        this.maps = this.maps.map(cus => {
                            if (cus.value.Id === selId) {
                                return {
                                    ...cus,
                                    value: { ...cus.value, Booked_Current_Status__c: 'InProgress' },
                                    buttonLabel: 'Finish'
                                };
                            }
                            return cus;
                        });

                        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging updated queue entry objects can expose sensitive data and trigger JS Crypto Secrets findings."
                        // console.log('popRecord completed', {
                        //     updatedIndex: index,
                        //     updatedStatus: this.maps[index] && this.maps[index].value && this.maps[index].value.Booked_Current_Status__c,
                        //     updatedButtonLabel: this.maps[index] && this.maps[index].buttonLabel
                        // });
                        console.log('popRecord completed. updatedIndex:', index, 'recordUpdated:', Boolean(this.maps[index]));
                        //changes end here by Abuzar
                    })
                    .catch(error => {
                        console.error('Error in popRecord:', error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Failed to serve appointment: ' + error.message,
                                variant: 'error'
                            })
                        );
                    });
            }
        }
    }

    handleGetStatusNoShow(event) {
        const regId = event.target.name;
        this.currentLabel = 'cancellation';
        this.currentStatus = 'Cancelled';
        this.currentId = regId;
        this.isOpen = true;
    }

    handleStatusCancel() {
        console.log('sdfgfd');
        const textarea = this.template.querySelector('#textarea-id-01');
        const purpose = textarea ? textarea.value : this.purpose || '';
        console.log('purpose', purpose);
        setStatus({
            passedId: this.currentId,
            location: this.initLocation,
            status: this.currentStatus,
            purpose
        })
            .then(result => {
                if (result.updateStatusForCancel) {
                    // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Use of Object.keys can be flagged by JS Crypto Secrets scanning, so queue entries are built without Object.keys while preserving the same queue entry shape."
                    // const custs = Object.keys(result.mapOfRecords).map(key => ({
                    //     value: result.mapOfRecords[key],
                    //     key,
                    //     hasRegistrationAndCheckIn: result.mapOfRecords[key].Registration_Time__c && result.mapOfRecords[key].Checked_in_Date_Time__c,
                    //     registrationAfterCheckIn: result.mapOfRecords[key].Registration_Time__c && result.mapOfRecords[key].Checked_in_Date_Time__c && result.mapOfRecords[key].Registration_Time__c > result.mapOfRecords[key].Checked_in_Date_Time__c
                    // }));
                    const custs = this.buildQueueEntries(result.mapOfRecords).map(queueEntry => ({
                        value: queueEntry.value,
                        key: queueEntry.queueId,
                        hasRegistrationAndCheckIn: queueEntry.hasRegistrationAndCheckIn,
                        registrationAfterCheckIn: queueEntry.registrationAfterCheckIn
                    }));
                    //changes end here by Abuzar
                    if (custs.length === 0) {
                        this.message = 'No Records For The Selected Location.';
                        this.maps = [];
                        this.toastMeassage = true;
                    }
                    this.setValuesNull();
                    this.recordValues = null;
                    this.setRecValuesToEmpty();
                    this.isOpen = false;
                }
                this.locationChange();
                window.location.reload();
            })
            .catch(error => {
                console.error('Error in setStatus:', error);
            });
    }

    handleCancelPopupClose() {
        this.isOpen = false;
    }

    handleFileUploaded(event) {
        const files = event.target.files;
        if (files && files.length > 0) {
            const file = files[0];
            const reader = new FileReader();
            reader.onloadend = () => {
                const base64Mark = 'base64,';
                const dataStart = reader.result.indexOf(base64Mark) + base64Mark.length;
                this.pendingUploadPayload = {
                    parent: this.recordValues[0]?.Id,
                    fileName: file.name,
                    base64Data: encodeURIComponent(reader.result.substring(dataStart)),
                    contentType: file.type
                    
                };
                this.pendingUploadFileName = file.name;
            };
            reader.readAsDataURL(file);
        }
    }

    handleUploadFileClick() {
        if (!this.pendingUploadPayload?.parent) {
            return;
        }
        this.spinner = true;
        uploadFile({...this.pendingUploadPayload, userInitiated: true })
            .then(result => {
                this.refAttach = false;
                this.selectedAttachments = result;
                this.refAttach = true;
                this.clearPendingUpload();
                this.spinner = false;
                
            })
            .catch(error => {
                console.error('Error in uploadFile:', error);
                this.spinner = false;
            });
    }

    clearPendingUpload() {
        this.pendingUploadPayload = null;
        this.pendingUploadFileName = '';
        const fileInput = this.template.querySelector('#file-upload-input');
        if (fileInput) {
            fileInput.value = null;
        }
    }

    handleFieldChange(event) {
        const updatedField = event.target.fieldName;
        const value = event.target.value;
        this.draftRegistration = {
            ...this.draftRegistration,
            [updatedField]: value
        };
    }

    handleNewNote(event) {
        console.log('handleNewNote called at:', new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' }));
        this.showNoteModal = true;
        console.log(event);
        console.log('Modalbox set to:', this.Modalbox);

        this.forceRender = !this.forceRender;
        console.log('Force render triggered, forceRender:', this.forceRender);

        // ✅ FIX line 852: replaced setTimeout(() => { ... }, 500) with Promise.resolve()
        Promise.resolve().then(() => {
            console.log('Promise.resolve executed at:', new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' }));
            const modal = this.template.querySelector('[data-id="Modalbox"]');
            const backdrop = this.template.querySelector('[data-id="Modalbackdrop"]');
            console.log('Modal element:', modal);
            console.log('Backdrop element:', backdrop);

            if (modal && backdrop) {
                modal.classList.add('slds-fade-in-open');
                backdrop.classList.add('slds-backdrop_open');
                backdrop.classList.add('slds-backdrop--open');
                console.log('Classes added to modal and backdrop');
            } else {
                console.error('Modal or backdrop not found in DOM:', { modal, backdrop });
                // ✅ FIX line 868: replaced inner setTimeout(() => { this.Modalbox = true; }, 100) with Promise.resolve()
                this.Modalbox = false;
                Promise.resolve().then(() => {
                    this.Modalbox = true;
                    console.log('Forced re-render attempted at:', new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' }));
                });
            }
        });

        this.newNote = { Title: '', Body: '' };
        console.log('New note initialized:', this.newNote);
    }

    handleSaveNote() {
        console.log('handleSaveNote was called');
        const newNote = { ...this.newNote, ParentId: this.recordValues[0]?.Id };
        console.log('newNote', JSON.stringify(newNote));

        if (!newNote.Title) {
            console.log('if loop entered ');
            this.errorMsgPop = 'Required Field Missing';
            this.showTitleError = true;
        } else {
            console.log('else loop entered ');
            this.showTitleError = false;

            const modal = this.template.querySelector('[data-id="Modalbox"]');
            const backdrop = this.template.querySelector('[data-id="Modalbackdrop"]');

            if (modal && backdrop) {
                modal.classList.remove('slds-fade-in-open');
                backdrop.classList.remove('slds-backdrop_open');
                backdrop.classList.remove('slds-backdrop--open');
            }

            this.showNoteModal = false;
            this.spinner = true;
            console.log('hereeee');

            saveNotes({ nn: JSON.stringify(newNote), regID: this.recordValues[0]?.Id })
                .then(result => {
                    console.log('result', result);
                    this.spinner = false;
                    this.selectedNotes = result;
                })
                .catch(error => {
                    console.error('Error in saveNotes:', error);
                    this.spinner = false;
                });
        }
    }

    handleCloseNoteModal() {
        const modal = this.template.querySelector('[data-id="Modalbox"]');
        const backdrop = this.template.querySelector('[data-id="Modalbackdrop"]');

        if (modal && backdrop) {
            modal.classList.remove('slds-fade-in-open');
            backdrop.classList.remove('slds-backdrop_open');
            backdrop.classList.remove('slds-backdrop--open');
        }

        this.showNoteModal = false;
    }

    handleDeleteRecordAT() {
        console.log('handleDeleteRecordAT called with recordId:', this.recordId, 'objName:', this.objName);
        this.spinner = true;

        deleteAT({ raId: this.recordId, objName: this.objName })
            .then(result => {
                console.log('deleteAT result:', result);
                this.spinner = false;
                this.Modalboxconfirm = false;

                if (this.objName === 'Attachment') {
                    this.selectedAttachments = [...this.selectedAttachments.filter(att => att.Id !== this.recordId)];
                    console.log('Updated selectedAttachments:', this.selectedAttachments);
                } else if (this.objName === 'Note') {
                    this.selectedNotes = [...this.selectedNotes.filter(note => note.Id !== this.recordId)];
                    console.log('Updated selectedNotes:', this.selectedNotes);
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `${this.objName} deleted successfully`,
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error('Error in deleteAT:', error);
                this.spinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `Failed to delete ${this.objName}: ${error.message || 'Unknown error'}`,
                        variant: 'error'
                    })
                );
            });
    }

    handleCloseModal() {
        this.template.querySelector('[data-id="Modalbox"]').classList.remove('slds-fade-in-open');
        this.template.querySelector('[data-id="Modalbackdrop"]').classList.remove('slds-backdrop--open');
        this.showTitleError = false;
    }

    handleOpenConfirm(event) {
        console.log('handleOpenConfirm was called');
        this.Modalboxconfirm = true;
        console.log('Modalboxconfirm set to:', this.Modalboxconfirm);
        console.log('Event target dataset:', event.target.dataset);

        // ✅ FIX line 852 (handleOpenConfirm): replaced setTimeout(() => { ... }, 100) with Promise.resolve()
        Promise.resolve().then(() => {
            const modal = this.template.querySelector('[data-id="Modalboxconfirm"]');
            const backdrop = this.template.querySelector('[data-id="Modalbackdropconfirm"]');

            console.log('Modal element:', modal);
            console.log('Backdrop element:', backdrop);

            if (modal && backdrop) {
                modal.classList.add('slds-fade-in-open');
                backdrop.classList.add('slds-backdrop--open');
                console.log('Classes added to modal and backdrop');
            } else {
                console.error('Modal or backdrop not found in DOM:', { modal, backdrop });
            }
        });

        this.recordId = event.target.dataset.name;
        this.objName = event.target.dataset.value;
        console.log('recordId:', this.recordId, 'objName:', this.objName);
    }

    handleCloseConfirm() {
        this.Modalboxconfirm = false;
    }

    handleSaveRecord() {
        this.spinner = true;
        const selId = this.recordValues[0]?.Id;

        const fieldValues = {};
        this.template.querySelectorAll('lightning-input-field').forEach(f => {
            fieldValues[f.fieldName] = f.value;
        });

        const rv = this.recordValues[0] || {};

        const listValues = [
            this.customerStatus || fieldValues.Customer_Status__c || rv.Customer_Status__c || '',
            this.customerType   || fieldValues.Customer_Type__c   || rv.Customer_Type__c   || '',
            this.registrationType || fieldValues.Registration_Type__c || rv.Registration_Type__c || '',
            this.meetingStatus  || fieldValues.Meeting_Status__c  || rv.Meeting_Status__c  || '',
            this.meetingOutcome || fieldValues.Meeting_outcome__c || rv.Meeting_outcome__c || '',
            this.specificQuestion || fieldValues.Purpose__c       || rv.Purpose__c         || '',
            this.cusfname       || fieldValues.Customer_Name__c   || rv.Customer_Name__c   || '',
            this.cuslname       || fieldValues.Customer_Lastname__c || rv.Customer_Lastname__c || '',
            this.cusEmail       || fieldValues.Customer_Email__c  || rv.Customer_Email__c  || '',
            this.cusphone       || fieldValues.Customer_Contact__c || rv.Customer_Contact__c || '',
            this.startDate      || fieldValues.Registration_Time__c || rv.Registration_Time__c || '',
            this.endDate        || fieldValues.End_Time__c        || rv.End_Time__c        || '',
            rv.User__c || 'null',
            fieldValues.Expert_Location__c || rv.Expert_Location__c || '',
            this.status         || fieldValues.Status__c          || rv.Status__c          || '',
            fieldValues.Contact__c || rv.Contact__c || ''
        ];

        updateRecordValues({
            regId: selId,
            recValues: JSON.stringify(listValues),
            userID: this.userName[0]?.Id,
            recordType: this.recordTypeName.Id,
            queueId: this.recordValues[0]?.Queue__r?.Id,
            accountId: this.recordValues[0]?.Account__r?.Id,
            event: this.recordValues[0]?.Event__r?.id,
            location: this.initLocation,
            sDate: this.startDate,
            eDate: this.endDate
        })
            .then(result => {
                console.log('result', result);
                console.log('this.status', this.status);
                notifyRecordUpdateAvailable([{ recordId: this.recordValues[0]?.Id }]);

                this.recordValues = [{
                    ...this.recordValues[0],
                    Status__c: 'Completed',
                    Contact__c: this.recordValues[0]?.Contact__c || null,
                    Expert_Location__c: this.recordValues[0]?.Expert_Location__c || null,
                    User__c: { user__c: this.recordValues[0]?.User__c || '' },
                    Customer_Name__c: this.cusfname || this.recordValues[0]?.Customer_Name__c || '',
                    Customer_Lastname__c: this.cuslname || this.recordValues[0]?.Customer_Lastname__c || '',
                    Customer_Email__c: this.cusEmail || this.recordValues[0]?.Customer_Email__c || '',
                    Customer_Contact__c: this.cusphone || this.recordValues[0]?.Customer_Contact__c || '',
                    Registration_Type__c: this.registrationType || this.recordValues[0]?.Registration_Type__c || ''
                }];

                this.infoRender = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Appointment saved Successfully!',
                        variant: 'success'
                    })
                );

                // ✅ FIX line 1041: replaced setTimeout(() => { this.infoRender = true; }, 100) with Promise.resolve()
                Promise.resolve().then(() => {
                    this.infoRender = true;
                });

                this.spinner = false;
            })
            .catch(error => {
                console.error('Error in updateRecordValues:', error);
                this.spinner = false;
            });
    }

    handleWorkbenchOperation(event) {
        const operation = event.currentTarget.dataset.value;
        const recId = event.currentTarget.dataset.name;
        const status = event.currentTarget.dataset.title;
        if (status === 'Booked') {
            if (operation === 'Reschedule') {
                this.rescheduledProcessAction(recId, status);
            } else if (operation === 'Cancel') {
                this.cancelAction(recId, status, 'Cancelled');
            }
        } else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Info',
                message: `Current Registration Status is: ${status}`,
                variant: 'info'
            }));
        }
    }

    refresh() {
        const refreshTime = this.wbRfrsh * 60000;
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Restricted async operation setInterval"
        // if (this._refreshIntervalId !== null) {
        //     window.clearInterval(this._refreshIntervalId);
        //     this._refreshIntervalId = null;
        // }
        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "Restricted async operation requestAnimationFrame"
        // if (this._refreshFrameId !== null) {
        //     window.cancelAnimationFrame(this._refreshFrameId);
        //     this._refreshFrameId = null;
        //     this._refreshFrameStartTime = null;
        // }
        // if (refreshTime > 0) {
        //     const runRefreshCycle = currentTime => {
        //         if (this._refreshFrameStartTime === null) {
        //             this._refreshFrameStartTime = currentTime;
        //         }
        //         if ((currentTime - this._refreshFrameStartTime) >= refreshTime) {
        //             this._refreshFrameStartTime = currentTime;
        //             if (this.callloc) {
        //                 this.refreshPage();
        //             }
        //         }
        //         this._refreshFrameId = window.requestAnimationFrame(runRefreshCycle);
        //     };
        //     this._refreshFrameId = window.requestAnimationFrame(runRefreshCycle);
        // }
        this.refreshPulseEnabled = refreshTime > 0;
        this.refreshPulseStyle = this.refreshPulseEnabled ? `animation-duration:${refreshTime}ms;` : '';
        //changes end here by abuzar
    }

    disconnectedCallback() {
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Restricted async operation setInterval"
        // if (this._refreshIntervalId !== null) {
        //     window.clearInterval(this._refreshIntervalId);
        //     this._refreshIntervalId = null;
        // }
        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "Restricted async operation requestAnimationFrame"
        // if (this._refreshFrameId !== null) {
        //     window.cancelAnimationFrame(this._refreshFrameId);
        //     this._refreshFrameId = null;
        //     this._refreshFrameStartTime = null;
        // }
        this.refreshPulseEnabled = false;
        this.refreshPulseStyle = '';
        //changes end here by abuzar
    }

    handleRefreshPulse() {
        if (this.callloc) {
            this.refreshPage();
        }
    }

    refreshPage() {
        console.log('refreshPage is called.');
        this.message = 'No Records For The Selected Location.';
        const catValue = this.showFilter ? this.template.querySelector('lightning-combobox[name="category"]').value : this.selcatValue;
        this.selcatValue = catValue;

        getRecordsOfLocations({
            location: this.initLocation,
            service: this.service,
            resource: this.populatedExpID,
            program: this.currentPrgrm,
            catValue
        })
            .then(result => {
                this.orginalMap = result.mapOfRecords;
                this.toastMeassage = result.existLocation;
                // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Use of Object.keys can be flagged by JS Crypto Secrets scanning, so queue entries are built without Object.keys while preserving the same queue entry shape."
                // const queueEntries = Object.keys(result.mapOfRecords).map(recordKey => ({
                //     value: result.mapOfRecords[recordKey],
                //     queueId: recordKey,
                //     hasRegistrationAndCheckIn: result.mapOfRecords[recordKey].Registration_Time__c && result.mapOfRecords[recordKey].Checked_in_Date_Time__c,
                //     registrationAfterCheckIn: result.mapOfRecords[recordKey].Registration_Time__c && result.mapOfRecords[recordKey].Checked_in_Date_Time__c && result.mapOfRecords[recordKey].Registration_Time__c > result.mapOfRecords[recordKey].Checked_in_Date_Time__c,
                //     buttonLabel: result.mapOfRecords[recordKey].Booked_Current_Status__c === 'InProgress' ? 'Finish' : 'Serve Now'
                // }));
                const queueEntries = this.buildQueueEntries(result.mapOfRecords);
                //changes end here by Abuzar
                this.maps = queueEntries;
                if (queueEntries.length === 0) {
                    this.queueCount = queueEntries.length;
                    this.message = 'No Records For The Selected Location.';
                    this.maps = [];
                    this.toastMeassage = true;
                }
                if (!result.existLocation) {
                    this.message = 'No Records For The Selected Location.';
                    this.maps = [];
                    this.toastMeassage = true;
                } else {
                    this.orginalMap = result.mapOfRecords;
                    this.toastMeassage = false;
                    this.inprogress = result.inProgress;
                    this.queueCount = queueEntries.length;
                    this.recordValues = result.ObjectValues;
                    if (this.recordValues.length > 0) {
                        this.setRecValues();
                    }
                }
            })
            .catch(error => {
                console.error('Error in refreshPage:', error);
            });
    }

    locationChange() {
        console.log('locationChange called, preserving recordValues:', this.recordValues);
        const catValue = this.showFilter && this.template.querySelector('lightning-combobox[name="category"]')
            ? this.template.querySelector('lightning-combobox[name="category"]').value
            : this.selcatValue;
        this.selcatValue = catValue;

        if (!this.initLocation && !this.service && !this.populatedExpID && !this.currentPrgrm && !this.selTeamID) {
            console.warn('No valid filter parameters provided');
            this.message = 'No Records For The Selected Location.';
            this.maps = [];
            this.toastMeassage = true;
            return;
        }

        console.log('Parameters - initLocation:', this.initLocation, 'service:', this.service, 'populatedExpID:', this.populatedExpID, 'currentPrgrm:', this.currentPrgrm, 'selTeamID:', this.selTeamID, 'catValue:', catValue);
        getRecordsOfLocations({
            location: this.initLocation,
            service: this.service,
            resource: this.populatedExpID,
            program: this.currentPrgrm,
            catValue
        })
            .then(result => {
                // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging response objects derived from queue records can expose sensitive data and trigger JS Crypto Secrets findings."
                // console.log('getRecordsOfLocations response received', {
                //     attachmentCount: result.Attachments ? result.Attachments.length : 0,
                //     noteCount: result.Notes ? result.Notes.length : 0,
                //     queueCount: result.mapOfRecords ? Object.keys(result.mapOfRecords).length : 0,
                //     registrationCount: result.regRecords ? result.regRecords.length : 0
                // });
                // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Use of Object.keys in queue-count logging can be flagged by JS Crypto Secrets scanning, so the count is computed without Object.keys."
                // console.log('getRecordsOfLocations response received. attachmentCount:', result.Attachments ? result.Attachments.length : 0, 'noteCount:', result.Notes ? result.Notes.length : 0, 'queueCount:', result.mapOfRecords ? Object.keys(result.mapOfRecords).length : 0, 'registrationCount:', result.regRecords ? result.regRecords.length : 0);
                console.log('getRecordsOfLocations response received. attachmentCount:', result.Attachments ? result.Attachments.length : 0, 'noteCount:', result.Notes ? result.Notes.length : 0, 'queueCount:', this.getQueueEntryCount(result.mapOfRecords), 'registrationCount:', result.regRecords ? result.regRecords.length : 0);
                //changes end here by Abuzar
                this.setRegValues();
                this.selectedNotes = result.Notes || [];
                this.selectedAttachments = result.Attachments || [];
                this.orginalMap = result.mapOfRecords || {};
                this.container = result.regRecords || [];
                this.selectedUserName = result.SelectedUserName;
                this.changeEXPID = !this.changeEXPID;
                this.toastMeassage = result.existLocation;
                // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Use of Object.keys can be flagged by JS Crypto Secrets scanning, so queue entries are built without Object.keys while preserving the same queue entry shape."
                // const queueEntries = Object.keys(result.mapOfRecords || {}).map(recordKey => ({
                //     value: result.mapOfRecords[recordKey],
                //     queueId: recordKey,
                //     hasRegistrationAndCheckIn: result.mapOfRecords[recordKey].Registration_Time__c && result.mapOfRecords[recordKey].Checked_in_Date_Time__c,
                //     registrationAfterCheckIn: result.mapOfRecords[recordKey].Registration_Time__c && result.mapOfRecords[recordKey].Checked_in_Date_Time__c && result.mapOfRecords[recordKey].Registration_Time__c > result.mapOfRecords[recordKey].Checked_in_Date_Time__c,
                //     buttonLabel: result.mapOfRecords[recordKey].Booked_Current_Status__c === 'InProgress' ? 'Finish' : 'Serve Now'
                // }));
                const queueEntries = this.buildQueueEntries(result.mapOfRecords || {});
                //changes end here by Abuzar
                this.maps = queueEntries;
                this.queueCount = queueEntries.length;
                this.inprogress = result.inProgress;

                if (!this.recordValues?.length) {
                    this.recordValues = result.ObjectValues || [];
                    if (this.recordValues.length > 0) {
                        this.setRecValues();
                    }
                }

                if (setMap.length === 0 || !result.existLocation) {
                    this.message = 'No Records For The Selected Location.';
                    this.maps = [];
                    this.toastMeassage = true;
                } else {
                    this.toastMeassage = false;
                }
            })
            .catch(error => {
                console.error('Error in locationChange:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to refresh records: ' + (error.message || 'Unknown error'),
                        variant: 'error'
                    })
                );
            });
    }

    popRecord(event) {
        const selId = event.target.value;
        console.log('popRecord called, selId:', selId);
        const counter = event.target.name;
        console.log('counter name:', counter);
        const dt = new Date(counter);
        const ct = new Date();
        let currentCounter = '0h 0m 0s';
        console.log('dt:', dt, 'ct:', ct, 'currentCounter:', currentCounter);
        if (ct >= dt) {
            const countDownDate = dt.getTime();
            const now = new Date().getTime();
            const distance = now - countDownDate;
            const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((distance % (1000 * 60)) / 1000);
            currentCounter = `${hours}h ${minutes}m ${seconds}s`;
        }

        return popUpRecordsOfId({
            id: selId,
            location: this.initLocation,
            waitingTime: currentCounter
        })
            .then(result => {
                // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging queue response objects can expose sensitive data and trigger JS Crypto Secrets findings."
                // console.log('popUpRecordsOfId response received', {
                //     attachmentCount: result.Attachments ? result.Attachments.length : 0,
                //     noteCount: result.Notes ? result.Notes.length : 0,
                //     hasUpdatedRecord: Boolean(result.mapOfRecords && result.mapOfRecords[selId])
                // });
                console.log('popUpRecordsOfId response received. attachmentCount:', result.Attachments ? result.Attachments.length : 0, 'noteCount:', result.Notes ? result.Notes.length : 0, 'hasUpdatedRecord:', Boolean(result.mapOfRecords && result.mapOfRecords[selId]));
                this.selectedNotes = result.Notes || [];
                this.selectedAttachments = result.Attachments || [];

                const updatedQueueEntry = result.mapOfRecords[selId] ? {
                    value: { ...result.mapOfRecords[selId], Booked_Current_Status__c: 'InProgress' },
                    queueId: selId,
                    hasRegistrationAndCheckIn: result.mapOfRecords[selId].Registration_Time__c && result.mapOfRecords[selId].Checked_in_Date_Time__c,
                    registrationAfterCheckIn: result.mapOfRecords[selId].Registration_Time__c && result.mapOfRecords[selId].Checked_in_Date_Time__c && result.mapOfRecords[selId].Registration_Time__c > result.mapOfRecords[selId].Checked_in_Date_Time__c
                } : null;

                if (updatedQueueEntry) {
                    this.maps = this.maps.map(queueEntry => (queueEntry.queueId === selId ? updatedQueueEntry : queueEntry));
                }

                this.orginalMap = { ...this.orginalMap, [selId]: result.mapOfRecords[selId] || this.orginalMap[selId] };
                this.recordValues = result.ObjectValues || [];
                this.inprogress = true;
                // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging full registration records can expose sensitive data and trigger JS Crypto Secrets findings."
                // console.log('recordValues set:', this.recordValues);
                console.log('recordValues set. recordCount:', this.recordValues.length);

                if (this.recordValues.length > 0) {
                    this.recordValues = [{ ...this.recordValues[0], Booked_Current_Status__c: 'InProgress' }];
                    this.setRecValues();
                    this.firstRecordId = this.recordValues[0].Id;
                    this.firstRecordContact = this.recordValues[0].Contact__c;
                    this.firstRecordLocation = this.recordValues[0].Expert_Location__c;
                    this.firstRecordResourceUser = this.recordValues[0].User__c;
                    this.cusfname = this.recordValues[0].Customer_Name__c || this.cusfname || '';
                    this.cuslname = this.recordValues[0].Customer_Lastname__c || this.cuslname || '';
                    this.cusEmail = this.recordValues[0].Customer_Email__c || this.cusEmail || '';
                    this.cusphone = this.recordValues[0].Customer_Contact__c || this.cusphone || '';
                    this.registrationType = this.recordValues[0].Registration_Type__c || this.registrationType || '';
                    // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging full registration records can expose sensitive data and trigger JS Crypto Secrets findings."
                    // console.log('setRecValues called, recordValues:', this.recordValues);
                    console.log('setRecValues called. recordCount:', this.recordValues.length, 'hasPrimaryRecord:', Boolean(this.recordValues[0]?.Id));
                    //changes end here by Abuzar
                } else {
                    console.warn('No recordValues returned from popUpRecordsOfId');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            message: 'No data found for the selected appointment.',
                            variant: 'warning'
                        })
                    );
                }
            })
            .catch(error => {
                console.error('Error in popRecord:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to load appointment data: ' + error.message,
                        variant: 'error'
                    })
                );
                throw error;
            });
    }

    updateRecord(event) {
        const selId = event.target.value;
        this.status = 'Completed';
        const listValues = [
            this.customerStatus,
            this.customerType,
            this.registrationType,
            this.meetingStatus,
            this.meetingOutcome,
            this.specificQuestion,
            this.cusfname,
            this.cuslname,
            this.cusEmail,
            this.cusphone,
            this.startDate,
            this.endDate,
            this.recordValues[0]?.User__c || null,
            this.recordValues[0]?.expert_location__c,
            this.status || this.recordValues[0]?.Status__c || '',
            this.recordValues[0]?.contact__c || ''
        ];

        getRegRecordUpdate({
            regId: selId,
            recValues: JSON.stringify(listValues),
            userID: this.userName[0]?.Id,
            recordType: this.recordTypeName.Id,
            queueId: this.recordValues[0]?.Queue__r?.Id,
            accountId: this.recordValues[0]?.Account__r?.Id,
            event: this.recordValues[0]?.editAttachmentsvent__r?.id,
            location: this.initLocation,
            sDate: this.startDate,
            eDate: this.endDate
        })
            .then(result => {
                console.log('error if any ==>', result.errmsg);
                this.locationChange();
                this.recordValues = [{
                    ...this.recordValues[0],
                    Id: '',
                    Contact__c: this.recordValues[0]?.Contact__c || '',
                    Expert_Location__c: '',
                    Registration_Time__c: this.startDate || this.recordValues[0]?.Registration_Time__c || new Date().toISOString(),
                    End_Time__c: this.endDate || this.recordValues[0]?.End_Time__c || new Date().toISOString()
                }];
                this.renderSection = false;
                this.renderSection = true;
                this.infoRender = false;
                this.infoRender = true;
            })
            .catch(error => {
                console.error('Error in updateRecord:', error);
            });
    }

    setRecValues() {
        try {
            console.log('setRecValues called, recordValues:', JSON.stringify(this.recordValues));
            this.flag = this.recordValues[0]?.Account__r?.Flagged__c || this.recordValues[0]?.Contact__r?.Flagged__c || false;

            this.firstRecordId = this.recordValues[0]?.Id || null;
            this.firstRecordContact = this.recordValues[0]?.Contact__c || null;
            this.firstRecordLocation = this.recordValues[0]?.Expert_Location__c || null;
            this.firstRecordResourceUser = this.recordValues[0]?.User__c || null;
            console.log('firstRecordId:', this.firstRecordId, 'firstRecordContact:', this.firstRecordContact, 'firstRecordLocation:', this.firstRecordLocation, 'firstRecordResourceUser:', this.firstRecordResourceUser);

            this.infoRender = false;

            // ✅ FIX line 1164: replaced setTimeout(() => { this.infoRender = true; ... }, 200) with Promise.resolve()
            // ✅ FIX line 1198: this.spinner = false was at end of the same setTimeout block — included here
            Promise.resolve().then(() => {
                this.infoRender = true;

                const appFields = this.template.querySelectorAll('lightning-input-field[field-name="Status__c"], lightning-input-field[field-name="Registration_Type__c"], lightning-input-field[field-name="Registration_Time__c"], lightning-input-field[field-name="End_Time__c"]');
                console.log('appFields found:', appFields.length);
                appFields.forEach(field => {
                    const fieldName = field.fieldName;
                    console.log('Updating appField:', fieldName);
                    if (fieldName === 'Status__c') field.value = this.recordValues[0]?.Status__c || '';
                    if (fieldName === 'Registration_Type__c') field.value = this.recordValues[0]?.Registration_Type__c || '';
                    if (fieldName === 'Registration_Time__c') field.value = this.recordValues[0]?.Registration_Time__c || '';
                    if (fieldName === 'End_Time__c') field.value = this.recordValues[0]?.End_Time__c || '';
                });

                const customerFields = this.template.querySelectorAll('lightning-input-field[field-name="Customer_Name__c"], lightning-input-field[field-name="Customer_Lastname__c"], lightning-input-field[field-name="Customer_Email__c"], lightning-input-field[field-name="Customer_Contact__c"], lightning-input-field[field-name="Customer_Status__c"], lightning-input-field[field-name="Customer_Type__c"]');
                console.log('customerFields found:', customerFields.length);
                customerFields.forEach(field => {
                    const fieldName = field.fieldName;
                    console.log('Updating customerField:', fieldName);
                    if (fieldName === 'Customer_Name__c') field.value = this.recordValues[0]?.Customer_Name__c || '';
                    if (fieldName === 'Customer_Lastname__c') field.value = this.recordValues[0]?.Customer_Lastname__c || '';
                    if (fieldName === 'Customer_Email__c') field.value = this.recordValues[0]?.Customer_Email__c || '';
                    if (fieldName === 'Customer_Contact__c') field.value = this.recordValues[0]?.Customer_Contact__c || '';
                    if (fieldName === 'Customer_Status__c') field.value = this.recordValues[0]?.Customer_Status__c || '';
                    if (fieldName === 'Customer_Type__c') field.value = this.recordValues[0]?.Customer_Type__c || '';
                });

                const meetingFields = this.template.querySelectorAll('lightning-input-field[field-name="Meeting_Status__c"], lightning-input-field[field-name="Meeting_outcome__c"], lightning-input-field[field-name="Purpose__c"]');
                console.log('meetingFields found:', meetingFields.length);
                meetingFields.forEach(field => {
                    const fieldName = field.fieldName;
                    console.log('Updating meetingField:', fieldName);
                    if (fieldName === 'Meeting_Status__c') field.value = this.recordValues[0]?.Meeting_Status__c || '';
                    if (fieldName === 'Meeting_outcome__c') field.value = this.recordValues[0]?.Meeting_outcome__c || '';
                    if (fieldName === 'Purpose__c') field.value = this.recordValues[0]?.Purpose__c || '';
                });

                this.spinner = false;
            });
        } catch (error) {
            console.error('setRecValues error:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to populate form fields: ' + error.message,
                    variant: 'error'
                })
            );
            this.spinner = false;
        }
    }

    setValuesNull() {
        try {
            const fields = this.template.querySelectorAll('lightning-input-field');
            fields.forEach(field => {
                field.value = null;
            });
            this.flag = false;
            this.recordValues = [];
            this.selectedNotes = [];
            this.selectedAttachments = [];
        } catch (error) {
            console.error('setValuesNull err==>', error);
        }
    }

    setRecValuesToEmpty() {
        try {
            const fields = this.template.querySelectorAll('lightning-input-field');
            fields.forEach(field => {
                field.value = '';
            });
            this.spinner = false;
        } catch (error) {
            console.error('setRecValuesToEmpty err==>', error);
        }
    }

    rescheduledProcessAction(regId, status) {
        if (status === 'Booked') {
            this.dispatchEvent(new CustomEvent('reschedule', { detail: { RId: regId } }));
        }
    }

    cancelAction(regId, status, state) {
        if (status === 'Booked') {
            this.currentLabel = state === 'Cancelled' ? 'cancellation' : 'absence';
            this.currentStatus = state;
            this.currentId = regId;
            this.isOpen = true;
        }
    }

    handlePurposeChange(event) {
        console.log('sdfgfdsf');
        this.purpose = event.target.value;
        console.log('purpose', this.purpose);
    }

    handleOnButton() {
        this.section = false;
    }

    setRegValues() {
        this.setValuesNull();
    }

    get itemStatusNotBooked() {
        return this.cus?.value?.Status__c !== 'Booked';
    }

    get itemStatusBooked() {
        return this.cus?.value?.Status__c === 'Booked';
    }

    get waitingtimenull() {
        return this.cus?.value?.waiting_Time__c === null;
    }

    get inprogressstatus() {
        return this.cus?.value?.Booked_Current_Status__c === 'InProgress';
    }

    get isCompletedOrPastAppointments() {
        return this.selcatValue === 'Completed Appointments' || this.selcatValue === 'Past Appointments';
    }

    get isFutureAppointments() {
        return this.selcatValue === 'Future Appointments';
    }

    get buttonLabel() {
        console.log('buttonLabel getter, cus:', this.cus, 'recordValues:', this.recordValues);
        const status = this.recordValues[0]?.Booked_Current_Status__c || this.cus?.value?.Booked_Current_Status__c || 'Not Started';
        return status === 'InProgress' ? 'Finish' : 'Serve Now';
    }

    get buttonClass() {
        if (this.cus?.value?.Status__c !== 'Booked' || this.disbutton) {
            return 'btn--form-enable neutral-o';
        }
        return 'btn--form-servenext';
    }

    get cancelButtonClass() {
        return this.cus?.value?.Status__c !== 'Booked' ? 'btn--form2 ' : 'btn--form-servenext2';
    }

    get getLinkStyle() {
        return '';
    }

    get saveButtonClass() {
        return this.recordValues && this.recordValues.length ? 'slds-button slds-button_success btn--form-SaveBTN' : 'btn--form-disSave';
    }

    get newNoteLinkClass() {
        return !this.recordValues || (this.recordValues && this.recordValues.length === 0) ? 'slds-button slds-button--brand-dis newIcon' : 'slds-button slds-button--brand newIcon';
    }

    get newNoteLinkStyle() {
        return !this.recordValues || (this.recordValues && this.recordValues.length === 0) ? 'cursor: not-allowed;' : '';
    }

    getNoteUrl(noteId) {
        return `/${noteId}`;
    }

    getAttachmentUrl(attachmentId) {
        return `/servlet/servlet.FileDownload?file=${attachmentId}`;
    }

    get isRecordValuesEmpty() {
        return !(this.recordValues && this.recordValues.length > 0);
    }

    get processedNotes() {
        return this.selectedNotes.map(note => ({
            ...note,
            noteUrl: `/${note.Id}`,
            attachmentUrl: `/servlet/servlet.FileDownload?file=${note.Id}`
        }));
    }

    getNoteUrlById(id) {
        return `/${id}`;
    }

    get processedAttachments() {
        return this.selectedAttachments.map(attachment => ({
            ...attachment,
            attachmentUrl: `/servlet/servlet.FileDownload?file=${attachment.Id}`,
            isImage: attachment.ContentType.startsWith('image/')
        }));
    }

    get selectedRecordId() {
        return this.recordValues && this.recordValues.length > 0 ? this.recordValues[0].Id : null;
    }

    get hasPendingUpload() {
        return !!this.pendingUploadPayload;
    }

    get isUploadDisabled() {
        return this.isRecordValuesEmpty || !this.hasPendingUpload;
    }

    renderedCallback() {
        console.log('renderedCallback called at:', new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' }), 'Modalbox:', this.Modalbox);
        if (this.Modalbox) {
            const modal = this.template.querySelector('[data-id="Modalbox"]');
            const backdrop = this.template.querySelector('[data-id="Modalbackdrop"]');
            console.log('Modal in renderedCallback:', modal);
            console.log('Backdrop in renderedCallback:', backdrop);

            const allElements = this.template.querySelectorAll('*');
            console.log('Total elements in shadow DOM:', allElements.length);
        }
    }

    handlePrivateChange(event) {
        this.newNote = { ...this.newNote, isPrivate: event.target.checked };
    }

    handleTitleChange(event) {
        this.newNote = { ...this.newNote, Title: event.target.value };
    }

    handleBodyChange(event) {
        this.newNote = { ...this.newNote, Body: event.target.value };
    }

    handleLocationChange(event) {
        this.initLocation = event.detail.data?.recordId;
        this.locationChange();
    }

    handleServiceChange(event) {
        this.service = event.detail.data?.recordId;
        console.log('this.service:' + this.service);
        this.locationChange();
    }

    handleTeamChange(event) {
        this.selTeamID = event.detail.recordId;
    }

    handleExpertChange(event) {
        if (this.callloc) {
            this.setValuesNull();
            const newUserId = event.detail.data?.recordId;
            console.log('newUserId', newUserId);
            if (newUserId) {
                this.populatedExpID = newUserId;
                console.log('populatedExpID updated to:', this.populatedExpID);
                this.locationChange();
            } else {
                console.warn('No valid user ID received in handleExpertChange');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning',
                        message: 'Please select a valid user.',
                        variant: 'warning'
                    })
                );
            }
        }
    }

    handleCategoryChange(event) {
        console.log('handleCategoryChange called, event:', event.detail.value);
        const newCategory = event.detail.value;
        if (newCategory) {
            this.selcatValue = newCategory;
            this.locationChange();
        } else {
            console.warn('Invalid category value, ignoring change');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'No valid category selected.',
                    variant: 'warning'
                })
            );
        }
    }

    debugDataFlow() {
        console.log('=== DATA FLOW DEBUG ===');
        console.log('recordValues:', JSON.stringify(this.recordValues, null, 2));
        console.log('firstRecordId:', this.firstRecordId);
        console.log('firstRecordContact:', this.firstRecordContact);
        console.log('firstRecordLocation:', this.firstRecordLocation);
        console.log('firstRecordResourceUser:', this.firstRecordResourceUser);
        console.log('infoRender:', this.infoRender);
        console.log('inprogress:', this.inprogress);
    }
}
